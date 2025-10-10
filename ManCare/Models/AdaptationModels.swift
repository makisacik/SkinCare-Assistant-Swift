//
//  AdaptationModels.swift
//  ManCare
//
//  Created for routine adaptation system
//

import Foundation
import SwiftUI

// MARK: - Adaptation Type

enum AdaptationType: String, Codable, CaseIterable {
    case cycle      // Menstruation cycle-based
    case seasonal   // Future: weather/season based
    case skinState  // Future: real-time skin condition
    
    var displayName: String {
        switch self {
        case .cycle:
            return "Cycle Tracking"
        case .seasonal:
            return "Seasonal"
        case .skinState:
            return "Skin State"
        }
    }
    
    var description: String {
        switch self {
        case .cycle:
            return "Adapt routine based on your menstruation cycle phase"
        case .seasonal:
            return "Adapt routine based on weather and season"
        case .skinState:
            return "Adapt routine based on current skin condition"
        }
    }
}

// MARK: - Step Emphasis

enum StepEmphasis: String, Codable {
    case skip       // Don't do this step
    case reduce     // Use less / lighter application
    case normal     // Standard application
    case emphasize  // Focus on this / use more
    
    var displayName: String {
        switch self {
        case .skip:
            return "Skip"
        case .reduce:
            return "Reduce"
        case .normal:
            return "Normal"
        case .emphasize:
            return "Emphasize"
        }
    }
    
    var icon: String {
        switch self {
        case .skip:
            return "xmark.circle.fill"
        case .reduce:
            return "arrow.down.circle.fill"
        case .normal:
            return "checkmark.circle.fill"
        case .emphasize:
            return "arrow.up.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .skip:
            return ThemeManager.shared.theme.palette.error
        case .reduce:
            return ThemeManager.shared.theme.palette.warning
        case .normal:
            return ThemeManager.shared.theme.palette.textMuted
        case .emphasize:
            return ThemeManager.shared.theme.palette.secondaryLight
        }
    }
}

// MARK: - Adaptation Origin

enum AdaptationOrigin: String, Codable {
    case `default`  // Built-in rule set
    case gpt        // AI-recommended
    case user       // User customized
    
    var displayName: String {
        switch self {
        case .default:
            return "Default"
        case .gpt:
            return "AI Recommended"
        case .user:
            return "Custom"
        }
    }
    
    var icon: String {
        switch self {
        case .default:
            return "book.fill"
        case .gpt:
            return "sparkles"
        case .user:
            return "person.fill"
        }
    }
}

// MARK: - Step Adaptation

struct StepAdaptation: Codable, Equatable {
    let stepId: UUID
    let contextKey: String  // e.g., "menstrual", "follicular", "winter"
    let emphasis: StepEmphasis
    let guidance: String?
    let orderOverride: Int?
    let warnings: [String]
    let origin: AdaptationOrigin
    
    init(stepId: UUID, contextKey: String, emphasis: StepEmphasis, guidance: String? = nil, orderOverride: Int? = nil, warnings: [String] = [], origin: AdaptationOrigin = .default) {
        self.stepId = stepId
        self.contextKey = contextKey
        self.emphasis = emphasis
        self.guidance = guidance
        self.orderOverride = orderOverride
        self.warnings = warnings
        self.origin = origin
    }
}

// MARK: - Adaptation Rule

struct AdaptationRule: Codable, Identifiable, Equatable {
    let id: String
    let productType: String  // ProductType rawValue
    let contextKey: String   // e.g., "menstrual", "luteal"
    let action: RuleAction
    
    init(id: String, productType: String, contextKey: String, action: RuleAction) {
        self.id = id
        self.productType = productType
        self.contextKey = contextKey
        self.action = action
    }
}

// MARK: - Rule Action

struct RuleAction: Codable, Equatable {
    let emphasis: StepEmphasis
    let guidanceTemplate: String?
    let orderPriority: Int?
    let warnings: [String]
    
    init(emphasis: StepEmphasis, guidanceTemplate: String? = nil, orderPriority: Int? = nil, warnings: [String] = []) {
        self.emphasis = emphasis
        self.guidanceTemplate = guidanceTemplate
        self.orderPriority = orderPriority
        self.warnings = warnings
    }
}

// MARK: - Adaptation Rule Set

struct AdaptationRuleSet: Codable {
    let type: AdaptationType
    let version: String
    let rules: [AdaptationRule]
    let briefings: [PhaseBriefing]
    
    init(type: AdaptationType, version: String, rules: [AdaptationRule], briefings: [PhaseBriefing]) {
        self.type = type
        self.version = version
        self.rules = rules
        self.briefings = briefings
    }
}

// MARK: - Phase Briefing

struct PhaseBriefing: Codable, Equatable {
    let contextKey: String
    let title: String
    let summary: String
    let tips: [String]
    let generalWarnings: [String]
    
    init(contextKey: String, title: String, summary: String, tips: [String] = [], generalWarnings: [String] = []) {
        self.contextKey = contextKey
        self.title = title
        self.summary = summary
        self.tips = tips
        self.generalWarnings = generalWarnings
    }
}

// MARK: - Adapted Step Detail

struct AdaptedStepDetail: Identifiable, Equatable {
    let baseStep: SavedStepDetailModel
    let adaptation: StepAdaptation?
    let displayOrder: Int
    
    var id: UUID { baseStep.id }
    
    var shouldShow: Bool { adaptation?.emphasis != .skip }
    var emphasisLevel: StepEmphasis { adaptation?.emphasis ?? .normal }
    var guidanceText: String { adaptation?.guidance ?? baseStep.how ?? "" }
    
    init(baseStep: SavedStepDetailModel, adaptation: StepAdaptation? = nil, displayOrder: Int? = nil) {
        self.baseStep = baseStep
        self.adaptation = adaptation
        self.displayOrder = displayOrder ?? baseStep.order
    }
}

// MARK: - Routine Snapshot

struct RoutineSnapshot: Equatable {
    let baseRoutine: SavedRoutineModel
    let contextKey: String  // Current phase/season/state
    let date: Date
    let adaptedSteps: [AdaptedStepDetail]
    let briefing: PhaseBriefing
    
    init(baseRoutine: SavedRoutineModel, contextKey: String, date: Date, adaptedSteps: [AdaptedStepDetail], briefing: PhaseBriefing) {
        self.baseRoutine = baseRoutine
        self.contextKey = contextKey
        self.date = date
        self.adaptedSteps = adaptedSteps
        self.briefing = briefing
    }
    
    var morningSteps: [AdaptedStepDetail] {
        adaptedSteps.filter { $0.baseStep.timeOfDayEnum == .morning }.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    var eveningSteps: [AdaptedStepDetail] {
        adaptedSteps.filter { $0.baseStep.timeOfDayEnum == .evening }.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    var weeklySteps: [AdaptedStepDetail] {
        adaptedSteps.filter { $0.baseStep.timeOfDayEnum == .weekly }.sorted { $0.displayOrder < $1.displayOrder }
    }
}

// MARK: - Routine Adaptation Attachment (Optional custom rules per routine)

struct RoutineAdaptationAttachment: Codable, Equatable {
    let routineId: UUID
    let type: AdaptationType
    let customRules: [AdaptationRule]?
    let lastUpdated: Date
    
    init(routineId: UUID, type: AdaptationType, customRules: [AdaptationRule]? = nil, lastUpdated: Date = Date()) {
        self.routineId = routineId
        self.type = type
        self.customRules = customRules
        self.lastUpdated = lastUpdated
    }
}

