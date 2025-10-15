//
//  MorningRoutineCompletionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MorningRoutineCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var completionViewModel: RoutineCompletionViewModel
    @ObservedObject var cycleStore: CycleStore

    @ObservedObject private var productService = ProductService.shared

    @State private var routineSteps: [RoutineStepDetail]
    let selectedDate: Date
    let onComplete: () -> Void

    init(routineSteps: [RoutineStepDetail], selectedDate: Date, completionViewModel: RoutineCompletionViewModel, cycleStore: CycleStore, onComplete: @escaping () -> Void) {
        self._routineSteps = State(initialValue: routineSteps)
        self.selectedDate = selectedDate
        self.completionViewModel = completionViewModel
        self._cycleStore = ObservedObject(wrappedValue: cycleStore)
        self.onComplete = onComplete
    }
    @State private var completedSteps: Set<String> = []
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingProductSelection: RoutineStepDetail?
    @State private var showingEditRoutine = false
    @State private var showingCompanionMode = false
    @State private var companionLaunch: CompanionLaunch?

    // Payload for Companion presentation
    private struct CompanionLaunch: Identifiable {
        let id = UUID()
        let steps: [CompanionStep]
        let selectedDate: Date
    }

    // MARK: - Cycle Tracking State
    @State private var activeRoutine: SavedRoutineModel?
    @State private var routineSnapshot: RoutineSnapshot?
    @State private var showCyclePromotion = true
    @State private var showCycleSetup = false
    @State private var showEnableConfirmation = false
    @State private var showPaywall = false
    @State private var hasCycleData = false
    private let routineStore = RoutineStore()
    @ObservedObject private var premiumManager = PremiumManager.shared

    // FIXED: Use the passed-in cycleStore instead of creating a new one
    private var adapterService: RoutineAdapterProtocol {
        ServiceFactory.shared.routineAdapterService(cycleStore: cycleStore)
    }

    private var completedStepsCount: Int {
        // Filter completed steps to only include morning routine steps
        let morningStepIds = Set(routineSteps.map { $0.id })
        return completedSteps.intersection(morningStepIds).count
    }
    private var totalSteps: Int {
        routineSteps.count
    }
    private var isRoutineComplete: Bool {
        completedStepsCount == totalSteps
    }

    // MARK: - Cycle Tracking Helpers

    private var shouldShowCycleBanner: Bool {
        guard let routine = activeRoutine else { return false }
        return !routine.adaptationEnabled && showCyclePromotion && cycleBannerDismissCount < 3
    }

    private var cycleBannerDismissCount: Int {
        UserDefaults.standard.integer(forKey: "cycleBannerDismissCount")
    }

    private var currentCycleDay: Int {
        cycleStore.cycleData.currentDayInCycle(for: selectedDate)
    }

    private var totalCycleDays: Int {
        cycleStore.cycleData.averageCycleLength
    }

    private func findAdaptedStep(for stepId: String) -> AdaptedStepDetail? {
        guard let snapshot = routineSnapshot else {
            print("⚠️ [MorningCompletion] No snapshot available for step \(stepId)")
            return nil
        }
        let adaptedStep = snapshot.morningSteps.first { $0.id.uuidString == stepId }
        if let adapted = adaptedStep {
            print("✅ [MorningCompletion] Found adapted step: \(adapted.baseStep.title) - emphasis: \(adapted.emphasisLevel.rawValue)")
        } else {
            print("⚠️ [MorningCompletion] No adapted step found for ID: \(stepId)")
        }
        return adaptedStep
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient

                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Cycle Promotion Banner
                            if shouldShowCycleBanner {
                                CyclePromotionBanner(
                                    onEnable: {
                                        enableCycleTracking()
                                    },
                                    onDismiss: {
                                        showCyclePromotion = false
                                        let count = cycleBannerDismissCount + 1
                                        UserDefaults.standard.set(count, forKey: "cycleBannerDismissCount")
                                    }
                                )
                            }

                            // Steps Section
                            stepsSection

                            Spacer(minLength: 120)
                        }                    .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }                .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea(.all, edges: .bottom))
                }        }        .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingButtons
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                // Load completion state from RoutineManager
                Task {
                    completedSteps = await completionViewModel.getCompletedSteps(for: selectedDate)
                }
            }
            .task {
                // Load active routine and adaptation if enabled
                do {
                    activeRoutine = try await routineStore.fetchActiveRoutine()

                    print("🔍 [MorningCompletion] Active routine: \(activeRoutine?.title ?? "none")")
                    print("🔍 [MorningCompletion] Adaptation enabled: \(activeRoutine?.adaptationEnabled ?? false)")
                    print("🔍 [MorningCompletion] Adaptation type: \(activeRoutine?.adaptationType?.rawValue ?? "none")")

                    if let routine = activeRoutine, routine.adaptationEnabled {
                        print("🔄 [MorningCompletion] Loading adapted snapshot for \(routine.adaptationType?.rawValue ?? "unknown") adaptation")
                        routineSnapshot = await adapterService.getSnapshot(routine: routine, for: selectedDate)
                        print("✅ [MorningCompletion] Snapshot loaded with \(routineSnapshot?.adaptedSteps.count ?? 0) adapted steps")
                        print("📋 [MorningCompletion] Morning steps in snapshot: \(routineSnapshot?.morningSteps.count ?? 0)")
                    } else {
                        print("ℹ️ [MorningCompletion] No adaptation enabled or no active routine")
                    }

                    // Check if cycle data exists
                    let calendar = Calendar.current
                    let daysSinceLastPeriod = calendar.dateComponents([.day], from: cycleStore.cycleData.lastPeriodStartDate, to: Date()).day ?? 0
                    hasCycleData = daysSinceLastPeriod >= 0 && daysSinceLastPeriod < 60
                } catch {
                    print("❌ Error loading active routine: \(error)")
                }
            }
            .task(id: selectedDate) {
                // Reload completions when selected date changes
                completedSteps = await completionViewModel.getCompletedSteps(for: selectedDate)
            }
            .onReceive(completionViewModel.completionChangesStream) { changedDate in
                let calendar = Calendar.current
                let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
                let normalizedChangedDate = calendar.startOfDay(for: changedDate)

                if calendar.isDate(normalizedChangedDate, inSameDayAs: normalizedSelectedDate) {
                    print("🌅 Morning completion view received completion change for \(normalizedChangedDate)")
                    Task {
                        let updatedCompletions = await completionViewModel.getCompletedSteps(for: normalizedSelectedDate)
                        await MainActor.run {
                            print("🔄 Updating morning completion view with \(updatedCompletions.count) completions: \(updatedCompletions)")
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.completedSteps = updatedCompletions
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            Group {
                if let step = showingProductSelection {
                    HalfScreenSheet(
                        isPresented: .constant(true),
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showingProductSelection = nil
                            }                    }                ) {
                        StepProductSelectionSheet(
                            step: step,
                            onDismiss: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showingProductSelection = nil
                                }                        }                    )
                    }            }        }        .allowsHitTesting(showingProductSelection != nil)
        )
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(
                stepDetail: stepDetail,
                adaptedStep: findAdaptedStep(for: stepDetail.id)
            )
        }
        .sheet(isPresented: $showingEditRoutine) {
            if let active = activeRoutine {
                // Use SavedRoutineModel directly (single source of truth)
                EditRoutineView(
                    savedRoutine: active,
                    completionViewModel: completionViewModel,
                    onRoutineUpdated: { updatedRoutine in
                        // Update the routine steps when the routine is edited
                        updateRoutineSteps(from: updatedRoutine)
                    }
                )
            }
        }
        .sheet(isPresented: $showCycleSetup) {
            CycleSetupView { cycleData in
                // After setup, save the cycle data
                if let cycleData = cycleData {
                    cycleStore.updateCycleData(cycleData)
                    hasCycleData = true
                }
                showCycleSetup = false
                // Now enable adaptation
                enableCycleTracking()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onSubscribe: {
                    // Paywall handles premium status via PremiumManager
                    showPaywall = false

                    // Now check if user has cycle data
                    if hasCycleData {
                        // Enable adaptation with existing data
                        enableCycleTracking()
                    } else {
                        // Show cycle setup to collect data
                        showCycleSetup = true
                    }
                },
                onClose: {
                    // User closed paywall without subscribing
                    showPaywall = false
                }
            )
        }
        .alert("Enable Cycle-Adaptive Routine?", isPresented: $showEnableConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Enable") {
                Task {
                    await performEnableCycleTracking()
                }
            }
        } message: {
            let phase = cycleStore.cycleData.currentPhase(for: selectedDate)
            let day = currentCycleDay
            Text("Your routine will automatically adapt based on your cycle phase.\n\nCurrent Phase: \(phase.title) (Day \(day))")
        }
        .fullScreenCover(item: $companionLaunch) { launch in
            CompanionSessionView(
                routineId: "morning_routine",
                routineName: "Morning Routine",
                steps: launch.steps,
                selectedDate: launch.selectedDate,
                completionViewModel: completionViewModel,
                onComplete: {
                    companionLaunch = nil
                }
            )
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ThemeManager.shared.theme.palette.background
            .ignoresSafeArea()
    }
    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            // Morning background image header - extends into safe area
            ZStack {
                // Morning background image
                Image("morning-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all, edges: .top) // Extend into safe area

                VStack(spacing: 16) {
                    // Title and decorations
                    HStack {
                        Text("MORNING ROUTINE")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 2, x: 0, y: 1)

                        Spacer()

                        // Decorative elements
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                        }                }                .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Progress indicator
                    progressIndicator
                }        }        .frame(height: 120)
        }}

    private var progressIndicator: some View {
        HStack(spacing: 12) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index < completedStepsCount ? ThemeManager.shared.theme.palette.background : ThemeManager.shared.theme.palette.border)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index < completedStepsCount ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: completedStepsCount)
                }        }
            Spacer()

            // Completion percentage
            Text("\(totalSteps > 0 ? Int((Double(completedStepsCount) / Double(totalSteps)) * 100) : 0)%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
        }    .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Steps")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("\(totalSteps) products")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                Spacer()

                // Cycle status or enable button
                if activeRoutine?.adaptationEnabled ?? false, activeRoutine?.activeAdaptationTypes.contains(.cycle) ?? false {
                    // Cycle is enabled - show status
                    Text("Routine adapted to your cycle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                } else {
                    // Cycle not enabled - show enable button
                    Button {
                        handleEnableCycleAdaptation()
                    } label: {
                        HStack(spacing: 4) {
                            Text("✨")
                                .font(.system(size: 12))
                            Text("Enable Cycle-Adaptive Routines")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(ThemeManager.shared.theme.palette.primary)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            // Steps list
            VStack(spacing: 20) {
                ForEach(Array(routineSteps.enumerated()), id: \.element.id) { index, step in
                    DetailedStepRow(
                        step: step,
                        stepNumber: index + 1,
                        isCompleted: completedSteps.contains(step.id),
                        onToggle: {
                            toggleStepCompletion(step.id)
                        },
                        onAddProduct: {
                            showingProductSelection = step
                        },
                        onTap: {
                            showingStepDetail = step
                        },
                        adaptedStep: findAdaptedStep(for: step.id),
                        adaptationType: activeRoutine?.adaptationType
                    )
                }        }    }}


    // MARK: - Navigation Buttons

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }}

    private var editButton: some View {
        Button {
            showingEditRoutine = true
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }}

    private var trailingButtons: some View {
        HStack(spacing: 16) {
            playButton
            editButton
        }
    }

    private var playButton: some View {
        Button {
            startCompanionMode()
        } label: {
            Image(systemName: "play.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }

    private var cycleButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if activeRoutine?.adaptationEnabled == true {
                // Cycle is enabled - adaptations shown inline on steps
                // Just provide haptic feedback
            } else {
                // Enable cycle tracking
                enableCycleTracking()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(cycleButtonBackgroundColor)
                    .frame(width: 32, height: 32)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(cycleButtonForegroundColor)
            }
        }
    }

    private var cycleButtonBackgroundColor: Color {
        if let routine = activeRoutine, routine.adaptationEnabled {
            // Show phase color
            let phase = cycleStore.cycleData.currentPhase(for: selectedDate)
            return phase.mainColor.opacity(0.2)
        } else {
            return ThemeManager.shared.theme.palette.border
        }
    }

    private var cycleButtonForegroundColor: Color {
        if let routine = activeRoutine, routine.adaptationEnabled {
            // Show phase color
            let phase = cycleStore.cycleData.currentPhase(for: selectedDate)
            return phase.mainColor
        } else {
            return ThemeManager.shared.theme.palette.textSecondary
        }
    }

    // MARK: - Helper Methods

    private func toggleStepCompletion(_ stepId: String) {
        // Find the step to get its details
        guard let step = routineSteps.first(where: { $0.id == stepId }) else {
            print("❌ Step not found with ID: \(stepId)")
            return
        }

        print("🔄 Toggling step completion - ID: \(stepId), Title: \(step.title)")

        // Immediately update local state for responsive UI
        let wasCompleted = completedSteps.contains(stepId)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if wasCompleted {
                completedSteps.remove(stepId)
                print("✅ Locally removed completion for: \(stepId)")
            } else {
                completedSteps.insert(stepId)
                print("✅ Locally added completion for: \(stepId)")
            }
        }

        // Use the RoutineManager to persist the completion
        completionViewModel.toggleStepCompletion(
            stepId: stepId,
            stepTitle: step.title,
            stepType: step.stepType,
            timeOfDay: step.timeOfDay,
            date: selectedDate
        )

        // Add haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        print("📊 Current completed steps count: \(completedSteps.count)")
        print("📊 Completed steps: \(completedSteps)")
    }
    private func updateRoutineSteps(from routine: RoutineResponse) {
        // Store the current state before updating
        Task {
            let oldCompletedSteps = await completionViewModel.getCompletedSteps(for: selectedDate)
            await MainActor.run {
                self.updateRoutineStepsSync(from: routine, oldCompletedSteps: oldCompletedSteps)
            }    }}

    private func updateRoutineStepsSync(from routine: RoutineResponse, oldCompletedSteps: Set<String>) {
        let oldRoutineSteps = routineSteps

        // Convert the updated routine to RoutineStepDetail array
        routineSteps = routine.routine.morning.enumerated().map { (index, apiStep) in
            RoutineStepDetail(
                id: "morning_\(apiStep.step.rawValue)_\(index)", // Use consistent deterministic ID
                title: apiStep.name,
                description: "\(apiStep.why) - \(apiStep.how)",
                stepType: apiStep.step,
                timeOfDay: .morning,
                why: apiStep.why,
                how: apiStep.how
            )
        }
        // Preserve completion state by mapping old step IDs to new ones
        var newCompletedSteps: Set<String> = []

        // Try to match completed steps by title (since IDs might change)
        for completedStepId in oldCompletedSteps {
            // First try to find the old step to get its title
            if let oldStep = oldRoutineSteps.first(where: { $0.id == completedStepId }) {
                // If the step still exists with the same ID, keep it completed
                if routineSteps.contains(where: { $0.id == completedStepId }) {
                    newCompletedSteps.insert(completedStepId)
                } else {
                    // Try to find a matching step by title
                    if let matchingStep = routineSteps.first(where: { $0.title == oldStep.title }) {
                        newCompletedSteps.insert(matchingStep.id)
                    }            }        }    }
        completedSteps = newCompletedSteps
    }

    // MARK: - Cycle Tracking Functions

    private func handleEnableCycleAdaptation() {
        // Check if user is premium
        if !premiumManager.isPremium {
            // Show paywall for non-premium users
            showPaywall = true
        } else {
            // Premium user - check if they have cycle data
            if hasCycleData {
                // Has data - enable adaptation
                enableCycleTracking()
            } else {
                // No data - show cycle setup
                showCycleSetup = true
            }
        }
    }

    private func enableCycleTracking() {
        // Check if cycle data exists (simple heuristic: last period is within reasonable time)
        let calendar = Calendar.current
        let daysSinceLastPeriod = calendar.dateComponents([.day], from: cycleStore.cycleData.lastPeriodStartDate, to: Date()).day ?? 0
        let hasValidData = daysSinceLastPeriod >= 0 && daysSinceLastPeriod < 60

        if hasValidData {
            // Show confirmation dialog
            showEnableConfirmation = true
        } else {
            // Show cycle setup
            showCycleSetup = true
        }
    }

    private func performEnableCycleTracking() async {
        guard let routine = activeRoutine else { return }

        do {
            try await routineStore.updateAdaptationSettings(
                routineId: routine.id,
                enabled: true,
                type: .cycle
            )

            // Reload routine and generate snapshot
            do {
                activeRoutine = try await routineStore.fetchActiveRoutine()
                if let updated = activeRoutine {
                    routineSnapshot = await adapterService.getSnapshot(
                        routine: updated,
                        for: selectedDate
                    )
                }
            } catch {
                print("❌ Error reloading routine: \(error)")
            }

            // Hide banner and provide success feedback
            await MainActor.run {
                withAnimation {
                    showCyclePromotion = false
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } catch {
            print("❌ Error enabling cycle tracking: \(error)")
        }
    }

    private func startCompanionMode() {
        print("🌅 Starting companion mode for morning routine")
        let companionSteps = routineSteps.enumerated().map { index, step in
            CompanionStep.from(routineStep: step, order: index)
        }
        companionLaunch = CompanionLaunch(
            steps: companionSteps,
            selectedDate: selectedDate
        )
    }

}

// MARK: - Detailed Step Row

private struct DetailedStepRow: View {

    let step: RoutineStepDetail
    let stepNumber: Int
    let isCompleted: Bool
    let onToggle: () -> Void
    let onAddProduct: () -> Void
    let onTap: () -> Void
    let adaptedStep: AdaptedStepDetail? // NEW: Adaptation info
    let adaptationType: AdaptationType? // NEW: For displaying correct label

    @State private var showCheckmarkAnimation = false

    private var stepColor: Color {
        switch step.stepType.color {
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
        }}

    var body: some View {
        HStack(spacing: 0) {
            // Left content area
            VStack(alignment: .leading, spacing: 16) {
                // Horizontal row with step number, icon, name, and badge
                HStack(spacing: 12) {
                    // Step number
                    Text("\(stepNumber)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(stepColor)
                        .frame(width: 40)

                    // Product image
                    Image(step.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)

                    // Step title (smaller font) - allow it to expand and wrap
                    ZStack {
                        Text(step.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Custom strikethrough for iOS 15.6 compatibility
                        if adaptedStep?.emphasisLevel == .skip {
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(ThemeManager.shared.theme.palette.textMuted)
                                    .frame(height: 1.5)
                                    .offset(y: geometry.size.height / 2)
                            }
                        }
                    }

                    Spacer(minLength: 8)
                }

                // Add product button below the horizontal row
                Button {
                    onAddProduct()
                } label: {
                    Text("+ Add your own product")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(stepColor.opacity(0.3))
                        )
                }            .buttonStyle(PlainButtonStyle())
                .padding(.leading, 52) // Align with the image

                // Adaptation guidance - Only show for non-normal emphasis
                if let adapted = adaptedStep, adapted.emphasisLevel != .normal {
                    VStack(alignment: .leading, spacing: 8) {
                        // Emphasis label
                        HStack(spacing: 6) {
                            Image(systemName: adapted.emphasisLevel.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(adapted.emphasisLevel.color)

                            Text(adapted.emphasisLevel.displayName.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(adapted.emphasisLevel.color)

                            // Show label based on adaptation source
                            if ["menstrual", "follicular", "ovulatory", "luteal"].contains(adapted.adaptation?.contextKey ?? "") {
                                Text("• Cycle Adapted")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(adapted.emphasisLevel.color.opacity(0.7))
                            } else {
                                Text("• Based on Weather")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(adapted.emphasisLevel.color.opacity(0.7))
                            }
                        }

                        // Guidance text
                        if let guidance = adapted.adaptation?.guidance, !guidance.isEmpty {
                            Text(guidance)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(adapted.emphasisLevel.color)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(adapted.emphasisLevel.color.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(adapted.emphasisLevel.color.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .padding(.leading, 52) // Align with the image
                }
            }        .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.trailing, 20)
            .padding(.leading, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .opacity(adaptedStep?.emphasisLevel == .skip ? 0.5 : 1.0)

            // Right completion area
            completionArea
        }    .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }

    private var completionArea: some View {
        VStack {
            Spacer()

            // Completion indicator
            ZStack {
                Circle()
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 2)
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary)
                        .frame(width: 40, height: 40)
                        .scaleEffect(showCheckmarkAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)

                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .scaleEffect(showCheckmarkAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                }        }

            // Completion text
            Text(isCompleted ? "Done" : "Tap to complete")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .padding(.top, 4)

            Spacer()
        }    .frame(width: 60)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
        .opacity(0.6) // Decreased opacity for visual distinction
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()

            if !isCompleted {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCheckmarkAnimation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCheckmarkAnimation = false
                }        }    }}
}

// MARK: - Step Product Selection Sheet

private struct StepProductSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var productService = ProductService.shared
    let step: RoutineStepDetail
    let onDismiss: () -> Void

    @State private var showingAddProduct = false
    @State private var selectedProductType: ProductType?

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("Add Product to \(step.title)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }        }        .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Text("Choose from your products or add a new one")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Content
            if getMatchingProducts().isEmpty {
                // Empty state - show add product options
                EmptyProductTypeView(
                    productType: step.stepType,
                    onAddProduct: {
                        selectedProductType = step.stepType
                        showingAddProduct = true
                    }            )
            } else {
                // Show existing products
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(getMatchingProducts(), id: \.id) { product in
                            StepProductRow(
                                product: product,
                                step: step,
                                onSelect: {
                                    // Here you would attach the product to the step
                                    // For now, just dismiss
                                    onDismiss()
                                }                        )
                        }
                        // Add new product option
                        Button {
                            selectedProductType = step.stepType
                            showingAddProduct = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)

                                Text("Add New \(step.stepType.displayName)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)

                                Spacer()
                            }                        .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ThemeManager.shared.theme.palette.info.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.info.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }                    .buttonStyle(PlainButtonStyle())
                    }                .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }        }    }    .sheet(isPresented: $showingAddProduct) {
            if let productType = selectedProductType {
                AddProductView(
                    productService: productService,
                    initialProductType: productType
                ) { newProduct in
                    // Product was added successfully
                    // The product list will be updated automatically via ProductService
                    showingAddProduct = false
                }        }    }}

    private func getMatchingProducts() -> [Product] {
        return productService.userProducts.filter { product in
            product.tagging.productType == step.stepType
        }}
}

