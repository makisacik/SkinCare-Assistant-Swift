//
//  RoutineEditingService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

@MainActor
class RoutineEditingService: ObservableObject {
    @Published var editableRoutine: EditableRoutine
    @Published var coachMessages: [CoachMessage] = []
    @Published var editingState: RoutineEditingState = .viewing
    @Published var showingPreview = false
    
    private let routineTrackingService: RoutineTrackingService
    private let persistenceController = PersistenceController.shared
    
    init(originalRoutine: RoutineResponse?, routineTrackingService: RoutineTrackingService) {
        if let routine = originalRoutine {
            self.editableRoutine = EditableRoutine(from: routine)
        } else {
            // Create empty routine for preview/testing
            self.editableRoutine = EditableRoutine()
        }
        self.routineTrackingService = routineTrackingService
    }
    
    // MARK: - Public Methods
    
    /// Start editing mode
    func startEditing() {
        editingState = .editing
        coachMessages.removeAll()
    }
    
    /// Cancel editing and revert to original
    func cancelEditing() {
        if let original = editableRoutine.originalRoutine {
            editableRoutine = EditableRoutine(from: original)
        }
        editingState = .viewing
        coachMessages.removeAll()
    }
    
    /// Save the edited routine
    func saveRoutine() async {
        editingState = .saving
        
        // Save to UserDefaults for now (in a real app, you might save to Core Data)
        do {
            let data = try JSONEncoder().encode(editableRoutine)
            UserDefaults.standard.set(data, forKey: "customized_routine")
            
            // Update routine tracking service with new step IDs if needed
            await updateRoutineTracking()
            
            editingState = .viewing
            showingPreview = false
        } catch {
            print("Error saving routine: \(error)")
            editingState = .editing
        }
    }
    
    /// Show preview of changes
    func showPreview() {
        editingState = .previewing
        showingPreview = true
    }
    
    /// Toggle step enabled/disabled
    func toggleStep(_ step: EditableRoutineStep) {
        let updatedStep = step.copy(isEnabled: !step.isEnabled)
        editableRoutine.updateStep(updatedStep)
        
        // Generate coach message if removing an important step
        if !step.isEnabled && step.isLocked {
            generateCoachMessageForStepRemoval(step)
        }
    }
    
    /// Remove a step
    func removeStep(_ step: EditableRoutineStep) {
        // Generate coach message before removal
        generateCoachMessageForStepRemoval(step)
        
        editableRoutine.removeStep(withId: step.id)
    }
    
    /// Swap step type
    func swapStepType(_ step: EditableRoutineStep, newType: StepType) {
        let newTitle = getDefaultTitle(for: newType)
        let newDescription = getDefaultDescription(for: newType)
        let newIconName = iconNameForStepType(newType)
        let newWhy = getDefaultWhy(for: newType)
        let newHow = getDefaultHow(for: newType)
        
        let updatedStep = step.copy(
            title: newTitle,
            description: newDescription,
            iconName: newIconName,
            stepType: newType,
            why: newWhy,
            how: newHow,
            originalStep: false
        )
        
        editableRoutine.updateStep(updatedStep)
        generateCoachMessageForStepSwap(step, newType: newType)
    }
    
    /// Reorder steps
    func reorderSteps(_ steps: [EditableRoutineStep], for timeOfDay: TimeOfDay) {
        var reorderedSteps = steps
        for (index, step) in reorderedSteps.enumerated() {
            reorderedSteps[index] = step.copy(order: index)
        }
        editableRoutine.updateSteps(reorderedSteps, for: timeOfDay)
    }
    
    /// Update step frequency
    func updateStepFrequency(_ step: EditableRoutineStep, frequency: StepFrequency) {
        let updatedStep = step.copy(frequency: frequency)
        editableRoutine.updateStep(updatedStep)
        
        if frequency == .custom {
            generateCoachMessageForCustomFrequency(step)
        }
    }
    
    /// Add custom instructions
    func addCustomInstructions(_ step: EditableRoutineStep, instructions: String) {
        let updatedStep = step.copy(customInstructions: instructions)
        editableRoutine.updateStep(updatedStep)
    }
    
