//
//  RoutineHomeViewModel.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Routine Home View Model

@MainActor
class RoutineHomeViewModel: ObservableObject {
    // MARK: - Published Properties (Own State)
    @Published var savedRoutines: [SavedRoutineModel] = []
    @Published var activeRoutine: SavedRoutineModel? = nil
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    // MARK: - Dependencies
    private var routineManager: RoutineManagerProtocol?
    
    // MARK: - Computed Properties
    var hasRoutines: Bool {
        !savedRoutines.isEmpty
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    // MARK: - Initialization
    
    init(routineManager: RoutineManagerProtocol? = nil) {
        self.routineManager = routineManager
        print("🏠 RoutineHomeViewModel initialized")

        // If routineManager is provided, start observing immediately
        if routineManager != nil {
            observeRoutineManager()
        }
    }

    // MARK: - Configuration

    func configure(with routineManager: RoutineManagerProtocol) {
        self.routineManager = routineManager
        observeRoutineManager()
        print("🏠 RoutineHomeViewModel configured with routineManager")
    }

    // MARK: - Private Methods

    private func observeRoutineManager() {
        // Since RoutineManager is @MainActor and ObservableObject,
        // we can observe its published properties directly
        guard let manager = routineManager as? RoutineManager else {
            print("⚠️ RoutineManager is not available for observation")
            return
        }

        // Observe savedRoutines changes
        manager.$savedRoutines
            .assign(to: &$savedRoutines)

        // Observe activeRoutine changes
        manager.$activeRoutine
            .assign(to: &$activeRoutine)

        // Observe loading state
        manager.$isLoading
            .assign(to: &$isLoading)

        // Observe error state
        manager.$error
            .assign(to: &$error)

        print("🔗 RoutineHomeViewModel now observing RoutineManager")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        print("🏠 RoutineHome appeared")
        routineManager?.loadRoutines()
    }
    
    func refresh() {
        print("🔄 Refreshing routines")
        routineManager?.loadRoutines()
    }
    
    func setActiveRoutine(_ routine: SavedRoutineModel) {
        guard let routineManager = routineManager else {
            print("⚠️ RoutineManager not configured")
            return
        }

        Task {
            do {
                try await routineManager.setActiveRoutine(routine)
                print("✅ Active routine set: \(routine.title)")
            } catch {
                print("❌ Failed to set active routine: \(error)")
                self.error = error
            }
        }
    }

    func removeRoutine(_ routine: SavedRoutineModel) {
        guard let routineManager = routineManager else {
            print("⚠️ RoutineManager not configured")
            return
        }

        Task {
            do {
                try await routineManager.removeRoutine(routine)
                print("✅ Routine removed: \(routine.title)")
            } catch {
                print("❌ Failed to remove routine: \(error)")
                self.error = error
            }
        }
    }

    func saveInitialRoutine(from routineResponse: RoutineResponse) {
        guard let routineManager = routineManager else {
            print("⚠️ RoutineManager not configured")
            return
        }

        Task {
            do {
                let savedRoutine = try await routineManager.saveInitialRoutine(from: routineResponse)
                print("✅ Initial routine saved: \(savedRoutine.title)")
            } catch {
                print("❌ Failed to save initial routine: \(error)")
                self.error = error
            }
        }
    }
    
    func clearError() {
        error = nil
        routineManager?.clearError()
    }
    
    // MARK: - Utility Methods
    
    func isRoutineSaved(_ template: RoutineTemplate) async -> Bool {
        guard let routineManager = routineManager else {
            print("⚠️ RoutineManager not configured")
            return false
        }

        do {
            return try await routineManager.isRoutineSaved(template)
        } catch {
            print("❌ Failed to check if routine is saved: \(error)")
            return false
        }
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

