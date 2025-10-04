//
//  DiscoverView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var listViewModel = RoutineListViewModel(routineService: ServiceFactory.shared.createRoutineService())
    @State private var showingRoutineDetail: RoutineTemplate?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.shared.theme.palette.background,
                    ThemeManager.shared.theme.palette.background,
                    ThemeManager.shared.theme.palette.background,
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header Section
                    headerSection

                    // Trending & Popular Routines
                    featuredSection

                    // All Routines Grid
                    routinesGridSection
                }
                .padding(.bottom, 100) // Space for tab bar
            }
        }
        .sheet(item: $showingRoutineDetail) { routine in
            RoutineDetailSheet(routine: routine, listViewModel: listViewModel)
        }
        .onAppear {
            listViewModel.loadRoutines()
        }
        .withRoutineLoading(listViewModel.isLoading)
        .handleRoutineError(listViewModel.error)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Expert-curated routines for every skin concern")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                Spacer()

                // Profile icon placeholder
                Circle()
                    .fill(ThemeManager.shared.theme.palette.primary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }



    // MARK: - Trending & Popular Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trending & Popular")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()

                Button("See All") {
                    // TODO: Navigate to all featured
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(RoutineTemplate.featuredRoutines, id: \.id) { routine in
                        FeaturedRoutineCard(routine: routine) {
                            showingRoutineDetail = routine
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Routines Grid Section

    private var routinesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("All Routines")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()

                Text("\(filteredRoutines.count) routines")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: gridColumns, alignment: .center, spacing: 20) {
                ForEach(filteredRoutines, id: \.id) { routine in
                    RoutineGridCard(routine: routine) {
                        showingRoutineDetail = routine
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Computed Properties

    private var filteredRoutines: [RoutineTemplate] {
        return RoutineTemplate.allRoutines
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12, alignment: .top),
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12, alignment: .top)
        ]
    }
}


// MARK: - Preview

#Preview("Discover View") {
    DiscoverView()
}
