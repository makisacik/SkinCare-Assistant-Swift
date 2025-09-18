//
//  RoutineHomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineHomeView: View {

    let generatedRoutine: RoutineResponse?
    @Binding var selectedTab: MainTabView.Tab

    @EnvironmentObject var routineManager: RoutineManager
    @State private var routineViewModel: RoutineHomeViewModel?
    @State private var selectedDate = Date()
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingEditRoutine = false
    @State private var showingRoutineDetail: RoutineDetailData?
    @State private var showingMorningRoutineCompletion = false
    @State private var showingEveningRoutineCompletion = false
    @State private var showingCompanionMode = false
    @State private var companionRoutineType: TimeOfDay?
    @State private var companionSteps: [CompanionStep] = []
    @State private var companionLaunch: CompanionLaunch?
    @State private var showingRoutineSwitcher = false

    // Payload for item-based Companion presentation to ensure stable snapshot
    private struct CompanionLaunch: Identifiable {
        let id = UUID()
        let routineType: TimeOfDay
        let steps: [CompanionStep]
    }

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
            .onAppear {
                // Initialize view model if needed
                if routineViewModel == nil {
                    routineViewModel = RoutineHomeViewModel(routineManager: routineManager)
                }
                print("🏠 RoutineHomeView onAppear")
                print("📊 generatedRoutine: \(generatedRoutine != nil ? "exists" : "nil")")
                print("📊 activeRoutine: \(routineViewModel?.activeRoutine?.title ?? "nil")")
                print("📊 savedRoutines count: \(routineViewModel?.savedRoutines.count ?? 0)")

                // Load routines first
                routineViewModel?.onAppear()
                // TEMPORARY DEBUG: Check for problematic active routine
                if let activeRoutine = routineViewModel?.activeRoutine {
                    let allStepIds = activeRoutine.stepDetails.map { $0.id.uuidString }
                    let uniqueStepIds = Set(allStepIds)
                    if allStepIds.count != uniqueStepIds.count {
                        print("🚨 WARNING: Active routine '\(activeRoutine.title)' has duplicate step IDs!")
                        print("🚨 Total steps: \(allStepIds.count), Unique IDs: \(uniqueStepIds.count)")
                        print("🚨 Consider clearing the routine data to fix duplicates")
                    }
                }
                // Auto-save initial routine if available and no active routine exists
                if let routine = generatedRoutine, routineViewModel?.activeRoutine == nil {
                    print("💾 Saving initial routine from generatedRoutine")
                    routineViewModel?.saveInitialRoutine(from: routine)
                } else {
                    print("⚠️ Not saving routine - generatedRoutine: \(generatedRoutine != nil), activeRoutine: \(routineViewModel?.activeRoutine != nil)")
                }
            }

            VStack(spacing: 0) {
                // Calendar section with its own background extending to top safe area
                VStack(spacing: 0) {
                    // Header with greeting and user icon
                    ModernHeaderView(
                        selectedDate: $selectedDate,
                            routineManager: routineManager
                    )

                    // Calendar Strip
                    CalendarStripView(selectedDate: $selectedDate, routineManager: routineManager)
                }        .background(
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
            .withModernRoutineLoading(routineViewModel?.isLoading ?? false)
            .handleModernRoutineError(routineViewModel?.error)}
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }.sheet(isPresented: $showingEditRoutine) {
            if let routine = generatedRoutine {
                EditRoutineView(
                    originalRoutine: routine,
                            routineManager: routineManager,
                    onRoutineUpdated: nil
                )
            }}
        .sheet(item: $showingRoutineDetail) { routineData in
            RoutineDetailView(
                title: routineData.title,
                iconName: routineData.iconName,
                iconColor: routineData.iconColor,
                steps: routineData.steps,
                            routineManager: routineManager,
                selectedDate: selectedDate,
                onStepTap: { step in
                    showingStepDetail = step
                }    )
        }        .fullScreenCover(isPresented: $showingMorningRoutineCompletion) {
            MorningRoutineCompletionView(
                routineSteps: generateMorningRoutine(),
                onComplete: {
                    showingMorningRoutineCompletion = false
                },
                originalRoutine: generatedRoutine
            )
        }        .fullScreenCover(isPresented: $showingEveningRoutineCompletion) {
            EveningRoutineCompletionView(
                routineSteps: generateEveningRoutine(),
                onComplete: {
                    showingEveningRoutineCompletion = false
                },
                originalRoutine: generatedRoutine
            )
        }.fullScreenCover(item: $companionLaunch) { launch in
            CompanionSessionView(
                routineId: "\(launch.routineType.rawValue)_routine",
                routineName: "\(launch.routineType.displayName) Routine",
                steps: launch.steps,
                            routineManager: routineManager,
                onComplete: {
                    companionLaunch = nil
                    companionRoutineType = nil
                    companionSteps = []
                }    )
            .onAppear {
                print("🎭 Companion fullScreenCover appeared with payload")
                print("📋 Routine type in cover: \(launch.routineType.rawValue)")
                print("📝 Steps count in cover: \(launch.steps.count)")
                print("📝 Steps: \(launch.steps.map { $0.title })")
            }}
        .sheet(isPresented: $showingRoutineSwitcher) {
            if #available(iOS 16.0, *) {
                if let routineViewModel = routineViewModel {
                    RoutineSwitcherView(routineViewModel: routineViewModel)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            } else {
                if let routineViewModel = routineViewModel {
                    RoutineSwitcherView(routineViewModel: routineViewModel)
                }
            }                }    }
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

                        // Current Routine Display
                        if let activeRoutine = routineViewModel?.activeRoutine {
                            let _ = print("🎯 Displaying active routine: \(activeRoutine.title)")
                            Button {
                                showingRoutineSwitcher = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text(activeRoutine.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }
                            }                } else {
                            Button {
                                showingRoutineSwitcher = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Choose routine")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }                    }                }            }

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
                            routineManager: routineManager,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingMorningRoutineCompletion = true
                    },
                    onCompanionTap: {
                        print("🌅 Morning companion tap triggered")
                        companionRoutineType = .morning
                        companionSteps = getCompanionSteps(for: .morning)
                        print("🕐 companionRoutineType set to: \(companionRoutineType?.rawValue ?? "nil")")
                        print("📝 companionSteps count: \(companionSteps.count)")
                        companionLaunch = CompanionLaunch(routineType: .morning, steps: companionSteps)
                        print("🚀 Set companionLaunch with \(companionSteps.count) steps")
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }        )

                // Evening Routine Card
                RoutineCard(
                    title: "Evening routine",
                    iconName: "moon.fill",
                    iconColor: ThemeManager.shared.theme.palette.primary,
                    productCount: generateEveningRoutine().count,
                    steps: generateEveningRoutine(),
                            routineManager: routineManager,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingEveningRoutineCompletion = true
                    },
                    onCompanionTap: {
                        print("🌙 Evening companion tap triggered")
                        companionRoutineType = .evening
                        companionSteps = getCompanionSteps(for: .evening)
                        print("🕐 companionRoutineType set to: \(companionRoutineType?.rawValue ?? "nil")")
                        print("📝 companionSteps count: \(companionSteps.count)")
                        companionLaunch = CompanionLaunch(routineType: .evening, steps: companionSteps)
                        print("🚀 Set companionLaunch with \(companionSteps.count) steps")
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }        )

                // Explore Routine Library Card
                ExploreRoutineLibraryCard(selectedTab: $selectedTab)

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
                            routineManager: routineManager,
                        selectedDate: selectedDate,
                        onRoutineTap: {
                            showingRoutineDetail = RoutineDetailData(
                                title: "Weekly routine",
                                iconName: "calendar",
                                iconColor: ThemeManager.shared.theme.palette.secondary,
                                steps: weeklySteps
                            )
                        },
                        onCompanionTap: {
                            print("📅 Weekly companion tap triggered")
                            companionRoutineType = .weekly
                            companionSteps = getCompanionSteps(for: .weekly)
                            print("🕐 companionRoutineType set to: \(companionRoutineType?.rawValue ?? "nil")")
                            print("📝 companionSteps count: \(companionSteps.count)")
                            companionLaunch = CompanionLaunch(routineType: .weekly, steps: companionSteps)
                            print("🚀 Set companionLaunch with \(companionSteps.count) steps")
                        },
                        onStepTap: { step in
                            showingStepDetail = step
                        }            )
                }    }        .padding(.bottom, 100) // Space for bottom navigation
        }}


    // MARK: - Routine Generation

    private func generateMorningRoutine() -> [RoutineStepDetail] {
        // Use active routine from RoutineViewModel if available
        if let activeRoutine = routineViewModel?.activeRoutine {
            let morningSteps = activeRoutine.stepDetails.filter { $0.timeOfDay == "morning" }
            print("🐛 DEBUG: Using active routine '\(activeRoutine.title)' with \(morningSteps.count) morning steps")
            for step in morningSteps {
                print("🐛 DEBUG: Morning step - ID: \(step.id), Title: '\(step.title)'")
            }
            return morningSteps.map { stepDetail in
                RoutineStepDetail(
                    id: stepDetail.id.uuidString,
                    title: stepDetail.title,
                    description: stepDetail.stepDescription,
                    stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                    timeOfDay: .morning,
                    why: stepDetail.why,
                    how: stepDetail.how
                )
            }
        }

        // Fallback to generated routine from onboarding
        if let routine = generatedRoutine {
            print("🐛 DEBUG: Using generated routine from onboarding with \(routine.routine.morning.count) morning steps")
            return routine.routine.morning.map { apiStep in
                RoutineStepDetail(
                    id: UUID().uuidString,
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    stepType: apiStep.step,
                    timeOfDay: .morning,
                    why: apiStep.why,
                    how: apiStep.how
                )
            }}

        // Fallback routine
        print("🐛 DEBUG: Using hardcoded fallback morning routine")
        return [
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Toner",
                description: "Balances pH and prepares skin for next steps",
                stepType: .faceSerum,
                timeOfDay: .morning,
                why: "Restores skin's natural pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Sunscreen",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevents UV damage, premature aging, and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
            )
        ]
    }

    private func generateEveningRoutine() -> [RoutineStepDetail] {
        // Use active routine from RoutineViewModel if available
        if let activeRoutine = routineViewModel?.activeRoutine {
            let eveningSteps = activeRoutine.stepDetails.filter { $0.timeOfDay == "evening" }
            print("🐛 DEBUG: Using active routine '\(activeRoutine.title)' with \(eveningSteps.count) evening steps")
            for step in eveningSteps {
                print("🐛 DEBUG: Evening step - ID: \(step.id), Title: '\(step.title)'")
            }
            return eveningSteps.map { stepDetail in
                RoutineStepDetail(
                    id: stepDetail.id.uuidString,
                    title: stepDetail.title,
                    description: stepDetail.stepDescription,
                    stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                    timeOfDay: .evening,
                    why: stepDetail.why,
                    how: stepDetail.how
                )
            }
        }

        // Fallback to generated routine from onboarding
        if let routine = generatedRoutine {
            print("🐛 DEBUG: Using generated routine from onboarding with \(routine.routine.evening.count) evening steps")
            return routine.routine.evening.map { apiStep in
                RoutineStepDetail(
                    id: UUID().uuidString,
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    stepType: apiStep.step,
                    timeOfDay: .evening,
                    why: apiStep.why,
                    how: apiStep.how
                )
            }}

        // Fallback routine
        print("🐛 DEBUG: Using hardcoded fallback evening routine")
        return [
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – removes daily buildup",
                stepType: .cleanser,
                timeOfDay: .evening,
                why: "Removes makeup, sunscreen, and daily pollutants",
                how: "Apply to dry skin first, then add water and massage, rinse thoroughly"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Face Serum",
                description: "Targeted serum for your skin concerns",
                stepType: .faceSerum,
                timeOfDay: .evening,
                why: "Active ingredients work best overnight when skin is in repair mode",
                how: "Apply 2-3 drops, pat gently until absorbed, avoid eye area"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Night Moisturizer",
                description: "Rich cream moisturizer – repairs while you sleep",
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
                id: UUID().uuidString,
                title: apiStep.name,
                description: "\(apiStep.why) - \(apiStep.how)",
                stepType: apiStep.step,
                timeOfDay: .weekly,
                why: apiStep.why,
                how: apiStep.how
            )
        }}

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
        }}

    // iconName is computed from stepType in the model, not in helper functions

    private func stepTypeForStepName(_ stepName: String) -> ProductType {
        let lowercased = stepName.lowercased()
        if lowercased.contains("cleanser") || lowercased.contains("cleanse") {
            return .cleanser
        } else if lowercased.contains("serum") || lowercased.contains("treatment") {
            return .faceSerum
        } else if lowercased.contains("moisturizer") || lowercased.contains("cream") {
            return .moisturizer
        } else if lowercased.contains("sunscreen") || lowercased.contains("spf") {
            return .sunscreen
        } else {
            return .faceSerum // Default fallback
        }}

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
        }}

    private func getCompanionSteps(for timeOfDay: TimeOfDay) -> [CompanionStep] {
        let routineSteps: [RoutineStepDetail]

        switch timeOfDay {
        case .morning:
            routineSteps = generateMorningRoutine()
        case .evening:
            routineSteps = generateEveningRoutine()
        case .weekly:
            routineSteps = generateWeeklyRoutine() ?? []
        }

        let companionSteps = routineSteps.enumerated().map { index, step in
            CompanionStep.from(routineStep: step, order: index)
        }

        print("Generated \(companionSteps.count) companion steps for \(timeOfDay.rawValue)")
        print("Step titles: \(companionSteps.map { $0.title })")

        return companionSteps
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
        }.padding(16)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                .fill(ThemeManager.shared.theme.palette.warning.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(ThemeManager.shared.theme.palette.warning.opacity(0.3), lineWidth: 1)
                )
        )
                }    }

