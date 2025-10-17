//
//  RoutineService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Routine Service Protocol

protocol RoutineServiceProtocol {
    // Read Stream - Central Source of Truth
    var routinesStream: AnyPublisher<RoutineServiceState, Never> { get }
    var completionChangesStream: AnyPublisher<Date, Never> { get }

    // Write Operations (Stateless)
    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        routineDepth: RoutineDepth?,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers?
    ) async throws -> RoutineResponse

    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel
    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel
    func removeRoutine(_ routine: SavedRoutineModel) async throws
    func removeRoutineTemplate(_ template: RoutineTemplate) async throws
    func setActiveRoutine(_ routine: SavedRoutineModel) async throws
    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool

    // Tracking Operations
    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date) async throws
    func isStepCompleted(stepId: String, date: Date) async throws -> Bool
    func getCompletedSteps(for date: Date) async throws -> Set<String>
    func getCurrentStreak() async throws -> Int
    func clearAllCompletions() async throws
    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats]

    // Convenience Operations
    func generateAndSaveInitialRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        routineDepth: RoutineDepth?,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers?
    ) async throws -> SavedRoutineModel

    // State Management
    func refreshData() async throws

    // Adaptation Operations
    func toggleAdaptation(
        for routine: SavedRoutineModel,
        enabled: Bool,
        type: AdaptationType?
    ) async throws

    func getAdaptedSnapshot(
        _ routine: SavedRoutineModel,
        for date: Date
    ) async throws -> RoutineSnapshot?
}

// MARK: - Routine Service State

struct RoutineServiceState: Equatable {
    let savedRoutines: [SavedRoutineModel]
    let activeRoutine: SavedRoutineModel?
    let lastUpdated: Date

    static func == (lhs: RoutineServiceState, rhs: RoutineServiceState) -> Bool {
        return lhs.savedRoutines == rhs.savedRoutines &&
               lhs.activeRoutine == rhs.activeRoutine &&
               lhs.lastUpdated == rhs.lastUpdated
    }

    static let initial = RoutineServiceState(
        savedRoutines: [],
        activeRoutine: nil,
        lastUpdated: Date()
    )
}

// MARK: - Routine Service Implementation

final class RoutineService: RoutineServiceProtocol {
    // MARK: - Central Read Stream
    private let stateSubject = CurrentValueSubject<RoutineServiceState, Never>(.initial)
    private let completionChangeSubject = PassthroughSubject<Date, Never>()

    var routinesStream: AnyPublisher<RoutineServiceState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var completionChangesStream: AnyPublisher<Date, Never> {
        completionChangeSubject.eraseToAnyPublisher()
    }

    // Current state accessor
    var currentState: RoutineServiceState {
        stateSubject.value
    }

    // MARK: - Dependencies
    private let gptService: GPTService
    private let store: RoutineStoreProtocol

    // MARK: - Initialization

    init(
        gptService: GPTService,
        store: RoutineStoreProtocol
    ) {
        self.gptService = gptService
        self.store = store
        print("🔧 RoutineService initialized")

        // Load initial data
        Task {
            try? await refreshData()
        }
    }