    /// Toggle time of day for a step
    func toggleTimeOfDay(_ step: EditableRoutineStep, timeOfDay: TimeOfDay) {
        var updatedStep = step
        switch timeOfDay {
        case .morning:
            updatedStep = step.copy(morningEnabled: !step.morningEnabled)
        case .evening:
            updatedStep = step.copy(eveningEnabled: !step.eveningEnabled)
        case .weekly:
            // Weekly steps are handled differently
            break
        }
        editableRoutine.updateStep(updatedStep)
    }
    
    /// Add a new step
    func addNewStep(type: StepType, timeOfDay: TimeOfDay) {
        let newStep = createNewStep(type: type, timeOfDay: timeOfDay)
        editableRoutine.addStep(newStep)
        generateCoachMessageForNewStep(newStep)
    }
    
    /// Get available step types for swapping
    func getAvailableStepTypes(excluding currentType: StepType) -> [StepType] {
        return StepType.allCases.filter { $0 != currentType }
    }
    
    /// Clear all coach messages
    func clearCoachMessages() {
        coachMessages.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func updateRoutineTracking() async {
        // Update routine tracking service with new step configurations
        // This would involve updating the step IDs and configurations
        // in the tracking service to match the edited routine
    }
    
    private func generateCoachMessageForStepRemoval(_ step: EditableRoutineStep) {
        let message: CoachMessage
        
        switch step.stepType {
        case .cleanser:
            message = CoachMessage(
                type: .warning,
                title: "Removing Cleanser",
                message: "Cleansing is essential for removing dirt, oil, and makeup. Without it, your other products may not work effectively.",
                actionTitle: "Keep Cleanser",
                action: {
                    self.toggleStep(step)
                }
            )
        case .sunscreen:
            message = CoachMessage(
                type: .warning,
                title: "Removing Sunscreen",
                message: "Sunscreen is crucial for preventing sun damage and premature aging. Consider keeping it for daily protection.",
                actionTitle: "Keep Sunscreen",
                action: {
                    self.toggleStep(step)
                }
            )
        case .moisturizer:
            message = CoachMessage(
                type: .suggestion,
                title: "Removing Moisturizer",
                message: "Moisturizer helps maintain skin hydration. Without it, your skin may feel dry. Consider a lighter gel option instead.",
                actionTitle: "Swap to Gel",
                action: {
                    self.swapStepType(step, newType: .treatment)
                }
            )
        case .treatment:
            message = CoachMessage(
                type: .information,
                title: "Removing Treatment",
                message: "This treatment was recommended for your specific concerns. You can always add it back later if needed.",
                actionTitle: nil,
                action: nil
            )
        case .optional:
            message = CoachMessage(
                type: .information,
                title: "Removing Optional Step",
                message: "This step is optional and can be safely removed without affecting your core routine.",
                actionTitle: nil,
                action: nil
            )
        }
        
        coachMessages.append(message)
    }
    
    private func generateCoachMessageForStepSwap(_ step: EditableRoutineStep, newType: StepType) {
        let message: CoachMessage
        
        switch (step.stepType, newType) {
        case (.moisturizer, .treatment):
            message = CoachMessage(
                type: .suggestion,
                title: "Swapped to Treatment",
                message: "You've replaced moisturizer with a treatment. Make sure to add hydration back with a lightweight moisturizer or serum.",
                actionTitle: "Add Hydration",
                action: {
                    self.addNewStep(type: .moisturizer, timeOfDay: step.timeOfDay)
                }
            )
        case (.treatment, .moisturizer):
            message = CoachMessage(
                type: .suggestion,
                title: "Swapped to Moisturizer",
                message: "Good choice! Moisturizer provides essential hydration. Consider adding a treatment serum for targeted benefits.",
                actionTitle: "Add Treatment",
                action: {
                    self.addNewStep(type: .treatment, timeOfDay: step.timeOfDay)
                }
            )
        default:
            message = CoachMessage(
                type: .information,
                title: "Step Updated",
                message: "You've updated your routine step. The new configuration should work well with your skin type.",
                actionTitle: nil,
                action: nil
            )
        }
        
        coachMessages.append(message)
    }
    
    private func generateCoachMessageForCustomFrequency(_ step: EditableRoutineStep) {
        let message = CoachMessage(
            type: .suggestion,
            title: "Custom Frequency",
            message: "You've set a custom frequency for \(step.title). Consider starting with 2-3 times per week and adjusting based on how your skin responds.",
            actionTitle: "Set to 2x/Week",
            action: {
                self.updateStepFrequency(step, frequency: .twiceWeekly)
            }
        )
        
        coachMessages.append(message)
    }
    
    private func generateCoachMessageForNewStep(_ step: EditableRoutineStep) {
        let message: CoachMessage
        
        switch step.stepType {
        case .treatment:
            message = CoachMessage(
                type: .suggestion,
                title: "New Treatment Added",
                message: "You've added a new treatment. Start with 2-3 times per week to avoid irritation, then increase frequency as your skin adapts.",
                actionTitle: "Set Frequency",
                action: {
                    self.updateStepFrequency(step, frequency: .twiceWeekly)
                }
            )
        case .moisturizer:
            message = CoachMessage(
                type: .encouragement,
                title: "Hydration Added",
                message: "Great choice! Adding moisturizer will help keep your skin hydrated and healthy.",
                actionTitle: nil,
                action: nil
            )
        default:
            message = CoachMessage(
                type: .information,
                title: "New Step Added",
                message: "You've added a new step to your routine. Make sure to follow the application instructions for best results.",
                actionTitle: nil,
                action: nil
            )
        }
        
        coachMessages.append(message)
    }
    
    private func createNewStep(type: StepType, timeOfDay: TimeOfDay) -> EditableRoutineStep {
        let existingSteps = editableRoutine.steps(for: timeOfDay)
        let nextOrder = existingSteps.count
        
        return EditableRoutineStep(
            id: "\(timeOfDay.rawValue)_\(type.rawValue)_\(UUID().uuidString.prefix(8))",
            title: getDefaultTitle(for: type),
            description: getDefaultDescription(for: type),
            iconName: iconNameForStepType(type),
            stepType: type,
            timeOfDay: timeOfDay,
            why: getDefaultWhy(for: type),
            how: getDefaultHow(for: type),
            isEnabled: true,
            frequency: .daily,
            customInstructions: nil,
            isLocked: isStepTypeLocked(type),
            originalStep: false,
            order: nextOrder,
            morningEnabled: timeOfDay == .morning,
            eveningEnabled: timeOfDay == .evening
        )
    }
    
    private func getDefaultTitle(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Gentle Cleanser"
        case .treatment:
            return "Face Serum"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen SPF 30+"
        case .optional:
            return "Optional Treatment"
        }
    }
    
