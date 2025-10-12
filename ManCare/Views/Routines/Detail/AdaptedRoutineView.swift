//
//  AdaptedRoutineView.swift
//  ManCare
//
//  View for displaying cycle-adapted routines
//

import SwiftUI

struct AdaptedRoutineView: View {
    let snapshot: RoutineSnapshot
    @State private var selectedStep: AdaptedStepDetail?
    @State private var showingWhyModal = false

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Briefing Card
                AdaptationBriefingCard(
                    briefing: snapshot.briefing,
                    contextKey: snapshot.contextKey,
                    date: snapshot.date
                )
                .padding(.horizontal)

                // Morning Steps
                if !snapshot.morningSteps.isEmpty {
                    stepSection(
                        title: "Morning Routine",
                        steps: snapshot.morningSteps,
                        icon: "sunrise.fill"
                    )
                }

                // Evening Steps
                if !snapshot.eveningSteps.isEmpty {
                    stepSection(
                        title: "Evening Routine",
                        steps: snapshot.eveningSteps,
                        icon: "moon.stars.fill"
                    )
                }

                // Weekly Steps
                if !snapshot.weeklySteps.isEmpty {
                    stepSection(
                        title: "Weekly Routine",
                        steps: snapshot.weeklySteps,
                        icon: "calendar"
                    )
                }
            }
            .padding(.vertical)
        }
        .background(theme.theme.palette.background.ignoresSafeArea())
        .navigationTitle("Adapted Routine")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingWhyModal) {
            if let step = selectedStep {
                WhyThisAdaptationModal(adaptedStep: step)
                    .environmentObject(theme)
            }
        }
    }

    @ViewBuilder
    private func stepSection(title: String, steps: [AdaptedStepDetail], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.theme.palette.primary)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.theme.palette.textPrimary)

                Spacer()

                Text("\(steps.filter { $0.shouldShow }.count) steps")
                    .font(.caption)
                    .foregroundColor(theme.theme.palette.textSecondary)
            }
            .padding(.horizontal)

            // Steps
            VStack(spacing: 12) {
                ForEach(steps.filter { $0.shouldShow }) { step in
                    AdaptedStepRow(adaptedStep: step) {
                        selectedStep = step
                        showingWhyModal = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Adapted Step Row

struct AdaptedStepRow: View {
    let adaptedStep: AdaptedStepDetail
    let onTapWhyThis: () -> Void

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Emphasis Badge
            emphasisBadge
                .frame(width: 32, height: 32)

            // Step Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(adaptedStep.baseStep.title)
                    .font(.headline)
                    .foregroundColor(theme.theme.palette.textPrimary)

                // Description
                if !adaptedStep.baseStep.stepDescription.isEmpty {
                    Text(adaptedStep.baseStep.stepDescription)
                        .font(.caption)
                        .foregroundColor(theme.theme.palette.textSecondary)
                        .lineLimit(2)
                }

                // Adapted Guidance
                if let guidance = adaptedStep.adaptation?.guidance, !guidance.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption2)
                            .foregroundColor(adaptedStep.emphasisLevel.color)

                        Text(guidance)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(adaptedStep.emphasisLevel.color)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(adaptedStep.emphasisLevel.color.opacity(0.1))
                    )
                }

                // Warnings
                if let warnings = adaptedStep.adaptation?.warnings, !warnings.isEmpty {
                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)

                            Text(warning)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }

                // "Why this?" button
                if adaptedStep.adaptation != nil {
                    Button(action: onTapWhyThis) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                                .font(.caption)

                            Text("Why this?")
                                .font(.caption)
                        }
                        .foregroundColor(theme.theme.palette.primary)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.theme.palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(adaptedStep.emphasisLevel.color.opacity(0.3), lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private var emphasisBadge: some View {
        ZStack {
            Circle()
                .fill(adaptedStep.emphasisLevel.color.opacity(0.2))

            Image(systemName: adaptedStep.emphasisLevel.icon)
                .font(.system(size: 14))
                .foregroundColor(adaptedStep.emphasisLevel.color)
        }
    }
}