// MARK: - Step Product Row

private struct StepProductRow: View {

    let product: Product
    let step: RoutineStepDetail
    let onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // Product image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(productColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(productIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    )

                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }            }
                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }        .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            )
        }    .buttonStyle(PlainButtonStyle())
    }
    private var productColor: Color {
        switch product.tagging.productType.color {
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
        default: return ThemeManager.shared.theme.palette.textMuted
        }}

    private var productIcon: String {
        product.tagging.productType.iconName
    }
}

// MARK: - Empty Product Type View

private struct EmptyProductTypeView: View {

    let productType: ProductType
    let onAddProduct: () -> Void

    private var productColor: Color {
        switch productType.color {
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
        default: return ThemeManager.shared.theme.palette.textMuted
        }}

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(productColor.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(productType.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            // Text
            VStack(spacing: 6) {
                Text("No \(productType.displayName) Added")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text("You don't have any \(productType.displayName.lowercased()) products yet. Add one to get started!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            // Add Product Options
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Scan Product Card
                    Button {
                        // TODO: Implement scan functionality
                        onAddProduct()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                            VStack(spacing: 2) {
                                Text("Scan Product")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                                Text("Take a photo to automatically extract product information")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        }                    .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(productColor)
                        .cornerRadius(10)
                    }                .buttonStyle(PlainButtonStyle())

                    // Or Text
                    VStack {
                        Text("Or")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 6)
                    }

                    // Add Manually Card
                    Button {
                        onAddProduct()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                            VStack(spacing: 2) {
                                Text("Add Manually")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                                Text("Enter product details manually")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        }                    .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(productColor)
                        .cornerRadius(10)
                    }                .buttonStyle(PlainButtonStyle())
                }            .padding(.horizontal, 20)
            }    }    .padding(.vertical, 20)
    }
}


// MARK: - Preview

#if DEBUG
#Preview("MorningRoutineCompletionView") {
    MorningRoutineCompletionView(
        routineSteps: [
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
                title: "Water-based Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Sunscreen SPF 30+",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevents UV damage, premature aging, and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
            )
        ],
        selectedDate: Date(),
        completionViewModel: RoutineCompletionViewModel.preview,
        cycleStore: CycleStore(),
        onComplete: { print("Routine completed!") }
    )
}
#endif
