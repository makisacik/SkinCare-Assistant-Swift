//
//  RoutineHomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineHomeView: View {
    @Environment(\.themeManager) private var tm
    let generatedRoutine: RoutineResponse?
    let onBackToResults: () -> Void
    
    @State private var selectedDate = Date()
    @State private var completedSteps: Set<String> = []
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var selectedTab: HomeTab = .routine
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            RoutineHomeHeader(
                selectedDate: $selectedDate,
                onBackToResults: onBackToResults
            )
            
            // Tab Selector
            HomeTabSelector(selectedTab: $selectedTab)
            
            // Content
            TabView(selection: $selectedTab) {
                // Routine Tab
                routineTabContent
                    .tag(HomeTab.routine)
                
                // Products Tab
                productsTabContent
                    .tag(HomeTab.products)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }
    }
    
    @ViewBuilder
    private var routineTabContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Morning Routine
                RoutineCalendarSection(
                    title: "Morning Routine",
                    steps: generateMorningRoutine(),
                    iconName: "sun.max.fill",
                    completedSteps: $completedSteps,
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )
                
                // Evening Routine
                RoutineCalendarSection(
                    title: "Evening Routine",
                    steps: generateEveningRoutine(),
                    iconName: "moon.fill",
                    completedSteps: $completedSteps,
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )
                
                // Weekly Routine (if available)
                if let weeklySteps = generateWeeklyRoutine(), !weeklySteps.isEmpty {
                    RoutineCalendarSection(
                        title: "Weekly Routine",
                        steps: weeklySteps,
                        iconName: "calendar",
                        completedSteps: $completedSteps,
                        onStepTap: { step in
                            showingStepDetail = step
                        }
                    )
                }
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private var productsTabContent: some View {
        if let routine = generatedRoutine, !routine.productSlots.isEmpty {
            ProductSlotsView(productSlots: routine.productSlots)
        } else {
            // Fallback product slots
            ProductSlotsView(productSlots: generateFallbackProductSlots())
        }
    }
    
    // MARK: - Routine Generation
    
    private func generateMorningRoutine() -> [RoutineStepDetail] {
        if let routine = generatedRoutine {
            return routine.routine.morning.map { apiStep in
                RoutineStepDetail(
                    id: "morning_\(apiStep.name)",
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    iconName: iconNameForStepType(apiStep.step),
                    stepType: apiStep.step,
                    timeOfDay: .morning
                )
            }
        }
        
        // Fallback routine
        return [
            RoutineStepDetail(
                id: "morning_cleanser",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                iconName: "drop.fill",
                stepType: .cleanser,
                timeOfDay: .morning
            ),
            RoutineStepDetail(
                id: "morning_toner",
                title: "Toner",
                description: "Balances pH and prepares skin for next steps",
                iconName: "drop.circle",
                stepType: .treatment,
                timeOfDay: .morning
            ),
            RoutineStepDetail(
                id: "morning_moisturizer",
                title: "Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                iconName: "drop.circle.fill",
                stepType: .moisturizer,
                timeOfDay: .morning
            ),
            RoutineStepDetail(
                id: "morning_sunscreen",
                title: "Sunscreen",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                iconName: "sun.max.fill",
                stepType: .sunscreen,
                timeOfDay: .morning
            )
        ]
    }
    
    private func generateEveningRoutine() -> [RoutineStepDetail] {
        if let routine = generatedRoutine {
            return routine.routine.evening.map { apiStep in
                RoutineStepDetail(
                    id: "evening_\(apiStep.name)",
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    iconName: iconNameForStepType(apiStep.step),
                    stepType: apiStep.step,
                    timeOfDay: .evening
                )
            }
        }
        
        // Fallback routine
        return [
            RoutineStepDetail(
                id: "evening_cleanser",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – removes daily buildup",
                iconName: "drop.fill",
                stepType: .cleanser,
                timeOfDay: .evening
            ),
            RoutineStepDetail(
                id: "evening_serum",
                title: "Face Serum",
                description: "Targeted treatment for your skin concerns",
                iconName: "star.fill",
                stepType: .treatment,
                timeOfDay: .evening
            ),
            RoutineStepDetail(
                id: "evening_moisturizer",
                title: "Night Moisturizer",
                description: "Rich cream moisturizer – repairs while you sleep",
                iconName: "moon.circle.fill",
                stepType: .moisturizer,
                timeOfDay: .evening
            )
        ]
    }
    
    private func generateWeeklyRoutine() -> [RoutineStepDetail]? {
        guard let routine = generatedRoutine,
              let weeklySteps = routine.routine.weekly else {
            return nil
        }
        
        return weeklySteps.map { apiStep in
            RoutineStepDetail(
                id: "weekly_\(apiStep.name)",
                title: apiStep.name,
                description: "\(apiStep.why) - \(apiStep.how)",
                iconName: iconNameForStepType(apiStep.step),
                stepType: apiStep.step,
                timeOfDay: .weekly
            )
        }
    }
    
    private func iconNameForStepType(_ stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "drop.fill"
        case .treatment:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen:
            return "sun.max.fill"
        case .optional:
            return "plus.circle.fill"
        }
    }
    
    private func generateFallbackProductSlots() -> [ProductSlot] {
        return [
            ProductSlot(
                slotID: "1",
                step: .cleanser,
                time: .AM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["salicylic acid", "niacinamide"]
                ),
                budget: .mid,
                notes: "Choose a gentle formula that suits your skin type."
            ),
            ProductSlot(
                slotID: "2",
                step: .treatment,
                time: .AM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["niacinamide"]
                ),
                budget: .mid,
                notes: "Focus on ingredients that address your main concerns."
            ),
            ProductSlot(
                slotID: "3",
                step: .moisturizer,
                time: .AM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["hyaluronic acid"]
                ),
                budget: .mid,
                notes: "Look for lightweight options that won't clog pores."
            ),
            ProductSlot(
                slotID: "4",
                step: .sunscreen,
                time: .AM,
                constraints: Constraints(
                    spf: 30,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: []
                ),
                budget: .mid,
                notes: "Ensure broad-spectrum protection for daily use."
            ),
            ProductSlot(
                slotID: "5",
                step: .cleanser,
                time: .PM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["salicylic acid", "niacinamide"]
                ),
                budget: .mid,
                notes: "Use the same gentle cleanser as in the morning."
            ),
            ProductSlot(
                slotID: "6",
                step: .treatment,
                time: .PM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["retinol"]
                ),
                budget: .mid,
                notes: "Retinol should be introduced gradually."
            ),
            ProductSlot(
                slotID: "7",
                step: .moisturizer,
                time: .PM,
                constraints: Constraints(
                    spf: 0,
                    fragranceFree: true,
                    sensitiveSafe: true,
                    vegan: true,
                    crueltyFree: true,
                    avoidIngredients: [],
                    preferIngredients: ["peptides"]
                ),
                budget: .mid,
                notes: "Opt for a nourishing night cream."
            )
        ]
    }
}