// MARK: - Why This Adaptation Modal

struct WhyThisAdaptationModal: View {
    let adaptedStep: AdaptedStepDetail
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Step Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(adaptedStep.baseStep.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.theme.palette.textPrimary)

                        Text(adaptedStep.baseStep.stepDescription)
                            .font(.body)
                            .foregroundColor(theme.theme.palette.textSecondary)
                    }

                    Divider()

                    // Adaptation Info
                    if let adaptation = adaptedStep.adaptation {
                        // Emphasis Level
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adaptation Level")
                                .font(.headline)
                                .foregroundColor(theme.theme.palette.textPrimary)

                            HStack {
                                Image(systemName: adaptation.emphasis.icon)
                                    .foregroundColor(adaptation.emphasis.color)

                                Text(adaptation.emphasis.displayName)
                                    .font(.body)
                                    .foregroundColor(adaptation.emphasis.color)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(adaptation.emphasis.color.opacity(0.1))
                            )
                        }

                        // Guidance
                        if let guidance = adaptation.guidance, !guidance.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Guidance")
                                    .font(.headline)
                                    .foregroundColor(theme.theme.palette.textPrimary)

                                Text(guidance)
                                    .font(.body)
                                    .foregroundColor(theme.theme.palette.textSecondary)
                            }
                        }

                        // Origin
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Source")
                                .font(.headline)
                                .foregroundColor(theme.theme.palette.textPrimary)

                            HStack {
                                Image(systemName: adaptation.origin.icon)
                                    .foregroundColor(theme.theme.palette.primary)

                                Text(adaptation.origin.displayName)
                                    .font(.body)
                                    .foregroundColor(theme.theme.palette.textSecondary)
                            }
                        }

                        // Warnings
                        if !adaptation.warnings.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Warnings")
                                    .font(.headline)
                                    .foregroundColor(theme.theme.palette.textPrimary)

                                ForEach(adaptation.warnings, id: \.self) { warning in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)

                                        Text(warning)
                                            .font(.body)
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.orange.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }

                    // Original Instructions
                    if let how = adaptedStep.baseStep.how, !how.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Original Instructions")
                                .font(.headline)
                                .foregroundColor(theme.theme.palette.textPrimary)

                            Text(how)
                                .font(.body)
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }
                    }
                }
                .padding()
            }
            .background(theme.theme.palette.background)
            .navigationTitle("Why This?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleBriefing = PhaseBriefing(
        contextKey: "follicular",
        title: "Follicular Phase (Days 6-13)",
        summary: "Your skin is resilient and glowing!",
        tips: ["Perfect time for treatments"],
        generalWarnings: []
    )

    let sampleStep = SavedStepDetailModel(
        title: "Exfoliant",
        stepDescription: "Remove dead skin cells",
        stepType: "exfoliant",
        timeOfDay: "morning",
        why: "Promotes cell turnover",
        how: "Apply to clean skin",
        order: 1
    )

    let adaptation = StepAdaptation(
        stepId: sampleStep.id,
        contextKey: "follicular",
        emphasis: .emphasize,
        guidance: "Great time for deeper exfoliation. Your skin can handle more intensive treatment.",
        warnings: []
    )

    let adaptedStep = AdaptedStepDetail(
        baseStep: sampleStep,
        adaptation: adaptation
    )

    let routine = SavedRoutineModel(
        from: RoutineTemplate(
            id: UUID(),
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
        contextKey: "follicular",
        date: Date(),
        adaptedSteps: [adaptedStep],
        briefing: sampleBriefing
    )

    return NavigationView {
        AdaptedRoutineView(snapshot: snapshot)
            .environmentObject(ThemeManager.shared)
    }
}