// MARK: - Modern Header View

private struct ModernHeaderView: View {

    @Binding var selectedDate: Date
    let routineManager: RoutineManager

    private var currentStreak: Int {
        routineManager.getCurrentStreak()
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
                            .foregroundColor(ThemeManager.shared.theme.palette.error)

                        Text("\(currentStreak) day streak")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }            .padding(.horizontal, 12)
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
                }    }        .padding(.top, 8)
        }.padding(.horizontal, 20)
        .padding(.bottom, 20)
                }    }
// MARK: - Calendar Strip View

private struct CalendarStripView: View {

    @Binding var selectedDate: Date
    let routineManager: RoutineManager

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
                            routineManager: routineManager
                    ) {
                        selectedDate = date
                    }        }    }        .padding(.horizontal, 20)
        }.padding(.vertical, 12)
    }

    private func getWeekDates() -> [Date] {
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }                }    }
// MARK: - Calendar Day View

private struct CalendarDayView: View {

    let date: Date
    let isSelected: Bool
    let routineManager: RoutineManager
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
        let completedSteps = routineManager.getCompletedSteps(for: date)
        return !completedSteps.isEmpty
    }

    private var completionRate: Double {
        // This is a simplified version - in a real app you'd want to track total possible steps
        let completedSteps = routineManager.getCompletedSteps(for: date)
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
                }    }        .frame(width: 40, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.background : Color.clear)
            )
        }.buttonStyle(PlainButtonStyle())
                }    }
