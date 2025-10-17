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
        // Ask GPT to return batched translations (en + device language if different)
        let i18nLangs: [String] = {
            var langs = ["en"]
            if userLanguage != "en" { langs.append(userLanguage) }
            return langs
        }()

        let request = GPTService.createRequest(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            routineDepth: routineDepth,
            preferences: preferences,
            lifestyle: lifestyle,
            locale: userLanguage,
            i18nLanguages: i18nLangs
        )

        // Generate routine with batched translations from GPT
        print("📝 Generating routine with batched i18n: \(i18nLangs)")
        print("⏱️ Timeout set to: 40 seconds")
        print("🤖 Using model: gpt-3.5-turbo")
        let startTime = Date()
        let response = try await gptService.generateRoutine(for: request)
        let elapsed = Date().timeIntervalSince(startTime)
        print("⚡ Generation completed in \(String(format: "%.2f", elapsed)) seconds")

        // Log successful generation
        print("✅ ========== ROUTINE GENERATION COMPLETED ==========")
        print("🌍 Primary Language: \(response.locale)")
        print("📋 Routine Title (\(response.locale)): \(response.summary.title)")
        print("📋 One-liner (\(response.locale)): \(response.summary.oneLiner)")
        print("🌅 Morning Steps (\(response.locale)): \(response.routine.morning.count)")
        for (idx, step) in response.routine.morning.enumerated() {
            print("   \(idx+1). \(step.name) (\(step.step.rawValue))")
        }
        print("🌙 Evening Steps (\(response.locale)): \(response.routine.evening.count)")
        for (idx, step) in response.routine.evening.enumerated() {
            print("   \(idx+1). \(step.name) (\(step.step.rawValue))")
        }
        if let weekly = response.routine.weekly, !weekly.isEmpty {
            print("📅 Weekly Steps (\(response.locale)): \(weekly.count)")
            for (idx, step) in weekly.enumerated() {
                print("   \(idx+1). \(step.name) (\(step.step.rawValue))")
            }
        } else {
            print("📅 Weekly Steps: None")
        }

        // Log i18n translations if present
        if let i18n = response.i18n {
            print("\n🌐 ========== TRANSLATIONS RECEIVED (Zero Extra API Calls!) ==========")
            print("📦 Languages in i18n: \(i18n.keys.sorted())")

            for lang in i18n.keys.sorted() {
                if let langData = i18n[lang] {
                    print("\n🗣️ Language: \(lang)")
                    print("   Title: \(langData.routine.title)")
                    print("   One-liner: \(langData.routine.oneLiner)")
                    print("   Morning steps: \(langData.steps.morning.count)")
                    for (idx, step) in langData.steps.morning.enumerated() {
                        print("      \(idx+1). \(step.name)")
                    }
                    print("   Evening steps: \(langData.steps.evening.count)")
                    for (idx, step) in langData.steps.evening.enumerated() {
                        print("      \(idx+1). \(step.name)")
                    }
                }
            }
        } else {
            print("\n❌ ========== WARNING: NO i18n PAYLOAD ==========")
            print("⚠️ GPT did not return i18n translations!")
            print("⚠️ Falling back to LanguageService (will make ~100+ API calls)")
            print("⚠️ This will be SLOW and EXPENSIVE")
            print("❌ ================================================\n")
        }
        print("✅ ================================================\n")

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
            productSlots: response.productSlots, // Keep product slots in English for matching
            i18n: response.i18n
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
        // Prefer i18n payload for zero-API conversion; fallback to translation only if needed
        let englishResponse: RoutineResponse
        if routineResponse.locale.lowercased().hasPrefix("en") {
            englishResponse = routineResponse
        } else if let i18n = routineResponse.i18n,
                  let enLang = i18n["en"] {
            // Map steps preserving product types and constraints
            let englishMorning: [APIRoutineStep] = zip(routineResponse.routine.morning, enLang.steps.morning).map { (orig, txt) in
                APIRoutineStep(step: orig.step, name: txt.name, why: txt.why, how: txt.how, constraints: orig.constraints)
            }
            let englishEvening: [APIRoutineStep] = zip(routineResponse.routine.evening, enLang.steps.evening).map { (orig, txt) in
                APIRoutineStep(step: orig.step, name: txt.name, why: txt.why, how: txt.how, constraints: orig.constraints)
            }
            let englishWeekly: [APIRoutineStep]? = {
                if let origWeekly = routineResponse.routine.weekly, let weeklyTxt = enLang.steps.weekly {
                    return zip(origWeekly, weeklyTxt).map { (orig, txt) in
                        APIRoutineStep(step: orig.step, name: txt.name, why: txt.why, how: txt.how, constraints: orig.constraints)
                    }
                }
                return nil
            }()

            let guardrailsEn: Guardrails = {
                if let enG = enLang.guardrails {
                    return Guardrails(cautions: enG.cautions, whenToStop: enG.whenToStop, sunNotes: enG.sunNotes)
                }
                return routineResponse.guardrails
            }()

            englishResponse = RoutineResponse(
                version: routineResponse.version,
                locale: "en-US",
                summary: Summary(title: enLang.routine.title, oneLiner: enLang.routine.oneLiner),
                routine: Routine(depth: routineResponse.routine.depth, morning: englishMorning, evening: englishEvening, weekly: englishWeekly),
                guardrails: guardrailsEn,
                adaptation: routineResponse.adaptation,
                productSlots: routineResponse.productSlots,
                i18n: routineResponse.i18n
            )

            print("✅ ========== ENGLISH CONVERSION (from i18n) ==========")
            print("📋 English Title: \(enLang.routine.title)")
            print("📋 English One-liner: \(enLang.routine.oneLiner)")
            print("🌅 English Morning Steps: \(englishMorning.count)")
            for (idx, step) in englishMorning.enumerated() {
                print("   \(idx+1). \(step.name) (\(step.step.rawValue))")
            }
            print("🌙 English Evening Steps: \(englishEvening.count)")
            for (idx, step) in englishEvening.enumerated() {
                print("   \(idx+1). \(step.name) (\(step.step.rawValue))")
            }
            print("✅ ==================================================\n")
        } else {
            print("🔄 i18n missing English; translating back to English via LanguageService...")
            englishResponse = try await translateRoutineResponse(routineResponse, to: "en")
        }

        // Generate translations using i18n payload if available
        let translations = try await createRoutineTranslations(from: englishResponse)
        
        print("📦 ========== TRANSLATIONS CREATED ==========")
        print("📋 Routine translations languages: \(translations.routine.title.keys.sorted())")
        print("📋 Step translations count: \(translations.steps.count)")
        for (idx, stepTrans) in translations.steps.enumerated() {
            print("   Step \(idx+1) languages: \(stepTrans.title.keys.sorted())")
            for lang in stepTrans.title.keys.sorted() {
                print("      [\(lang)] \(stepTrans.title[lang] ?? "nil")")
            }
        }
        print("✅ ==========================================\n")

        let savedRoutine = try await store.saveInitialRoutine(from: englishResponse, translations: translations)
        
        print("💾 ========== SAVED TO CORE DATA ==========")
        print("📋 Saved routine: \(savedRoutine.title)")
        print("🌅 Morning steps count: \(savedRoutine.stepDetails.filter { $0.timeOfDay == "morning" }.count)")
        print("🌙 Evening steps count: \(savedRoutine.stepDetails.filter { $0.timeOfDay == "evening" }.count)")
        print("📅 Weekly steps count: \(savedRoutine.stepDetails.filter { $0.timeOfDay == "weekly" }.count)")
        print("📝 Step details:")
        for (idx, step) in savedRoutine.stepDetails.enumerated() {
            print("   \(idx+1). [\(step.timeOfDay)] \(step.title) - Has translations: \(step.translations != nil)")
        }
        print("✅ =========================================\n")

        // Emit updated state
        try await emitUpdatedState()

        return savedRoutine
    }

    /// Create translation objects for a routine response, including both English and device locale
    private func createRoutineTranslations(from response: RoutineResponse) async throws -> (routine: RoutineTranslations, steps: [StepTranslations]) {
        // Prefer GPT-batched i18n payload for zero API overhead
        if let i18n = response.i18n {
            let baseLang: String = response.locale.lowercased().hasPrefix("tr") ? "tr" : "en"

            var routineTitleTranslations: [String: String] = [baseLang: response.summary.title]
            var routineDescTranslations: [String: String] = [baseLang: response.summary.oneLiner]
            for (lang, langData) in i18n {
                routineTitleTranslations[lang] = langData.routine.title
                routineDescTranslations[lang] = langData.routine.oneLiner
            }

            let benefitsEn = ["Personalized for your skin", "Based on your preferences", "Easy to follow"]
            let tagsEn = ["Personalized", "Onboarding", "Custom"]
            var benefitsTranslations: [String: [String]] = ["en": benefitsEn]
            var tagsTranslations: [String: [String]] = ["en": tagsEn]
            if baseLang == "tr" {
                benefitsTranslations["tr"] = ["Cildinize özel", "Tercihlerinize dayanır", "Kolay uygulanır"]
                tagsTranslations["tr"] = ["Kişiselleştirilmiş", "Onboarding", "Özel"]
            }

            var allStepTranslations: [StepTranslations] = []

            func textFor(lang: String, time: String, index: Int) -> (name: String, why: String, how: String)? {
                guard let langData = i18n[lang] else { return nil }
                let langSteps = langData.steps
                switch time {
                case "morning":
                    guard index < langSteps.morning.count else { return nil }
                    let t = langSteps.morning[index]; return (t.name, t.why, t.how)
                case "evening":
                    guard index < langSteps.evening.count else { return nil }
                    let t = langSteps.evening[index]; return (t.name, t.why, t.how)
                case "weekly":
                    guard let weekly = langSteps.weekly, index < weekly.count else { return nil }
                    let t = weekly[index]; return (t.name, t.why, t.how)
                default: return nil
                }
            }

            for (idx, step) in response.routine.morning.enumerated() {
                var titleMap: [String: String] = [baseLang: step.name]
                var descMap: [String: String] = [baseLang: "\(step.why) - \(step.how)"]
                var whyMap: [String: String] = [baseLang: step.why]
                var howMap: [String: String] = [baseLang: step.how]
                for lang in i18n.keys { if let t = textFor(lang: lang, time: "morning", index: idx) { titleMap[lang] = t.name; descMap[lang] = "\(t.why) - \(t.how)"; whyMap[lang] = t.why; howMap[lang] = t.how } }
                allStepTranslations.append(StepTranslations(title: titleMap, stepDescription: descMap, why: whyMap, how: howMap))
            }
            for (idx, step) in response.routine.evening.enumerated() {
                var titleMap: [String: String] = [baseLang: step.name]
                var descMap: [String: String] = [baseLang: "\(step.why) - \(step.how)"]
                var whyMap: [String: String] = [baseLang: step.why]
                var howMap: [String: String] = [baseLang: step.how]
                for lang in i18n.keys { if let t = textFor(lang: lang, time: "evening", index: idx) { titleMap[lang] = t.name; descMap[lang] = "\(t.why) - \(t.how)"; whyMap[lang] = t.why; howMap[lang] = t.how } }
                allStepTranslations.append(StepTranslations(title: titleMap, stepDescription: descMap, why: whyMap, how: howMap))
            }
            if let weekly = response.routine.weekly {
                for (idx, step) in weekly.enumerated() {
                    var titleMap: [String: String] = [baseLang: step.name]
                    var descMap: [String: String] = [baseLang: "\(step.why) - \(step.how)"]
                    var whyMap: [String: String] = [baseLang: step.why]
                    var howMap: [String: String] = [baseLang: step.how]
                    for lang in i18n.keys { if let t = textFor(lang: lang, time: "weekly", index: idx) { titleMap[lang] = t.name; descMap[lang] = "\(t.why) - \(t.how)"; whyMap[lang] = t.why; howMap[lang] = t.how } }
                    allStepTranslations.append(StepTranslations(title: titleMap, stepDescription: descMap, why: whyMap, how: howMap))
                }
            }

            let routineTranslations = RoutineTranslations(title: routineTitleTranslations, description: routineDescTranslations, benefits: benefitsTranslations, tags: tagsTranslations)
            return (routine: routineTranslations, steps: allStepTranslations)
        }

        // Fallback to translation service if i18n is unavailable
        let deviceLanguage = LocalizationUtils.deviceLocaleLanguage()
        var routineTitleTranslations: [String: String] = ["en": response.summary.title]
        var routineDescTranslations: [String: String] = ["en": response.summary.oneLiner]
        let benefitsEn = ["Personalized for your skin", "Based on your preferences", "Easy to follow"]
        let tagsEn = ["Personalized", "Onboarding", "Custom"]
        var benefitsTranslations: [String: [String]] = ["en": benefitsEn]
        var tagsTranslations: [String: [String]] = ["en": tagsEn]
        var allStepTranslations: [StepTranslations] = []

        if deviceLanguage != "en" {
            print("🌍 Creating translations for device language (fallback): \(deviceLanguage)")
            let languageService = LanguageService.shared
            do { routineTitleTranslations[deviceLanguage] = try await languageService.translateFromEnglish(response.summary.title, to: deviceLanguage) } catch { }
            do { routineDescTranslations[deviceLanguage] = try await languageService.translateFromEnglish(response.summary.oneLiner, to: deviceLanguage) } catch { }
            do { benefitsTranslations[deviceLanguage] = try await languageService.translateArray(benefitsEn, from: "en", to: deviceLanguage) } catch { }
            do { tagsTranslations[deviceLanguage] = try await languageService.translateArray(tagsEn, from: "en", to: deviceLanguage) } catch { }

            for step in response.routine.morning {
                var t: [String: String] = ["en": step.name]
                var d: [String: String] = ["en": "\(step.why) - \(step.how)"]
                var w: [String: String] = ["en": step.why]
                var h: [String: String] = ["en": step.how]
                do { t[deviceLanguage] = try await languageService.translateFromEnglish(step.name, to: deviceLanguage) } catch { }
                do { d[deviceLanguage] = try await languageService.translateFromEnglish("\(step.why) - \(step.how)", to: deviceLanguage) } catch { }
                do { w[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage) } catch { }
                do { h[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage) } catch { }
                allStepTranslations.append(StepTranslations(title: t, stepDescription: d, why: w, how: h))
            }
            for step in response.routine.evening {
                var t: [String: String] = ["en": step.name]
                var d: [String: String] = ["en": "\(step.why) - \(step.how)"]
                var w: [String: String] = ["en": step.why]
                var h: [String: String] = ["en": step.how]
                do { t[deviceLanguage] = try await languageService.translateFromEnglish(step.name, to: deviceLanguage) } catch { }
                do { d[deviceLanguage] = try await languageService.translateFromEnglish("\(step.why) - \(step.how)", to: deviceLanguage) } catch { }
                do { w[deviceLanguage] = try await languageService.translateFromEnglish(step.why, to: deviceLanguage) } catch { }
                do { h[deviceLanguage] = try await languageService.translateFromEnglish(step.how, to: deviceLanguage) } catch { }
                allStepTranslations.append(StepTranslations(title: t, stepDescription: d, why: w, how: h))
            }
        } else {
            for step in response.routine.morning { allStepTranslations.append(StepTranslations(title: ["en": step.name], stepDescription: ["en": "\(step.why) - \(step.how)"], why: ["en": step.why], how: ["en": step.how])) }
            for step in response.routine.evening { allStepTranslations.append(StepTranslations(title: ["en": step.name], stepDescription: ["en": "\(step.why) - \(step.how)"], why: ["en": step.why], how: ["en": step.how])) }
        }

        let routineTranslations = RoutineTranslations(title: routineTitleTranslations, description: routineDescTranslations, benefits: benefitsTranslations, tags: tagsTranslations)
        return (routine: routineTranslations, steps: allStepTranslations)
    }

    /// Create translation objects for a routine template, including both English and device locale
    private func createTemplateTranslations(from template: RoutineTemplate) async throws -> (routine: RoutineTranslations, steps: [StepTranslations]) {
        // IMPORTANT: Premade templates should NOT call translation APIs
        // For now, we only store English until we add proper template translations to JSON
        print("📦 Creating template translations (English-only, no API calls)")

        let deviceLanguage = LocalizationUtils.deviceLocaleLanguage()

        // Start with English versions (from the template)
        var routineTitleTranslations: [String: String] = ["en": template.title]
        var routineDescTranslations: [String: String] = ["en": template.description]
        var benefitsTranslations: [String: [String]] = ["en": template.benefits]
        var tagsTranslations: [String: [String]] = ["en": template.tags]

        // Merge embedded translations if available (NO API calls)
        if let templateTrans = template.translations {
            for (lang, title) in templateTrans.title {
                routineTitleTranslations[lang] = title
            }
            for (lang, desc) in templateTrans.description {
                routineDescTranslations[lang] = desc
            }
            for (lang, benefits) in templateTrans.benefits {
                benefitsTranslations[lang] = benefits
            }
            for (lang, tags) in templateTrans.tags {
                tagsTranslations[lang] = tags
            }
            print("✅ Found embedded translations for: \(templateTrans.title.keys.sorted())")
        }

        // Create step translations
        var allStepTranslations: [StepTranslations] = []

        // Process morning steps with embedded translations
        for step in template.morningSteps {
            var titleTrans: [String: String] = ["en": step.title]
            var whyTrans: [String: String] = ["en": step.why]
            var howTrans: [String: String] = ["en": step.how]

            if let stepTrans = step.translations {
                for (lang, title) in stepTrans.title { titleTrans[lang] = title }
                for (lang, why) in stepTrans.why { whyTrans[lang] = why }
                for (lang, how) in stepTrans.how { howTrans[lang] = how }
            }

            allStepTranslations.append(StepTranslations(
                title: titleTrans,
                stepDescription: whyTrans, // Use why as description
                why: whyTrans,
                how: howTrans
            ))
        }

        // Process evening steps with embedded translations
        for step in template.eveningSteps {
            var titleTrans: [String: String] = ["en": step.title]
            var whyTrans: [String: String] = ["en": step.why]
            var howTrans: [String: String] = ["en": step.how]

            if let stepTrans = step.translations {
                for (lang, title) in stepTrans.title { titleTrans[lang] = title }
                for (lang, why) in stepTrans.why { whyTrans[lang] = why }
                for (lang, how) in stepTrans.how { howTrans[lang] = how }
            }

            allStepTranslations.append(StepTranslations(
                title: titleTrans,
                stepDescription: whyTrans,
                why: whyTrans,
                how: howTrans
            ))
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