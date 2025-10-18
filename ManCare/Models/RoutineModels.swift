//
//  RoutineModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 18.09.2025.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Time of Day Enum

enum TimeOfDay: String, Codable, CaseIterable {
    case morning, evening, weekly

    var displayName: String {
        switch self {
        case .morning:
            return L10n.Routines.morningOnly
        case .evening:
            return L10n.Routines.eveningOnly
        case .weekly:
            return L10n.Routines.weeklyOnly
        }
    }
}

// MARK: - Translation Models

/// Stores translations for a routine's user-facing content
struct RoutineTranslations: Codable, Equatable {
    let title: [String: String]         // Language code -> Title
    let description: [String: String]   // Language code -> Description
    let benefits: [String: [String]]    // Language code -> Benefits array
    let tags: [String: [String]]        // Language code -> Tags array

    init(title: [String: String], description: [String: String], benefits: [String: [String]], tags: [String: [String]]) {
        self.title = title
        self.description = description
        self.benefits = benefits
        self.tags = tags
    }

    /// Get localized title for current language with fallback to English
    func localizedTitle(for language: String) -> String {
        return title[language] ?? title["en"] ?? ""
    }

    /// Get localized description for current language with fallback to English
    func localizedDescription(for language: String) -> String {
        return description[language] ?? description["en"] ?? ""
    }

    /// Get localized benefits for current language with fallback to English
    func localizedBenefits(for language: String) -> [String] {
        return benefits[language] ?? benefits["en"] ?? []
    }

    /// Get localized tags for current language with fallback to English
    func localizedTags(for language: String) -> [String] {
        return tags[language] ?? tags["en"] ?? []
    }
}

/// Stores translations for a step's user-facing content
struct StepTranslations: Codable, Equatable {
    let title: [String: String]             // Language code -> Title
    let stepDescription: [String: String]   // Language code -> Description
    let why: [String: String]               // Language code -> Why text
    let how: [String: String]               // Language code -> How text

    init(title: [String: String], stepDescription: [String: String], why: [String: String], how: [String: String]) {
        self.title = title
        self.stepDescription = stepDescription
        self.why = why
        self.how = how
    }

    /// Get localized title for current language with fallback to English
    func localizedTitle(for language: String) -> String {
        return title[language] ?? title["en"] ?? ""
    }

    /// Get localized description for current language with fallback to English
    func localizedDescription(for language: String) -> String {
        return stepDescription[language] ?? stepDescription["en"] ?? ""
    }

    /// Get localized why text for current language with fallback to English
    func localizedWhy(for language: String) -> String {
        return why[language] ?? why["en"] ?? ""
    }

    /// Get localized how text for current language with fallback to English
    func localizedHow(for language: String) -> String {
        return how[language] ?? how["en"] ?? ""
    }
}


// MARK: - SavedStepDetailModel (Swift Model)

struct SavedStepDetailModel: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let stepDescription: String
    // iconName is computed from stepType, not stored
    let stepType: String
    let timeOfDay: String
    let why: String?
    let how: String?
    let order: Int
    let translations: StepTranslations?

    // Computed property - iconName is derived from stepType, not stored
    var iconName: String {
        guard let productType = ProductType(rawValue: stepType) else {
            return ProductIconManager.getFallbackIcon()
        }
        return ProductIconManager.getIconName(for: productType)
    }

    // Computed properties for enum access
    var stepTypeEnum: ProductType {
        return ProductType(rawValue: stepType) ?? .cleanser
    }

    var timeOfDayEnum: TimeOfDay {
        return TimeOfDay(rawValue: timeOfDay) ?? .morning
    }

    // MARK: - Localized Properties

    /// Get localized title based on current language
    var localizedTitle: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedTitle(for: currentLanguage) ?? title
    }

    /// Get localized description based on current language
    var localizedDescription: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedDescription(for: currentLanguage) ?? stepDescription
    }

    /// Get localized why text based on current language
    var localizedWhy: String? {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        if let translations = translations {
            return translations.localizedWhy(for: currentLanguage)
        }
        return why
    }

    /// Get localized how text based on current language
    var localizedHow: String? {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        if let translations = translations {
            return translations.localizedHow(for: currentLanguage)
        }
        return how
    }

    init(id: UUID = UUID(), title: String, stepDescription: String, stepType: String, timeOfDay: String, why: String? = nil, how: String? = nil, order: Int, translations: StepTranslations? = nil) {
        self.id = id
        self.title = title
        self.stepDescription = stepDescription
        self.stepType = stepType
        self.timeOfDay = timeOfDay
        self.why = why
        self.how = how
        self.order = order
        self.translations = translations
    }

    init(from entity: SavedStepDetailEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.stepDescription = entity.stepDescription ?? ""
        // iconName is computed from stepType, not stored
        self.stepType = entity.stepType ?? ""
        self.timeOfDay = entity.timeOfDay ?? ""
        self.why = entity.why
        self.how = entity.how
        self.order = Int(entity.order)

        // Decode translations from JSON if available
        if let translationsData = entity.translationsJSON {
            self.translations = try? JSONDecoder().decode(StepTranslations.self, from: translationsData)
        } else {
            self.translations = nil
        }
    }
}