    // MARK: - Generation Operations

    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        routineDepth: RoutineDepth? = nil,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) async throws -> RoutineResponse {
        print("🤖 Generating routine with GPT")

        // Get user's current language
        let userLanguage = LocalizationManager.shared.currentLanguage
        print("🌍 User language: \(userLanguage)")

        // Create the request using the convenience method
        // GPT always processes in English for stability
        let request = GPTService.createRequest(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            routineDepth: routineDepth,
            preferences: preferences,
            lifestyle: lifestyle
        )

        // Step 1: Generate routine in English (stable internal processing)
        print("📝 Generating routine in English...")
        var response = try await gptService.generateRoutine(for: request)

        // Step 2: If user language is not English, translate the response
        if userLanguage != "en" {
            print("🔄 Translating routine to \(userLanguage)...")
            response = try await translateRoutineResponse(response, to: userLanguage)
            print("✅ Routine translated successfully")
        }

        return response
    }

    /// Translate a routine response to user's language
    private func translateRoutineResponse(_ response: RoutineResponse, to targetLanguage: String) async throws -> RoutineResponse {
        let languageService = LanguageService.shared

        // Translate summary title and one-liner
        let translatedSummary = Summary(
            title: try await languageService.translateFromEnglish(response.summary.title, to: targetLanguage),
            oneLiner: try await languageService.translateFromEnglish(response.summary.oneLiner, to: targetLanguage)
        )

        // Translate morning steps
        let translatedMorningSteps = try await withThrowingTaskGroup(of: (Int, APIRoutineStep).self) { group in
            for (index, step) in response.routine.morning.enumerated() {
                group.addTask {
                    let translatedName = try await languageService.translateFromEnglish(step.name, to: targetLanguage)
                    let translatedWhy = try await languageService.translateFromEnglish(step.why, to: targetLanguage)
                    let translatedHow = try await languageService.translateFromEnglish(step.how, to: targetLanguage)

                    let translatedStep = APIRoutineStep(
                        step: step.step, // Keep product type in English
                        name: translatedName,
                        why: translatedWhy,
                        how: translatedHow,
                        constraints: step.constraints
                    )

                    return (index, translatedStep)
                }
            }

            var results: [(Int, APIRoutineStep)] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }

        // Translate evening steps
        let translatedEveningSteps = try await withThrowingTaskGroup(of: (Int, APIRoutineStep).self) { group in
            for (index, step) in response.routine.evening.enumerated() {
                group.addTask {
                    let translatedName = try await languageService.translateFromEnglish(step.name, to: targetLanguage)
                    let translatedWhy = try await languageService.translateFromEnglish(step.why, to: targetLanguage)
                    let translatedHow = try await languageService.translateFromEnglish(step.how, to: targetLanguage)

                    let translatedStep = APIRoutineStep(
                        step: step.step, // Keep product type in English
                        name: translatedName,
                        why: translatedWhy,
                        how: translatedHow,
                        constraints: step.constraints
                    )

                    return (index, translatedStep)
                }
            }

            var results: [(Int, APIRoutineStep)] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }

        // Translate weekly steps if they exist
        let translatedWeeklySteps: [APIRoutineStep]?
        if let weeklySteps = response.routine.weekly {
            let translated = try await withThrowingTaskGroup(of: (Int, APIRoutineStep).self) { group in
                for (index, step) in weeklySteps.enumerated() {
                    group.addTask {
                        let translatedName = try await languageService.translateFromEnglish(step.name, to: targetLanguage)
                        let translatedWhy = try await languageService.translateFromEnglish(step.why, to: targetLanguage)
                        let translatedHow = try await languageService.translateFromEnglish(step.how, to: targetLanguage)

                        let translatedStep = APIRoutineStep(
                            step: step.step, // Keep product type in English
                            name: translatedName,
                            why: translatedWhy,
                            how: translatedHow,
                            constraints: step.constraints
                        )

                        return (index, translatedStep)
                    }
                }

                var results: [(Int, APIRoutineStep)] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted { $0.0 < $1.0 }.map { $0.1 }
            }
            translatedWeeklySteps = translated
        } else {
            translatedWeeklySteps = nil
        }

        // Translate guardrails
        let translatedCautions = try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, caution) in response.guardrails.cautions.enumerated() {
                group.addTask {
                    let translated = try await languageService.translateFromEnglish(caution, to: targetLanguage)
                    return (index, translated)
                }
            }

            var results: [(Int, String)] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }

        let translatedWhenToStop = try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, stop) in response.guardrails.whenToStop.enumerated() {
                group.addTask {
                    let translated = try await languageService.translateFromEnglish(stop, to: targetLanguage)
                    return (index, translated)
                }
            }

            var results: [(Int, String)] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }

        let translatedGuardrails = Guardrails(
            cautions: translatedCautions,
            whenToStop: translatedWhenToStop,
            sunNotes: try await languageService.translateFromEnglish(response.guardrails.sunNotes, to: targetLanguage)
        )

        // Create translated routine
        let translatedRoutine = Routine(
            depth: response.routine.depth,
            morning: translatedMorningSteps,
            evening: translatedEveningSteps,
            weekly: translatedWeeklySteps
        )

        // Return translated response
        return RoutineResponse(
            version: response.version,
            locale: targetLanguage, // Update locale to target language
            summary: translatedSummary,
            routine: translatedRoutine,
            guardrails: translatedGuardrails,
            adaptation: response.adaptation, // Keep adaptation in English for internal processing
            productSlots: response.productSlots // Keep product slots in English for matching
        )
    }

    // MARK: - Write Operations (Stateless)

    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel {
        print("💾 Saving routine: \(template.title)")

        // Generate translations for both English and device locale
        let translations = try await createTemplateTranslations(from: template)

        // Create SavedRoutineModel with translations
        let savedRoutine = try await store.saveRoutine(
            SavedRoutineModel(
                from: template,
                stepTranslations: translations.steps,
                routineTranslations: translations.routine
            )
        )

        // Emit updated state
        try await emitUpdatedState()

        return savedRoutine
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        print("💾 Saving initial routine from response")

        // CRITICAL: Always save routines in English to database for consistency
        // This ensures language switching works properly
        let englishResponse: RoutineResponse
        if routineResponse.locale != "en" {
            print("🔄 Converting routine back to English for database storage...")
            englishResponse = try await translateRoutineResponse(routineResponse, to: "en")
        } else {
            englishResponse = routineResponse
        }

        // Generate translations for both English and device locale
        let translations = try await createRoutineTranslations(from: englishResponse)

        let savedRoutine = try await store.saveInitialRoutine(from: englishResponse, translations: translations)

        // Emit updated state
        try await emitUpdatedState()

        return savedRoutine
    }

    /// Create translation objects for a routine response, including both English and device locale
    private func createRoutineTranslations(from response: RoutineResponse) async throws -> (routine: RoutineTranslations, steps: [StepTranslations]) {
        let deviceLanguage = LocalizationUtils.deviceLocaleLanguage()

        // Start with English versions (from the response)
        var routineTitleTranslations: [String: String] = ["en": response.summary.title]
        var routineDescTranslations: [String: String] = ["en": response.summary.oneLiner]

        // Benefits and tags - we'll use hardcoded values for "My Routine"
        let benefitsEn = ["Personalized for your skin", "Based on your preferences", "Easy to follow"]
        let tagsEn = ["Personalized", "Onboarding", "Custom"]
        var benefitsTranslations: [String: [String]] = ["en": benefitsEn]
        var tagsTranslations: [String: [String]] = ["en": tagsEn]

        // Create step translations
        var allStepTranslations: [StepTranslations] = []

        // If device language is not English, translate
        if deviceLanguage != "en" {
            print("🌍 Creating translations for device language: \(deviceLanguage)")
            let languageService = LanguageService.shared

            do {
                // Translate routine-level content
                routineTitleTranslations[deviceLanguage] = try await languageService.translateFromEnglish(response.summary.title, to: deviceLanguage)
                routineDescTranslations[deviceLanguage] = try await languageService.translateFromEnglish(response.summary.oneLiner, to: deviceLanguage)
            } catch {
                print("⚠️ Failed to translate routine title/description: \(error), using English only")
            }

            // Translate benefits
            do {
                let translatedBenefits = try await languageService.translateArray(benefitsEn, from: "en", to: deviceLanguage)
                benefitsTranslations[deviceLanguage] = translatedBenefits
            } catch {
                print("⚠️ Failed to translate benefits: \(error), using English only")
            }

            // Translate tags
            do {
                let translatedTags = try await languageService.translateArray(tagsEn, from: "en", to: deviceLanguage)
                tagsTranslations[deviceLanguage] = translatedTags
            } catch {
                print("⚠️ Failed to translate tags: \(error), using English only")
            }

            // Translate morning steps (with individual error handling)
            for step in response.routine.morning {
                var stepTitleTrans: [String: String] = ["en": step.name]
                var stepDescTrans: [String: String] = ["en": "\(step.why) - \(step.how)"]
                var stepWhyTrans: [String: String] = ["en": step.why]
                var stepHowTrans: [String: String] = ["en": step.how]

                do {
                    stepTitleTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.name, to: deviceLanguage)
                    stepDescTrans[deviceLanguage] = try await languageService.translateFromEnglish("\(step.why) - \(step.how)", to: deviceLanguage)
                    stepWhyTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepHowTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage)
                } catch {
                    print("⚠️ Failed to translate morning step '\(step.name)': \(error), using English only")
                }

                allStepTranslations.append(StepTranslations(
                    title: stepTitleTrans,
                    stepDescription: stepDescTrans,
                    why: stepWhyTrans,
                    how: stepHowTrans
                ))
            }

            // Translate evening steps (with individual error handling)
            for step in response.routine.evening {
                var stepTitleTrans: [String: String] = ["en": step.name]
                var stepDescTrans: [String: String] = ["en": "\(step.why) - \(step.how)"]
                var stepWhyTrans: [String: String] = ["en": step.why]
                var stepHowTrans: [String: String] = ["en": step.how]

                do {
                    stepTitleTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.name, to: deviceLanguage)
                    stepDescTrans[deviceLanguage] = try await languageService.translateFromEnglish("\(step.why) - \(step.how)", to: deviceLanguage)
                    stepWhyTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepHowTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage)
                } catch {
                    print("⚠️ Failed to translate evening step '\(step.name)': \(error), using English only")
                }

                allStepTranslations.append(StepTranslations(
                    title: stepTitleTrans,
                    stepDescription: stepDescTrans,
                    why: stepWhyTrans,
                    how: stepHowTrans
                ))
            }

            print("✅ Translations created for \(allStepTranslations.count) steps (some may be English-only if translation failed)")
        } else {
            // English only - still create translation objects for consistency
            for step in response.routine.morning {
                allStepTranslations.append(StepTranslations(
                    title: ["en": step.name],
                    stepDescription: ["en": "\(step.why) - \(step.how)"],
                    why: ["en": step.why],
                    how: ["en": step.how]
                ))
            }

            for step in response.routine.evening {
                allStepTranslations.append(StepTranslations(
                    title: ["en": step.name],
                    stepDescription: ["en": "\(step.why) - \(step.how)"],
                    why: ["en": step.why],
                    how: ["en": step.how]
                ))
            }
        }

        let routineTranslations = RoutineTranslations(
            title: routineTitleTranslations,
            description: routineDescTranslations,
            benefits: benefitsTranslations,
            tags: tagsTranslations
        )

        return (routine: routineTranslations, steps: allStepTranslations)
    }

    /// Create translation objects for a routine template, including both English and device locale
    private func createTemplateTranslations(from template: RoutineTemplate) async throws -> (routine: RoutineTranslations, steps: [StepTranslations]) {
        let deviceLanguage = LocalizationUtils.deviceLocaleLanguage()

        // Start with English versions (from the template)
        var routineTitleTranslations: [String: String] = ["en": template.title]
        var routineDescTranslations: [String: String] = ["en": template.description]
        var benefitsTranslations: [String: [String]] = ["en": template.benefits]
        var tagsTranslations: [String: [String]] = ["en": template.tags]

        // Create step translations
        var allStepTranslations: [StepTranslations] = []

        // If device language is not English, translate
        if deviceLanguage != "en" {
            print("🌍 Creating translations for template '\(template.title)' in language: \(deviceLanguage)")
            let languageService = LanguageService.shared

            // Translate routine-level content
            do {
                routineTitleTranslations[deviceLanguage] = try await languageService.translateFromEnglish(template.title, to: deviceLanguage)
                routineDescTranslations[deviceLanguage] = try await languageService.translateFromEnglish(template.description, to: deviceLanguage)
            } catch {
                print("⚠️ Failed to translate template title/description: \(error), using English only")
            }

            // Translate benefits
            do {
                let translatedBenefits = try await languageService.translateArray(template.benefits, from: "en", to: deviceLanguage)
                benefitsTranslations[deviceLanguage] = translatedBenefits
            } catch {
                print("⚠️ Failed to translate template benefits: \(error), using English only")
            }

            // Translate tags
            do {
                let translatedTags = try await languageService.translateArray(template.tags, from: "en", to: deviceLanguage)
                tagsTranslations[deviceLanguage] = translatedTags
            } catch {
                print("⚠️ Failed to translate template tags: \(error), using English only")
            }

            // Translate morning steps (with individual error handling)
            for step in template.morningSteps {
                var stepTitleTrans: [String: String] = ["en": step.title]
                var stepDescTrans: [String: String] = ["en": step.why]
                var stepWhyTrans: [String: String] = ["en": step.why]
                var stepHowTrans: [String: String] = ["en": step.how]

                do {
                    stepTitleTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.title, to: deviceLanguage)
                    stepDescTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepWhyTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepHowTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage)
                } catch {
                    print("⚠️ Failed to translate template morning step '\(step.title)': \(error), using English only")
                }

                allStepTranslations.append(StepTranslations(
                    title: stepTitleTrans,
                    stepDescription: stepDescTrans,
                    why: stepWhyTrans,
                    how: stepHowTrans
                ))
            }

            // Translate evening steps (with individual error handling)
            for step in template.eveningSteps {
                var stepTitleTrans: [String: String] = ["en": step.title]
                var stepDescTrans: [String: String] = ["en": step.why]
                var stepWhyTrans: [String: String] = ["en": step.why]
                var stepHowTrans: [String: String] = ["en": step.how]

                do {
                    stepTitleTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.title, to: deviceLanguage)
                    stepDescTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepWhyTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage)
                    stepHowTrans[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage)
                } catch {
                    print("⚠️ Failed to translate template evening step '\(step.title)': \(error), using English only")
                }

                allStepTranslations.append(StepTranslations(
                    title: stepTitleTrans,
                    stepDescription: stepDescTrans,
                    why: stepWhyTrans,
                    how: stepHowTrans
                ))
            }

            print("✅ Template translations created for \(allStepTranslations.count) steps (some may be English-only if translation failed)")
        } else {
            // English only - still create translation objects for consistency
            for step in template.morningSteps {
                allStepTranslations.append(StepTranslations(
                    title: ["en": step.title],
                    stepDescription: ["en": step.why],
                    why: ["en": step.why],
                    how: ["en": step.how]
                ))
            }

            for step in template.eveningSteps {
                allStepTranslations.append(StepTranslations(
                    title: ["en": step.title],
                    stepDescription: ["en": step.why],
                    why: ["en": step.why],
                    how: ["en": step.how]
                ))
            }
        }

        let routineTranslations = RoutineTranslations(
            title: routineTitleTranslations,
            description: routineDescTranslations,
            benefits: benefitsTranslations,
            tags: tagsTranslations
        )

        return (routine: routineTranslations, steps: allStepTranslations)
    }

    func removeRoutine(_ routine: SavedRoutineModel) async throws {
        print("🗑️ Removing routine: \(routine.title)")

        try await store.removeRoutine(routine)

        // Emit updated state
        try await emitUpdatedState()
    }

    func removeRoutineTemplate(_ template: RoutineTemplate) async throws {
        print("🗑️ Removing routine template: \(template.title)")

        try await store.removeRoutineTemplate(template)

        // Emit updated state
        try await emitUpdatedState()
    }

    func setActiveRoutine(_ routine: SavedRoutineModel) async throws {
        print("⭐ Setting active routine: \(routine.title)")

        try await store.setActiveRoutine(routine)

        // Emit updated state
        try await emitUpdatedState()
    }

    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool {
        return try await store.isRoutineSaved(template)
    }

    // MARK: - Tracking Operations

    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) async throws {
        let startOfDay = DateUtils.startOfDay(for: date)

        print("🔄 RoutineService: Toggling step completion: \(stepTitle) (ID: \(stepId)) for date: \(DateUtils.formatForLog(startOfDay))")

        try await store.toggleStepCompletion(
            stepId: stepId,
            stepTitle: stepTitle,
            stepType: stepType,
            timeOfDay: timeOfDay,
            date: startOfDay
        )

        print("📡 RoutineService: Emitting completion change notification for date: \(DateUtils.formatForLog(startOfDay))")
        // Emit completion change notification for this date
        Task { @MainActor in
            self.completionChangeSubject.send(startOfDay)
        }

        // Emit updated state (for routines and active routine)
        try await emitUpdatedState()
    }

    func isStepCompleted(stepId: String, date: Date = Date()) async throws -> Bool {
        let startOfDay = DateUtils.startOfDay(for: date)
        return try await store.isStepCompleted(stepId: stepId, date: startOfDay)
    }

    func getCompletedSteps(for date: Date = Date()) async throws -> Set<String> {
        let startOfDay = DateUtils.startOfDay(for: date)
        return try await store.getCompletedSteps(for: startOfDay)
    }

    func getCurrentStreak() async throws -> Int {
        return try await store.getCurrentStreak()
    }

    func clearAllCompletions() async throws {
        print("🧹 Clearing all completions")

        try await store.clearAllCompletions()

        // Emit completion change notification for today (affects all dates)
        Task { @MainActor in
            self.completionChangeSubject.send(Date())
        }

        // Emit updated state
        try await emitUpdatedState()
    }

    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats] {
        return try await store.getCompletionStats(from: startDate, to: endDate)
    }

    // MARK: - Convenience Operations

    func generateAndSaveInitialRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        routineDepth: RoutineDepth? = nil,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) async throws -> SavedRoutineModel {
        print("🤖💾 Generating and saving routine in one operation")

        // Generate routine
        let routineResponse = try await generateRoutine(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            routineDepth: routineDepth,
            preferences: preferences,
            lifestyle: lifestyle
        )

        // Save routine
        let savedRoutine = try await saveInitialRoutine(from: routineResponse)

        return savedRoutine
    }

    // MARK: - State Management

    func refreshData() async throws {
        print("🔄 Refreshing routine service data")

        // Fetch all data concurrently
        async let routinesResult = store.fetchSavedRoutines()
        async let activeRoutineResult = store.fetchActiveRoutine()

        let (routines, activeRoutine) = try await (routinesResult, activeRoutineResult)

        // Emit new state
        let newState = RoutineServiceState(
            savedRoutines: routines,
            activeRoutine: activeRoutine,
            lastUpdated: Date()
        )

        Task { @MainActor in
            self.stateSubject.send(newState)
        }

        print("✅ Refreshed: \(routines.count) routines")
    }

    // MARK: - Private Helpers

    private func emitUpdatedState() async throws {
        try await refreshData()
    }
}

// MARK: - Convenience Extensions

extension RoutineService {
    /// Get current routines synchronously (for immediate access)
    var savedRoutines: [SavedRoutineModel] {
        currentState.savedRoutines
    }

    /// Get current active routine synchronously
    var activeRoutine: SavedRoutineModel? {
        currentState.activeRoutine
    }

    // Note: completedSteps removed - use getCompletedSteps(for: date) for date-specific completions
}

// MARK: - Adaptation Extensions

extension RoutineService {
    func toggleAdaptation(
        for routine: SavedRoutineModel,
        enabled: Bool,
        type: AdaptationType?
    ) async throws {
        print("🔄 RoutineService: Toggling adaptation for routine \(routine.title)")

        try await store.updateAdaptationSettings(
            routineId: routine.id,
            enabled: enabled,
            type: type
        )

        // Emit updated state
        try await emitUpdatedState()
    }

    func getAdaptedSnapshot(
        _ routine: SavedRoutineModel,
        for date: Date
    ) async throws -> RoutineSnapshot? {
        // This will be provided by the RoutineAdapterService
        // For now, return nil - UI will handle this via RoutineAdapterService directly
        return nil
    }
}