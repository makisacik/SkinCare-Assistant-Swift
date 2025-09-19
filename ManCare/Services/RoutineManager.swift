//
//  RoutineManager.swift
//  ManCare
//

//  Created by Mehmet Ali Kısacık on 18.09.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - Routine Manager Protocol

protocol RoutineManagerProtocol {
    // State Properties (MainActor)
    @MainActor var savedRoutines: [SavedRoutineModel] { get }
    @MainActor var activeRoutine: SavedRoutineModel? { get }
    @MainActor var isLoading: Bool { get }
    @MainActor var error: Error? { get }

    // Generation (Background)
    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo?
    ) async throws -> RoutineResponse

    // Storage (Background)
    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel
    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel
    func removeRoutine(_ routine: SavedRoutineModel) async throws
    func setActiveRoutine(_ routine: SavedRoutineModel) async throws

    // Queries (Background)
    func fetchSavedRoutines() async throws -> [SavedRoutineModel]
    func fetchActiveRoutine() async throws -> SavedRoutineModel?
    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool

    // UI Actions (MainActor)
    @MainActor func loadRoutines()
    @MainActor func clearError()

    // Tracking Methods (MainActor)
    @MainActor func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date)
    @MainActor func isStepCompleted(stepId: String, date: Date) async -> Bool
    @MainActor func getCompletedSteps(for date: Date) async -> Set<String>
    @MainActor func getCurrentStreak() async -> Int
    @MainActor func clearAllCompletions()

    // Tracking Queries (Background)
    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats]

    // Convenience Methods
    func generateAndSaveInitialRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo?
    ) async throws -> SavedRoutineModel
}

// MARK: - Routine Manager Implementation

@MainActor
final class RoutineManager: ObservableObject, RoutineManagerProtocol {
    // No shared instance - use dependency injection

    // MARK: - Published Properties (Always MainActor)
    @Published var savedRoutines: [SavedRoutineModel] = []
    @Published var activeRoutine: SavedRoutineModel? = nil
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil

    // MARK: - Tracking Properties
    @Published var completedSteps: Set<String> = []

    // MARK: - Private Dependencies
    private let routineService: RoutineService
    private let persistenceController: PersistenceController
    private let store: RoutineStoreProtocol

    // MARK: - Task Management (Fixed)
    private var loadTask: Task<Void, Never>?
    private var operationTasks: [UUID: Task<Void, Error>] = [:]

    // MARK: - Initialization

    init(
        routineService: RoutineService = RoutineService.shared,
        persistenceController: PersistenceController = .shared,
        store: RoutineStoreProtocol = RoutineStore()
    ) {
        self.routineService = routineService
        self.persistenceController = persistenceController
        self.store = store
        print("🎯 RoutineManager initialized with modern threading")
    }

    deinit {
        // Cancel all tasks
        loadTask?.cancel()
        for task in operationTasks.values {
            task.cancel()
        }
        print("🎯 RoutineManager deinitialized")
    }

