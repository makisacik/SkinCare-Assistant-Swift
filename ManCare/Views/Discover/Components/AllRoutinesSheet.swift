//
//  AllRoutinesSheet.swift
//  ManCare
//
//  Sheet displaying all premade routines
//

import SwiftUI

struct AllRoutinesSheet: View {
    @ObservedObject var listViewModel: RoutineListViewModel
    let onRoutineTap: (RoutineTemplate) -> Void

    @State private var selectedCategory: RoutineCategory = .all

    var body: some View {
        ZStack {
            // Background
            ThemeManager.shared.theme.palette.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Category filter chips
                    categoryFilterSection

                    // Routines grid
                    routinesGridSection
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(L10n.Discover.allRoutines)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    // MARK: - Category Filter Section

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RoutineCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Routines Grid Section

    private var routinesGridSection: some View {
        LazyVGrid(columns: gridColumns, alignment: .center, spacing: 10) {
            ForEach(filteredRoutines, id: \.id) { routine in
                RoutineGridCard(routine: routine) {
                    onRoutineTap(routine)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Computed Properties

    private var filteredRoutines: [RoutineTemplate] {
        if selectedCategory == .all {
            return RoutineTemplate.allRoutines
        }
        return RoutineTemplate.allRoutines.filter { $0.category == selectedCategory }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12, alignment: .top),
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12, alignment: .top)
        ]
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let category: RoutineCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .semibold))

                Text(category.title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.onPrimary : ThemeManager.shared.theme.palette.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surface)
            )
            .overlay(
                Capsule()
                    .stroke(ThemeManager.shared.theme.palette.border.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AllRoutinesSheet(
            listViewModel: RoutineListViewModel(
                routineService: ServiceFactory.shared.createRoutineService()
            )
        ) { _ in }
    }
}

