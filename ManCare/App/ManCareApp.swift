//
//  ManCareApp.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

@main
struct ManCareApp: App {
    // MARK: - Dependencies (No Shared)
    @StateObject private var routineManager = RoutineManager()
    var body: some Scene {
        WindowGroup {
            MainFlowView()
                .environmentObject(routineManager)
        }
    }
}
