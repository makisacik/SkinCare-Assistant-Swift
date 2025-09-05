//
//  EditableRoutineModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Editable Routine Models

/// Represents an editable version of a routine step with all customization options
struct EditableRoutineStep: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var iconName: String
    var stepType: StepType
    var timeOfDay: TimeOfDay
    var why: String
    var how: String
    
    // Editing properties
    var isEnabled: Bool
    var frequency: StepFrequency
    var customInstructions: String?
    var isLocked: Bool // For AI-recommended steps that shouldn't be easily removed
    var originalStep: Bool // Whether this was in the original AI routine
    
    // Order and timing
    var order: Int
    var morningEnabled: Bool
    var eveningEnabled: Bool
    
    /// Convert to new SlotType for forward compatibility
    var slotType: SlotType {
        return stepType.toSlotType()
    }
    init(from apiStep: APIRoutineStep, timeOfDay: TimeOfDay, order: Int) {
        self.id = "\(timeOfDay.rawValue)_\(apiStep.name.replacingOccurrences(of: " ", with: "_"))"
        self.title = apiStep.name
        self.description = "\(apiStep.why) - \(apiStep.how)"
        self.iconName = iconNameForStepType(apiStep.step)
        self.stepType = apiStep.step
        self.timeOfDay = timeOfDay
        self.why = apiStep.why
        self.how = apiStep.how
        self.isEnabled = true
        self.frequency = .daily
        self.customInstructions = nil
        self.isLocked = isStepTypeLocked(apiStep.step)
        self.originalStep = true
        self.order = order
        self.morningEnabled = timeOfDay == .morning
        self.eveningEnabled = timeOfDay == .evening
    }
    
    init(id: String, title: String, description: String, iconName: String, stepType: StepType, timeOfDay: TimeOfDay, why: String, how: String, isEnabled: Bool = true, frequency: StepFrequency = .daily, customInstructions: String? = nil, isLocked: Bool = false, originalStep: Bool = false, order: Int, morningEnabled: Bool, eveningEnabled: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.stepType = stepType
        self.timeOfDay = timeOfDay
        self.why = why
        self.how = how
        self.isEnabled = isEnabled
        self.frequency = frequency
        self.customInstructions = customInstructions
        self.isLocked = isLocked
        self.originalStep = originalStep
        self.order = order
        self.morningEnabled = morningEnabled
        self.eveningEnabled = eveningEnabled
    }
}

/// Frequency options for routine steps
enum StepFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case everyOtherDay = "every_other_day"
    case twiceWeekly = "twice_weekly"
    case weekly = "weekly"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .everyOtherDay:
            return "Every other day"
        case .twiceWeekly:
            return "2x per week"
        case .weekly:
            return "Weekly"
        case .custom:
            return "Custom"
        }
    }
    
    var description: String {
        switch self {
        case .daily:
            return "Use every day"
        case .everyOtherDay:
            return "Use every other day"
        case .twiceWeekly:
            return "Use twice per week"
        case .weekly:
            return "Use once per week"
        case .custom:
            return "Set custom frequency"
        }
    }
}

/// Represents a complete editable routine with all customization options
struct EditableRoutine: Codable {
    var morningSteps: [EditableRoutineStep]
    var eveningSteps: [EditableRoutineStep]
    var weeklySteps: [EditableRoutineStep]
    
    // Metadata
    var originalRoutine: RoutineResponse?
    var lastModified: Date
    var isCustomized: Bool
    
    init(from routine: RoutineResponse) {
        self.morningSteps = routine.routine.morning.enumerated().map { index, step in
            EditableRoutineStep(from: step, timeOfDay: .morning, order: index)
        }
        self.eveningSteps = routine.routine.evening.enumerated().map { index, step in
            EditableRoutineStep(from: step, timeOfDay: .evening, order: index)
        }
        self.weeklySteps = (routine.routine.weekly ?? []).enumerated().map { index, step in
            EditableRoutineStep(from: step, timeOfDay: .weekly, order: index)
        }
        self.originalRoutine = routine
        self.lastModified = Date()
        self.isCustomized = false
    }
    
    init(morningSteps: [EditableRoutineStep] = [], eveningSteps: [EditableRoutineStep] = [], weeklySteps: [EditableRoutineStep] = [], originalRoutine: RoutineResponse? = nil, lastModified: Date = Date(), isCustomized: Bool = false) {
        self.morningSteps = morningSteps
        self.eveningSteps = eveningSteps
        self.weeklySteps = weeklySteps
        self.originalRoutine = originalRoutine
        self.lastModified = lastModified
        self.isCustomized = isCustomized
    }
    
    /// Get all steps for a specific time of day
    func steps(for timeOfDay: TimeOfDay) -> [EditableRoutineStep] {
        switch timeOfDay {
        case .morning:
            return morningSteps.sorted { $0.order < $1.order }
        case .evening:
            return eveningSteps.sorted { $0.order < $1.order }
        case .weekly:
            return weeklySteps.sorted { $0.order < $1.order }
        }
    }
    
    /// Get all enabled steps for a specific time of day
    func enabledSteps(for timeOfDay: TimeOfDay) -> [EditableRoutineStep] {
        return steps(for: timeOfDay).filter { $0.isEnabled }
    }
    