// MARK: - Modern Routine Card

private struct RoutineCard: View {

    let title: String
    let iconName: String
    let iconColor: Color
    let productCount: Int
    let steps: [RoutineStepDetail]
    let routineManager: RoutineManager
    let selectedDate: Date
    let onRoutineTap: () -> Void
    let onCompanionTap: () -> Void
    let onStepTap: (RoutineStepDetail) -> Void

    private var completedCount: Int {
        // Use lastUpdateTime to trigger UI updates when steps are completed
        let _ = routineManager.lastUpdateTime
        return steps.filter { step in
            routineManager.isStepCompleted(stepId: step.id, date: selectedDate)
        }.count
    }

    private var progressPercentage: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Main routine card
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
                    }        }        .padding(20)
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
            }    .buttonStyle(PlainButtonStyle())

            // Companion mode button
            Button {
                print("🔥 Companion button tapped!")
                onCompanionTap()
            } label: {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)

                    Text("Start Companion Mode")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }        .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.primary.opacity(0.3), lineWidth: 1)
                        )
                )
            }    .buttonStyle(PlainButtonStyle())
        }.padding(.horizontal, 20)
                }    }
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
        }}

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
                    }        }    } label: {
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
                    }        }    }        .buttonStyle(PlainButtonStyle())

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
            Image(step.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
        }.padding(.vertical, 8)
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
        }                }    }

