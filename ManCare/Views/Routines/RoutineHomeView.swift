//
//  RoutineHomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineHomeView: View {

    @Binding var selectedTab: MainTabView.CurrentTab
    let routineService: RoutineServiceProtocol

    @StateObject private var routineViewModel: RoutineHomeViewModel
    @StateObject private var cycleStore = CycleStore()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedDate = Date()

    init(selectedTab: Binding<MainTabView.CurrentTab>, routineService: RoutineServiceProtocol) {
        self._selectedTab = selectedTab
        self.routineService = routineService
        self._routineViewModel = StateObject(wrappedValue: RoutineHomeViewModel(routineService: routineService))
    }
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingEditRoutine = false
    @State private var showingRoutineDetail: RoutineDetailData?
    @State private var showingMorningRoutineCompletion = false
    @State private var showingEveningRoutineCompletion = false
    @State private var showingRoutineSwitcher = false

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
                print("📊 activeRoutine: \(routineViewModel.activeRoutine?.title ?? "nil")")
                print("📊 savedRoutines count: \(routineViewModel.savedRoutines.count)")

                // Load routines (they are already saved to Core Data from onboarding flow)
                routineViewModel.onAppear()

                // TEMPORARY DEBUG: Check for problematic active routine
                if let activeRoutine = routineViewModel.activeRoutine {
                    let allStepIds = activeRoutine.stepDetails.map { $0.id.uuidString }
                    let uniqueStepIds = Set(allStepIds)
                    if allStepIds.count != uniqueStepIds.count {
                        print("🚨 WARNING: Active routine '\(activeRoutine.title)' has duplicate step IDs!")
                        print("🚨 Total steps: \(allStepIds.count), Unique IDs: \(uniqueStepIds.count)")
                        print("🚨 Consider clearing the routine data to fix duplicates")
                    }
                }
            }

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
                    GeometryReader { geometry in
                        Image("header-background-4")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    .ignoresSafeArea(.all, edges: .top) // Extend to top safe area
                )

                // Content
                routineTabContent
            }.withRoutineLoading(routineViewModel.isLoading)
            .handleRoutineError(routineViewModel.error)}
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }.sheet(isPresented: $showingEditRoutine) {
            if let active = routineViewModel.activeRoutine {
                // Use SavedRoutineModel directly - our single source of truth
                EditRoutineView(
                    savedRoutine: active,
                    completionViewModel: routineViewModel.completionViewModel,
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
                }
            )
        }        .fullScreenCover(isPresented: $showingEveningRoutineCompletion) {
            EveningRoutineCompletionView(
                routineSteps: generateEveningRoutine(),
                selectedDate: selectedDate,
                completionViewModel: routineViewModel.completionViewModel,
                cycleStore: cycleStore,
                onComplete: {
                    showingEveningRoutineCompletion = false
                }
            )
        }.sheet(isPresented: $showingRoutineSwitcher) {
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
                    HStack(alignment: .center) {
                        Text(L10n.Routines.yourDailyRoutine)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Spacer()

                        // Current Routine Display
                        if let activeRoutine = routineViewModel.activeRoutine {
                            let _ = print("🎯 Displaying active routine: \(activeRoutine.title)")
                            Button {
                                showingRoutineSwitcher = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text(activeRoutine.localizedTitle)
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
                                    Text(L10n.Routines.myRoutines)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }
                            }
                        }
                    }

                    Text(L10n.Routines.tapToComplete)
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)


                // Morning Routine Card
                RoutineCard(
                    title: L10n.Routines.morningRoutine,
                    iconName: "sun.max.fill",
                    iconColor: ThemeManager.shared.theme.palette.primary,
                    timeOfDay: .morning,
                    routineViewModel: routineViewModel,
                    completionViewModel: routineViewModel.completionViewModel,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingMorningRoutineCompletion = true
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )

                // Daily Mood Tracking Card
                DailyMoodTrackingCard(selectedDate: selectedDate)

                // Evening Routine Card
                RoutineCard(
                    title: L10n.Routines.eveningRoutine,
                    iconName: "moon.fill",
                    iconColor: ThemeManager.shared.theme.palette.primary,
                    timeOfDay: .evening,
                    routineViewModel: routineViewModel,
                    completionViewModel: routineViewModel.completionViewModel,
                    selectedDate: selectedDate,
                    onRoutineTap: {
                        showingEveningRoutineCompletion = true
                    },
                    onStepTap: { step in
                        showingStepDetail = step
                    }
                )

                // Weather Adaptation Card
                WeatherAdaptationCard()

                // Weekly Routine (if available)
                if let weeklySteps = generateWeeklyRoutine(), !weeklySteps.isEmpty {
                    RoutineCard(
                        title: L10n.Routines.weeklyRoutine,
                        iconName: "calendar",
                        iconColor: ThemeManager.shared.theme.palette.secondary,
                        timeOfDay: .weekly,
                        routineViewModel: routineViewModel,
                        completionViewModel: routineViewModel.completionViewModel,
                        selectedDate: selectedDate,
                        onRoutineTap: {
                            showingRoutineDetail = RoutineDetailData(
                                title: L10n.Routines.weeklyRoutine,
                                iconName: "calendar",
                                iconColor: ThemeManager.shared.theme.palette.secondary,
                                steps: weeklySteps
                            )
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
                    title: stepDetail.localizedTitle,
                    description: stepDetail.localizedDescription,
                    stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                    timeOfDay: .morning,
                    why: stepDetail.localizedWhy,
                    how: stepDetail.localizedHow
                )
            }
        }

        // Fallback routine - this shouldn't happen in normal flow
        print("🐛 DEBUG: Using hardcoded fallback morning routine")
        return [
            RoutineStepDetail(
                id: "morning_cleanser_0",
                title: L10n.Routines.Fallback.Title.morningCleanser,
                description: L10n.Routines.Fallback.Desc.morningCleanser,
                stepType: .cleanser,
                timeOfDay: .morning,
                why: L10n.Routines.Fallback.Why.morningCleanser,
                how: L10n.Routines.Fallback.How.morningCleanser
            ),
            RoutineStepDetail(
                id: "morning_faceSerum_1",
                title: L10n.Routines.Fallback.Title.morningToner,
                description: L10n.Routines.Fallback.Desc.morningToner,
                stepType: .faceSerum,
                timeOfDay: .morning,
                why: L10n.Routines.Fallback.Why.morningToner,
                how: L10n.Routines.Fallback.How.morningToner
            ),
            RoutineStepDetail(
                id: "morning_moisturizer_2",
                title: L10n.Routines.Fallback.Title.morningMoisturizer,
                description: L10n.Routines.Fallback.Desc.morningMoisturizer,
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: L10n.Routines.Fallback.Why.morningMoisturizer,
                how: L10n.Routines.Fallback.How.morningMoisturizer
            ),
            RoutineStepDetail(
                id: "morning_sunscreen_3",
                title: L10n.Routines.Fallback.Title.morningSunscreen,
                description: L10n.Routines.Fallback.Desc.morningSunscreen,
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: L10n.Routines.Fallback.Why.morningSunscreen,
                how: L10n.Routines.Fallback.How.morningSunscreen
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
                    title: stepDetail.localizedTitle,
                    description: stepDetail.localizedDescription,
                    stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                    timeOfDay: .evening,
                    why: stepDetail.localizedWhy,
                    how: stepDetail.localizedHow
                )
            }
        }

        // Fallback routine - this shouldn't happen in normal flow
        print("🐛 DEBUG: Using hardcoded fallback evening routine")
        return [
            RoutineStepDetail(
                id: "evening_cleanser_0",
                title: L10n.Routines.Fallback.Title.eveningCleanser,
                description: L10n.Routines.Fallback.Desc.eveningCleanser,
                stepType: .cleanser,
                timeOfDay: .evening,
                why: L10n.Routines.Fallback.Why.eveningCleanser,
                how: L10n.Routines.Fallback.How.eveningCleanser
            ),
            RoutineStepDetail(
                id: "evening_faceSerum_1",
                title: L10n.Routines.Fallback.Title.eveningSerum,
                description: L10n.Routines.Fallback.Desc.eveningSerum,
                stepType: .faceSerum,
                timeOfDay: .evening,
                why: L10n.Routines.Fallback.Why.eveningSerum,
                how: L10n.Routines.Fallback.How.eveningSerum
            ),
            RoutineStepDetail(
                id: "evening_moisturizer_2",
                title: L10n.Routines.Fallback.Title.eveningMoisturizer,
                description: L10n.Routines.Fallback.Desc.eveningMoisturizer,
                stepType: .moisturizer,
                timeOfDay: .evening,
                why: L10n.Routines.Fallback.Why.eveningMoisturizer,
                how: L10n.Routines.Fallback.How.eveningMoisturizer
            )
        ]
    }

    private func generateWeeklyRoutine() -> [RoutineStepDetail]? {
        // Use active routine from RoutineViewModel if available
        guard let activeRoutine = routineViewModel.activeRoutine else {
            return nil
        }

        let weeklySteps = activeRoutine.stepDetails.filter { $0.timeOfDay == "weekly" }
        guard !weeklySteps.isEmpty else { return nil }

        return weeklySteps.map { stepDetail in
            RoutineStepDetail(
                id: stepDetail.id.uuidString,
                title: stepDetail.localizedTitle,
                description: stepDetail.localizedDescription,
                stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                timeOfDay: .weekly,
                why: stepDetail.localizedWhy,
                how: stepDetail.localizedHow
            )
        }
    }

    private func getCoachMessage() -> String {
        let hour = Calendar.current.component(.hour, from: selectedDate)

        if hour < 12 {
            // Morning messages
            let morningMessages = [
                L10n.Routines.Coach.Morning.hydration,
                L10n.Routines.Coach.Morning.spf,
                L10n.Routines.Coach.Morning.refresh,
                L10n.Routines.Coach.Morning.tone
            ]
            return morningMessages.randomElement() ?? morningMessages[0]
        } else {
            // Evening messages
            let eveningMessages = [
                L10n.Routines.Coach.Evening.unwind,
                L10n.Routines.Coach.Evening.repair,
                L10n.Routines.Coach.Evening.recovery,
                L10n.Routines.Coach.Evening.ritual
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

    var body: some View {
        VStack(spacing: 16) {
            // Top bar with date
            HStack {
                Spacer()

                // Date display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(selectedDate, style: .date)
                        .font(ThemeManager.shared.theme.typo.h2.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                    Text(L10n.Routines.today)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                }    }        .padding(.top, 8)
        }.padding(.horizontal, 20)
        .padding(.bottom, 20)
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
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(getWeekDates(), id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            completionViewModel: completionViewModel,
                            onTap: {
                                selectedDate = date
                            })
                        .frame(width: geometry.size.width / 7)
                    }}
            }
            .padding(.vertical, 12)
        }
        .frame(height: 74)
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

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))

                Text(dateFormatter.string(from: date))
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.textInverse.opacity(0.2) : Color.clear)
                    .padding(.horizontal, 4)
            )
        .buttonStyle(PlainButtonStyle())
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
                title: stepDetail.localizedTitle,
                description: stepDetail.localizedDescription,
                stepType: ProductType(rawValue: stepDetail.stepType) ?? .faceSerum,
                timeOfDay: timeOfDay,
                why: stepDetail.localizedWhy,
                how: stepDetail.localizedHow
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

                        Text(L10n.Routines.progressFormat(completed: completedCount, total: productCount, completedText: L10n.Routines.completed))
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    // Progress indicator and arrow
                    HStack(spacing: 8) {
                        VStack(spacing: 2) {
                            Text(L10n.Routines.progressPercentage(Int(progressPercentage * 100)))
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
                    Text(L10n.Routines.UV.question)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(L10n.Routines.UV.description)
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

                Text(L10n.Routines.UV.recommended)
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
    let adaptedStep: AdaptedStepDetail?

    init(stepDetail: RoutineStepDetail, adaptedStep: AdaptedStepDetail? = nil) {
        self.stepDetail = stepDetail
        self.adaptedStep = adaptedStep
    }

    private var stepColor: Color {
        switch stepDetail.stepType.color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "orange": return ThemeManager.shared.theme.palette.warning
        case "purple": return ThemeManager.shared.theme.palette.primary
        case "red": return ThemeManager.shared.theme.palette.error
        case "pink": return ThemeManager.shared.theme.palette.primary
        case "teal": return ThemeManager.shared.theme.palette.info
        case "indigo": return ThemeManager.shared.theme.palette.info
        case "brown": return ThemeManager.shared.theme.palette.textMuted
        case "gray": return ThemeManager.shared.theme.palette.textMuted
        default: return ThemeManager.shared.theme.palette.primary
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Product Icon and Title Header - Compact Layout
                    HStack(alignment: .top, spacing: 12) {
                        Image(stepDetail.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .clipped()
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(stepDetail.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                            Text(stepDetail.stepType.category.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // Combined Why and How Section
                    if (stepDetail.why != nil && !stepDetail.why!.isEmpty) ||
                       (stepDetail.how != nil && !stepDetail.how!.isEmpty) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let why = stepDetail.why, !why.isEmpty {
                                Text(why)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let how = stepDetail.how, !how.isEmpty,
                               let why = stepDetail.why, !why.isEmpty {
                                Divider()
                                    .padding(.vertical, 4)
                            }

                            if let how = stepDetail.how, !how.isEmpty {
                                Text(how)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ThemeManager.shared.theme.palette.surface)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }

                    // Adaptation Section (Cycle or Weather)
                    if let adapted = adaptedStep, adapted.emphasisLevel != .normal {
                        adaptationSection(adapted: adapted)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 20)
            }
            .background(ThemeManager.shared.theme.palette.background)
            .navigationTitle(L10n.Routines.Detail.stepDetails)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                }
            }
        }
        .modifier(PresentationModifier())
    }

    // MARK: - Adaptation Section (Cycle or Weather)

    private func adaptationSection(adapted: AdaptedStepDetail) -> some View {
        let isCycleAdaptation = ["menstrual", "follicular", "ovulatory", "luteal"].contains(adapted.adaptation?.contextKey ?? "")
        let sectionTitle = isCycleAdaptation ? L10n.Routines.Detail.cycleAdaptation : L10n.Routines.Detail.weatherAdaptation
        let sectionIcon = isCycleAdaptation ? "waveform.path.ecg" : "sun.max.fill"
        let sectionSubtitle = isCycleAdaptation ? L10n.Routines.Detail.basedOnCycle : L10n.Routines.Detail.basedOnWeather

        return VStack(alignment: .leading, spacing: 10) {
            // Section Header with Badge
            HStack(spacing: 8) {
                Image(systemName: sectionIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(adapted.emphasisLevel.color)

                Text(sectionTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()

                // Emphasis Badge - smaller
                ZStack {
                    Circle()
                        .fill(adapted.emphasisLevel.color.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Circle()
                        .stroke(adapted.emphasisLevel.color.opacity(0.3), lineWidth: 1.2)
                        .frame(width: 28, height: 28)

                    Image(systemName: adapted.emphasisLevel.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(adapted.emphasisLevel.color)
                }
            }

            // Emphasis Label
            HStack(spacing: 6) {
                Text(adapted.emphasisLevel.displayName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(adapted.emphasisLevel.color)

                Text(L10n.Routines.sectionSubtitleBullet(sectionSubtitle))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(adapted.emphasisLevel.color.opacity(0.1))
            )

            // Adaptation Guidance
            if let guidance = adapted.adaptation?.guidance, !guidance.isEmpty {
                Text(guidance)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(adapted.emphasisLevel.color)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(adapted.emphasisLevel.color.opacity(0.3), lineWidth: 1.2)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}
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
                    Text(L10n.Routines.chooseRoutine)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Routines.selectActiveRoutine)
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }.padding(.top, 15)

                Spacer()

                Button(L10n.Common.cancel) {
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

                    Text(L10n.Routines.noSavedRoutines)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Routines.saveFromDiscover)
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
                        Text(routine.localizedTitle)
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

                    Text(routine.localizedDescription)
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
                            Text(L10n.Routines.stepsCount(routine.stepCount))
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
        selectedTab: .constant(.routines),
        routineService: ServiceFactory.shared.createMockRoutineService()
    )
}

