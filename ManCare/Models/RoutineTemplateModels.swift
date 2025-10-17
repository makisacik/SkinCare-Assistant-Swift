//
//  RoutineTemplateModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Routine Category

enum RoutineCategory: String, CaseIterable, Codable {
    case all = "all"
    case korean = "korean"
    case antiAging = "anti_aging"
    case acne = "acne"
    case minimalist = "minimalist"
    case sensitive = "sensitive"
    case oily = "oily"
    case dry = "dry"
    case combination = "combination"
    
    var title: String {
        return L10n.Templates.Category.title(self.rawValue)
    }
    
    var iconName: String {
        switch self {
        case .all: return "sparkles"
        case .korean: return "leaf.fill"
        case .antiAging: return "clock.fill"
        case .acne: return "target"
        case .minimalist: return "minus.circle.fill"
        case .sensitive: return "heart.fill"
        case .oily: return "drop.fill"
        case .dry: return "sun.max.fill"
        case .combination: return "circle.grid.2x2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return ThemeManager.shared.theme.palette.primary
        case .korean: return Color(red: 0.2, green: 0.8, blue: 0.3) // Green
        case .antiAging: return Color(red: 0.8, green: 0.4, blue: 0.8) // Purple
        case .acne: return Color(red: 0.9, green: 0.3, blue: 0.3) // Red
        case .minimalist: return Color(red: 0.3, green: 0.6, blue: 0.9) // Blue
        case .sensitive: return Color(red: 1.0, green: 0.6, blue: 0.8) // Pink
        case .oily: return Color(red: 0.4, green: 0.7, blue: 0.9) // Light Blue
        case .dry: return Color(red: 0.9, green: 0.7, blue: 0.3) // Orange
        case .combination: return Color(red: 0.6, green: 0.4, blue: 0.8) // Violet
        }
    }
    
    var description: String {
        return L10n.Templates.Category.description(self.rawValue)
    }
}

// MARK: - Template Routine Step

struct TemplateRoutineStep: Codable, Equatable {
    let title: String
    let why: String
    let how: String
    let translations: TemplateStepTranslations?

    init(title: String, why: String, how: String, translations: TemplateStepTranslations? = nil) {
        self.title = title
        self.why = why
        self.how = how
        self.translations = translations
    }
}

// MARK: - Template Translations

struct TemplateTranslations: Codable, Equatable {
    let title: [String: String]         // lang -> title
    let description: [String: String]   // lang -> description
    let benefits: [String: [String]]    // lang -> benefits array
    let tags: [String: [String]]        // lang -> tags array
}

struct TemplateStepTranslations: Codable, Equatable {
    let title: [String: String]    // lang -> title
    let why: [String: String]      // lang -> why
    let how: [String: String]      // lang -> how
}

// MARK: - Routine Template

struct RoutineTemplate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: RoutineCategory
    let duration: String
    let difficulty: Difficulty
    let tags: [String]
    let morningSteps: [TemplateRoutineStep]
    let eveningSteps: [TemplateRoutineStep]
    let benefits: [String]
    let isFeatured: Bool
    let isPremium: Bool
    let imageName: String
    let translations: TemplateTranslations?

    // Computed properties
    var stepCount: Int {
        return morningSteps.count + eveningSteps.count
    }

    // Computed property for backward compatibility
    var steps: [TemplateRoutineStep] {
        return morningSteps + eveningSteps
    }

    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var title: String {
            switch self {
            case .beginner: return L10n.Templates.Difficulty.beginner
            case .intermediate: return L10n.Templates.Difficulty.intermediate
            case .advanced: return L10n.Templates.Difficulty.advanced
            }
        }
        
        var color: Color {
            switch self {
            case .beginner: return Color.green
            case .intermediate: return Color.orange
            case .advanced: return Color.red
            }
        }
    }
}

// MARK: - Sample Data

extension RoutineTemplate {
    // Stable UUIDs for specific routines
    static let koreanGlassSkinId = UUID(uuidString: "A1111111-1111-1111-1111-111111111111")!
    static let acneClearId = UUID(uuidString: "A2222222-2222-2222-2222-222222222222")!
    static let antiAgingId = UUID(uuidString: "A3333333-3333-3333-3333-333333333333")!
    static let minimalistId = UUID(uuidString: "A4444444-4444-4444-4444-444444444444")!
    static let sensitiveId = UUID(uuidString: "A5555555-5555-5555-5555-555555555555")!
    static let oilyId = UUID(uuidString: "A6666666-6666-6666-6666-666666666666")!
    static let dryId = UUID(uuidString: "A7777777-7777-7777-7777-777777777777")!
    static let combinationId = UUID(uuidString: "A8888888-8888-8888-8888-888888888888")!
    static let advancedKoreanId = UUID(uuidString: "A9999999-9999-9999-9999-999999999999")!
    static let teenAcneId = UUID(uuidString: "AA111111-1111-1111-1111-111111111111")!
    static let matureSkinId = UUID(uuidString: "AB111111-1111-1111-1111-111111111111")!

