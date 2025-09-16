//
//  DiscoverView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var selectedCategory: RoutineCategory = .all
    @State private var showingRoutineDetail: RoutineTemplate?
    @StateObject private var savedRoutineService = CoreDataRoutineService.shared
    
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
            RoutineDetailSheet(routine: routine, savedRoutineService: savedRoutineService)
        }
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
    let savedRoutineService: CoreDataRoutineService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Image
                    ZStack {
                        Image("example-photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.7)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        VStack {
                            Spacer()
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(routine.title)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(routine.stepCount) steps • \(routine.duration)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                            }
                            .padding(24)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Description
                        Text(routine.description)
                            .font(.system(size: 16))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(nil)
                        
                        // Tags
                        if !routine.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 80))
                                ], spacing: 8) {
                                    ForEach(routine.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Steps Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Routine Steps")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            let stepsToShow = isStepsExpanded ? routine.steps : Array(routine.steps.prefix(3))
                            ForEach(Array(stepsToShow.enumerated()), id: \.offset) { index, step in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(ThemeManager.shared.theme.palette.primary)
                                        )
                                    
                                    Text(step)
                                        .font(.system(size: 14))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    
                                    Spacer()
                                }
                            }
                            
                            if routine.steps.count > 3 {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isStepsExpanded.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(isStepsExpanded ? "Show less" : "+ \(routine.steps.count - 3) more steps")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                                        Image(systemName: isStepsExpanded ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.primary)}
                                    .padding(.top, 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // CTA Button
                        Button {
                            savedRoutineService.saveRoutine(routine)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Add to My Routines")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ThemeManager.shared.theme.palette.primary)
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeManager.shared.theme.palette.background)
                    )
                    .padding(.horizontal, 16)
                }
            }
            .background(ThemeManager.shared.theme.palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
            }
        }
    }
}

// MARK: - Extensions
// Note: cornerRadius and RoundedCorner are defined in PresentationModifier.swift

// MARK: - Preview

#Preview("Discover View") {
    DiscoverView()
}
