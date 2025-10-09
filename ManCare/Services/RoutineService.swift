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
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) async throws -> RoutineResponse {
        print("🤖 Generating routine with GPT")

        // Create the request using the convenience method
        let request = GPTService.createRequest(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            preferences: preferences,
            lifestyle: lifestyle
        )

        return try await gptService.generateRoutine(for: request)
    }

    // MARK: - Write Operations (Stateless)

    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel {
        print("💾 Saving routine: \(template.title)")

        let savedRoutine = try await store.saveRoutine(SavedRoutineModel(from: template))

        // Emit updated state
        try await emitUpdatedState()

        return savedRoutine
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        print("💾 Saving initial routine from response")

        let savedRoutine = try await store.saveInitialRoutine(from: routineResponse)

        // Emit updated state
        try await emitUpdatedState()

        return savedRoutine
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
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        print("🔄 RoutineService: Toggling step completion: \(stepTitle) (ID: \(stepId)) for date: \(startOfDay)")

        try await store.toggleStepCompletion(
            stepId: stepId,
            stepTitle: stepTitle,
            stepType: stepType,
            timeOfDay: timeOfDay,
            date: startOfDay
        )

        print("📡 RoutineService: Emitting completion change notification for date: \(startOfDay)")
        // Emit completion change notification for this date
        Task { @MainActor in
            self.completionChangeSubject.send(startOfDay)
        }

        // Emit updated state (for routines and active routine)
        try await emitUpdatedState()
    }

    func isStepCompleted(stepId: String, date: Date = Date()) async throws -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return try await store.isStepCompleted(stepId: stepId, date: startOfDay)
    }

    func getCompletedSteps(for date: Date = Date()) async throws -> Set<String> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
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