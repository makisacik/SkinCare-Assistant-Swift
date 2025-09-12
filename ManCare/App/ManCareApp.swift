//
//  ManCareApp.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

@main
struct ManCareApp: App {
    var body: some Scene {
        WindowGroup {
            MainFlowView()
                .themed(ThemeManager.shared)
        }
    }
}
