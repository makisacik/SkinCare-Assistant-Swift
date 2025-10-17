//
//  RoutineDetailView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineDetailView: View {
    @Environment(\.dismiss) private var dismiss


    let title: String
    let iconName: String
    let iconColor: Color
    let steps: [RoutineStepDetail]
    let completionViewModel: RoutineCompletionViewModel
    let selectedDate: Date
    let onStepTap: (RoutineStepDetail) -> Void
    let routine: SavedRoutineModel? // NEW: For adaptation support
    let cycleStore: CycleStore? // NEW: For cycle adaptations

    @State private var showingStepDetail: RoutineStepDetail?
    @State private var completedCount: Int = 0
    @State private var completedStepIds: Set<String> = []
    @State private var routineSnapshot: RoutineSnapshot? // NEW: Adapted snapshot

    private var progressPercentage: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                contentView
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        }
        .task {
            await loadCompletionData()
            await loadAdaptations()
        }
        .task(id: selectedDate) {
            await loadCompletionData()
            await loadAdaptations()
        }
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }
    }

    private func loadCompletionData() async {
        let completedSteps = await completionViewModel.getCompletedSteps(for: selectedDate)
        let completed = steps.filter { completedSteps.contains($0.id) }

        await MainActor.run {
            self.completedStepIds = completedSteps
            self.completedCount = completed.count
        }
    }

    private func loadAdaptations() async {
        guard let routine = routine,
              routine.adaptationEnabled,
              let cycleStore = cycleStore else {
            return
        }

        // Create adapter service
        let adapterService = ServiceFactory.shared.routineAdapterService(cycleStore: cycleStore)

        // Get adapted snapshot
        if let snapshot = await adapterService.getSnapshot(routine: routine, for: selectedDate) {
            await MainActor.run {
                self.routineSnapshot = snapshot
            }
        }
    }

    private func getAdaptationEmphasis(for step: RoutineStepDetail) -> StepEmphasis? {
        guard let snapshot = routineSnapshot else { return nil }

        // Find the adapted step matching this step ID
        let adaptedStep = snapshot.adaptedSteps.first { $0.baseStep.id.uuidString == step.id }
        return adaptedStep?.emphasisLevel
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.shared.theme.palette.surface,              // Surface color
                ThemeManager.shared.theme.palette.cardBackground,        // Card background
                ThemeManager.shared.theme.palette.surfaceAlt             // Surface alt
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard
                stepsList
                completionMessage
                Spacer(minLength: 100)
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 20) {
            progressIcon
            titleAndProgress
        }
        .padding(24)
        .background(headerBackground)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var progressIcon: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 80, height: 80)

            Circle()
                .stroke(iconColor.opacity(0.3), lineWidth: 4)
                .frame(width: 80, height: 80)

            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(iconColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progressPercentage)

            Image(systemName: iconName)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(iconColor)
        }
    }

    private var titleAndProgress: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                .multilineTextAlignment(.center)

            Text("\(completedCount) of \(steps.count) steps completed")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.7))

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var headerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(ThemeManager.shared.theme.palette.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
            )
    }

    private var stepsList: some View {
        VStack(spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                RoutineDetailStepCard(
                    step: step,
                    stepNumber: index + 1,
                    isCompleted: completedStepIds.contains(step.id),
                    onToggle: {
                        // Use localized title from saved routine if available
                        let localizedTitle: String = {
                            if let routine = routine,
                               let savedStep = routine.stepDetails.first(where: { $0.id.uuidString == step.id }) {
                                return savedStep.localizedTitle
                            }
                            return step.title
                        }()
                        completionViewModel.toggleStepCompletion(
                            stepId: step.id,
                            stepTitle: localizedTitle,
                            stepType: step.stepType,
                            timeOfDay: step.timeOfDay,
                            date: selectedDate
                        )
                    },
                    onTap: {
                        showingStepDetail = step
                    },
                    adaptationEmphasis: getAdaptationEmphasis(for: step)
                )
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var completionMessage: some View {
        if completedCount == steps.count && !steps.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.success)

                Text("Routine Complete! 🎉")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)

                Text("Great job taking care of your skin today!")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.shared.theme.palette.success.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeManager.shared.theme.palette.success.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
        }
    }
}

// MARK: - Routine Detail Step Card

private struct RoutineDetailStepCard: View {

    let step: RoutineStepDetail
    let stepNumber: Int
    let isCompleted: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    let adaptationEmphasis: StepEmphasis? // NEW: For cycle adaptation badge

    @State private var showCheckmarkAnimation = false

    private var stepColor: Color { Color(step.stepType.color) }

    var body: some View {
        HStack(spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(isCompleted ? stepColor : stepColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(stepColor)
                }
            }

            // Step content
            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCompleted ? ThemeManager.shared.theme.palette.textInverse.opacity(0.7) : ThemeManager.shared.theme.palette.textInverse)
                    .strikethrough(isCompleted)

                Text(step.description)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.6))
                    .lineLimit(nil)
            }

            Spacer()

            // Step icon, adaptation badge, and completion button
            HStack(spacing: 12) {
                Image(systemName: step.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(stepColor)

                // Adaptation badge
                if let emphasis = adaptationEmphasis, emphasis != .normal {
                    StepAdaptationBadge(emphasis: emphasis)
                }

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
                            .frame(width: 24, height: 24)

                        if isCompleted {
                            Circle()
                                .fill(stepColor)
                                .frame(width: 24, height: 24)
                                .scaleEffect(showCheckmarkAnimation ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                                .scaleEffect(showCheckmarkAnimation ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.textInverse.opacity(0.1), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("RoutineDetailView") {
    RoutineDetailView(
        title: "Morning Routine",
        iconName: "sun.max.fill",
        iconColor: Color(hex: "#7A8CA8"),
        steps: [
            RoutineStepDetail(
                id: "morning_cleanser",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: "morning_toner",
                title: "Toner",
                description: "Balances pH and prepares skin for next steps",
                stepType: .faceSerum,
                timeOfDay: .morning,
                why: "Restores skin's natural pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed"
            )
        ],
        completionViewModel: RoutineCompletionViewModel.preview,
        selectedDate: Date(),
        onStepTap: { _ in },
        routine: nil,
        cycleStore: nil
    )
}
#endif
