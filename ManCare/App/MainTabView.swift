//
//  MainTabView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.themeManager) private var tm
    @State private var selectedTab: Tab = .routines
    let generatedRoutine: RoutineResponse?
    
    enum Tab: String, CaseIterable {
        case routines = "Routines"
        case products = "My Products"
        
        var iconName: String {
            switch self {
            case .routines:
                return "list.bullet.rectangle"
            case .products:
                return "bag.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Routines Tab
            RoutineHomeView(generatedRoutine: generatedRoutine)
                .tabItem {
                    Image(systemName: Tab.routines.iconName)
                    Text(Tab.routines.rawValue)
                }
                .tag(Tab.routines)
            
            // Products Tab
            ProductSlotsView()
                .tabItem {
                    Image(systemName: Tab.products.iconName)
                    Text(Tab.products.rawValue)
                }
                .tag(Tab.products)
        }
        .accentColor(tm.theme.palette.secondary)
        .onAppear {
            // Set up tab bar appearance
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(tm.theme.palette.bg)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(tm.theme.palette.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(tm.theme.palette.textMuted)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(tm.theme.palette.secondary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(tm.theme.palette.secondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


// MARK: - Preview

#Preview("Main Tab View") {
    MainTabView(generatedRoutine: nil)
}