// MARK: - Explore Routine Library Card

private struct ExploreRoutineLibraryCard: View {
    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        Button(action: {
            selectedTab = .discover
        }) {
            VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explore Routine Library")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("Discover Korean Skincare, Anti-Aging, Acne-focused routines →")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }

            // Routine Categories Preview
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)

                Text("Expert-curated routines personalized for you")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()
            }    .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.primary.opacity(0.08))
            )
        }.padding(20)
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
        }.buttonStyle(PlainButtonStyle())
                }    }
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
            }    .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.08))
            )
        }.padding(20)
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
                }    }

// MARK: - Models

struct RoutineStepDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let stepType: ProductType
    let timeOfDay: TimeOfDay
    let why: String?
    let how: String?

    // Computed property - iconName is derived from stepType, not stored
    var iconName: String {
        return ProductIconManager.getIconName(for: stepType)
    }

    init(id: String, title: String, description: String, stepType: ProductType, timeOfDay: TimeOfDay, why: String? = nil, how: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
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
        }                }    }
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
                    Image(stepDetail.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
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
            }    .padding(24)
            .navigationTitle("Step Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }            .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }    }    }                }    }
// MARK: - Preview


// MARK: - Routine Switcher View

struct RoutineSwitcherView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var routineViewModel: RoutineHomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose Routine")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Select your active routine")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }        .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }    .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Routines List
            if routineViewModel.savedRoutines.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                    Text("No saved routines")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Save routines from the Discover tab to see them here")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }        .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(routineViewModel.savedRoutines) { routine in
                            RoutineSwitcherCard(
                                routine: routine,
                                isActive: routineViewModel.activeRoutine?.id == routine.id,
                                onSelect: {
                                    routineViewModel.setActiveRoutine(routine)
                                    dismiss()
                                }                    )
                        }            }            .padding(.horizontal, 20)
                }    }

            Spacer(minLength: 20)
        }.background(ThemeManager.shared.theme.palette.background)
                }    }
// MARK: - Routine Switcher Card

private struct RoutineSwitcherCard: View {
    let routine: SavedRoutineModel
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(routine.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: routine.category.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(routine.category.color)
                }

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(routine.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)

                        Spacer()

                        if isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.success)
                        }            }

                    Text(routine.description)
                        .font(.system(size: 13))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .medium))
                            Text(routine.duration)
                                .font(.system(size: 11, weight: .medium))
                        }                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 10, weight: .medium))
                            Text("\(routine.stepCount) steps")
                                .font(.system(size: 11, weight: .medium))
                        }                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                        Spacer()

                        Text(routine.category.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(routine.category.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(routine.category.color.opacity(0.1))
                            )
                    }        }    }        .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isActive ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border,
                                lineWidth: isActive ? 2 : 1
                            )
                    )
            )
        }.buttonStyle(PlainButtonStyle())
                }    }

#Preview("RoutineHomeView") {
    RoutineHomeView(
        generatedRoutine: nil,
        selectedTab: .constant(.routines)
    )
}

