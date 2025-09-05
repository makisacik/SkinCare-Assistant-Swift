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
        case progress = "Progress"
        case profile = "Profile"
        
        var iconName: String {
            switch self {
            case .routines:
                return "list.bullet.rectangle"
            case .products:
                return "bag.fill"
            case .progress:
                return "chart.line.uptrend.xyaxis"
            case .profile:
                return "person.circle"
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
            
            // Progress Tab
            ProgressView()
                .tabItem {
                    Image(systemName: Tab.progress.iconName)
                    Text(Tab.progress.rawValue)
                }
                .tag(Tab.progress)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: Tab.profile.iconName)
                    Text(Tab.profile.rawValue)
                }
                .tag(Tab.profile)
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

// MARK: - Progress View (Placeholder)

struct ProgressView: View {
    @Environment(\.themeManager) private var tm
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(tm.theme.palette.secondary)
                    
                    Text("Progress Tracking")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("Track your skincare journey and see your improvements over time")
                        .font(tm.theme.typo.sub)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Coming Soon Card
                VStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(tm.theme.palette.secondary)
                    
                    Text("Coming Soon")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("We're working on bringing you detailed progress tracking, habit analytics, and personalized insights.")
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(tm.theme.palette.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    @Environment(\.themeManager) private var tm
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(tm.theme.palette.secondary)
                    
                    Text("Profile")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("Manage your account, preferences, and settings")
                        .font(tm.theme.typo.sub)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Coming Soon Card
                VStack(spacing: 16) {
                    Image(systemName: "gear")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(tm.theme.palette.secondary)
                    
                    Text("Coming Soon")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("We're working on bringing you profile management, account settings, and personalized preferences.")
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(tm.theme.palette.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#Preview("Main Tab View") {
    MainTabView(generatedRoutine: nil)
        .themed(ThemeManager())
}
