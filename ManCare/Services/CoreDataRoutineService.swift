//
//  CoreDataRoutineService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - Core Data Routine Service

class CoreDataRoutineService: ObservableObject {
    static let shared = CoreDataRoutineService()

    @Published var savedRoutines: [SavedRoutineModel] = []
    @Published var activeRoutine: SavedRoutineModel?

    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    private init() {
        loadSavedRoutines()
        loadActiveRoutine()
    }

    // MARK: - Public Methods

    func saveRoutine(_ template: RoutineTemplate) {
        // Check if routine is already saved
        if savedRoutines.contains(where: { $0.templateId == template.id }) {
            return
        }

        let savedRoutine = SavedRoutineModel(from: template)
        saveRoutineToCoreData(savedRoutine)
        loadSavedRoutines() // Refresh the published array
    }

    func removeRoutine(_ routine: SavedRoutineModel) {
        // Find and delete from Core Data
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

        do {
            let results = try viewContext.fetch(request)
            for savedRoutine in results {
                viewContext.delete(savedRoutine)
            }
            try viewContext.save()

            // If removing active routine, clear it
            if activeRoutine?.id == routine.id {
                activeRoutine = nil
                saveActiveRoutineToCoreData(nil)
            }

            loadSavedRoutines() // Refresh the published array
        } catch {
            print("❌ Error removing routine: \(error)")
        }
    }

    func setActiveRoutine(_ routine: SavedRoutineModel) {
        // Deactivate current active routine
        if let currentActive = activeRoutine {
            updateRoutineActiveStatus(currentActive.id, isActive: false)
        }

        // Set new active routine
        updateRoutineActiveStatus(routine.id, isActive: true)
        activeRoutine = routine
        saveActiveRoutineToCoreData(routine)
    }

    func isRoutineSaved(_ template: RoutineTemplate) -> Bool {
        return savedRoutines.contains { $0.templateId == template.id }
    }

    func getSavedRoutine(for template: RoutineTemplate) -> SavedRoutineModel? {
        return savedRoutines.first { $0.templateId == template.id }
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) {
        print("🔄 saveInitialRoutine called (Core Data)")
        print("📊 Current activeRoutine: \(activeRoutine?.title ?? "nil")")
        print("📊 Current savedRoutines count: \(savedRoutines.count)")

        // Create a custom saved routine directly from the onboarding response
        let morningSteps = routineResponse.routine.morning.map { $0.name }
        let eveningSteps = routineResponse.routine.evening.map { $0.name }
        let allSteps = morningSteps + eveningSteps

        print("📝 Morning steps: \(morningSteps)")
        print("📝 Evening steps: \(eveningSteps)")
        print("📝 Total steps: \(allSteps.count)")

        // Create step details from the routine response
        var stepDetails: [SavedStepDetailModel] = []
        var order = 0

        // Add morning steps
        for step in routineResponse.routine.morning {
            stepDetails.append(SavedStepDetailModel(
                title: step.name,
                stepDescription: "\(step.why) - \(step.how)",
                iconName: iconNameForStepType(step.step),
                stepType: step.step.rawValue,
                timeOfDay: "morning",
                why: step.why,
                how: step.how,
                order: order
            ))
            order += 1
        }

        // Add evening steps
        for step in routineResponse.routine.evening {
            stepDetails.append(SavedStepDetailModel(
                title: step.name,
                stepDescription: "\(step.why) - \(step.how)",
                iconName: iconNameForStepType(step.step),
                stepType: step.step.rawValue,
                timeOfDay: "evening",
                why: step.why,
                how: step.how,
                order: order
            ))
            order += 1
        }

        let initialRoutine = SavedRoutineModel(
            templateId: UUID(), // Generate new ID for custom routine
            title: "My First Routine",
            description: "Your personalized skincare routine created during onboarding",
            category: .all, // Default category
            stepCount: allSteps.count,
            duration: "10-15 min",
            difficulty: .beginner,
            tags: ["Personalized", "Onboarding", "Custom"],
            morningSteps: morningSteps,
            eveningSteps: eveningSteps,
            benefits: ["Personalized for your skin", "Based on your preferences", "Easy to follow"],
            isFeatured: false,
            isPremium: false,
            savedDate: Date(),
            isActive: true,
            stepDetails: stepDetails
        )

        print("✅ Created initialRoutine: \(initialRoutine.title)")

        // Check if we already have a "My First Routine" to avoid duplicates
        let existingFirstRoutine = savedRoutines.first { $0.title == "My First Routine" }

        if let existing = existingFirstRoutine {
            print("🔄 Updating existing 'My First Routine'")
            // Update the existing routine
            updateRoutineInCoreData(existing.id, with: initialRoutine)
            activeRoutine = initialRoutine
            saveActiveRoutineToCoreData(initialRoutine)
            print("✅ Updated existing routine and set as active")
        } else {
            print("💾 Saving new initial routine")
            // Deactivate current active routine if it exists
            if let currentActive = activeRoutine {
                updateRoutineActiveStatus(currentActive.id, isActive: false)
            }

            // Add new routine and set as active
            saveRoutineToCoreData(initialRoutine)
            activeRoutine = initialRoutine
            saveActiveRoutineToCoreData(initialRoutine)
            print("✅ New routine saved and set as active")
        }

        loadSavedRoutines() // Refresh the published array
        print("📊 Final savedRoutines count: \(savedRoutines.count)")
        print("📊 Final activeRoutine: \(activeRoutine?.title ?? "nil")")
        print("📊 All saved routine titles: \(savedRoutines.map { $0.title })")
    }