    /// Update steps for a specific time of day
    mutating func updateSteps(_ steps: [EditableRoutineStep], for timeOfDay: TimeOfDay) {
        switch timeOfDay {
        case .morning:
            self.morningSteps = steps
        case .evening:
            self.eveningSteps = steps
        case .weekly:
            self.weeklySteps = steps
        }
        self.lastModified = Date()
        self.isCustomized = true
    }
    
    /// Add a new step
    mutating func addStep(_ step: EditableRoutineStep) {
        switch step.timeOfDay {
        case .morning:
            self.morningSteps.append(step)
        case .evening:
            self.eveningSteps.append(step)
        case .weekly:
            self.weeklySteps.append(step)
        }
        self.lastModified = Date()
        self.isCustomized = true
    }
    
    /// Remove a step by ID
    mutating func removeStep(withId id: String) {
        morningSteps.removeAll { $0.id == id }
        eveningSteps.removeAll { $0.id == id }
        weeklySteps.removeAll { $0.id == id }
        self.lastModified = Date()
        self.isCustomized = true
    }
    
    /// Update a step
    mutating func updateStep(_ updatedStep: EditableRoutineStep) {
        let timeOfDay = updatedStep.timeOfDay
        
        switch timeOfDay {
        case .morning:
            if let index = morningSteps.firstIndex(where: { $0.id == updatedStep.id }) {
                morningSteps[index] = updatedStep
            }
        case .evening:
            if let index = eveningSteps.firstIndex(where: { $0.id == updatedStep.id }) {
                eveningSteps[index] = updatedStep
            }
        case .weekly:
            if let index = weeklySteps.firstIndex(where: { $0.id == updatedStep.id }) {
                weeklySteps[index] = updatedStep
            }
        }
        self.lastModified = Date()
        self.isCustomized = true
    }
}

/// AI Coach message types
enum CoachMessageType: String, CaseIterable {
    case warning = "warning"
    case suggestion = "suggestion"
    case information = "information"
    case encouragement = "encouragement"
    
    var iconName: String {
        switch self {
        case .warning:
            return "exclamationmark.triangle.fill"
        case .suggestion:
            return "lightbulb.fill"
        case .information:
            return "info.circle.fill"
        case .encouragement:
            return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .warning:
            return .orange
        case .suggestion:
            return .yellow
        case .information:
            return .blue
        case .encouragement:
            return .pink
        }
    }
}

/// AI Coach message for routine editing
struct CoachMessage: Identifiable {
    let id = UUID()
    let type: CoachMessageType
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(type: CoachMessageType, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}

/// Step modification action
enum StepModificationAction {
    case remove
    case swap(StepType)
    case reorder(Int)
    case toggleEnabled
    case changeFrequency(StepFrequency)
    case addCustomInstructions(String)
    case toggleTimeOfDay(TimeOfDay)
}

/// Routine editing state
enum RoutineEditingState {
    case viewing
    case editing
    case previewing
    case saving
}

// MARK: - Helper Functions

private func iconNameForStepType(_ stepType: StepType) -> String {
    switch stepType {
    case .cleanser:
        return "drop.fill"
    case .treatment:
        return "star.fill"
    case .moisturizer:
        return "drop.circle.fill"
    case .sunscreen:
        return "sun.max.fill"
    case .optional:
        return "plus.circle.fill"
    }
}

private func isStepTypeLocked(_ stepType: StepType) -> Bool {
    // Lock essential steps that shouldn't be easily removed
    switch stepType {
    case .cleanser, .sunscreen:
        return true
    case .treatment, .moisturizer, .optional:
        return false
    }
}

// MARK: - Extensions

extension EditableRoutineStep {
    /// Create a copy with updated properties
    func copy(
        title: String? = nil,
        description: String? = nil,
        iconName: String? = nil,
        stepType: StepType? = nil,
        timeOfDay: TimeOfDay? = nil,
        why: String? = nil,
        how: String? = nil,
        isEnabled: Bool? = nil,
        frequency: StepFrequency? = nil,
        customInstructions: String? = nil,
        isLocked: Bool? = nil,
        originalStep: Bool? = nil,
        order: Int? = nil,
        morningEnabled: Bool? = nil,
        eveningEnabled: Bool? = nil
    ) -> EditableRoutineStep {
        return EditableRoutineStep(
            id: self.id,
            title: title ?? self.title,
            description: description ?? self.description,
            iconName: iconName ?? self.iconName,
            stepType: stepType ?? self.stepType,
            timeOfDay: timeOfDay ?? self.timeOfDay,
            why: why ?? self.why,
            how: how ?? self.how,
            isEnabled: isEnabled ?? self.isEnabled,
            frequency: frequency ?? self.frequency,
            customInstructions: customInstructions ?? self.customInstructions,
            isLocked: isLocked ?? self.isLocked,
            originalStep: originalStep ?? self.originalStep,
            order: order ?? self.order,
            morningEnabled: morningEnabled ?? self.morningEnabled,
            eveningEnabled: eveningEnabled ?? self.eveningEnabled
        )
    }
    
    /// Get display name for step type
    var stepTypeDisplayName: String {
        switch stepType {
        case .cleanser:
            return "Cleanser"
        case .treatment:
            return "Treatment"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen"
        case .optional:
            return "Optional"
        }
    }
    
    /// Get color for step type
    var stepTypeColor: Color {
        switch stepType {
        case .cleanser:
            return .blue
        case .treatment:
            return .purple
        case .moisturizer:
            return .green
        case .sunscreen:
            return .yellow
        case .optional:
            return .orange
        }
    }
}
