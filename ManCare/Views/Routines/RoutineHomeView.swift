//
//  RoutineHomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineHomeView: View {
    
    let generatedRoutine: RoutineResponse?

    @StateObject private var routineTrackingService = RoutineTrackingService()
    @State private var selectedDate = Date()
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingEditRoutine = false
    @State private var showingRoutineDetail: RoutineDetailData?
    @State private var showingMorningRoutineCompletion = false

    var body: some View {
        ZStack {
            // Main background for content area
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.shared.theme.palette.background,       // #F8F6F6 - main background
                    ThemeManager.shared.theme.palette.background,
                    ThemeManager.shared.theme.palette.background,
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Calendar section with its own background extending to top safe area
                VStack(spacing: 0) {
                    // Header with greeting and user icon
                    ModernHeaderView(
                        selectedDate: $selectedDate,
                        routineTrackingService: routineTrackingService
                    )

                    // Calendar Strip
                    CalendarStripView(selectedDate: $selectedDate, routineTrackingService: routineTrackingService)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.primaryLight,     // Lighter primary
                            ThemeManager.shared.theme.palette.primary,          // Base primary
                            ThemeManager.shared.theme.palette.primaryLight
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(.all, edges: .top) // Extend to top safe area
                )

                // Content
                routineTabContent
            }
        }
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }
        .sheet(isPresented: $showingEditRoutine) {
            if let routine = generatedRoutine {
                EditRoutineView(
                    originalRoutine: routine,
                    routineTrackingService: routineTrackingService,
                    onRoutineUpdated: nil
                )
            }
        }
        .sheet(item: $showingRoutineDetail) { routineData in
            RoutineDetailView(
                title: routineData.title,
                iconName: routineData.iconName,
                iconColor: routineData.iconColor,
                steps: routineData.steps,
                routineTrackingService: routineTrackingService,
                selectedDate: selectedDate,
                onStepTap: { step in
                    showingStepDetail = step
                }
            )
        }
        .fullScreenCover(isPresented: $showingMorningRoutineCompletion) {
            MorningRoutineCompletionView(
                routineSteps: generateMorningRoutine(),
                onComplete: {
                    routineTrackingService.objectWillChange.send()
                    showingMorningRoutineCompletion = false
                },
                originalRoutine: generatedRoutine,
                routineTrackingService: routineTrackingService
            )
        }
    }

    @ViewBuilder
    private var routineTabContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Daily Routine Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your daily routine")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Spacer()

                        Button {
                            showingEditRoutine = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Edit routines")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            }
                        }
                    }

                    Text("Tap on a routine to complete")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Morning Routine Card
                RoutineCard(
                    title: "Morning routine",
                    iconName: "sun.max.fill",
                    iconColor: ThemeManager.shared.theme.palette.info,
                    productCount: generateMorningRoutine().count,
                    steps: generateMorningRoutine(),
                    routineTrackingService: routineTrackingService,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingMorningRoutineCompletion = true
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )

                // Evening Routine Card
                RoutineCard(
                    title: "Evening routine",
                    iconName: "moon.fill",
                    iconColor: ThemeManager.shared.theme.palette.primary,
                    productCount: generateEveningRoutine().count,
                    steps: generateEveningRoutine(),
                    routineTrackingService: routineTrackingService,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingRoutineDetail = RoutineDetailData(
                            title: "Evening routine",
                            iconName: "moon.fill",
                            iconColor: ThemeManager.shared.theme.palette.primary,
                            steps: generateEveningRoutine()
                        )
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )

                // UV Index Card
                UVIndexCard()

                // Weekly Routine (if available)
                if let weeklySteps = generateWeeklyRoutine(), !weeklySteps.isEmpty {
                    RoutineCard(
                        title: "Weekly routine",
                        iconName: "calendar",
                        iconColor: ThemeManager.shared.theme.palette.secondary,
                        productCount: weeklySteps.count,
                        steps: weeklySteps,
                        routineTrackingService: routineTrackingService,
                        selectedDate: selectedDate,
                        onRoutineTap: {
                            showingRoutineDetail = RoutineDetailData(
                                title: "Weekly routine",
                                iconName: "calendar",
                                iconColor: ThemeManager.shared.theme.palette.secondary,
                                steps: weeklySteps
                            )
                        },
                        onStepTap: { step in
                            showingStepDetail = step
                        }
                    )
                }
            }
            .padding(.bottom, 100) // Space for bottom navigation
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
                stepType: .faceSerum,
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
                description: "Targeted serum for your skin concerns",
                iconName: "star.fill",
                stepType: .faceSerum,
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

    private func iconNameForStepType(_ stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "drop.fill"
        case .faceSerum:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen:
            return "sun.max.fill"
        default:
            return stepType.iconName
        }
    }

    private func colorForStepType(_ stepType: ProductType) -> Color {
        switch stepType {
        case .cleanser:
            return ThemeManager.shared.theme.palette.info
        case .faceSerum:
            return ThemeManager.shared.theme.palette.primary
        case .moisturizer:
            return ThemeManager.shared.theme.palette.success
        case .sunscreen:
            return ThemeManager.shared.theme.palette.warning
        default:
            return Color(stepType.color)
        }
    }

}


// MARK: - Coach Message View

private struct CoachMessageView: View {
    
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.warning)

            Text(message)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                .fill(ThemeManager.shared.theme.palette.warning.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(ThemeManager.shared.theme.palette.warning.opacity(0.3), lineWidth: 1)
                )
        )
    }
}


// MARK: - Modern Header View

private struct ModernHeaderView: View {
    
    @Binding var selectedDate: Date
    let routineTrackingService: RoutineTrackingService