// MARK: - SavedRoutineModel (Swift Model)

struct SavedRoutineModel: Identifiable, Codable, Equatable {
    let id: UUID
    let templateId: UUID
    let title: String
    let description: String
    let category: RoutineCategory
    let stepCount: Int
    let duration: String
    let difficulty: RoutineTemplate.Difficulty
    let tags: [String]
    let morningSteps: [String]
    let eveningSteps: [String]

    // Computed property for backward compatibility
    var steps: [String] {
        return morningSteps + eveningSteps
    }
    let benefits: [String]
    let isFeatured: Bool
    let isPremium: Bool
    let savedDate: Date
    let isActive: Bool
    let stepDetails: [SavedStepDetailModel]
    let adaptationEnabled: Bool
    let adaptationType: AdaptationType?  // Legacy: single type (backward compatible)
    let adaptationTypes: [AdaptationType]?  // New: multiple types for combined adaptations
    let imageName: String
    let translations: RoutineTranslations?

    // Computed property to get all active adaptation types
    var activeAdaptationTypes: [AdaptationType] {
        if let types = adaptationTypes, !types.isEmpty {
            return types
        } else if let type = adaptationType {
            return [type]
        }
        return []
    }

    // MARK: - Localized Properties

    /// Get localized title based on current language
    var localizedTitle: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedTitle(for: currentLanguage) ?? title
    }

    /// Get localized description based on current language
    var localizedDescription: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedDescription(for: currentLanguage) ?? description
    }

    /// Get localized benefits based on current language
    var localizedBenefits: [String] {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedBenefits(for: currentLanguage) ?? benefits
    }

    /// Get localized tags based on current language
    var localizedTags: [String] {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        return translations?.localizedTags(for: currentLanguage) ?? tags
    }

    init(from template: RoutineTemplate, isActive: Bool = false, adaptationEnabled: Bool = false, adaptationType: AdaptationType? = nil, stepTranslations: [StepTranslations]? = nil, routineTranslations: RoutineTranslations? = nil) {
        self.id = UUID()
        self.templateId = template.id
        self.title = template.title
        self.description = template.description
        self.category = template.category
        self.stepCount = template.stepCount
        self.duration = template.duration
        self.difficulty = template.difficulty
        self.tags = template.tags
        self.morningSteps = template.morningSteps.map { $0.title }
        self.eveningSteps = template.eveningSteps.map { $0.title }
        self.benefits = template.benefits
        self.isFeatured = template.isFeatured
        self.isPremium = template.isPremium
        self.savedDate = Date()
        self.isActive = isActive
        self.adaptationEnabled = adaptationEnabled
        self.adaptationType = adaptationType
        self.adaptationTypes = adaptationType.map { [$0] }  // Convert single to array
        self.imageName = template.imageName
        self.translations = routineTranslations
        // Create step details from template steps
        var allStepDetails: [SavedStepDetailModel] = []
        var stepTranslationIndex = 0

        // Add morning steps
        for (index, step) in template.morningSteps.enumerated() {
            // CRITICAL: Template steps MUST have explicit productType (English enum value)
            // This ensures deterministic business logic independent of localization
            guard let enumType = ProductType(rawValue: step.productType) else {
                print("❌ CRITICAL: Invalid productType '\(step.productType)' for step '\(step.title)'")
                assertionFailure("Template step missing valid productType")
                continue
            }

            print("✅ [TEMPLATE_SAVE] Morning step \(index+1): '\(step.title)' -> productType: '\(step.productType)' ✅")

            let stepTranslation = (stepTranslations != nil && stepTranslationIndex < stepTranslations!.count) ? stepTranslations![stepTranslationIndex] : nil

            let savedStep = SavedStepDetailModel(
                title: step.title,
                stepDescription: step.why,
                stepType: enumType.rawValue,  // Guaranteed English enum value
                timeOfDay: "morning",
                why: step.why,
                how: step.how,
                order: index,
                translations: stepTranslation
            )

            print("   📝 Saved as: stepType='\(savedStep.stepType)' (English, deterministic)")
            allStepDetails.append(savedStep)
            stepTranslationIndex += 1
        }

        // Add evening steps
        for (index, step) in template.eveningSteps.enumerated() {
            // CRITICAL: Template steps MUST have explicit productType (English enum value)
            // This ensures deterministic business logic independent of localization
            guard let enumType = ProductType(rawValue: step.productType) else {
                print("❌ CRITICAL: Invalid productType '\(step.productType)' for step '\(step.title)'")
                assertionFailure("Template step missing valid productType")
                continue
            }

            print("✅ [TEMPLATE_SAVE] Evening step \(index+1): '\(step.title)' -> productType: '\(step.productType)' ✅")

            let stepTranslation = (stepTranslations != nil && stepTranslationIndex < stepTranslations!.count) ? stepTranslations![stepTranslationIndex] : nil

            let savedStep = SavedStepDetailModel(
                title: step.title,
                stepDescription: step.why,
                stepType: enumType.rawValue,  // Guaranteed English enum value
                timeOfDay: "evening",
                why: step.why,
                how: step.how,
                order: index + template.morningSteps.count,
                translations: stepTranslation
            )

            print("   📝 Saved as: stepType='\(savedStep.stepType)' (English, deterministic)")
            allStepDetails.append(savedStep)
            stepTranslationIndex += 1
        }

        self.stepDetails = allStepDetails
    }

    init(id: UUID = UUID(), templateId: UUID, title: String, description: String, category: RoutineCategory, stepCount: Int, duration: String, difficulty: RoutineTemplate.Difficulty, tags: [String], morningSteps: [String], eveningSteps: [String], benefits: [String], isFeatured: Bool, isPremium: Bool, savedDate: Date, isActive: Bool, stepDetails: [SavedStepDetailModel] = [], adaptationEnabled: Bool = false, adaptationType: AdaptationType? = nil, adaptationTypes: [AdaptationType]? = nil, imageName: String = "routine-minimalist", translations: RoutineTranslations? = nil) {
        self.id = id
        self.templateId = templateId
        self.title = title
        self.description = description
        self.category = category
        self.stepCount = stepCount
        self.duration = duration
        self.difficulty = difficulty
        self.tags = tags
        self.morningSteps = morningSteps
        self.eveningSteps = eveningSteps
        self.benefits = benefits
        self.isFeatured = isFeatured
        self.isPremium = isPremium
        self.savedDate = savedDate
        self.isActive = isActive
        self.stepDetails = stepDetails
        self.adaptationEnabled = adaptationEnabled
        self.adaptationType = adaptationType
        self.adaptationTypes = adaptationTypes ?? adaptationType.map { [$0] }
        self.imageName = imageName
        self.translations = translations
    }

    init(from entity: SavedRoutineEntity) {
        self.id = entity.id ?? UUID()
        self.templateId = entity.templateId ?? UUID()
        self.title = entity.title ?? ""
        self.description = entity.routineDescription ?? ""
        self.category = RoutineCategory(rawValue: entity.category ?? "all") ?? .all
        self.stepCount = Int(entity.stepCount)
        self.duration = entity.duration ?? ""
        self.difficulty = RoutineTemplate.Difficulty(rawValue: entity.difficulty ?? "beginner") ?? .beginner
        self.tags = entity.tags as? [String] ?? []
        // For backward compatibility, we'll need to split the steps into morning/evening
        // For now, we'll put all steps in morning and leave evening empty
        let allSteps = entity.steps as? [String] ?? []
        self.morningSteps = allSteps
        self.eveningSteps = []
        self.benefits = entity.benefits as? [String] ?? []
        self.isFeatured = entity.isFeatured
        self.isPremium = entity.isPremium
        self.savedDate = entity.savedDate ?? Date()
        self.isActive = entity.isActive
        // Convert step details from Core Data entities
        self.stepDetails = (entity.stepDetails as? Set<SavedStepDetailEntity>)?.compactMap { stepEntity in
            SavedStepDetailModel(from: stepEntity)
        }.sorted { $0.order < $1.order } ?? []
        // Adaptation fields (default to false for backward compatibility)
        self.adaptationEnabled = entity.adaptationEnabled
        self.adaptationType = entity.adaptationType.flatMap { AdaptationType(rawValue: $0) }
        self.adaptationTypes = self.adaptationType.map { [$0] }  // Convert to array for backward compat
        self.imageName = entity.imageName ?? "routine-minimalist"

        // Decode translations from JSON if available
        if let translationsData = entity.translationsJSON {
            self.translations = try? JSONDecoder().decode(RoutineTranslations.self, from: translationsData)
        } else {
            self.translations = nil
        }
    }

    // MARK: - Conversion to RoutineResponse

    /// Convert SavedRoutineModel back to RoutineResponse format for editing
    func toRoutineResponse() -> RoutineResponse {
        // Convert morning steps
        let morningAPISteps: [APIRoutineStep] = stepDetails
            .filter { $0.timeOfDay == "morning" }
            .sorted { $0.order < $1.order }
            .map { step in
                APIRoutineStep(
                    step: ProductType(rawValue: step.stepType) ?? .cleanser,
                    name: step.title,
                    why: step.why ?? "",
                    how: step.how ?? "",
                    constraints: Constraints()
                )
            }

        // Convert evening steps
        let eveningAPISteps: [APIRoutineStep] = stepDetails
            .filter { $0.timeOfDay == "evening" }
            .sorted { $0.order < $1.order }
            .map { step in
                APIRoutineStep(
                    step: ProductType(rawValue: step.stepType) ?? .cleanser,
                    name: step.title,
                    why: step.why ?? "",
                    how: step.how ?? "",
                    constraints: Constraints()
                )
            }

        // Convert weekly steps
        let weeklyAPISteps: [APIRoutineStep]? = {
            let weeklySteps = stepDetails
                .filter { $0.timeOfDay == "weekly" }
                .sorted { $0.order < $1.order }
            guard !weeklySteps.isEmpty else { return nil }
            return weeklySteps.map { step in
                APIRoutineStep(
                    step: ProductType(rawValue: step.stepType) ?? .cleanser,
                    name: step.title,
                    why: step.why ?? "",
                    how: step.how ?? "",
                    constraints: Constraints()
                )
            }
        }()

        return RoutineResponse(
            version: "1.0",
            locale: "en-US",
            summary: Summary(
                title: title,
                oneLiner: description
            ),
            routine: Routine(
                depth: .simple,
                morning: morningAPISteps,
                evening: eveningAPISteps,
                weekly: weeklyAPISteps
            ),
            guardrails: Guardrails(
                cautions: [],
                whenToStop: [],
                sunNotes: ""
            ),
            adaptation: Adaptation(
                forSkinType: "",
                forConcerns: [],
                forPreferences: []
            ),
            productSlots: [],
            i18n: nil
        )
    }

    // MARK: - Preview Support

    #if DEBUG
    static var preview: SavedRoutineModel {
        SavedRoutineModel(
            templateId: UUID(),
            title: "Preview Routine",
            description: "A sample routine for previews",
            category: .all,
            stepCount: 3,
            duration: "5-10 min",
            difficulty: .beginner,
            tags: ["preview"],
            morningSteps: ["Cleanser", "Moisturizer", "Sunscreen"],
            eveningSteps: ["Cleanser", "Serum", "Moisturizer"],
            benefits: ["Sample benefit"],
            isFeatured: false,
            isPremium: false,
            savedDate: Date(),
            isActive: true,
            stepDetails: [
                SavedStepDetailModel(
                    title: "Gentle Cleanser",
                    stepDescription: "Sample cleanser",
                    stepType: ProductType.cleanser.rawValue,
                    timeOfDay: "morning",
                    why: "Cleans your skin",
                    how: "Apply and rinse",
                    order: 0
                ),
                SavedStepDetailModel(
                    title: "Moisturizer",
                    stepDescription: "Sample moisturizer",
                    stepType: ProductType.moisturizer.rawValue,
                    timeOfDay: "morning",
                    why: "Hydrates your skin",
                    how: "Apply to face",
                    order: 1
                )
            ],
            adaptationEnabled: false,
            adaptationType: nil,
            adaptationTypes: nil,
            imageName: "routine-minimalist",
            translations: nil
        )
    }
    #endif
}
