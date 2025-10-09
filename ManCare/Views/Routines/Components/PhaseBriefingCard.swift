//
//  PhaseBriefingCard.swift
//  ManCare
//
//  Compact phase briefing card for completion views
//

import SwiftUI

struct PhaseBriefingCard: View {
    let snapshot: RoutineSnapshot?
    let currentDay: Int
    let totalDays: Int
    let isAdapted: Bool
    let onEnableCycleAdaptation: () -> Void

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isAdapted, let snapshot = snapshot {
                // Adapted state - show phase info
                HStack(spacing: 12) {
                    // Phase icon
                    ZStack {
                        Circle()
                            .fill(phaseColor.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: phaseIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(phaseColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(snapshot.briefing.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(theme.theme.palette.textPrimary)

                            Text("•")
                                .foregroundColor(theme.theme.palette.textMuted)

                            Text("Day \(currentDay) of \(totalDays)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }

                        Text(snapshot.briefing.summary)
                            .font(.system(size: 13))
                            .foregroundColor(theme.theme.palette.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                // Status indicator
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(theme.theme.palette.success)

                    Text("Routine adapted to your cycle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.theme.palette.textSecondary)
                }
                .padding(.top, 4)
            } else {
                // Not adapted - show call to action
                HStack(spacing: 12) {
                    // Generic cycle icon
                    ZStack {
                        Circle()
                            .fill(theme.theme.palette.primary.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme.theme.palette.primary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cycle-Adaptive Routines")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.theme.palette.textPrimary)

                        Text("Personalize your routine for each phase")
                            .font(.system(size: 13))
                            .foregroundColor(theme.theme.palette.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Enable button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onEnableCycleAdaptation()
                    } label: {
                        HStack(spacing: 4) {
                            Text("✨")
                                .font(.system(size: 12))
                            Text("Enable")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(theme.theme.palette.onPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(theme.theme.palette.primary)
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isAdapted ? phaseColor.opacity(0.08) : theme.theme.palette.primary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isAdapted ? phaseColor.opacity(0.2) : theme.theme.palette.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var phaseIcon: String {
        guard let snapshot = snapshot else { return "waveform.path.ecg" }
        switch snapshot.contextKey.lowercased() {
        case "menstrual":
            return "drop.fill"
        case "follicular":
            return "sparkles"
        case "ovulation":
            return "sun.max.fill"
        case "luteal":
            return "moon.fill"
        default:
            return "circle.fill"
        }
    }

    private var phaseColor: Color {
        guard let snapshot = snapshot else { return theme.theme.palette.primary }
        switch snapshot.contextKey.lowercased() {
        case "menstrual":
            return theme.theme.palette.error
        case "follicular":
            return theme.theme.palette.success
        case "ovulation":
            return theme.theme.palette.warning
        case "luteal":
            return theme.theme.palette.primary
        default:
            return theme.theme.palette.primary
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleBriefing = PhaseBriefing(
        contextKey: "luteal",
        title: "Luteal Phase",
        summary: "Your skin produces more oil now. Focus on oil control & breakout prevention.",
        tips: ["Use lighter moisturizers", "Add clay masks"],
        generalWarnings: []
    )

    let sampleStep = SavedStepDetailModel(
        title: "Cleanser",
        stepDescription: "Gentle cleanser",
        stepType: "cleanser",
        timeOfDay: "morning",
        why: "Removes oil",
        how: "Apply gently",
        order: 0
    )

    let routine = SavedRoutineModel(
        from: RoutineTemplate(
            title: "Test",
            description: "Test",
            category: .all,
            stepCount: 1,
            duration: "10 min",
            difficulty: .beginner,
            tags: [],
            morningSteps: ["Cleanser"],
            eveningSteps: [],
            benefits: [],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist"
        )
    )

    let snapshot = RoutineSnapshot(
        baseRoutine: routine,
        contextKey: "luteal",
        date: Date(),
        adaptedSteps: [AdaptedStepDetail(baseStep: sampleStep)],
        briefing: sampleBriefing
    )

    return VStack {
        PhaseBriefingCard(
            snapshot: snapshot,
            currentDay: 22,
            totalDays: 28,
            isAdapted: true,
            onEnableCycleAdaptation: {}
        )
        .padding()

        PhaseBriefingCard(
            snapshot: nil,
            currentDay: 22,
            totalDays: 28,
            isAdapted: false,
            onEnableCycleAdaptation: {}
        )
        .padding()

        Spacer()
    }
    .background(ThemeManager.shared.theme.palette.background)
    .environmentObject(ThemeManager.shared)
}

