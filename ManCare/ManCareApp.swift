//
//  ManCareApp.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

@main
struct ManCareApp: App {
    @StateObject private var themeManager = ThemeManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ThemeDemoView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .themed(themeManager)
        }
    }
}
