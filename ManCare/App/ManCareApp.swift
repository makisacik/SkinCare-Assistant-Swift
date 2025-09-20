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
    
    init() {
        // Use factory to create dependencies
        self.routineService = ServiceFactory.shared.createRoutineService()
    }
    
    var body: some Scene {
        WindowGroup {
            MainFlowView()
                // Note: We'll need to pass this down through environment or other means
                // since RoutineService doesn't conform to ObservableObject
        }
    }
}
