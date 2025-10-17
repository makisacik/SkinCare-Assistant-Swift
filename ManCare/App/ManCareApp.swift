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

    // Localization manager for reactive language switching
    @StateObject private var localizationManager = LocalizationManager.shared

    init() {
        // Use factory to create dependencies
        self.routineService = ServiceFactory.shared.createRoutineService()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingFlowView()
                .environmentObject(localizationManager)
        }
    }
}