    // Debug method to clear all routines
    func clearAllRoutines() {
        print("🗑️ Clearing all routines (Core Data)")
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()

        do {
            let results = try viewContext.fetch(request)
            for savedRoutine in results {
                viewContext.delete(savedRoutine)
            }
            try viewContext.save()

            savedRoutines.removeAll()
            activeRoutine = nil
            saveActiveRoutineToCoreData(nil)
            print("✅ All routines cleared")
        } catch {
            print("❌ Error clearing routines: \(error)")
        }
    }

    // MARK: - Private Methods

    private func loadSavedRoutines() {
        print("📂 Loading saved routines from Core Data")
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRoutineEntity.savedDate, ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            savedRoutines = results.compactMap { SavedRoutineModel(from: $0) }
            print("✅ Loaded \(savedRoutines.count) routines from Core Data")
            print("📊 Loaded routine titles: \(savedRoutines.map { $0.title })")
        } catch {
            print("❌ Error loading routines: \(error)")
            savedRoutines = []
        }
    }

    private func loadActiveRoutine() {
        print("📂 Loading active routine from Core Data")
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.fetchLimit = 1

        do {
            let results = try viewContext.fetch(request)
            if let activeRoutineEntity = results.first {
                activeRoutine = SavedRoutineModel(from: activeRoutineEntity)
                print("✅ Loaded active routine: \(activeRoutine?.title ?? "nil")")
            } else {
                activeRoutine = nil
                print("📂 No active routine found")
            }
        } catch {
            print("❌ Error loading active routine: \(error)")
            activeRoutine = nil
        }
    }

    private func saveRoutineToCoreData(_ routine: SavedRoutineModel) {
        print("💾 Saving routine to Core Data: \(routine.title)")
        let savedRoutineEntity = SavedRoutineEntity(context: viewContext)

        savedRoutineEntity.id = routine.id
        savedRoutineEntity.templateId = routine.templateId
        savedRoutineEntity.title = routine.title
        savedRoutineEntity.routineDescription = routine.description
        savedRoutineEntity.category = routine.category.rawValue
        savedRoutineEntity.stepCount = Int16(routine.stepCount)
        savedRoutineEntity.duration = routine.duration
        savedRoutineEntity.difficulty = routine.difficulty.rawValue
        savedRoutineEntity.tags = routine.tags as NSObject
        savedRoutineEntity.steps = routine.steps as NSObject
        savedRoutineEntity.benefits = routine.benefits as NSObject
        savedRoutineEntity.isFeatured = routine.isFeatured
        savedRoutineEntity.isPremium = routine.isPremium
        savedRoutineEntity.savedDate = routine.savedDate
        savedRoutineEntity.isActive = routine.isActive

        // Save step details
        for stepDetail in routine.stepDetails {
            let stepEntity = SavedStepDetailEntity(context: viewContext)
            stepEntity.id = stepDetail.id
            stepEntity.title = stepDetail.title
            stepEntity.stepDescription = stepDetail.stepDescription
            stepEntity.iconName = stepDetail.iconName
            stepEntity.stepType = stepDetail.stepType
            stepEntity.timeOfDay = stepDetail.timeOfDay
            stepEntity.why = stepDetail.why
            stepEntity.how = stepDetail.how
            stepEntity.order = Int16(stepDetail.order)
            stepEntity.routine = savedRoutineEntity
        }

        do {
            try viewContext.save()
            print("✅ Successfully saved routine to Core Data")
        } catch {
            print("❌ Failed to save routine to Core Data: \(error)")
        }
    }

    private func updateRoutineInCoreData(_ routineId: UUID, with newRoutine: SavedRoutineModel) {
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", routineId as CVarArg)

        do {
            let results = try viewContext.fetch(request)
            if let savedRoutineEntity = results.first {
                savedRoutineEntity.title = newRoutine.title
                savedRoutineEntity.routineDescription = newRoutine.description
                savedRoutineEntity.category = newRoutine.category.rawValue
                savedRoutineEntity.stepCount = Int16(newRoutine.stepCount)
                savedRoutineEntity.duration = newRoutine.duration
                savedRoutineEntity.difficulty = newRoutine.difficulty.rawValue
                savedRoutineEntity.tags = newRoutine.tags as NSObject
                savedRoutineEntity.steps = newRoutine.steps as NSObject
                savedRoutineEntity.benefits = newRoutine.benefits as NSObject
                savedRoutineEntity.isFeatured = newRoutine.isFeatured
                savedRoutineEntity.isPremium = newRoutine.isPremium
                savedRoutineEntity.savedDate = newRoutine.savedDate
                savedRoutineEntity.isActive = newRoutine.isActive

                // Delete existing step details
                if let existingSteps = savedRoutineEntity.stepDetails as? Set<SavedStepDetailEntity> {
                    for step in existingSteps {
                        viewContext.delete(step)
                    }
                }

                // Add new step details
                for stepDetail in newRoutine.stepDetails {
                    let stepEntity = SavedStepDetailEntity(context: viewContext)
                    stepEntity.id = stepDetail.id
                    stepEntity.title = stepDetail.title
                    stepEntity.stepDescription = stepDetail.stepDescription
                    stepEntity.iconName = stepDetail.iconName
                    stepEntity.stepType = stepDetail.stepType
                    stepEntity.timeOfDay = stepDetail.timeOfDay
                    stepEntity.why = stepDetail.why
                    stepEntity.how = stepDetail.how
                    stepEntity.order = Int16(stepDetail.order)
                    stepEntity.routine = savedRoutineEntity
                }

                try viewContext.save()
                print("✅ Successfully updated routine in Core Data")
            }
        } catch {
            print("❌ Failed to update routine in Core Data: \(error)")
        }
    }

    private func updateRoutineActiveStatus(_ routineId: UUID, isActive: Bool) {
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", routineId as CVarArg)

        do {
            let results = try viewContext.fetch(request)
            if let savedRoutineEntity = results.first {
                savedRoutineEntity.isActive = isActive
                try viewContext.save()
                print("✅ Updated routine active status: \(isActive)")
            }
        } catch {
            print("❌ Failed to update routine active status: \(error)")
        }
    }

    private func saveActiveRoutineToCoreData(_ routine: SavedRoutineModel?) {
        // Store active routine ID in UserDefaults for now (could be moved to Core Data later)
        if let routine = routine {
            UserDefaults.standard.set(routine.id.uuidString, forKey: "activeRoutineId")
        } else {
            UserDefaults.standard.removeObject(forKey: "activeRoutineId")
        }
    }

    // MARK: - Helper Methods

    private func iconNameForStepType(_ stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "drop.fill"
        case .faceSerum:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen:
            return "sun.max.fill"
        default:
            return stepType.iconName
        }
    }
}

