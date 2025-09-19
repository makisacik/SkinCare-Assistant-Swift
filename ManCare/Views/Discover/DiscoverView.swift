//
//  DiscoverView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var routineManager: RoutineManager
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
            RoutineDetailSheet(routine: routine, routineManager: routineManager)
        }
        .onAppear {
            routineManager.loadRoutines()
        }
        .withModernRoutineLoading(routineManager.isLoading)
        .handleModernRoutineError(routineManager.error)
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

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
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

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: RoutineCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .medium))

                Text(category.title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Featured Routine Card

private struct FeaturedRoutineCard: View {
    let routine: RoutineTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Background Image
                ZStack {
                    Image("example-photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 180)
                        .clipped()

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Category badge
                    VStack {
                        HStack {
                            Spacer()
                            Text(routine.category.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(routine.category.color.opacity(0.9))
                                )
                        }
                        Spacer()
                    }
                    .padding(16)

                    // Bottom content
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)

                                Text("\(routine.stepCount) steps • \(routine.duration)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(16)
                    }
                }
                .frame(width: 280, height: 180)
                .cornerRadius(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Routine Grid Card

private struct RoutineGridCard: View {
    let routine: RoutineTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Background Image
                ZStack {
                    Image("example-photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Category badge
                    VStack {
                        HStack {
                            Spacer()
                            Text(routine.category.title)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(routine.category.color.opacity(0.9))
                                )
                        }
                        Spacer()
                    }
                    .padding(12)
                }
                .cornerRadius(12, corners: [.topLeft, .topRight])

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Text(routine.description)
                        .font(.system(size: 13))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .medium))
                            Text(routine.duration)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 10, weight: .medium))
                            Text("\(routine.stepCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                }
                .padding(12)
                .background(
                    RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                        .fill(ThemeManager.shared.theme.palette.surface)
                        .overlay(
                            RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                        )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Routine Detail Sheet

private struct RoutineDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isStepsExpanded = false

    let routine: RoutineTemplate
    let routineManager: RoutineManager

    var body: some View {
        let palette = ThemeManager.shared.theme.palette
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 80))]

        let morningStepsToShow: [String] = {
            if isStepsExpanded { return routine.morningSteps }
            return Array(routine.morningSteps.prefix(2))
        }()

        let eveningStepsToShow: [String] = {
            if isStepsExpanded { return routine.eveningSteps }
            return Array(routine.eveningSteps.prefix(2))
        }()

        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HeroHeader(
                        title: routine.title,
                        subtitle: "\(routine.stepCount) steps • \(routine.duration)"
                    )

                    VStack(alignment: .leading, spacing: 20) {

                        // Description
                        Text(routine.description)
                            .font(.system(size: 16))
                            .foregroundColor(palette.textPrimary)

                        // Tags
                        if !routine.tags.isEmpty {
                            TagsView(tags: routine.tags, palette: palette, columns: columns)
                        }

                        // Steps
                        StepsSection(
                            palette: palette,
                            morningSteps: morningStepsToShow,
                            eveningSteps: eveningStepsToShow,
                            isExpanded: isStepsExpanded,
                            totalStepsCount: routine.steps.count,
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isStepsExpanded.toggle()
                                }
                            }
                        )

                        // CTA
                        CTAButton(
                            title: "Add to My Routines",
                            palette: palette,
                            action: {
                                Task {
                                    do {
                                        let _ = try await routineManager.saveRoutine(routine)
                                        await MainActor.run {
                                            dismiss()
                                        }
                                    } catch {
                                        print("❌ Failed to save routine: \(error)")
                                    }
                                }
                            }
                        )
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(palette.background)
                    )
                    .padding(.horizontal, 16)
                }
            }
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(palette.primary)
                }
            }
        }
    }
}

// MARK: - Subviews

private struct HeroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Image("example-photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(24)
            }
        }
    }
}

private struct TagsView: View {
    let tags: [String]
    let palette: ThemePalette
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(palette.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(palette.primary.opacity(0.1))
                        )
                }
            }
        }
    }
}

private struct StepsSection: View {
    let palette: ThemePalette
    let morningSteps: [String]
    let eveningSteps: [String]
    let isExpanded: Bool
    let totalStepsCount: Int
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Routine Steps")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            if !morningSteps.isEmpty {
                SectionHeader(systemName: "sun.max.fill", title: "Morning", tint: palette.warning)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(morningSteps.indices, id: \.self) { i in
                        StepRow(index: i, text: morningSteps[i], tint: palette.warning, palette: palette)
                    }
                }
            }

            if !eveningSteps.isEmpty {
                SectionHeader(systemName: "moon.fill", title: "Evening", tint: palette.primary)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(eveningSteps.indices, id: \.self) { i in
                        StepRow(index: i, text: eveningSteps[i], tint: palette.primary, palette: palette)
                    }
                }
            }

            if totalStepsCount > 3 {
                Button(action: onToggle) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show less" : "+ \(totalStepsCount - 3) more steps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(palette.primary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(palette.primary)
                    }
                    .padding(.top, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SectionHeader: View {
    let systemName: String
    let title: String
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(tint)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.top, 4)
    }
}

private struct StepRow: View {
    let index: Int
    let text: String
    let tint: Color
    let palette: ThemePalette

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(tint))

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(palette.textPrimary)

            Spacer()
        }
    }
}

private struct CTAButton: View {
    let title: String
    let palette: ThemePalette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(palette.primary)
            )
        }
    }
}

// MARK: - Extensions
// Note: cornerRadius and RoundedCorner are defined in PresentationModifier.swift

// MARK: - Preview

#Preview("Discover View") {
    DiscoverView()
        .environmentObject(RoutineManager())
}
