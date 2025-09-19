//
//  RoutineCompletionViewModel.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Routine Completion View Model

@MainActor
final class RoutineCompletionViewModel: ObservableObject {
    // MARK: - Published Properties (UI State Only)
    @Published var activeRoutine: SavedRoutineModel?
    @Published var completedSteps: Set<String> = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentStreak = 0
    
    // MARK: - Dependencies
    private let routineService: RoutineServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasActiveRoutine: Bool {
        activeRoutine != nil
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    // Completion statistics for active routine
    var completionStats: RoutineCompletionStats? {
        guard let routine = activeRoutine else { return nil }
        
        let morningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .morning }
        let eveningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .evening }
        
        let completedMorningSteps = morningSteps.filter { completedSteps.contains($0.id.uuidString) }
        let completedEveningSteps = eveningSteps.filter { completedSteps.contains($0.id.uuidString) }
        
        return RoutineCompletionStats(
            morningTotal: morningSteps.count,
            morningCompleted: completedMorningSteps.count,
            eveningTotal: eveningSteps.count,
            eveningCompleted: completedEveningSteps.count,
            overallTotal: routine.stepDetails.count,
            overallCompleted: completedSteps.count,
            currentStreak: currentStreak
        )
    }
    
    // MARK: - Initialization
    
    init(routineService: RoutineServiceProtocol = RoutineService.shared) {
        self.routineService = routineService
        print("✅ RoutineCompletionViewModel initialized")
        subscribeToRoutineStream()
        Task {
            await loadStreak()
        }
    }
    
    // MARK: - Stream Subscription
    
    private func subscribeToRoutineStream() {
        routineService.routinesStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateFromState(state)
            }
            .store(in: &cancellables)
        
        print("📡 RoutineCompletionViewModel subscribed to routine stream")
    }
    
    private func updateFromState(_ state: RoutineServiceState) {
        activeRoutine = state.activeRoutine
        completedSteps = state.completedSteps
        print("✅ Updated completion state: \(completedSteps.count) completed steps")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        print("✅ RoutineCompletionViewModel appeared")
        refresh()
    }
    
    func refresh() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await routineService.refreshData()
                await loadStreak()
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to refresh completion data: \(error)")
            }
        }
    }
    
    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) {
        Task {
            do {
                try await routineService.toggleStepCompletion(
                    stepId: stepId,
                    stepTitle: stepTitle,
                    stepType: stepType,
                    timeOfDay: timeOfDay,
                    date: date
                )
                
                // Reload streak after completion change
                await loadStreak()
                
                print("✅ Toggled step completion: \(stepTitle)")
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("❌ Failed to toggle step completion: \(error)")
            }
        }
    }
    
    func isStepCompleted(stepId: String, date: Date = Date()) async -> Bool {
        do {
            return try await routineService.isStepCompleted(stepId: stepId, date: date)
        } catch {
            print("❌ Failed to check step completion: \(error)")
            return false
        }
    }
    
    func getCompletedSteps(for date: Date = Date()) async -> Set<String> {
        do {
            let steps = try await routineService.getCompletedSteps(for: date)
            print("📊 Retrieved \(steps.count) completed steps for \(date): \(steps)")
            return steps
        } catch {
            print("❌ Failed to get completed steps: \(error)")
            return []
        }
    }
    
    func clearAllCompletions() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await routineService.clearAllCompletions()
                await loadStreak()
                await MainActor.run {
                    self.isLoading = false
                }
                print("🧹 All completions cleared")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to clear completions: \(error)")
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func loadStreak() async {
        do {
            let streak = try await routineService.getCurrentStreak()
            self.currentStreak = streak
        } catch {
            print("❌ Failed to load streak: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    func completionPercentage(for timeOfDay: TimeOfDay) -> Double {
        guard let routine = activeRoutine else { return 0.0 }
        
        let steps = routine.stepDetails.filter { $0.timeOfDayEnum == timeOfDay }
        let completedCount = steps.filter { completedSteps.contains($0.id.uuidString) }.count
        
        guard steps.count > 0 else { return 0.0 }
        return Double(completedCount) / Double(steps.count)
    }
    
    func isRoutineCompleted(for timeOfDay: TimeOfDay) -> Bool {
        completionPercentage(for: timeOfDay) == 1.0
    }
    
    func isRoutineFullyCompleted() -> Bool {
        guard let routine = activeRoutine else { return false }
        return completedSteps.count == routine.stepDetails.count
    }
}

// MARK: - Supporting Types

struct RoutineCompletionStats {
    let morningTotal: Int
    let morningCompleted: Int
    let eveningTotal: Int
    let eveningCompleted: Int
    let overallTotal: Int
    let overallCompleted: Int
    let currentStreak: Int
    
    var morningCompletionPercentage: Double {
        guard morningTotal > 0 else { return 0.0 }
        return Double(morningCompleted) / Double(morningTotal)
    }
    
    var eveningCompletionPercentage: Double {
        guard eveningTotal > 0 else { return 0.0 }
        return Double(eveningCompleted) / Double(eveningTotal)
    }
    
    var overallCompletionPercentage: Double {
        guard overallTotal > 0 else { return 0.0 }
        return Double(overallCompleted) / Double(overallTotal)
    }
    
    var isMorningCompleted: Bool {
        morningTotal > 0 && morningCompleted == morningTotal
    }
    
    var isEveningCompleted: Bool {
        eveningTotal > 0 && eveningCompleted == eveningTotal
    }
    
    var isFullyCompleted: Bool {
        overallTotal > 0 && overallCompleted == overallTotal
    }
}

// MARK: - Preview Support

#if DEBUG
extension RoutineCompletionViewModel {
    static let preview: RoutineCompletionViewModel = {
        let vm = RoutineCompletionViewModel()
        // Add mock data for previews
        return vm
    }()
}
#endif