// MARK: - SavedStepDetailModel (Swift Model)

struct SavedStepDetailModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let stepDescription: String
    let iconName: String
    let stepType: String
    let timeOfDay: String
    let why: String?
    let how: String?
    let order: Int

    init(id: UUID = UUID(), title: String, stepDescription: String, iconName: String, stepType: String, timeOfDay: String, why: String? = nil, how: String? = nil, order: Int) {
        self.id = id
        self.title = title
        self.stepDescription = stepDescription
        self.iconName = iconName
        self.stepType = stepType
        self.timeOfDay = timeOfDay
        self.why = why
        self.how = how
        self.order = order
    }

    init(from entity: SavedStepDetailEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.stepDescription = entity.stepDescription ?? ""
        self.iconName = entity.iconName ?? ""
        self.stepType = entity.stepType ?? ""
        self.timeOfDay = entity.timeOfDay ?? ""
        self.why = entity.why
        self.how = entity.how
        self.order = Int(entity.order)
    }
}

// MARK: - SavedRoutineModel (Swift Model)

struct SavedRoutineModel: Identifiable, Codable {
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

    init(from template: RoutineTemplate, isActive: Bool = false) {
        self.id = UUID()
        self.templateId = template.id
        self.title = template.title
        self.description = template.description
        self.category = template.category
        self.stepCount = template.stepCount
        self.duration = template.duration
        self.difficulty = template.difficulty
        self.tags = template.tags
        self.morningSteps = template.morningSteps
        self.eveningSteps = template.eveningSteps
        self.benefits = template.benefits
        self.isFeatured = template.isFeatured
        self.isPremium = template.isPremium
        self.savedDate = Date()
        self.isActive = isActive
        // Create step details from template steps using ProductTypeDatabase
        var allStepDetails: [SavedStepDetailModel] = []

        // Add morning steps
        for (index, stepName) in template.morningSteps.enumerated() {
            let productInfo = ProductTypeDatabase.getInfo(for: stepName)
            allStepDetails.append(SavedStepDetailModel(
                title: productInfo.name,
                stepDescription: productInfo.description,
                iconName: productInfo.iconName,
                stepType: ProductTypeDatabase.getStepType(for: stepName),
                timeOfDay: "morning",
                why: productInfo.why,
                how: productInfo.how,
                order: index
            ))
        }

        // Add evening steps
        for (index, stepName) in template.eveningSteps.enumerated() {
            let productInfo = ProductTypeDatabase.getInfo(for: stepName)
            allStepDetails.append(SavedStepDetailModel(
                title: productInfo.name,
                stepDescription: productInfo.description,
                iconName: productInfo.iconName,
                stepType: ProductTypeDatabase.getStepType(for: stepName),
                timeOfDay: "evening",
                why: productInfo.why,
                how: productInfo.how,
                order: index + template.morningSteps.count
            ))
        }

        self.stepDetails = allStepDetails
    }

    init(templateId: UUID, title: String, description: String, category: RoutineCategory, stepCount: Int, duration: String, difficulty: RoutineTemplate.Difficulty, tags: [String], morningSteps: [String], eveningSteps: [String], benefits: [String], isFeatured: Bool, isPremium: Bool, savedDate: Date, isActive: Bool, stepDetails: [SavedStepDetailModel] = []) {
        self.id = UUID()
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
    }
}
