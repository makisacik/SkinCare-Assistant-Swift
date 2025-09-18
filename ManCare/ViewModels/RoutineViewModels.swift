//
//  ModernRoutineViewModels.swift
//  ManCare
//
//  Modern Threading Implementation
//  Created by Mehmet Ali Kısacık on 18.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Modern Routine Home View Model

@MainActor
class RoutineHomeViewModel: ObservableObject {
    // MARK: - Dependencies
    private let routineManager: RoutineManagerProtocol
    
    // MARK: - Published Properties (Direct from Manager)
    var savedRoutines: [SavedRoutineModel] {
        routineManager.savedRoutines
    }
    
    var activeRoutine: SavedRoutineModel? {
        routineManager.activeRoutine
    }
    
    var isLoading: Bool {
        routineManager.isLoading
    }
    
    var error: Error? {
        routineManager.error
    }
    
    // MARK: - Computed Properties
    var hasRoutines: Bool {
        !savedRoutines.isEmpty
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    // MARK: - Initialization
    
    init(routineManager: RoutineManagerProtocol) {
        self.routineManager = routineManager
        print("🏠 ModernRoutineHomeViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        print("🏠 RoutineHome appeared")
        routineManager.loadRoutines()
    }
    
    func refresh() {
        print("🔄 Refreshing routines")
        routineManager.loadRoutines()
    }
    
    func setActiveRoutine(_ routine: SavedRoutineModel) {
        Task {
            do {
                try await routineManager.setActiveRoutine(routine)
                print("✅ Active routine set: \(routine.title)")
            } catch {
                print("❌ Failed to set active routine: \(error)")
                // Error is automatically handled by the manager
            }
        }
    }
    
    func removeRoutine(_ routine: SavedRoutineModel) {
        Task {
            do {
                try await routineManager.removeRoutine(routine)
                print("✅ Routine removed: \(routine.title)")
            } catch {
                print("❌ Failed to remove routine: \(error)")
                // Error is automatically handled by the manager
            }
        }
    }
    
    func saveInitialRoutine(from routineResponse: RoutineResponse) {
        Task {
            do {
                let savedRoutine = try await routineManager.saveInitialRoutine(from: routineResponse)
                print("✅ Initial routine saved: \(savedRoutine.title)")
            } catch {
                print("❌ Failed to save initial routine: \(error)")
                // Error is automatically handled by the manager
            }
        }
    }
    
    func clearError() {
        routineManager.clearError()
    }
    
    // MARK: - Utility Methods
    
    func isRoutineSaved(_ template: RoutineTemplate) async -> Bool {
        do {
            return try await routineManager.isRoutineSaved(template)
        } catch {
            print("❌ Failed to check if routine is saved: \(error)")
            return false
        }
    }
}

// MARK: - Modern Discover View Model

@MainActor
class DiscoverViewModel: ObservableObject {
    // MARK: - Dependencies
    private let routineManager: RoutineManagerProtocol
    
    // MARK: - Published Properties (Direct from Manager)
    var savedRoutines: [SavedRoutineModel] {
        routineManager.savedRoutines
    }
    
    var isLoading: Bool {
        routineManager.isLoading
    }
    
    var error: Error? {
        routineManager.error
    }
    
    // MARK: - Initialization
    
    init(routineManager: RoutineManagerProtocol) {
        self.routineManager = routineManager
        print("🔍 ModernDiscoverViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        // Load saved routines to check which templates are already saved
        routineManager.loadRoutines()
    }
    
    func saveRoutine(_ template: RoutineTemplate) {
        Task {
            do {
                let savedRoutine = try await routineManager.saveRoutine(template)
                print("✅ Routine saved from Discover: \(savedRoutine.title)")
            } catch {
                print("❌ Failed to save routine from Discover: \(error)")
                // Error is automatically handled by the manager
            }
        }
    }
    
    func isRoutineSaved(_ template: RoutineTemplate) -> Bool {
        return savedRoutines.contains { $0.templateId == template.id }
    }
    
    func clearError() {
        routineManager.clearError()
    }
}

// MARK: - Modern Main Flow View Model

@MainActor
class MainFlowViewModel: ObservableObject {
    // MARK: - Dependencies
    private let routineManager: RoutineManagerProtocol
    
    // MARK: - Published Properties
    @Published var isGeneratingRoutine = false
    @Published var generationError: Error?
    
    // MARK: - Manager Properties
    var isLoading: Bool {
        routineManager.isLoading || isGeneratingRoutine
    }
    
    var error: Error? {
        routineManager.error ?? generationError
    }
    
    // MARK: - Initialization
    
    init(routineManager: RoutineManagerProtocol) {
        self.routineManager = routineManager
        print("🌊 ModernMainFlowViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    func generateAndSaveRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo? = nil
    ) async throws -> SavedRoutineModel {
        isGeneratingRoutine = true
        generationError = nil
        
        defer {
            isGeneratingRoutine = false
        }
        
        do {
            let savedRoutine = try await routineManager.generateAndSaveInitialRoutine(
                skinType: skinType,
                concerns: concerns,
                mainGoal: mainGoal,
                preferences: preferences,
                lifestyle: lifestyle
            )
            
            print("✅ Routine generated and saved from MainFlow")
            return savedRoutine
        } catch {
            generationError = error
            print("❌ Failed to generate and save routine: \(error)")
            throw error
        }
    }
    
    func saveInitialRoutine(from routineResponse: RoutineResponse) async throws -> SavedRoutineModel {
        return try await routineManager.saveInitialRoutine(from: routineResponse)
    }
    
    func clearError() {
        routineManager.clearError()
        generationError = nil
    }
}

// MARK: - View Helpers and Extensions

extension View {
    func handleModernRoutineError(_ error: Error?) -> some View {
        self.alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
    }
    
    func withModernRoutineLoading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 5)
                                    .frame(width: 80, height: 80)
                            )
                    }
                }
            }
        )
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

extension DiscoverViewModel {
    var viewState: ViewState {
        if isLoading {
            return .loading
        } else if let error = error {
            return .error(error)
        } else {
            return .loaded
        }
    }
}

enum ViewState {
    case loading
    case loaded
    case empty
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
