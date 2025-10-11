//
//  CycleSetupView.swift
//  ManCare
//
//  Onboarding page for menstruation cycle setup
//

import SwiftUI

struct CycleSetupView: View {
    @Environment(\.colorScheme) private var cs

    var onNext: (CycleData?) -> Void

    @State private var lastPeriodDate: Date = Date()
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    @State private var showDatePicker = false
    @State private var showPaywall = false
    @State private var showDefaultDataAlert = false

    // Track if user has edited the default values
    @State private var hasUserEditedCycleData = false
    @State private var hasEditedDate = false
    @State private var hasEditedCycleLength = false
    @State private var hasEditedPeriodLength = false

    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Title section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Track Your Cycle")
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    Text("Your skincare evolves with you — routines adapt to each phase.")
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // ScrollView with content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Visual Element - Cycle Phases Illustration
                        HStack(spacing: 12) {
                            CyclePhaseIcon(
                                phase: .menstrual,
                                icon: "drop.fill",
                                color: ThemeManager.shared.theme.palette.error
                            )
                            CyclePhaseIcon(
                                phase: .follicular,
                                icon: "sparkles",
                                color: ThemeManager.shared.theme.palette.success
                            )
                            CyclePhaseIcon(
                                phase: .ovulation,
                                icon: "sun.max.fill",
                                color: ThemeManager.shared.theme.palette.warning
                            )
                            CyclePhaseIcon(
                                phase: .luteal,
                                icon: "moon.fill",
                                color: ThemeManager.shared.theme.palette.primary
                            )
                        }

                        // Input Section
                        VStack(spacing: 16) {
                            // Last Period Start Date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("When did your last period start?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                Button {
                                    showDatePicker.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.primary)

                                        Text(lastPeriodDate, style: .date)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(hasEditedDate ? ThemeManager.shared.theme.palette.textPrimary : ThemeManager.shared.theme.palette.textMuted)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(ThemeManager.shared.theme.palette.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                            )
                                    )
                                }

                                if showDatePicker {
                                    DatePicker(
                                        "Select Date",
                                        selection: $lastPeriodDate,
                                        in: ...Date(),
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .accentColor(ThemeManager.shared.theme.palette.primary)
                                    .colorScheme(.light)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(ThemeManager.shared.theme.palette.surface)
                                    )
                                    .transition(.opacity.combined(with: .scale))
                                    .onChange(of: lastPeriodDate) { _ in
                                        hasEditedDate = true
                                        hasUserEditedCycleData = true
                                    }
                                }
                            }

                            // Cycle Length
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Average cycle length")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                    Spacer()

                                    Text("\(Int(cycleLength)) days")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(hasEditedCycleLength ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textMuted)
                                }

                                Slider(value: $cycleLength, in: 21...35, step: 1)
                                    .accentColor(ThemeManager.shared.theme.palette.primary)
                                    .onChange(of: cycleLength) { _ in
                                        hasEditedCycleLength = true
                                        hasUserEditedCycleData = true
                                    }

                                Text("Typical range: 21-35 days")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ThemeManager.shared.theme.palette.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                    )
                            )

                            // Period Length
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Period length")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                    Spacer()

                                    Text("\(Int(periodLength)) days")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(hasEditedPeriodLength ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textMuted)
                                }

                                Slider(value: $periodLength, in: 3...7, step: 1)
                                    .accentColor(ThemeManager.shared.theme.palette.primary)
                                    .onChange(of: periodLength) { _ in
                                        hasEditedPeriodLength = true
                                        hasUserEditedCycleData = true
                                    }

                                Text("Typical range: 3-7 days")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ThemeManager.shared.theme.palette.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                    )
                            )

                            // Info Box
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

                                Text("Your cycle data stays private on your device")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                // Buttons - Fixed at bottom
                VStack(spacing: 12) {
                    // Continue Button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                        // Check if user has edited data
                        if !hasUserEditedCycleData {
                            showDefaultDataAlert = true
                        } else {
                            // Save cycle data locally
                            saveCycleDataLocally()
                            // Show paywall
                            showPaywall = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("✨")
                                .font(.system(size: 16))
                            Text("Enable Cycle-Adaptive Routines")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    // Skip Button
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        // Save data locally even if skipped (for future use)
                        saveCycleDataLocally()
                        onNext(nil)
                    } label: {
                        Text("Skip for now")
                    }
                    .buttonStyle(GhostButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 12)
            }
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
        .animation(.easeInOut, value: showDatePicker)
        .alert("Use Default Averages?", isPresented: $showDefaultDataAlert) {
            Button("Edit First", role: .cancel) {
                // Just close the alert
            }
            Button("Continue") {
                // User confirmed to use defaults
                saveCycleDataLocally()
                // Show paywall
                showPaywall = true
            }
        } message: {
            Text("Would you like to use these default averages (28-day cycle, 5-day period) or update them first to match your cycle?")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onSubscribe: {
                    // For testing: act as if subscription was successful
                    let cycleData = CycleData(
                        lastPeriodStartDate: lastPeriodDate,
                        averageCycleLength: Int(cycleLength),
                        periodLength: Int(periodLength)
                    )
                    showPaywall = false
                    onNext(cycleData)
                },
                onClose: {
                    // User closed paywall without subscribing
                    showPaywall = false
                    // Save data locally for future use, but skip activation
                    onNext(nil)
                }
            )
        }
    }

    // MARK: - Helper Functions

    private func saveCycleDataLocally() {
        let cycleData = CycleData(
            lastPeriodStartDate: lastPeriodDate,
            averageCycleLength: Int(cycleLength),
            periodLength: Int(periodLength)
        )

        // Save to CycleStore for future use
        CycleStore().updateCycleData(cycleData)
    }
}

// MARK: - Cycle Phase Icon

private struct CyclePhaseIcon: View {
    let phase: CyclePhase
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(phase.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("CycleSetupView - Light") {
    CycleSetupView(
        onNext: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("CycleSetupView - Dark") {
    CycleSetupView(
        onNext: { _ in }
    )
    .preferredColorScheme(.dark)
}
