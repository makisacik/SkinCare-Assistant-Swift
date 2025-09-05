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
            
            // Progress Indicator (only show on routine tab)
            if selectedTab == .routine {
                ProgressIndicator(
                    morningSteps: generateMorningRoutine(),
                    eveningSteps: generateEveningRoutine(),
                    completedSteps: $completedSteps
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            
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
                // Coach Message
                CoachMessageView(message: getCoachMessage())
                
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
                    timeOfDay: .morning,
                    why: apiStep.why,
                    how: apiStep.how
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
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: "morning_toner",
                title: "Toner",
                description: "Balances pH and prepares skin for next steps",
                iconName: "drop.circle",
                stepType: .treatment,
                timeOfDay: .morning,
                why: "Restores skin's natural pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed"
            ),
            RoutineStepDetail(
                id: "morning_moisturizer",
                title: "Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                iconName: "drop.circle.fill",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: "morning_sunscreen",
                title: "Sunscreen",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                iconName: "sun.max.fill",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevents UV damage, premature aging, and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
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
                    timeOfDay: .evening,
                    why: apiStep.why,
                    how: apiStep.how
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
                timeOfDay: .evening,
                why: "Removes makeup, sunscreen, and daily pollutants",
                how: "Apply to dry skin first, then add water and massage, rinse thoroughly"
            ),
            RoutineStepDetail(
                id: "evening_serum",
                title: "Face Serum",
                description: "Targeted treatment for your skin concerns",
                iconName: "star.fill",
                stepType: .treatment,
                timeOfDay: .evening,
                why: "Active ingredients work best overnight when skin is in repair mode",
                how: "Apply 2-3 drops, pat gently until absorbed, avoid eye area"
            ),
            RoutineStepDetail(
                id: "evening_moisturizer",
                title: "Night Moisturizer",
                description: "Rich cream moisturizer – repairs while you sleep",
                iconName: "moon.circle.fill",
                stepType: .moisturizer,
                timeOfDay: .evening,
                why: "Provides deep hydration and supports overnight skin repair",
                how: "Apply generously, massage in upward motions, let absorb before bed"
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
                timeOfDay: .weekly,
                why: apiStep.why,
                how: apiStep.how
            )
        }
    }
    
    private func getCoachMessage() -> String {
        let hour = Calendar.current.component(.hour, from: selectedDate)
        
        if hour < 12 {
            // Morning messages
            let morningMessages = [
                "Today's focus: hydration — don't skip your moisturizer 💧",
                "It's sunny outside, SPF is your best defense ☀️",
                "Start your day with clean, refreshed skin ✨",
                "Your morning routine sets the tone for the day 🌅"
            ]
            return morningMessages.randomElement() ?? morningMessages[0]
        } else {
            // Evening messages
            let eveningMessages = [
                "Time to unwind and treat your skin 🌙",
                "Your skin repairs while you sleep — give it the best care 💤",
                "Evening routine is your skin's recovery time 🛌",
                "End the day with a relaxing skincare ritual 🧴"
            ]
            return eveningMessages.randomElement() ?? eveningMessages[0]
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
    
    private func colorForStepType(_ stepType: StepType) -> Color {
        switch stepType {
        case .cleanser:
            return .blue
        case .treatment:
            return .purple
        case .moisturizer:
            return .green
        case .sunscreen:
            return .yellow
        case .optional:
            return .orange
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

// MARK: - Progress Indicator

private struct ProgressIndicator: View {
    @Environment(\.themeManager) private var tm
    let morningSteps: [RoutineStepDetail]
    let eveningSteps: [RoutineStepDetail]
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        HStack(spacing: 20) {
            // Morning Progress
            ProgressRing(
                title: "Morning",
                completed: morningCompleted,
                total: morningSteps.count,
                color: .blue
            )
            
            // Evening Progress
            ProgressRing(
                title: "Evening",
                completed: eveningCompleted,
                total: eveningSteps.count,
                color: .purple
            )
        }
    }
    
    private var morningCompleted: Int {
        morningSteps.filter { completedSteps.contains($0.id) }.count
    }
    
    private var eveningCompleted: Int {
        eveningSteps.filter { completedSteps.contains($0.id) }.count
    }
}

// MARK: - Progress Ring

private struct ProgressRing: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let completed: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(completed)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    Text("/\(total)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(tm.theme.palette.textMuted)
                }
            }
            
            Text(title)
                .font(tm.theme.typo.caption.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            if completed == total && total > 0 {
                Text("✅")
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Coach Message View

private struct CoachMessageView: View {
    @Environment(\.themeManager) private var tm
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.yellow)
            
            Text(message)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                .fill(Color.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
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
    
    @State private var showCheckmarkAnimation = false
    @State private var showConfetti = false
    @State private var isExpanded = false
    
    private var stepColor: Color {
        switch step.stepType {
        case .cleanser: return .blue
        case .treatment: return .purple
        case .moisturizer: return .green
        case .sunscreen: return .yellow
        case .optional: return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onToggle()
                
                // Trigger animations
                if !isCompleted {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showCheckmarkAnimation = true
                    }
                    
                    // Check if this is the last step to show confetti
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showConfetti = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showConfetti = false
                        }
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(stepColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Circle()
                            .fill(stepColor)
                            .frame(width: 24, height: 24)
                            .scaleEffect(showCheckmarkAnimation ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(showCheckmarkAnimation ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .onChange(of: isCompleted) { completed in
                if completed {
                    showCheckmarkAnimation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckmarkAnimation = false
                    }
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(tm.theme.typo.title)
                    .foregroundColor(isCompleted ? tm.theme.palette.textMuted : tm.theme.palette.textPrimary)
                    .strikethrough(isCompleted)
                
                Text(step.description)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .lineLimit(isExpanded ? nil : 2)
                
                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        if let why = step.why {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Why:")
                                    .font(tm.theme.typo.caption.weight(.semibold))
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                Text(why)
                                    .font(tm.theme.typo.caption)
                                    .foregroundColor(tm.theme.palette.textSecondary)
                            }
                        }
                        
                        if let how = step.how {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("How:")
                                    .font(tm.theme.typo.caption.weight(.semibold))
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                Text(how)
                                    .font(tm.theme.typo.caption)
                                    .foregroundColor(tm.theme.palette.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            Spacer()
            
            // Expand/Collapse button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(tm.theme.palette.textMuted)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Step icon with color
            Image(systemName: step.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(stepColor)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .overlay(
            // Confetti animation
            ConfettiView(isActive: $showConfetti)
                .allowsHitTesting(false)
        )
    }
}

// MARK: - Confetti View

private struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: 4, height: 4)
                    .position(piece.position)
                    .opacity(piece.opacity)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                createConfetti()
            }
        }
    }
    
    private func createConfetti() {
        confettiPieces.removeAll()
        
        for i in 0..<20 {
            let piece = ConfettiPiece(
                id: i,
                position: CGPoint(x: 100, y: 20),
                color: [.red, .blue, .green, .yellow, .purple, .orange].randomElement() ?? .blue,
                opacity: 1.0
            )
            confettiPieces.append(piece)
            
            // Animate confetti
            withAnimation(.easeOut(duration: 1.0)) {
                if let index = confettiPieces.firstIndex(where: { $0.id == i }) {
                    confettiPieces[index].position = CGPoint(
                        x: CGFloat.random(in: 50...150),
                        y: CGFloat.random(in: 50...100)
                    )
                    confettiPieces[index].opacity = 0.0
                }
            }
        }
        
        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            confettiPieces.removeAll()
        }
    }
}

private struct ConfettiPiece {
    let id: Int
    var position: CGPoint
    let color: Color
    var opacity: Double
}

// MARK: - Models

struct RoutineStepDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let stepType: StepType
    let timeOfDay: TimeOfDay
    let why: String?
    let how: String?
    
    init(id: String, title: String, description: String, iconName: String, stepType: StepType, timeOfDay: TimeOfDay, why: String? = nil, how: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.stepType = stepType
        self.timeOfDay = timeOfDay
        self.why = why
        self.how = how
    }
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
