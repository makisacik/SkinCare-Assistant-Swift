//
//  ManCareApp.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

@main
struct ManCareApp: App {
    // Create services using factory
    private let routineService: RoutineServiceProtocol
    @StateObject private var appState = AppState()
    
    init() {
        // Use factory to create dependencies
        self.routineService = ServiceFactory.shared.createRoutineService()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentFlow {
                case .onboarding:
                    OnboardingFlowView(
                        onComplete: {
                            appState.completeOnboarding()
                        },
                        onSkipToHome: {
                            appState.completeOnboarding()
                        }
                    )
                case .routineCreator:
                    RoutineCreatorFlow(
                        onComplete: { routine in
                            appState.completeRoutineCreation(with: routine)
                        }
                    )
                case .mainApp:
                    MainTabView(generatedRoutine: appState.generatedRoutine)
                }
            }
            .environmentObject(appState)
        }
    }
}
