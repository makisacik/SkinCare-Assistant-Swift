//
//  RoutineResultView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineResultView: View {

    let cycleData: CycleData? // Cycle tracking data
    let onRestart: () -> Void
    let onContinue: () -> Void
    var showStartButton: Bool = true

    @State private var savedRoutine: SavedRoutineModel? = nil
    @State private var isLoadingRoutine = true
    private let routineStore = RoutineStore()

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            if isLoadingRoutine {
                // Loading indicator while routine is being fetched
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(ThemeManager.shared.theme.palette.primary)

                    Text(L10n.Routines.Result.loadingRoutine)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
            } else {
                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Cycle Tracking Badge (if enabled)
                            if cycleData != nil {
                                cycleAdaptationCard
                            }

                            // Steps Section
                            stepsSection

                            // Start Your Journey Button (optional)
                            if showStartButton {
                                startJourneyButton
                                    .padding(.top, 20)
                                    .padding(.bottom, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea(.all, edges: .bottom))
                }
            }
        }
        .task {
            // Load the saved routine from Core Data (single source of truth)
            do {
                // Add a small delay to ensure translations are saved
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                savedRoutine = try await routineStore.fetchActiveRoutine()
                print("✅ [RoutineResultView] Loaded active routine from Core Data: \(savedRoutine?.title ?? "none")")
                isLoadingRoutine = false
            } catch {
                print("❌ [RoutineResultView] Error loading routine from Core Data: \(error)")
                isLoadingRoutine = false
            }
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
            // Header background - extends into safe area
            ZStack {
                // Deep accent gradient background for header
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primaryLight,     // Lighter primary
                        ThemeManager.shared.theme.palette.primary,          // Base primary
                        ThemeManager.shared.theme.palette.primaryLight      // Lighter primary
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all, edges: .top) // Extend into safe area

                VStack(spacing: 16) {
                    // Title and decorations
                    HStack {
                        Text(L10n.Routines.Result.personalizedRoutine)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 2, x: 0, y: 1)

                        Spacer()

                        // Decorative elements
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Subtitle
                    Text(L10n.Routines.Result.basedOnProfile)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 140)
        }
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Morning Routine Section
            VStack(alignment: .leading, spacing: 16) {
                // Section header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Routines.Result.morningRoutine)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text(L10n.Routines.Result.stepsCount(generateMorningRoutine().count))
                            .font(.system(size: 16))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                    Spacer()
                }

                // Morning steps
                VStack(spacing: 20) {
                    ForEach(Array(generateMorningRoutine().enumerated()), id: \.offset) { index, step in
                        RoutineResultStepRow(
                            step: step,
                            stepNumber: index + 1
                        )
                    }
                }
            }

            // Evening Routine Section
            VStack(alignment: .leading, spacing: 16) {
                // Section header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Routines.Result.eveningRoutine)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text(L10n.Routines.Result.stepsCount(generateNightRoutine().count))
                            .font(.system(size: 16))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                    Spacer()
                }

                // Evening steps
                VStack(spacing: 20) {
                    ForEach(Array(generateNightRoutine().enumerated()), id: \.offset) { index, step in
                        RoutineResultStepRow(
                            step: step,
                            stepNumber: index + 1
                        )
                    }
                }
            }

            // Summary card - shows user's profile info
            // (routine-specific summary could be added here if needed)
        }
    }

    // MARK: - Cycle Adaptation Card

    private var cycleAdaptationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.success.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.success)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Routines.Adaptation.cycleAdaptive)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Routines.Adaptation.automaticallyAdapts)
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ThemeManager.shared.theme.palette.success)
            }

            Divider()

            // Explanation
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Routines.Adaptation.howItAdapts)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                adaptationPoint(
                    icon: "drop.fill",
                    color: ThemeManager.shared.theme.palette.error,
                    text: L10n.Routines.Adaptation.menstrualPhase
                )

                adaptationPoint(
                    icon: "sparkles",
                    color: ThemeManager.shared.theme.palette.success,
                    text: L10n.Routines.Adaptation.follicularPhase
                )

                adaptationPoint(
                    icon: "sun.max.fill",
                    color: ThemeManager.shared.theme.palette.warning,
                    text: L10n.Routines.Adaptation.ovulationPhase
                )

                adaptationPoint(
                    icon: "moon.fill",
                    color: ThemeManager.shared.theme.palette.primary,
                    text: L10n.Routines.Adaptation.lutealPhase
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private func adaptationPoint(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Start Journey Button

    private var startJourneyButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onContinue()
        } label: {
            HStack(spacing: 8) {
                Text(L10n.Routines.Result.startJourney)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primary,
                        ThemeManager.shared.theme.palette.primaryLight
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Routine Generation Functions

    private func generateMorningRoutine() -> [RoutineStep] {
        // Use saved routine from Core Data (single source of truth)
        guard let routine = savedRoutine else {
            print("⚠️ [RoutineResultView] No saved routine available for morning steps")
            return []
        }

        let morningSteps = routine.stepDetails.filter { $0.timeOfDay == "morning" }
        return morningSteps.sorted { $0.order < $1.order }.map { stepDetail in
            RoutineStep(
                productType: ProductType(rawValue: stepDetail.stepType) ?? .cleanser,
                title: stepDetail.localizedTitle,
                instructions: stepDetail.localizedDescription
            )
        }
    }

    private func generateNightRoutine() -> [RoutineStep] {
        // Use saved routine from Core Data (single source of truth)
        guard let routine = savedRoutine else {
            print("⚠️ [RoutineResultView] No saved routine available for evening steps")
            return []
        }

        let eveningSteps = routine.stepDetails.filter { $0.timeOfDay == "evening" }
        return eveningSteps.sorted { $0.order < $1.order }.map { stepDetail in
            RoutineStep(
                productType: ProductType(rawValue: stepDetail.stepType) ?? .cleanser,
                title: stepDetail.localizedTitle,
                instructions: stepDetail.localizedDescription
            )
        }
    }
}

// MARK: - Preview
// Note: RoutineResultStepRow is defined in Components/RoutineResultStepRow.swift

#Preview("RoutineResultView") {
    RoutineResultView(
        cycleData: nil,
        onRestart: {},
        onContinue: {}
    )
}

#Preview("RoutineResultView - Cycle Enabled") {
    RoutineResultView(
        cycleData: CycleData(
            lastPeriodStartDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            averageCycleLength: 28,
            periodLength: 5
        ),
        onRestart: {},
        onContinue: {}
    )
}
