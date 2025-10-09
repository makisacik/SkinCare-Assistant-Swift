//
//  RoutineHomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineHomeView: View {

    let generatedRoutine: RoutineResponse?
    @Binding var selectedTab: MainTabView.CurrentTab
    let routineService: RoutineServiceProtocol

    @StateObject private var routineViewModel: RoutineHomeViewModel
    @StateObject private var cycleStore = CycleStore()
    @State private var selectedDate = Date()

    init(generatedRoutine: RoutineResponse?, selectedTab: Binding<MainTabView.CurrentTab>, routineService: RoutineServiceProtocol) {
        self.generatedRoutine = generatedRoutine
        self._selectedTab = selectedTab
        self.routineService = routineService
        self._routineViewModel = StateObject(wrappedValue: RoutineHomeViewModel(routineService: routineService))
    }
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
        let selectedDate: Date
    }

    // MARK: - Initialization


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
                print("🏠 RoutineHomeView onAppear")
                print("📊 generatedRoutine: \(generatedRoutine != nil ? "exists" : "nil")")
                print("📊 activeRoutine: \(routineViewModel.activeRoutine?.title ?? "nil")")
                print("📊 savedRoutines count: \(routineViewModel.savedRoutines.count)")

                // Load routines first
                routineViewModel.onAppear()

                // TEMPORARY DEBUG: Check for problematic active routine
                if let activeRoutine = routineViewModel.activeRoutine {
                    let allStepIds = activeRoutine.stepDetails.map { $0.id.uuidString }
                    let uniqueStepIds = Set(allStepIds)
                    if allStepIds.count != uniqueStepIds.count {
                        print("🚨 WARNING: Active routine '\(activeRoutine.title)' has duplicate step IDs!")
                        print("🚨 Total steps: \(allStepIds.count), Unique IDs: \(uniqueStepIds.count)")
                        print("🚨 Consider clearing the routine data to fix duplicates")
                    }    }

                // Auto-save initial routine if available and no active routine exists
                if let routine = generatedRoutine, routineViewModel.activeRoutine == nil {
                    print("💾 Saving initial routine from generatedRoutine")
                    routineViewModel.saveInitialRoutine(from: routine)
                } else {
                    print("⚠️ Not saving routine - generatedRoutine: \(generatedRoutine != nil), activeRoutine: \(routineViewModel.activeRoutine != nil)")
                }}

            VStack(spacing: 0) {
                // Calendar section with its own background extending to top safe area
                VStack(spacing: 0) {
                    // Header with greeting and user icon
                    RoutineHeaderView(
                        selectedDate: $selectedDate,
                        completionViewModel: routineViewModel.completionViewModel
                    )

                    // Calendar Strip
                    CalendarStripView(selectedDate: $selectedDate, completionViewModel: routineViewModel.completionViewModel)
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
            }.withRoutineLoading(routineViewModel.isLoading)
            .handleRoutineError(routineViewModel.error)}
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }.sheet(isPresented: $showingEditRoutine) {
            if let routine = generatedRoutine {
                EditRoutineView(
                    originalRoutine: routine,
                    completionViewModel: routineViewModel.completionViewModel,
                    onRoutineUpdated: nil
                )
            }}
        .sheet(item: $showingRoutineDetail) { routineData in
            RoutineDetailView(
                title: routineData.title,
                iconName: routineData.iconName,
                iconColor: routineData.iconColor,
                steps: routineData.steps,
                completionViewModel: routineViewModel.completionViewModel,
                selectedDate: selectedDate,
                onStepTap: { step in
                    showingStepDetail = step
                },
                routine: routineViewModel.activeRoutine,
                cycleStore: cycleStore
            )
        }        .fullScreenCover(isPresented: $showingMorningRoutineCompletion) {
            MorningRoutineCompletionView(
                routineSteps: generateMorningRoutine(),
                selectedDate: selectedDate,
                completionViewModel: routineViewModel.completionViewModel,
                cycleStore: cycleStore,
                onComplete: {
                    showingMorningRoutineCompletion = false
                },
                originalRoutine: generatedRoutine
            )
        }        .fullScreenCover(isPresented: $showingEveningRoutineCompletion) {
            EveningRoutineCompletionView(
                routineSteps: generateEveningRoutine(),
                selectedDate: selectedDate,
                completionViewModel: routineViewModel.completionViewModel,
                cycleStore: cycleStore,
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
                selectedDate: launch.selectedDate,
                completionViewModel: routineViewModel.completionViewModel,
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
                RoutineSwitcherView(routineViewModel: routineViewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            } else {
                RoutineSwitcherView(routineViewModel: routineViewModel)
            }
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

                        // Current Routine Display
                        if let activeRoutine = routineViewModel.activeRoutine {
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
                        }
                } else {
                            Button {
                                showingRoutineSwitcher = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("My routines")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }
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
                    timeOfDay: .morning,
                    routineViewModel: routineViewModel,
                    completionViewModel: routineViewModel.completionViewModel,
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
                        companionLaunch = CompanionLaunch(routineType: .morning, steps: companionSteps, selectedDate: selectedDate)
                        print("🚀 Set companionLaunch with \(companionSteps.count) steps")
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
                    timeOfDay: .evening,
                    routineViewModel: routineViewModel,
                    completionViewModel: routineViewModel.completionViewModel,
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
                        companionLaunch = CompanionLaunch(routineType: .evening, steps: companionSteps, selectedDate: selectedDate)
                        print("🚀 Set companionLaunch with \(companionSteps.count) steps")
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )

                // Menstruation Cycle Card
                MenstruationCycleCard()

                // UV Index Card
                UVIndexCard()

                // Weekly Routine (if available)
                if let weeklySteps = generateWeeklyRoutine(), !weeklySteps.isEmpty {
                    RoutineCard(
                        title: "Weekly routine",
                        iconName: "calendar",
                        iconColor: ThemeManager.shared.theme.palette.secondary,
                        timeOfDay: .weekly,
                        routineViewModel: routineViewModel,
                        completionViewModel: routineViewModel.completionViewModel,
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
                            companionLaunch = CompanionLaunch(routineType: .weekly, steps: companionSteps, selectedDate: selectedDate)
                            print("🚀 Set companionLaunch with \(companionSteps.count) steps")
                        },
                        onStepTap: { step in
                            showingStepDetail = step
                        }
                    )
                }    }        .padding(.bottom, 100) // Space for bottom navigation
        }}


    // MARK: - Routine Generation

    private func generateMorningRoutine() -> [RoutineStepDetail] {
        // Use active routine from RoutineViewModel if available
        if let activeRoutine = routineViewModel.activeRoutine {
            let morningSteps = activeRoutine.stepDetails.filter { $0.timeOfDay == "morning" }
            print("🐛 DEBUG: Using active routine '\(activeRoutine.title)' with \(morningSteps.count) morning steps")
            for step in morningSteps {
                print("🐛 DEBUG: Morning step - ID: \(step.id), Title: '\(step.title)'")
            }
            return morningSteps.map { stepDetail in
                RoutineStepDetail(
                    id: stepDetail.id.uuidString, // FIXED: Use actual UUID from saved routine
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
            return routine.routine.morning.enumerated().map { (index, apiStep) in
                RoutineStepDetail(
                    id: "morning_\(apiStep.step.rawValue)_\(index)", // Use consistent deterministic ID
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
                id: "morning_cleanser_0",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: "morning_faceSerum_1",
                title: "Toner",
                description: "Balances pH and prepares skin for next steps",
                stepType: .faceSerum,
                timeOfDay: .morning,
                why: "Restores skin's natural pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed"
            ),
            RoutineStepDetail(
                id: "morning_moisturizer_2",
                title: "Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: "morning_sunscreen_3",
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
        if let activeRoutine = routineViewModel.activeRoutine {
            let eveningSteps = activeRoutine.stepDetails.filter { $0.timeOfDay == "evening" }
            print("🐛 DEBUG: Using active routine '\(activeRoutine.title)' with \(eveningSteps.count) evening steps")
            for step in eveningSteps {
                print("🐛 DEBUG: Evening step - ID: \(step.id), Title: '\(step.title)'")
            }
            return eveningSteps.map { stepDetail in
                RoutineStepDetail(
                    id: stepDetail.id.uuidString, // FIXED: Use actual UUID from saved routine
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
            return routine.routine.evening.enumerated().map { (index, apiStep) in
                RoutineStepDetail(
                    id: "evening_\(apiStep.step.rawValue)_\(index)", // Use consistent deterministic ID
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
                id: "evening_cleanser_0",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – removes daily buildup",
                stepType: .cleanser,
                timeOfDay: .evening,
                why: "Removes makeup, sunscreen, and daily pollutants",
                how: "Apply to dry skin first, then add water and massage, rinse thoroughly"
            ),
            RoutineStepDetail(
                id: "evening_faceSerum_1",
                title: "Face Serum",
                description: "Targeted serum for your skin concerns",
                stepType: .faceSerum,
                timeOfDay: .evening,
                why: "Active ingredients work best overnight when skin is in repair mode",
                how: "Apply 2-3 drops, pat gently until absorbed, avoid eye area"
            ),
            RoutineStepDetail(
                id: "evening_moisturizer_2",
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

        return weeklySteps.enumerated().map { (index, apiStep) in
            RoutineStepDetail(
                id: "weekly_\(apiStep.step.rawValue)_\(index)", // Use consistent deterministic ID
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

// MARK: - Routine Header View

private struct RoutineHeaderView: View {

    @Binding var selectedDate: Date
    @ObservedObject var completionViewModel: RoutineCompletionViewModel

    @State private var currentStreak: Int = 0

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
        .onAppear {
            currentStreak = completionViewModel.currentStreak
        }
    }    }
// MARK: - Calendar Strip View

private struct CalendarStripView: View {

    @Binding var selectedDate: Date
    @ObservedObject var completionViewModel: RoutineCompletionViewModel

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
                        completionViewModel: completionViewModel,
                        onTap: {
                            selectedDate = date
                        })
                }}
            .padding(.horizontal, 20)
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
    @ObservedObject var completionViewModel: RoutineCompletionViewModel
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

    @State private var hasCompletions: Bool = false
    @State private var completionRate: Double = 0.0
    
    private var indicatorColor: Color {
        if completionRate >= 1.0 {
            // Fully completed
            return ThemeManager.shared.theme.palette.success
        } else if completionRate >= 0.5 {
            // Partially completed (50% or more)
            return ThemeManager.shared.theme.palette.warning
        } else {
            // Started but low completion
            return ThemeManager.shared.theme.palette.info
        }
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

                // Completion indicator with different states
                if hasCompletions {
                    Circle()
                        .fill(isSelected ? indicatorColor : indicatorColor.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .scaleEffect(completionRate >= 1.0 ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: completionRate)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(width: 40, height: 50)
        .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.background : Color.clear)
            )
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadCompletionsForDate()
        }
        .task(id: date) {
            loadCompletionsForDate()
        }
        .onReceive(completionViewModel.completionChangesStream) { changedDate in
            let calendar = Calendar.current
            if calendar.isDate(changedDate, inSameDayAs: date) {
                print("📅 Calendar day received completion change for \(changedDate)")
                loadCompletionsForDate()
            }
        }
    }

    private func loadCompletionsForDate() {
        Task {
            // Normalize date to start of day for consistency
            let calendar = Calendar.current
            let normalizedDate = calendar.startOfDay(for: date)

            let completedSteps = await completionViewModel.getCompletedSteps(for: normalizedDate)

            // Calculate completion rate based on active routine
            var calculatedCompletionRate: Double = 0.0
            var hasAnyCompletions = false
            if let activeRoutine = completionViewModel.activeRoutine {
                let totalSteps = activeRoutine.stepDetails.count
                if totalSteps > 0 {
                    calculatedCompletionRate = Double(completedSteps.count) / Double(totalSteps)
                }
                hasAnyCompletions = !completedSteps.isEmpty
            } else {
                hasAnyCompletions = !completedSteps.isEmpty
                calculatedCompletionRate = hasAnyCompletions ? 1.0 : 0.0
            }
            await MainActor.run {
                self.hasCompletions = hasAnyCompletions
                self.completionRate = calculatedCompletionRate
            }
        }
    }
}

// MARK: - Routine Card

private struct RoutineCard: View {

    let title: String
    let iconName: String
    let iconColor: Color
    let timeOfDay: TimeOfDay
    @ObservedObject var routineViewModel: RoutineHomeViewModel
    @ObservedObject var completionViewModel: RoutineCompletionViewModel
    let selectedDate: Date
    let onRoutineTap: () -> Void
    let onCompanionTap: () -> Void
    let onStepTap: (RoutineStepDetail) -> Void

    @State private var completedStepsForDate: Set<String> = []
    
    private var steps: [RoutineStepDetail] {
        // Compute steps based on current routine and time of day
        guard let activeRoutine = routineViewModel.activeRoutine else { 
            return []
        }
        
        let routineSteps = activeRoutine.stepDetails.filter { step in
            step.timeOfDay == timeOfDay.rawValue
        }


        return routineSteps.map { stepDetail in
            RoutineStepDetail(
                id: stepDetail.id.uuidString, // FIXED: Use actual UUID
                title: stepDetail.title,
                description: stepDetail.stepDescription,
                stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                timeOfDay: timeOfDay,
                why: stepDetail.why,
                how: stepDetail.how
            )
        }
    }
    
    private var productCount: Int {
        let count = steps.count
        return count
    }
    
    private var completedCount: Int {
        steps.filter { step in
            completedStepsForDate.contains(step.id)
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
                            .foregroundColor(iconColor)
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
        .task(id: selectedDate) {
            // Load completions when date changes
            await loadCompletionsForDate()
        }
        .onReceive(completionViewModel.completionChangesStream) { changedDate in
            let calendar = Calendar.current
            let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
            let normalizedChangedDate = calendar.startOfDay(for: changedDate)
            
            if calendar.isDate(normalizedChangedDate, inSameDayAs: normalizedSelectedDate) {
                Task {
                    await loadCompletionsForDate()
                }
            }
        }
    }

    private func loadCompletionsForDate() async {
        // Normalize date to start of day for consistency
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        
        let completedSteps = await completionViewModel.getCompletedSteps(for: normalizedDate)
        await MainActor.run {
            self.completedStepsForDate = completedSteps
        }
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
        selectedTab: .constant(.routines),
        routineService: ServiceFactory.shared.createMockRoutineService()
    )
}

