//
//  RoutineListViewModel.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Routine List View Model

@MainActor
final class RoutineListViewModel: ObservableObject {
    // MARK: - Published Properties (UI State Only)
    @Published var savedRoutines: [SavedRoutineModel] = []
    @Published var activeRoutine: SavedRoutineModel? = nil
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Dependencies
    let routineService: RoutineServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasRoutines: Bool {
        !savedRoutines.isEmpty
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    // MARK: - Initialization
    
    init(routineService: RoutineServiceProtocol) {
        self.routineService = routineService
        print("📋 RoutineListViewModel initialized")
        subscribeToRoutineStream()
    }
    
    // MARK: - Stream Subscription
    
    private func subscribeToRoutineStream() {
        routineService.routinesStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateFromState(state)
            }
            .store(in: &cancellables)
        
        print("📡 RoutineListViewModel subscribed to routine stream")
    }
    
    private func updateFromState(_ state: RoutineServiceState) {
        savedRoutines = state.savedRoutines
        activeRoutine = state.activeRoutine
        isLoading = false // Clear loading state when data is received
        error = nil // Clear any previous errors
        print("📋 Updated with \(savedRoutines.count) routines, loading cleared")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        print("📋 RoutineListViewModel appeared")
        loadRoutines()
    }
    
    func refresh() {
        print("🔄 Refreshing routine list")
        loadRoutines()
    }
    
    func loadRoutines() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await routineService.refreshData()
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to load routines: \(error)")
            }
        }
    }
    
    func setActiveRoutine(_ routine: SavedRoutineModel) {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await routineService.setActiveRoutine(routine)
                await MainActor.run {
                    self.isLoading = false
                }
                print("✅ Active routine set: \(routine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to set active routine: \(error)")
            }
        }
    }
    
    func removeRoutine(_ routine: SavedRoutineModel) {
        isLoading = true
        error = nil

        Task {
            do {
                let wasActive = (activeRoutine?.id == routine.id)

                try await routineService.removeRoutine(routine)

                // If we removed the active routine and there are other routines available,
                // automatically set the first one as active
                if wasActive {
                    // Wait a moment for the routine stream to update
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

                    if let firstRoutine = savedRoutines.first(where: { $0.id != routine.id }) {
                        print("📌 Removed active routine, setting first available routine as active: \(firstRoutine.title)")
                        try await routineService.setActiveRoutine(firstRoutine)
                    } else {
                        print("ℹ️ No other routines available after removal")
                    }
                }

                await MainActor.run {
                    self.isLoading = false
                }
                print("✅ Routine removed: \(routine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to remove routine: \(error)")
            }
        }
    }
    
    func saveInitialRoutine(from routineResponse: RoutineResponse) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let savedRoutine = try await routineService.saveInitialRoutine(from: routineResponse)
                await MainActor.run {
                    self.isLoading = false
                }
                print("✅ Initial routine saved: \(savedRoutine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to save initial routine: \(error)")
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    func saveRoutineTemplate(_ template: RoutineTemplate) {
        isLoading = true
        error = nil
        
        Task {
            do {
                // NOTE: Saving premade templates does NOT count against routine generation limit
                // The limit only applies to generating new routines via GPT API
                // Premade templates can be saved unlimited times as they don't use API
                print("💾 Saving premade template '\(template.title)' (no API calls, no limit)")

                let savedRoutine = try await routineService.saveRoutine(template)

                // If there's no active routine, automatically set this as active
                if activeRoutine == nil {
                    print("📌 No active routine found, setting newly saved routine as active")
                    try await routineService.setActiveRoutine(savedRoutine)
                }

                await MainActor.run {
                    self.isLoading = false
                }
                print("✅ Routine template saved: \(template.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to save routine template: \(error)")
            }
        }
    }
    
    func removeRoutineTemplate(_ template: RoutineTemplate) {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await routineService.removeRoutineTemplate(template)
                await MainActor.run {
                    self.isLoading = false
                }
                print("✅ Routine template removed: \(template.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to remove routine template: \(error)")
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func routine(withId id: UUID) -> SavedRoutineModel? {
        savedRoutines.first { $0.id == id }
    }
    
    func routineIndex(withId id: UUID) -> Int? {
        savedRoutines.firstIndex { $0.id == id }
    }
}

// MARK: - Preview Support

#if DEBUG
extension RoutineListViewModel {
    static let preview: RoutineListViewModel = {
        let mockService = ServiceFactory.shared.createMockRoutineService()
        let vm = RoutineListViewModel(routineService: mockService)
        // Add mock data for previews
        return vm
    }()
}
#endif
