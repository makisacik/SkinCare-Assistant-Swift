//
//  DiscoverView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var listViewModel = RoutineListViewModel(routineService: ServiceFactory.shared.createRoutineService())
    @State private var searchText = ""
    @State private var selectedCategory: RoutineCategory = .all
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

                    // Search Bar
                    searchSection

                    // Category Filter
                    categorySection

                    // Featured Routines
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

    // MARK: - Search Section

    private var searchSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                TextField("Search routines...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            )

            // Filter button
            Button {
                // TODO: Show filter options
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Category Section

    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RoutineCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured")
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

            VStack(spacing: 20) {
                ForEach(Array(filteredRoutines.chunked(into: 2).enumerated()), id: \.offset) { index, row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.id) { routine in
                            RoutineGridCard(routine: routine) {
                                showingRoutineDetail = routine
                            }
                            .padding(.bottom, 10)
                            .frame(maxWidth: .infinity)
                        }

                        // Add invisible card to maintain grid structure if odd number of items
                        if row.count == 1 {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Computed Properties

    private var filteredRoutines: [RoutineTemplate] {
        let routines = RoutineTemplate.allRoutines

        let categoryFiltered = selectedCategory == .all ? routines : routines.filter { $0.category == selectedCategory }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { routine in
                routine.title.localizedCaseInsensitiveContains(searchText) ||
                routine.description.localizedCaseInsensitiveContains(searchText) ||
                routine.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}






// MARK: - Preview

#Preview("Discover View") {
    DiscoverView()
}