// MARK: - Home Tab Selector

private struct HomeTabSelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedTab: HomeTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.title)
                            .font(tm.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(selectedTab == tab ? .white : tm.theme.palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        selectedTab == tab ? 
                        tm.theme.palette.secondary : 
                        Color.clear
                    )
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .padding(.horizontal, 20)
    }
}

// MARK: - Routine Home Header

private struct RoutineHomeHeader: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedDate: Date
    let onBackToResults: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Back button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onBackToResults()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)
            
            // Title and Date
            VStack(spacing: 8) {
                Text("Your Routine")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Text(selectedDate, style: .date)
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Routine Calendar Section

private struct RoutineCalendarSection: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let steps: [RoutineStepDetail]
    let iconName: String
    @Binding var completedSteps: Set<String>
    let onStepTap: (RoutineStepDetail) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                Text(title)
                    .font(tm.theme.typo.h2)
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Spacer()
                
                Text("\(completedCount)/\(steps.count)")
                    .font(tm.theme.typo.caption)
                    .foregroundColor(tm.theme.palette.textMuted)
            }
            
            // Steps
            VStack(spacing: 12) {
                ForEach(steps, id: \.id) { step in
                    RoutineCalendarStepRow(
                        step: step,
                        isCompleted: completedSteps.contains(step.id),
                        onTap: {
                            onStepTap(step)
                        },
                        onToggle: {
                            if completedSteps.contains(step.id) {
                                completedSteps.remove(step.id)
                            } else {
                                completedSteps.insert(step.id)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 8, x: 0, y: 4)
    }
    
    private var completedCount: Int {
        steps.filter { completedSteps.contains($0.id) }.count
    }
}

// MARK: - Routine Calendar Step Row

private struct RoutineCalendarStepRow: View {
    @Environment(\.themeManager) private var tm
    let step: RoutineStepDetail
    let isCompleted: Bool
    let onTap: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onToggle()
            } label: {
                ZStack {
                    Circle()
                        .stroke(tm.theme.palette.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Circle()
                            .fill(tm.theme.palette.secondary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(tm.theme.typo.title)
                    .foregroundColor(isCompleted ? tm.theme.palette.textMuted : tm.theme.palette.textPrimary)
                    .strikethrough(isCompleted)
                
                Text(step.description)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Step icon
            Image(systemName: step.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.theme.palette.secondary.opacity(0.7))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Models

struct RoutineStepDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let stepType: StepType
    let timeOfDay: TimeOfDay
}

enum TimeOfDay {
    case morning, evening, weekly
}

enum HomeTab: CaseIterable {
    case routine, products
    
    var title: String {
        switch self {
        case .routine:
            return "Routine"
        case .products:
            return "Products"
        }
    }
    
    var iconName: String {
        switch self {
        case .routine:
            return "calendar"
        case .products:
            return "shopping.cart"
        }
    }
}

// MARK: - Routine Step Detail View

struct RoutineStepDetailView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    let stepDetail: RoutineStepDetail
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: stepDetail.iconName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                // Title
                Text(stepDetail.title)
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(stepDetail.description)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Step Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("RoutineHomeView") {
    RoutineHomeView(
        generatedRoutine: nil,
        onBackToResults: {}
    )
    .themed(ThemeManager())
}