    private func getDefaultDescription(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Removes dirt, oil, and makeup without stripping skin"
        case .treatment:
            return "Targeted treatment for your specific skin concerns"
        case .moisturizer:
            return "Provides essential hydration and skin barrier support"
        case .sunscreen:
            return "Protects against UV damage and premature aging"
        case .optional:
            return "Additional treatment for enhanced results"
        }
    }
    
    private func getDefaultWhy(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Essential for removing daily buildup and preparing skin for other products"
        case .treatment:
            return "Provides targeted benefits for your specific skin concerns"
        case .moisturizer:
            return "Maintains skin hydration and supports the skin barrier"
        case .sunscreen:
            return "Prevents UV damage, premature aging, and skin cancer"
        case .optional:
            return "Provides additional benefits beyond your core routine"
        }
    }
    
    private func getDefaultHow(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Apply to damp skin, massage gently for 30 seconds, rinse thoroughly"
        case .treatment:
            return "Apply 2-3 drops to clean skin, pat gently until absorbed"
        case .moisturizer:
            return "Apply a pea-sized amount, massage in upward circular motions"
        case .sunscreen:
            return "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
        case .optional:
            return "Follow product instructions for best results"
        }
    }
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
    switch stepType {
    case .cleanser, .sunscreen:
        return true
    case .treatment, .moisturizer, .optional:
        return false
    }
}
