//
//  RoutineHomeViewModel.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Routine Home View Model

@MainActor
class RoutineHomeViewModel: ObservableObject {
    // MARK: - Child View Models
    @Published var listViewModel: RoutineListViewModel
    @Published var completionViewModel: RoutineCompletionViewModel
    @Published var generationViewModel: RoutineGenerationViewModel

    // MARK: - UI State
    @Published var selectedDate = Date()
    @Published var showingStepDetail: RoutineStepDetail?
    @Published var showingEditRoutine = false
    @Published var showingRoutineDetail: RoutineDetailData?

    // MARK: - Dependencies
    private let routineService: RoutineServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties (Forwarded from child VMs)
    var savedRoutines: [SavedRoutineModel] {
        listViewModel.savedRoutines
    }

    var activeRoutine: SavedRoutineModel? {
        listViewModel.activeRoutine
    }

    var hasRoutines: Bool {
        listViewModel.hasRoutines
    }

    var isLoading: Bool {
        listViewModel.isLoading || completionViewModel.isLoading || generationViewModel.isLoading
    }

    var error: Error? {
        listViewModel.error ?? completionViewModel.error ?? generationViewModel.error
    }

    var errorMessage: String? {
        error?.localizedDescription
    }

    // Note: completedSteps and completionStats are now date-specific
    // Use completionViewModel.getCompletedSteps(for: date) and getCompletionStats(for: date) instead

    // MARK: - Initialization

    init(routineService: RoutineServiceProtocol) {
        self.routineService = routineService
        self.listViewModel = RoutineListViewModel(routineService: routineService)
        self.completionViewModel = RoutineCompletionViewModel(routineService: routineService)
        self.generationViewModel = RoutineGenerationViewModel(routineService: routineService)

        print("🏠 RoutineHomeViewModel initialized with new architecture")
    }

    // MARK: - Public Methods

    func onAppear() {
        print("🏠 RoutineHome appeared")
        listViewModel.onAppear()
        completionViewModel.onAppear()
        
        // Add a safety timeout to prevent infinite loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLoading {
                print("⚠️ Loading timeout reached, force clearing loading state")
                self.listViewModel.isLoading = false
                self.completionViewModel.isLoading = false
            }
        }
    }

    func refresh() {
        print("🔄 Refreshing routine home")
        listViewModel.refresh()
        completionViewModel.refresh()
    }

    // MARK: - Forwarded Methods (List Operations)

    func setActiveRoutine(_ routine: SavedRoutineModel) {
        listViewModel.setActiveRoutine(routine)
    }

    func removeRoutine(_ routine: SavedRoutineModel) {
        listViewModel.removeRoutine(routine)
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) {
        listViewModel.saveInitialRoutine(from: routineResponse)
    }

    // MARK: - Forwarded Methods (Completion Operations)

    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) {
        completionViewModel.toggleStepCompletion(
            stepId: stepId,
            stepTitle: stepTitle,
            stepType: stepType,
            timeOfDay: timeOfDay,
            date: date
        )
    }

    func isStepCompleted(stepId: String, date: Date = Date()) async -> Bool {
        return await completionViewModel.isStepCompleted(stepId: stepId, date: date)
    }

    func getCompletedSteps(for date: Date = Date()) async -> Set<String> {
        return await completionViewModel.getCompletedSteps(for: date)
    }

    func clearAllCompletions() {
        completionViewModel.clearAllCompletions()
    }

    // MARK: - Forwarded Methods (Generation Operations)

    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) {
        generationViewModel.generateRoutine(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            preferences: preferences,
            lifestyle: lifestyle
        )
    }

    func generateAndSaveRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) {
        generationViewModel.generateAndSaveRoutine(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            fitzpatrickSkinTone: fitzpatrickSkinTone,
            ageRange: ageRange,
            region: region,
            preferences: preferences,
            lifestyle: lifestyle
        )
    }

    // MARK: - State Management

    func clearError() {
        listViewModel.clearError()
        completionViewModel.clearError()
        generationViewModel.clearError()
    }

    // MARK: - Utility Methods

    func isRoutineSaved(_ template: RoutineTemplate) async -> Bool {
        do {
            return try await routineService.isRoutineSaved(template)
        } catch {
            print("❌ Error checking if routine is saved: \(error)")
            return false
        }
    }

    func routine(withId id: UUID) -> SavedRoutineModel? {
        return savedRoutines.first { $0.id == id }
    }

    func routineIndex(withId id: UUID) -> Int? {
        return savedRoutines.firstIndex { $0.id == id }
    }
}

// MARK: - State Management Helpers

extension RoutineHomeViewModel {
    var viewState: ViewState {
        if isLoading {
            return .loading
        } else if let error = error {
            return .error(error)
        } else if savedRoutines.isEmpty {
            return .empty
        } else {
            return .loaded
        }
    }
}