    // Helper method to create localized step
    private static func localizedStep(routineId: String, timeOfDay: String, index: Int) -> TemplateRoutineStep {
        TemplateRoutineStep(
            title: L10n.Templates.Routine.stepTitle(routineId, timeOfDay: timeOfDay, index: index),
            why: L10n.Templates.Routine.stepWhy(routineId, timeOfDay: timeOfDay, index: index),
            how: L10n.Templates.Routine.stepHow(routineId, timeOfDay: timeOfDay, index: index)
        )
    }

    // Helper method to create localized tags
    private static func localizedTags(routineId: String, count: Int) -> [String] {
        (1...count).map { L10n.Templates.Routine.tag(routineId, index: $0) }
    }

    // Helper method to create localized benefits
    private static func localizedBenefits(routineId: String, count: Int) -> [String] {
        (1...count).map { L10n.Templates.Routine.benefit(routineId, index: $0) }
    }

    static let featuredRoutines: [RoutineTemplate] = [
        RoutineTemplate(
            id: koreanGlassSkinId,
            title: L10n.Templates.Routine.title("koreanGlassSkin"),
            description: L10n.Templates.Routine.description("koreanGlassSkin"),
            category: .korean,
            duration: L10n.Templates.Routine.duration("koreanGlassSkin"),
            difficulty: .intermediate,
            tags: localizedTags(routineId: "koreanGlassSkin", count: 4),
            morningSteps: [
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 5),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "morning", index: 6)
            ],
            eveningSteps: [
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 5),
                localizedStep(routineId: "koreanGlassSkin", timeOfDay: "evening", index: 6)
            ],
            benefits: localizedBenefits(routineId: "koreanGlassSkin", count: 4),
            isFeatured: true,
            isPremium: false,
            imageName: "routine-korean",
            translations: nil
        ),
        RoutineTemplate(
            id: acneClearId,
            title: L10n.Templates.Routine.title("acneClear"),
            description: L10n.Templates.Routine.description("acneClear"),
            category: .acne,
            duration: L10n.Templates.Routine.duration("acneClear"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "acneClear", count: 4),
            morningSteps: [
                localizedStep(routineId: "acneClear", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "acneClear", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "acneClear", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "acneClear", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "acneClear", timeOfDay: "morning", index: 5)
            ],
            eveningSteps: [
                localizedStep(routineId: "acneClear", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "acneClear", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "acneClear", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "acneClear", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "acneClear", timeOfDay: "evening", index: 5)
            ],
            benefits: localizedBenefits(routineId: "acneClear", count: 4),
            isFeatured: true,
            isPremium: false,
            imageName: "routine-acne",
            translations: nil
        ),
        RoutineTemplate(
            id: antiAgingId,
            title: L10n.Templates.Routine.title("antiAging"),
            description: L10n.Templates.Routine.description("antiAging"),
            category: .antiAging,
            duration: L10n.Templates.Routine.duration("antiAging"),
            difficulty: .intermediate,
            tags: localizedTags(routineId: "antiAging", count: 4),
            morningSteps: [
                localizedStep(routineId: "antiAging", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "antiAging", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "antiAging", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "antiAging", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "antiAging", timeOfDay: "morning", index: 5)
            ],
            eveningSteps: [
                localizedStep(routineId: "antiAging", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "antiAging", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "antiAging", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "antiAging", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "antiAging", timeOfDay: "evening", index: 5)
            ],
            benefits: localizedBenefits(routineId: "antiAging", count: 4),
            isFeatured: true,
            isPremium: true,
            imageName: "routine-anti-aging",
            translations: nil
        )
    ]
    
    static let allRoutines: [RoutineTemplate] = featuredRoutines + [
        // Additional routines
        RoutineTemplate(
            id: minimalistId,
            title: L10n.Templates.Routine.title("minimalist"),
            description: L10n.Templates.Routine.description("minimalist"),
            category: .minimalist,
            duration: L10n.Templates.Routine.duration("minimalist"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "minimalist", count: 4),
            morningSteps: [
                localizedStep(routineId: "minimalist", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "minimalist", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "minimalist", timeOfDay: "morning", index: 3)
            ],
            eveningSteps: [
                localizedStep(routineId: "minimalist", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "minimalist", timeOfDay: "evening", index: 2)
            ],
            benefits: localizedBenefits(routineId: "minimalist", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist",
            translations: nil
        ),
        RoutineTemplate(
            id: sensitiveId,
            title: L10n.Templates.Routine.title("sensitive"),
            description: L10n.Templates.Routine.description("sensitive"),
            category: .sensitive,
            duration: L10n.Templates.Routine.duration("sensitive"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "sensitive", count: 4),
            morningSteps: [
                localizedStep(routineId: "sensitive", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "sensitive", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "sensitive", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "sensitive", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "sensitive", timeOfDay: "morning", index: 5)
            ],
            eveningSteps: [
                localizedStep(routineId: "sensitive", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "sensitive", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "sensitive", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "sensitive", timeOfDay: "evening", index: 4)
            ],
            benefits: localizedBenefits(routineId: "sensitive", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-sensitive",
            translations: nil
        ),
        RoutineTemplate(
            id: oilyId,
            title: L10n.Templates.Routine.title("oily"),
            description: L10n.Templates.Routine.description("oily"),
            category: .oily,
            duration: L10n.Templates.Routine.duration("oily"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "oily", count: 4),
            morningSteps: [
                localizedStep(routineId: "oily", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "oily", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "oily", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "oily", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "oily", timeOfDay: "morning", index: 5)
            ],
            eveningSteps: [
                localizedStep(routineId: "oily", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "oily", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "oily", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "oily", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "oily", timeOfDay: "evening", index: 5)
            ],
            benefits: localizedBenefits(routineId: "oily", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-oily",
            translations: nil
        ),
        RoutineTemplate(
            id: dryId,
            title: L10n.Templates.Routine.title("dry"),
            description: L10n.Templates.Routine.description("dry"),
            category: .dry,
            duration: L10n.Templates.Routine.duration("dry"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "dry", count: 4),
            morningSteps: [
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 5),
                localizedStep(routineId: "dry", timeOfDay: "morning", index: 6)
            ],
            eveningSteps: [
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 5),
                localizedStep(routineId: "dry", timeOfDay: "evening", index: 6)
            ],
            benefits: localizedBenefits(routineId: "dry", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-dry",
            translations: nil
        ),
        RoutineTemplate(
            id: combinationId,
            title: L10n.Templates.Routine.title("combination"),
            description: L10n.Templates.Routine.description("combination"),
            category: .combination,
            duration: L10n.Templates.Routine.duration("combination"),
            difficulty: .intermediate,
            tags: localizedTags(routineId: "combination", count: 4),
            morningSteps: [
                localizedStep(routineId: "combination", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "combination", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "combination", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "combination", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "combination", timeOfDay: "morning", index: 5)
            ],
            eveningSteps: [
                localizedStep(routineId: "combination", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "combination", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "combination", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "combination", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "combination", timeOfDay: "evening", index: 5)
            ],
            benefits: localizedBenefits(routineId: "combination", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-combination",
            translations: nil
        ),
        RoutineTemplate(
            id: advancedKoreanId,
            title: L10n.Templates.Routine.title("advancedKorean"),
            description: L10n.Templates.Routine.description("advancedKorean"),
            category: .korean,
            duration: L10n.Templates.Routine.duration("advancedKorean"),
            difficulty: .advanced,
            tags: localizedTags(routineId: "advancedKorean", count: 4),
            morningSteps: [
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 5),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 6),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 7),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 8),
                localizedStep(routineId: "advancedKorean", timeOfDay: "morning", index: 9)
            ],
            eveningSteps: [
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 5),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 6),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 7),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 8),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 9),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 10),
                localizedStep(routineId: "advancedKorean", timeOfDay: "evening", index: 11)
            ],
            benefits: localizedBenefits(routineId: "advancedKorean", count: 4),
            isFeatured: false,
            isPremium: true,
            imageName: "routine-advanced-korean",
            translations: nil
        ),
        RoutineTemplate(
            id: teenAcneId,
            title: L10n.Templates.Routine.title("teenAcne"),
            description: L10n.Templates.Routine.description("teenAcne"),
            category: .acne,
            duration: L10n.Templates.Routine.duration("teenAcne"),
            difficulty: .beginner,
            tags: localizedTags(routineId: "teenAcne", count: 4),
            morningSteps: [
                localizedStep(routineId: "teenAcne", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "teenAcne", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "teenAcne", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "teenAcne", timeOfDay: "morning", index: 4)
            ],
            eveningSteps: [
                localizedStep(routineId: "teenAcne", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "teenAcne", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "teenAcne", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "teenAcne", timeOfDay: "evening", index: 4)
            ],
            benefits: localizedBenefits(routineId: "teenAcne", count: 4),
            isFeatured: false,
            isPremium: false,
            imageName: "routine-acne",
            translations: nil
        ),
        RoutineTemplate(
            id: matureSkinId,
            title: L10n.Templates.Routine.title("matureSkin"),
            description: L10n.Templates.Routine.description("matureSkin"),
            category: .antiAging,
            duration: L10n.Templates.Routine.duration("matureSkin"),
            difficulty: .advanced,
            tags: localizedTags(routineId: "matureSkin", count: 4),
            morningSteps: [
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 1),
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 2),
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 3),
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 4),
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 5),
                localizedStep(routineId: "matureSkin", timeOfDay: "morning", index: 6)
            ],
            eveningSteps: [
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 1),
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 2),
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 3),
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 4),
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 5),
                localizedStep(routineId: "matureSkin", timeOfDay: "evening", index: 6)
            ],
            benefits: localizedBenefits(routineId: "matureSkin", count: 4),
            isFeatured: false,
            isPremium: true,
            imageName: "routine-mature",
            translations: nil
        )
    ]
}
