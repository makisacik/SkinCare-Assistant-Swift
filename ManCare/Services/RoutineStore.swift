//
//  RoutineStore.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 18.09.2025.
//

import Foundation
import CoreData

// MARK: - Store Errors

enum RoutineStoreError: Error {
    case routineNotFound
    case saveFailed
    case deleteFailed
    case invalidData
}

// MARK: - Store Protocol

protocol RoutineStoreProtocol: Sendable {
    func fetchSavedRoutines() async throws -> [SavedRoutineModel]
    func fetchActiveRoutine() async throws -> SavedRoutineModel?
    func saveRoutine(_ routine: SavedRoutineModel) async throws -> SavedRoutineModel
    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel
    func removeRoutine(_ routine: SavedRoutineModel) async throws
    func removeRoutineTemplate(_ template: RoutineTemplate) async throws
    func setActiveRoutine(_ routine: SavedRoutineModel) async throws
    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool

    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date) async throws
    func isStepCompleted(stepId: String, date: Date) async throws -> Bool
    func getCompletedSteps(for date: Date) async throws -> Set<String>
    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats]
    func getCurrentStreak() async throws -> Int
    func clearAllCompletions() async throws

    // Adaptation methods
    func updateAdaptationSettings(routineId: UUID, enabled: Bool, type: AdaptationType?) async throws
    func saveCustomRules(routineId: UUID, rules: [AdaptationRule]) async throws
    func fetchCustomRules(routineId: UUID) async throws -> [AdaptationRule]?
}

// MARK: - Store Actor Implementation

