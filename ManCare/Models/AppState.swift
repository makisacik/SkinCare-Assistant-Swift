//
//  AppState.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentFlow: AppFlow = .onboarding
    @Published var generatedRoutine: RoutineResponse?
    
    enum AppFlow {
        case onboarding
        case routineCreator
        case mainApp
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.currentFlow = hasCompletedOnboarding ? .mainApp : .onboarding
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentFlow = .routineCreator
    }
    
    func completeRoutineCreation(with routine: RoutineResponse? = nil) {
        generatedRoutine = routine
        currentFlow = .mainApp
    }
    
    func resetApp() {
        hasCompletedOnboarding = false
        currentFlow = .onboarding
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}