    // MARK: - Generation (Background)

    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo? = nil
    ) async throws -> RoutineResponse {
        // This runs on background thread - good for API calls
        isLoading = true
        error = nil // Clear previous errors

        defer {
            isLoading = false
        }

        do {
            let routine = try await routineService.generateRoutine(
                skinType: skinType,
                concerns: concerns,
                mainGoal: mainGoal,
                preferences: preferences,
                lifestyle: lifestyle,
                apiKey: Config.openAIAPIKey
            )

            print("✅ Routine generated successfully")
            return routine
        } catch {
            print("❌ Failed to generate routine: \(error)")
            self.error = error
            throw error
        }
    }

    // MARK: - Storage Operations (Background with UI Updates)

    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel {
        isLoading = true
        error = nil // Clear previous errors

        defer { isLoading = false }

        do {
            let savedRoutine = try await store.saveRoutine(SavedRoutineModel(from: template))

            // Update UI state on main thread
            try? await refreshRoutines()
            return savedRoutine
        } catch {
            self.error = error
            throw error
        }
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        isLoading = true
        error = nil // Clear previous errors

        defer { isLoading = false }

        do {
            let savedRoutine = try await store.saveInitialRoutine(from: routineResponse)

            // Update UI state on main thread
            try? await refreshRoutines()
            return savedRoutine
        } catch {
            self.error = error
            throw error
        }
    }

    func removeRoutine(_ routine: SavedRoutineModel) async throws {
        isLoading = true
        error = nil // Clear previous errors

        defer { isLoading = false }

        do {
            try await store.removeRoutine(routine)

            // Update UI state on main thread
            try? await refreshRoutines()
        } catch {
            self.error = error
            throw error
        }
    }

    func setActiveRoutine(_ routine: SavedRoutineModel) async throws {
        isLoading = true
        error = nil // Clear previous errors

        defer { isLoading = false }

        do {
            try await store.setActiveRoutine(routine)

            // Update UI state on main thread
            try? await refreshRoutines()
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Queries (Background)

    func fetchSavedRoutines() async throws -> [SavedRoutineModel] {
        return try await store.fetchSavedRoutines()
    }

    func fetchActiveRoutine() async throws -> SavedRoutineModel? {
        return try await store.fetchActiveRoutine()
    }

    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool {
        return try await store.isRoutineSaved(template)
    }

    // MARK: - UI Actions (MainActor)

    func loadRoutines() {
        // Cancel previous load task
        loadTask?.cancel()

        loadTask = Task {
            do {
                isLoading = true
                error = nil

                // Fetch data concurrently on background
                async let routinesResult = fetchSavedRoutines()
                async let activeRoutineResult = fetchActiveRoutine()
                async let completedStepsResult = store.getCompletedSteps(for: Date())

                let (routines, activeRoutine, completedSteps) = try await (routinesResult, activeRoutineResult, completedStepsResult)

                // Update UI on main thread (we're already MainActor)
                self.savedRoutines = routines
                self.activeRoutine = activeRoutine
                self.completedSteps = completedSteps
                self.isLoading = false

                print("✅ Loaded \(routines.count) routines and \(completedSteps.count) completed steps")
            } catch {
                self.error = error
                self.isLoading = false
                print("❌ Failed to load routines: \(error)")
            }
        }
    }

    func clearError() {
        error = nil
    }

    // MARK: - Private Helpers

    private func refreshRoutines() async throws {
        let routines = try await store.fetchSavedRoutines()
        let activeRoutine = try await store.fetchActiveRoutine()

        self.savedRoutines = routines
        self.activeRoutine = activeRoutine
    }

}

// MARK: - Convenience Extensions

extension RoutineManager {
    /// Generate and save routine in one operation with proper task management
    func generateAndSaveInitialRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo? = nil
    ) async throws -> SavedRoutineModel {
        isLoading = true
        error = nil // Clear previous errors

        defer { isLoading = false }

        do {
            // Generate routine (background)
            let routineResponse = try await generateRoutine(
                skinType: skinType,
                concerns: concerns,
                mainGoal: mainGoal,
                preferences: preferences,
                lifestyle: lifestyle
            )

            // Save routine (background)
            let savedRoutine = try await saveInitialRoutine(from: routineResponse)

            return savedRoutine
        } catch {
            self.error = error
            throw error
        }
    }

    /// Perform operation with automatic task tracking
    private func performOperation<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        let taskId = UUID()
        let task = Task<T, Error> {
            try await operation()
        }

        // Track task with UUID
        let trackingTask = Task<Void, Error> {
            let _ = try await task.value
        }

        await MainActor.run {
            self.operationTasks[taskId] = trackingTask
        }

        defer {
            Task { @MainActor in
                self.operationTasks.removeValue(forKey: taskId)
            }
        }

        return try await task.value
    }

    // MARK: - Tracking Methods

    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        Task {
            do {
                try await store.toggleStepCompletion(stepId: stepId, stepTitle: stepTitle, stepType: stepType, timeOfDay: timeOfDay, date: startOfDay)

                // Update UI on main thread
                await MainActor.run {
                    self.updateCompletedSteps(for: startOfDay)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("❌ Error toggling step completion: \(error)")
            }
        }
    }

    func isStepCompleted(stepId: String, date: Date = Date()) async -> Bool {
        return (try? await store.isStepCompleted(stepId: stepId, date: startOfDay(date))) ?? false
    }

    func getCompletedSteps(for date: Date = Date()) async -> Set<String> {
        return (try? await store.getCompletedSteps(for: startOfDay(date))) ?? []
    }

    func getCurrentStreak() async -> Int {
        return (try? await store.getCurrentStreak()) ?? 0
    }

    func clearAllCompletions() {
        Task {
            do {
                try await store.clearAllCompletions()
                await MainActor.run {
                    self.completedSteps.removeAll()
                }
            } catch {
                await MainActor.run { self.error = error }
                print("❌ Error clearing completions: \(error)")
            }
        }
    }

    // TEMPORARY DEBUG METHOD: Clear all routines to fix duplicates
    func clearAllRoutines() {
        Task {
            do {
                // Clear all saved routines
                let routines = try await store.fetchSavedRoutines()
                for routine in routines {
                    try await store.removeRoutine(routine)
                }

                // Clear all completions
                try await store.clearAllCompletions()

                await MainActor.run {
                    self.savedRoutines.removeAll()
                    self.activeRoutine = nil
                    self.completedSteps.removeAll()
                    print("🧹 All routines and completions cleared!")
                }
            } catch {
                await MainActor.run { self.error = error }
                print("❌ Error clearing all routines: \(error)")
            }
        }
    }

    // MARK: - Background Tracking Queries

    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats] {
        return try await store.getCompletionStats(from: startDate, to: endDate)
    }

    // MARK: - Private Tracking Helpers

    private func updateCompletedSteps(for date: Date) {
        Task {
            let completed = await getCompletedSteps(for: date)
            await MainActor.run {
                self.completedSteps = completed
            }
        }
    }

    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
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
}
