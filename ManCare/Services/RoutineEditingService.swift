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
        // Try to load saved routine first, then fall back to original or empty
        if let savedRoutine = Self.loadSavedRoutine() {
            self.editableRoutine = savedRoutine
        } else if let routine = originalRoutine {
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
    func saveRoutine() async -> RoutineResponse? {
        editingState = .saving
        
        // Save to UserDefaults for now (in a real app, you might save to Core Data)
        do {
            let data = try JSONEncoder().encode(editableRoutine)
            UserDefaults.standard.set(data, forKey: "customized_routine")
            
            // Update routine tracking service with new step IDs if needed
            await updateRoutineTracking()
            
            editingState = .viewing
            showingPreview = false
            
            // Return the updated routine converted back to RoutineResponse
            return editableRoutine.toRoutineResponse()
        } catch {
            print("Error saving routine: \(error)")
            editingState = .editing
            return nil
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
    func swapStepType(_ step: EditableRoutineStep, newType: ProductType) {
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
    
    /// Reorder two specific steps by swapping their positions
    func reorderSteps(draggedStepId: String, targetStepId: String) {
        // Find the dragged step and target step from all time periods
        var draggedStep: EditableRoutineStep?
        var targetStep: EditableRoutineStep?
        
        // Search in morning steps
        if draggedStep == nil {
            draggedStep = editableRoutine.morningSteps.first(where: { $0.id == draggedStepId })
        }
        if targetStep == nil {
            targetStep = editableRoutine.morningSteps.first(where: { $0.id == targetStepId })
        }
        
        // Search in evening steps
        if draggedStep == nil {
            draggedStep = editableRoutine.eveningSteps.first(where: { $0.id == draggedStepId })
        }
        if targetStep == nil {
            targetStep = editableRoutine.eveningSteps.first(where: { $0.id == targetStepId })
        }
        
        // Search in weekly steps
        if draggedStep == nil {
            draggedStep = editableRoutine.weeklySteps.first(where: { $0.id == draggedStepId })
        }
        if targetStep == nil {
            targetStep = editableRoutine.weeklySteps.first(where: { $0.id == targetStepId })
        }
        
        guard let dragged = draggedStep, let target = targetStep else {
            return
        }
        
        // Get all steps for the same time of day
        let timeOfDay = dragged.timeOfDay
        var steps = editableRoutine.steps(for: timeOfDay)
        
        // Find indices of the steps to swap
        guard let draggedIndex = steps.firstIndex(where: { $0.id == draggedStepId }),
              let targetIndex = steps.firstIndex(where: { $0.id == targetStepId }) else {
            return
        }
        
        // Swap the steps
        steps.swapAt(draggedIndex, targetIndex)
        
        // Update the order values
        for (index, step) in steps.enumerated() {
            steps[index] = step.copy(order: index)
        }
        
        // Update the routine
        editableRoutine.updateSteps(steps, for: timeOfDay)
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
    func addNewStep(type: ProductType, timeOfDay: TimeOfDay) {
        let newStep = createNewStep(type: type, timeOfDay: timeOfDay)
        editableRoutine.addStep(newStep)
        generateCoachMessageForNewStep(newStep)
    }
    
    /// Get available step types for swapping
    func getAvailableStepTypes(excluding currentType: ProductType) -> [ProductType] {
        return ProductType.allCases.filter { $0 != currentType }
    }
    
    /// Clear all coach messages
    func clearCoachMessages() {
        coachMessages.removeAll()
    }
    
    /// Attach a product to a step
    func attachProduct(_ product: Product, to step: EditableRoutineStep) {
        let updatedStep = step.copy(attachedProductId: product.id)
        editableRoutine.updateStep(updatedStep)
        generateCoachMessageForProductAttachment(step, product: product)
    }

    /// Detach product from a step
    func detachProduct(from step: EditableRoutineStep) {
        let updatedStep = step.copy(attachedProductId: nil)
        editableRoutine.updateStep(updatedStep)
    }

    /// Get compatible products for a step
    func getCompatibleProducts(for step: EditableRoutineStep) -> [Product] {
        return step.getCompatibleProducts(from: ProductService.shared)
    }

    /// Get attached product for a step
    func getAttachedProduct(for step: EditableRoutineStep) -> Product? {
        return step.getAttachedProduct(from: ProductService.shared)
    }
    
    // MARK: - Static Methods
    
    /// Load saved routine from UserDefaults
    static func loadSavedRoutine() -> EditableRoutine? {
        guard let data = UserDefaults.standard.data(forKey: "customized_routine") else {
            return nil
        }
        
        do {
            let routine = try JSONDecoder().decode(EditableRoutine.self, from: data)
            return routine
        } catch {
            print("Error loading saved routine: \(error)")
            return nil
        }
    }
    
    /// Check if there's a saved routine
    static func hasSavedRoutine() -> Bool {
        return UserDefaults.standard.data(forKey: "customized_routine") != nil
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
                    self.swapStepType(step, newType: .faceSerum)
                }
            )
        case .faceSerum:
            message = CoachMessage(
                type: .information,
                title: "Removing Treatment",
                message: "This treatment was recommended for your specific concerns. You can always add it back later if needed.",
                actionTitle: nil,
                action: nil
            )
        default:
            message = CoachMessage(
                type: .information,
                title: "Removing Step",
                message: "This step can be safely removed without affecting your core routine.",
                actionTitle: nil,
                action: nil
            )
        }
        
        coachMessages.append(message)
    }
    
    private func generateCoachMessageForStepSwap(_ step: EditableRoutineStep, newType: ProductType) {
        let message: CoachMessage
        
        switch (step.stepType, newType) {
        case (.moisturizer, .faceSerum):
            message = CoachMessage(
                type: .suggestion,
                title: "Swapped to Treatment",
                message: "You've replaced moisturizer with a treatment. Make sure to add hydration back with a lightweight moisturizer or serum.",
                actionTitle: "Add Hydration",
                action: {
                    self.addNewStep(type: .moisturizer, timeOfDay: step.timeOfDay)
                }
            )
        case (.faceSerum, .moisturizer):
            message = CoachMessage(
                type: .suggestion,
                title: "Swapped to Moisturizer",
                message: "Good choice! Moisturizer provides essential hydration. Consider adding a treatment serum for targeted benefits.",
                actionTitle: "Add Treatment",
                action: {
                    self.addNewStep(type: .faceSerum, timeOfDay: step.timeOfDay)
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
        case .faceSerum:
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
    
    private func createNewStep(type: ProductType, timeOfDay: TimeOfDay) -> EditableRoutineStep {
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
            eveningEnabled: timeOfDay == .evening,
            attachedProductId: nil,
            productConstraints: nil
        )
    }
    
    private func getDefaultTitle(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Gentle Cleanser"
        case .faceSerum:
            return "Face Serum"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen SPF 30+"
        default:
            return stepType.displayName
        }
    }
    
    private func getDefaultDescription(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Removes dirt, oil, and makeup without stripping skin"
        case .faceSerum:
            return "Targeted treatment for your specific skin concerns"
        case .moisturizer:
            return "Provides essential hydration and skin barrier support"
        case .sunscreen:
            return "Protects against UV damage and premature aging"
        default:
            return ""
        }
    }
    
    private func getDefaultWhy(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Essential for removing daily buildup and preparing skin for other products"
        case .faceSerum:
            return "Provides targeted benefits for your specific skin concerns"
        case .moisturizer:
            return "Maintains skin hydration and supports the skin barrier"
        case .sunscreen:
            return "Prevents UV damage, premature aging, and skin cancer"
        default:
            return ""
        }
    }
    
    private func getDefaultHow(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Apply to damp skin, massage gently for 30 seconds, rinse thoroughly"
        case .faceSerum:
            return "Apply 2-3 drops to clean skin, pat gently until absorbed"
        case .moisturizer:
            return "Apply a pea-sized amount, massage in upward circular motions"
        case .sunscreen:
            return "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
        default:
            return ""
        }
    }
    
    private func generateCoachMessageForProductAttachment(_ step: EditableRoutineStep, product: Product) {
        let message: CoachMessage

        // Check if product matches step type
        if product.tagging.productType == step.stepType {
            message = CoachMessage(
                type: .encouragement,
                title: "Perfect Match!",
                message: "Great choice! \(product.displayName) is a perfect match for your \(step.title) step.",
                actionTitle: nil,
                action: nil
            )
        } else {
            message = CoachMessage(
                type: .suggestion,
                title: "Product Type Mismatch",
                message: "\(product.displayName) is a \(product.tagging.productType.displayName), but this step is for \(step.stepType.displayName). Consider using a product that matches the step type.",
                actionTitle: "Find Compatible Product",
                action: {
                    // This would open a product selection view
                }
            )
        }

        coachMessages.append(message)
    }
}

// MARK: - Helper Functions

private func iconNameForStepType(_ stepType: ProductType) -> String {
    return stepType.iconName
}

private func isStepTypeLocked(_ stepType: ProductType) -> Bool {
    switch stepType {
    case .cleanser, .sunscreen, .faceSunscreen:
        return true
    default:
        return false
    }
}
