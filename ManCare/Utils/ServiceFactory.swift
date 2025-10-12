//
//  ServiceFactory.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import Combine

// MARK: - Service Factory

final class ServiceFactory {
    static let shared = ServiceFactory()

    private init() {}

    // MARK: - Core Services

    func createRoutineService() -> RoutineServiceProtocol {
        return RoutineService(
            gptService: createGPTService(),
            store: createRoutineStore()
        )
    }

    func createGPTService() -> GPTService {
        return GPTService.shared // Keep using singleton for now
    }

    func createRoutineStore() -> RoutineStoreProtocol {
        return RoutineStore()
    }

    // MARK: - Adaptation Services

    func createAdaptationRulesEngine() -> AdaptationRulesEngine {
        return AdaptationRulesEngine()
    }

    func createSnapshotCache() -> SnapshotCache {
        return SnapshotCache()
    }

    func createRoutineAdapterService() -> RoutineAdapterProtocol {
        return RoutineAdapterService(
            cycleStore: CycleStore(),
            rulesEngine: createAdaptationRulesEngine(),
            snapshotCache: createSnapshotCache()
        )
    }

    func routineAdapterService(cycleStore: CycleStore) -> RoutineAdapterProtocol {
        return RoutineAdapterService(
            cycleStore: cycleStore,
            rulesEngine: createAdaptationRulesEngine(),
            snapshotCache: createSnapshotCache()
        )
    }

    // MARK: - Discover Services

    func createDiscoverContentService() -> DiscoverContentService {
        return DiscoverContentService()
    }

    // MARK: - ViewModels

    @MainActor
    func createRoutineCompletionViewModel() -> RoutineCompletionViewModel {
        return RoutineCompletionViewModel(routineService: createRoutineService())
    }

    @MainActor
    func createCompanionSessionViewModel() -> CompanionSessionViewModel {
        return CompanionSessionViewModel(routineService: createRoutineService())
    }

    @MainActor
    func createRoutineListViewModel() -> RoutineListViewModel {
        return RoutineListViewModel(routineService: createRoutineService())
    }

    @MainActor
    func createRoutineGenerationViewModel() -> RoutineGenerationViewModel {
        return RoutineGenerationViewModel(routineService: createRoutineService())
    }

    // MARK: - Mock Services (for testing)

    func createMockRoutineService() -> RoutineServiceProtocol {
        return MockRoutineService()
    }

    @MainActor
    func createMockRoutineCompletionViewModel() -> RoutineCompletionViewModel {
        return RoutineCompletionViewModel(routineService: createMockRoutineService())
    }
}

// MARK: - Mock Routine Service

class MockRoutineService: RoutineServiceProtocol {
    func removeRoutineTemplate(_ template: RoutineTemplate) async throws {

    }

    var routinesStream: AnyPublisher<RoutineServiceState, Never> {
        Just(RoutineServiceState.initial)
            .eraseToAnyPublisher()
    }

    var completionChangesStream: AnyPublisher<Date, Never> {
        Just(Date())
            .eraseToAnyPublisher()
    }

    func generateRoutine(skinType: SkinType, concerns: Set<Concern>, mainGoal: MainGoal, fitzpatrickSkinTone: FitzpatrickSkinTone, ageRange: AgeRange, region: Region, routineDepth: RoutineDepth?, preferences: Preferences?, lifestyle: LifestyleAnswers?) async throws -> RoutineResponse {
        // Create a simple mock routine response
        let mockStep = APIRoutineStep(
            step: .cleanser,
            name: "Gentle Cleanser",
            why: "Removes dirt and oil",
            how: "Apply to wet face, massage gently, rinse",
            constraints: Constraints()
        )

        let mockSummary = Summary(
            title: "Mock Routine",
            oneLiner: "A simple mock routine for testing"
        )

        let mockRoutine = Routine(
            depth: .simple,
            morning: [mockStep],
            evening: [mockStep],
            weekly: nil
        )

        let mockGuardrails = Guardrails(
            cautions: ["Test caution"],
            whenToStop: ["If irritation occurs"],
            sunNotes: "Always wear sunscreen"
        )

        let mockAdaptation = Adaptation(
            forSkinType: "Mock skin type",
            forConcerns: ["Mock concern"],
            forPreferences: ["Mock preference"]
        )

        let mockProductSlot = ProductSlot(
            slotID: "mock-slot-1",
            step: .cleanser,
            time: .AM,
            constraints: Constraints(),
            notes: "Mock product slot"
        )

        return RoutineResponse(
            version: "1.0",
            locale: "en-US",
            summary: mockSummary,
            routine: mockRoutine,
            guardrails: mockGuardrails,
            adaptation: mockAdaptation,
            productSlots: [mockProductSlot]
        )
    }

    func saveRoutine(_ template: RoutineTemplate) async throws -> SavedRoutineModel {
        // Create a simple mock saved routine
        return SavedRoutineModel(from: template, isActive: false)
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        // Convert RoutineResponse to RoutineTemplate first
        let template = RoutineTemplate(
            id: UUID(),
            title: routineResponse.summary.title,
            description: routineResponse.summary.oneLiner,
            category: .all,
            stepCount: routineResponse.routine.morning.count + routineResponse.routine.evening.count,
            duration: "10 min",
            difficulty: .beginner,
            tags: ["Mock"],
            morningSteps: routineResponse.routine.morning.map { $0.name },
            eveningSteps: routineResponse.routine.evening.map { $0.name },
            benefits: ["Mock benefit"],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist"
        )

        return try await saveRoutine(template)
    }

    func removeRoutine(_ routine: SavedRoutineModel) async throws {}
    func setActiveRoutine(_ routine: SavedRoutineModel) async throws {}
    func isRoutineSaved(_ template: RoutineTemplate) async throws -> Bool { return false }
    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date) async throws {}
    func isStepCompleted(stepId: String, date: Date) async throws -> Bool { return false }
    func getCompletedSteps(for date: Date) async throws -> Set<String> { return [] }
    func getCurrentStreak() async throws -> Int { return 0 }
    func clearAllCompletions() async throws {}
    func getCompletionStats(from startDate: Date, to endDate: Date) async throws -> [Date: CompletionStats] { return [:] }
    func generateAndSaveInitialRoutine(skinType: SkinType, concerns: Set<Concern>, mainGoal: MainGoal, fitzpatrickSkinTone: FitzpatrickSkinTone, ageRange: AgeRange, region: Region, routineDepth: RoutineDepth?, preferences: Preferences?, lifestyle: LifestyleAnswers?) async throws -> SavedRoutineModel {
        let routineResponse = try await generateRoutine(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            routineDepth: routineDepth,
            preferences: preferences,
            lifestyle: lifestyle
        )
        return try await saveInitialRoutine(from: routineResponse)
    }
    func refreshData() async throws {}

    func toggleAdaptation(
        for routine: SavedRoutineModel,
        enabled: Bool,
        type: AdaptationType?
    ) async throws {}

    func getAdaptedSnapshot(
        _ routine: SavedRoutineModel,
        for date: Date
    ) async throws -> RoutineSnapshot? { return nil }
}