actor RoutineStore: RoutineStoreProtocol {
    private let persistenceController: PersistenceController
    private let backgroundContext: NSManagedObjectContext

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController

        self.backgroundContext = persistenceController.container.newBackgroundContext()
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        print("🏪 RoutineStore actor initialized with dedicated background context")
    }

    // MARK: - Core Data Context Access

    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    // MARK: - Routine Operations

    func fetchSavedRoutines() async throws -> [SavedRoutineModel] {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRoutineEntity.savedDate, ascending: false)]

                    let results = try self.backgroundContext.fetch(request)
                    let routines = results.compactMap { SavedRoutineModel(from: $0) }

                    continuation.resume(returning: routines)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchActiveRoutine() async throws -> SavedRoutineModel? {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "isActive == YES")
                    request.fetchLimit = 1

                    let results = try self.backgroundContext.fetch(request)
                    let activeRoutine = results.first.map { SavedRoutineModel(from: $0) }

                    continuation.resume(returning: activeRoutine)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveRoutine(_ routine: SavedRoutineModel) async throws -> SavedRoutineModel {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let savedRoutineEntity = SavedRoutineEntity(context: self.backgroundContext)
                    self.populateRoutineEntity(savedRoutineEntity, with: routine, in: self.backgroundContext)

                    try self.backgroundContext.save()
                    continuation.resume(returning: routine)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let initialRoutine = self.createInitialRoutineModel(from: routineResponse)

                    // Check if we already have a "My First Routine"
                    let existingRequest: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    existingRequest.predicate = NSPredicate(format: "title == %@", "My First Routine")

                    let existingResults = try self.backgroundContext.fetch(existingRequest)

                    if let existing = existingResults.first {
                        print("🔄 Updating existing 'My First Routine' (ID: \(existing.id?.uuidString ?? "nil"))")
                        self.populateRoutineEntity(existing, with: initialRoutine, in: self.backgroundContext)
                    } else {
                        print("✨ Creating new 'My First Routine'")
                        try self.deactivateAllRoutines(in: self.backgroundContext)
                        let newEntity = SavedRoutineEntity(context: self.backgroundContext)
                        self.populateRoutineEntity(newEntity, with: initialRoutine, in: self.backgroundContext)
                    }

                    // Update UserDefaults consistently
                    UserDefaults.standard.set(initialRoutine.id.uuidString, forKey: "activeRoutineId")

                    try self.backgroundContext.save()
                    continuation.resume(returning: initialRoutine)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func removeRoutine(_ routine: SavedRoutineModel) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

                    let results = try self.backgroundContext.fetch(request)

                    var wasActive = false
                    for savedRoutine in results {
                        if savedRoutine.isActive {
                            wasActive = true
                        }
                        self.backgroundContext.delete(savedRoutine)
                    }

                    if wasActive {
                        UserDefaults.standard.removeObject(forKey: "activeRoutineId")
                    }

                    try self.backgroundContext.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func removeRoutineTemplate(_ template: RoutineTemplate) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "templateId == %@", template.id as CVarArg)

                    let results = try self.backgroundContext.fetch(request)

                    var wasActive = false
                    for savedRoutine in results {
                        if savedRoutine.isActive {
                            wasActive = true
                        }
                        self.backgroundContext.delete(savedRoutine)
                    }

                    if wasActive {
                        UserDefaults.standard.removeObject(forKey: "activeRoutineId")
                    }

                    try self.backgroundContext.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func setActiveRoutine(_ routine: SavedRoutineModel) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    try self.deactivateAllRoutines(in: self.backgroundContext)

                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

                    let results = try self.backgroundContext.fetch(request)
                    if let routineEntity = results.first {
                        routineEntity.isActive = true
                        UserDefaults.standard.set(routine.id.uuidString, forKey: "activeRoutineId")
                    }

                    try self.backgroundContext.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "templateId == %@", template.id as CVarArg)
                    request.fetchLimit = 1

                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count > 0)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Tracking Operations

    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: date)

                    if let existingCompletion = self.getCompletionSync(stepId: stepId, date: startOfDay, in: self.backgroundContext) {
                        existingCompletion.isCompleted.toggle()
                        existingCompletion.createdAt = Date()
                    } else {
                        let completion = RoutineCompletion(context: self.backgroundContext)
                        completion.stepId = stepId
                        completion.stepTitle = stepTitle
                        completion.stepType = stepType.rawValue
                        completion.timeOfDay = timeOfDay.rawValue
                        completion.completionDate = startOfDay
                        completion.isCompleted = true
                        completion.createdAt = Date()
                    }

                    try self.backgroundContext.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func isStepCompleted(stepId: String, date: Date = Date()) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: date)

                    let completion = self.getCompletionSync(stepId: stepId, date: startOfDay, in: self.backgroundContext)
                    continuation.resume(returning: completion?.isCompleted ?? false)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getCompletedSteps(for date: Date = Date()) async throws -> Set<String> {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: date)

                    let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
                    request.predicate = NSPredicate(format: "completionDate == %@ AND isCompleted == YES", startOfDay as NSDate)

                    let completions = try self.backgroundContext.fetch(request)
                    let stepIds: Set<String> = Set(completions.compactMap { completion in
                        guard let stepId = completion.stepId, !stepId.isEmpty else { return nil }
                        return stepId
                    })

                    continuation.resume(returning: stepIds)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getCurrentStreak() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    var streak = 0
                    var currentDate = today

                    // Optimize: Single query for date range instead of daily queries
                    let endDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today

                    let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
                    request.predicate = NSPredicate(format: "completionDate >= %@ AND completionDate <= %@ AND isCompleted == YES",
                                                  endDate as NSDate, today as NSDate)

                    let completions = try self.backgroundContext.fetch(request)
                    let completionDates = Set(completions.compactMap { $0.completionDate })

                    // Count consecutive days
                    while completionDates.contains(currentDate) {
                        streak += 1
                        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    }

                    continuation.resume(returning: streak)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats] {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    var stats: [Date: CompletionStats] = [:]

                    let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
                    request.predicate = NSPredicate(format: "completionDate >= %@ AND completionDate <= %@",
                                                  calendar.startOfDay(for: startDate) as NSDate,
                                                  calendar.startOfDay(for: endDate) as NSDate)

                    let completions = try self.backgroundContext.fetch(request)

                    let groupedCompletions = Dictionary(grouping: completions) { completion in
                        guard let completionDate = completion.completionDate else { return Date() }
                        return calendar.startOfDay(for: completionDate)
                    }

                    for (date, dateCompletions) in groupedCompletions {
                        let completedCount = dateCompletions.filter { $0.isCompleted }.count
                        let totalCount = dateCompletions.count

                        stats[date] = CompletionStats(
                            date: date,
                            completedSteps: completedCount,
                            totalSteps: totalCount,
                            completionRate: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
                        )
                    }

                    continuation.resume(returning: stats)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func clearAllCompletions() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    // Use batch delete for efficiency
                    let request: NSFetchRequest<NSFetchRequestResult> = RoutineCompletion.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                    deleteRequest.resultType = .resultTypeObjectIDs

                    let result = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                    let objectIDArray = result?.result as? [NSManagedObjectID] ?? []

                    // Merge changes to main context
                    let changes = [NSDeletedObjectsKey: objectIDArray]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])

                    // Clear UserDefaults
                    UserDefaults.standard.removeObject(forKey: "activeRoutineId")

                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Private Helper Methods

    private func populateRoutineEntity(_ entity: SavedRoutineEntity, with routine: SavedRoutineModel, in context: NSManagedObjectContext) {
        entity.id = routine.id
        entity.templateId = routine.templateId
        entity.title = routine.title
        entity.routineDescription = routine.description
        entity.category = routine.category.rawValue
        entity.stepCount = Int16(routine.stepCount)
        entity.duration = routine.duration
        entity.difficulty = routine.difficulty.rawValue
        entity.tags = routine.tags as NSObject
        entity.steps = routine.steps as NSObject
        entity.benefits = routine.benefits as NSObject
        entity.isFeatured = routine.isFeatured
        entity.isPremium = routine.isPremium
        entity.savedDate = routine.savedDate
        entity.isActive = routine.isActive
        entity.adaptationEnabled = routine.adaptationEnabled
        entity.adaptationType = routine.adaptationType?.rawValue
        entity.imageName = routine.imageName

        // Delete existing step details
        if let existingSteps = entity.stepDetails as? Set<SavedStepDetailEntity> {
            for step in existingSteps {
                context.delete(step)
            }
        }

        // Save step details
        for stepDetail in routine.stepDetails {
            let stepEntity = SavedStepDetailEntity(context: context)
            stepEntity.id = stepDetail.id
            stepEntity.title = stepDetail.title
            stepEntity.stepDescription = stepDetail.stepDescription
            stepEntity.stepType = stepDetail.stepType
            stepEntity.timeOfDay = stepDetail.timeOfDay
            stepEntity.why = stepDetail.why
            stepEntity.how = stepDetail.how
            stepEntity.order = Int16(stepDetail.order)
            stepEntity.routine = entity
        }
    }

    private func createInitialRoutineModel(from routineResponse: RoutineResponse) -> SavedRoutineModel {
        var stepDetails: [SavedStepDetailModel] = []
        var order = 0

        for step in routineResponse.routine.morning {
            stepDetails.append(SavedStepDetailModel(
                title: step.name,
                stepDescription: "\(step.why) - \(step.how)",
                stepType: step.step.rawValue,
                timeOfDay: "morning",
                why: step.why,
                how: step.how,
                order: order
            ))
            order += 1
        }

        for step in routineResponse.routine.evening {
            stepDetails.append(SavedStepDetailModel(
                title: step.name,
                stepDescription: "\(step.why) - \(step.how)",
                stepType: step.step.rawValue,
                timeOfDay: "evening",
                why: step.why,
                how: step.how,
                order: order
            ))
            order += 1
        }

        let morningSteps = routineResponse.routine.morning.map { $0.name }
        let eveningSteps = routineResponse.routine.evening.map { $0.name }
        let allSteps = morningSteps + eveningSteps

        return SavedRoutineModel(
            templateId: UUID(),
            title: "My First Routine",
            description: "Your personalized skincare routine created during onboarding",
            category: .all,
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
    }

    private func deactivateAllRoutines(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")

        let activeRoutines = try context.fetch(request)
        for routine in activeRoutines {
            routine.isActive = false
        }
    }

    private func getCompletionSync(stepId: String, date: Date, in context: NSManagedObjectContext) -> RoutineCompletion? {
        let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "stepId == %@ AND completionDate == %@", stepId, date as NSDate)
        request.fetchLimit = 1

        do {
            let completions = try context.fetch(request)
            return completions.first
        } catch {
            print("❌ Error fetching completion: \(error)")
            return nil
        }
    }

    // MARK: - Adaptation Management

    func updateAdaptationSettings(
        routineId: UUID,
        enabled: Bool,
        type: AdaptationType?
    ) async throws {
        print("🔄 RoutineStore: Updating adaptation settings for routine \(routineId)")

        try await backgroundContext.perform {
            let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", routineId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first else {
                throw RoutineStoreError.routineNotFound
            }

            entity.adaptationEnabled = enabled
            entity.adaptationType = type?.rawValue

            try self.backgroundContext.save()
            print("✅ RoutineStore: Updated adaptation settings - enabled: \(enabled), type: \(type?.rawValue ?? "none")")
        }
    }

    func saveCustomRules(
        routineId: UUID,
        rules: [AdaptationRule]
    ) async throws {
        print("🔄 RoutineStore: Saving custom rules for routine \(routineId)")

        // For now, we'll store this as JSON in the adaptationJSON field
        // Future: Create AdaptationAttachmentEntity for more structured storage
        try await backgroundContext.perform {
            let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", routineId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first else {
                throw RoutineStoreError.routineNotFound
            }

            // Encode rules to JSON
            let encoder = JSONEncoder()
            let rulesData = try encoder.encode(rules)
            entity.adaptationJSON = rulesData

            try self.backgroundContext.save()
            print("✅ RoutineStore: Saved \(rules.count) custom rules")
        }
    }

    func fetchCustomRules(routineId: UUID) async throws -> [AdaptationRule]? {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", routineId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first else {
                throw RoutineStoreError.routineNotFound
            }

            guard let rulesData = entity.adaptationJSON else {
                return nil
            }

            let decoder = JSONDecoder()
            let rules = try decoder.decode([AdaptationRule].self, from: rulesData)
            return rules
        }
    }

    // MARK: - Save Tracking (for Discover Page)

    /// Get the number of times a routine template has been saved
    func getRoutineSaveCount(_ templateId: UUID) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "templateId == %@", templateId as CVarArg)

                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Get the save trend (new saves in recent days)
    func getRoutineSaveTrend(_ templateId: UUID, days: Int = 7) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    let calendar = Calendar.current
                    let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

                    let request: NSFetchRequest<SavedRoutineEntity> = SavedRoutineEntity.fetchRequest()
                    request.predicate = NSPredicate(
                        format: "templateId == %@ AND savedDate >= %@",
                        templateId as CVarArg,
                        startDate as NSDate
                    )

                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct CompletionStats: Sendable {
    let date: Date
    let completedSteps: Int
    let totalSteps: Int
    let completionRate: Double

    var isComplete: Bool {
        return completionRate >= 1.0
    }

    var progressPercentage: Double {
        return completionRate * 100
    }
}