    private var currentStreak: Int {
        routineTrackingService.getCurrentStreak()
    }

    var body: some View {
        VStack(spacing: 16) {
            // Top bar with streak and date
            HStack {
                // Streak display
                if currentStreak > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.warning)

                        Text("\(currentStreak) day streak")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.theme.palette.warning.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.warning.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                Spacer()

                // Date display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(selectedDate, style: .date)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Today")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Calendar Strip View

private struct CalendarStripView: View {
    
    @Binding var selectedDate: Date
    let routineTrackingService: RoutineTrackingService

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(getWeekDates(), id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        routineTrackingService: routineTrackingService
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }

    private func getWeekDates() -> [Date] {
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
}

// MARK: - Calendar Day View

private struct CalendarDayView: View {
    
    let date: Date
    let isSelected: Bool
    let routineTrackingService: RoutineTrackingService
    let onTap: () -> Void

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private var hasCompletions: Bool {
        let completedSteps = routineTrackingService.getCompletedSteps(for: date)
        return !completedSteps.isEmpty
    }

    private var completionRate: Double {
        // This is a simplified version - in a real app you'd want to track total possible steps
        let completedSteps = routineTrackingService.getCompletedSteps(for: date)
        return completedSteps.isEmpty ? 0.0 : 1.0 // For now, just show if any steps are completed
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

                Text(dateFormatter.string(from: date))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                // Completion indicator
                if hasCompletions {
                    Circle()
                        .fill(isSelected ? ThemeManager.shared.theme.palette.success : ThemeManager.shared.theme.palette.success.opacity(0.8))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 40, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.background : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Routine Card

private struct RoutineCard: View {
    
    let title: String
    let iconName: String
    let iconColor: Color
    let productCount: Int
    let steps: [RoutineStepDetail]
    let routineTrackingService: RoutineTrackingService
    let selectedDate: Date
    let onRoutineTap: () -> Void
    let onStepTap: (RoutineStepDetail) -> Void

    private var completedCount: Int {
        steps.filter { step in
            routineTrackingService.isStepCompleted(stepId: step.id, date: selectedDate)
        }.count
    }

    private var progressPercentage: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }

    var body: some View {
        Button {
            onRoutineTap()
        } label: {
            HStack(spacing: 16) {
                // Icon with progress ring
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    // Progress ring
                    Circle()
                        .stroke(iconColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(iconColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)

                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "#F5C26B"))
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("\(completedCount)/\(productCount) completed")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                Spacer()

                // Progress indicator and arrow
                HStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.shared.theme.palette.background.opacity(0.2),              // Surface color
                                ThemeManager.shared.theme.palette.background.opacity(0.2),
                                ThemeManager.shared.theme.palette.background.opacity(0.2),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1) // #C0B8B8 - Neutral gray border
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

// MARK: - Routine Step Row

private struct RoutineStepRow: View {
    
    let step: RoutineStepDetail
    let isCompleted: Bool
    let onToggle: () -> Void
    let onTap: () -> Void

    @State private var showCheckmarkAnimation = false

    private var stepColor: Color {
        switch step.stepType {
        case .cleanser: return ThemeManager.shared.theme.palette.info
        case .faceSerum: return ThemeManager.shared.theme.palette.primary
        case .moisturizer: return ThemeManager.shared.theme.palette.success
        case .sunscreen: return ThemeManager.shared.theme.palette.warning
        case .faceSunscreen: return ThemeManager.shared.theme.palette.warning
        default: return ThemeManager.shared.theme.palette.textMuted
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onToggle()

                if !isCompleted {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showCheckmarkAnimation = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckmarkAnimation = false
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(stepColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isCompleted {
                        Circle()
                            .fill(stepColor)
                            .frame(width: 20, height: 20)
                            .scaleEffect(showCheckmarkAnimation ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .scaleEffect(showCheckmarkAnimation ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Step content
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isCompleted ? ThemeManager.shared.theme.palette.textMuted : ThemeManager.shared.theme.palette.textPrimary)
                    .strikethrough(isCompleted)

                Text(step.description)
                    .font(.system(size: 12))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    .lineLimit(nil)
            }

            Spacer()

            // Step icon
            Image(systemName: step.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(stepColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.textInverse.opacity(0.1), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}


// MARK: - UV Index Card

private struct UVIndexCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Do you want to see daily UV index here?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("See crucial information about the UV levels based on your location and skin characteristics.")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }

            // SPF Recommendation
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.info)

                Text("Recommended 50 SPF")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.08))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,                // Surface color
                            ThemeManager.shared.theme.palette.surface,             // Accent background
                            ThemeManager.shared.theme.palette.surface.opacity(0.8),                 // Surface alt
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}


// MARK: - Models

struct RoutineStepDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let stepType: ProductType
    let timeOfDay: TimeOfDay
    let why: String?
    let how: String?

    init(id: String, title: String, description: String, iconName: String, stepType: ProductType, timeOfDay: TimeOfDay, why: String? = nil, how: String? = nil) {
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

enum TimeOfDay: String, Codable, CaseIterable {
    case morning, evening, weekly

    var displayName: String {
        switch self {
        case .morning:
            return "Morning"
        case .evening:
            return "Evening"
        case .weekly:
            return "Weekly"
        }
    }
}

struct RoutineDetailData: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let iconColor: Color
    let steps: [RoutineStepDetail]
}


// MARK: - Routine Step Detail View

struct RoutineStepDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    let stepDetail: RoutineStepDetail

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: stepDetail.iconName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }

                // Title
                Text(stepDetail.title)
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)

                // Description
                Text(stepDetail.description)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("RoutineHomeView") {
    RoutineHomeView(
        generatedRoutine: nil
    )
}

