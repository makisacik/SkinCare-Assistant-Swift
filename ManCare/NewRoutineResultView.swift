//
//  NewRoutineResultView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct NewRoutineResultView: View {
    @Environment(\.themeManager) private var tm
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    let preferences: Preferences?
    let generatedRoutine: RoutineResponse?
    let onRestart: () -> Void
    let onBack: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            RoutineResultHeader(onBack: onBack)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Morning Routine
                    RoutineSection(
                        title: "Morning",
                        steps: generateMorningRoutine(),
                        iconName: "sun.max.fill"
                    )
                    
                    // Night Routine
                    RoutineSection(
                        title: "Night",
                        steps: generateNightRoutine(),
                        iconName: "moon.fill"
                    )
                    
                    // Summary card
                    SummaryCard(
                        skinType: skinType,
                        concerns: concerns,
                        mainGoal: mainGoal
                    )
                }
                .padding(20)
            }
            
            // CTA Buttons
            VStack(spacing: 12) {
                // Continue Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Continue")
                            .font(tm.theme.typo.title.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(tm.theme.palette.secondary)
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())

                // Reminders Button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    // TODO: Implement reminders functionality
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Turn on reminders")
                            .font(tm.theme.typo.title.weight(.semibold))
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(tm.theme.palette.secondary.opacity(0.1))
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
    }
    
    private func generateMorningRoutine() -> [RoutineStep] {
        // Use generated routine if available
        if let routine = generatedRoutine {
            return routine.routine.morning.map { apiStep in
                RoutineStep(
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    iconName: iconNameForStepType(apiStep.step)
                )
            }
        }

        // Fallback to hardcoded routine
        var steps: [RoutineStep] = []
        
        // Always start with cleanser
        steps.append(RoutineStep(
            title: "Gentle Cleanser",
            description: "Oil-free gel cleanser – reduces shine, clears pores",
            iconName: "drop.fill"
        ))
        
        // Add treatment based on concerns
        if concerns.contains(.acne) {
            steps.append(RoutineStep(
                title: "Acne Treatment",
                description: "Salicylic acid serum – targets breakouts, prevents new ones",
                iconName: "circle.grid.cross.left.fill"
            ))
        }
        
        if concerns.contains(.redness) {
            steps.append(RoutineStep(
                title: "Soothing Serum",
                description: "Centella serum – calms redness, reduces irritation",
                iconName: "thermometer.snowflake"
            ))
        }
        
        // Always end with moisturizer and sunscreen
        steps.append(RoutineStep(
            title: "Moisturizer",
            description: "Lightweight gel moisturizer – hydrates without greasiness",
            iconName: "drop.circle.fill"
        ))
        
        steps.append(RoutineStep(
            title: "Sunscreen",
            description: "SPF 30+ broad spectrum – protects against sun damage",
            iconName: "sun.max.fill"
        ))
        
        return steps
    }
    
    private func generateNightRoutine() -> [RoutineStep] {
        // Use generated routine if available
        if let routine = generatedRoutine {
            return routine.routine.evening.map { apiStep in
                RoutineStep(
                    title: apiStep.name,
                    description: "\(apiStep.why) - \(apiStep.how)",
                    iconName: iconNameForStepType(apiStep.step)
                )
            }
        }

        // Fallback to hardcoded routine
        var steps: [RoutineStep] = []
        
        // Always start with cleanser
        steps.append(RoutineStep(
            title: "Gentle Cleanser",
            description: "Oil-free gel cleanser – removes daily buildup",
            iconName: "drop.fill"
        ))
        
        // Add treatment based on main goal
        switch mainGoal {
        case .reduceBreakouts:
            steps.append(RoutineStep(
                title: "Retinol Treatment",
                description: "Low-strength retinol – unclogs pores, reduces breakouts",
                iconName: "star.fill"
            ))
        case .sootheIrritation:
            steps.append(RoutineStep(
                title: "Repair Serum",
                description: "Ceramide serum – strengthens skin barrier",
                iconName: "shield.fill"
            ))
        case .preventAging:
            steps.append(RoutineStep(
                title: "Anti-aging Serum",
                description: "Peptide serum – boosts collagen, reduces fine lines",
                iconName: "sparkles"
            ))
        default:
            steps.append(RoutineStep(
                title: "Treatment Serum",
                description: "Vitamin C serum – brightens, evens skin tone",
                iconName: "sun.max.fill"
            ))
        }
        
        // Always end with moisturizer
        steps.append(RoutineStep(
            title: "Night Moisturizer",
            description: "Rich cream moisturizer – repairs while you sleep",
            iconName: "moon.circle.fill"
        ))
        
        return steps
    }

    // MARK: - Helper Functions

    private func iconNameForStepType(_ stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "drop.fill"
        case .treatment:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen:
            return "sun.max.fill"
        case .optional:
            return "plus.circle.fill"
        }
    }
}

// MARK: - Routine Section

private struct RoutineSection: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let steps: [RoutineStep]
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                Text(title)
                    .font(tm.theme.typo.h2)
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Spacer()
                
                Text("\(steps.count) steps")
                    .font(tm.theme.typo.caption)
                    .foregroundColor(tm.theme.palette.textMuted)
            }
            
            // Steps
            VStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    RoutineStepRow(step: step, stepNumber: index + 1)
                }
            }
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Routine Step Row

private struct RoutineStepRow: View {
    @Environment(\.themeManager) private var tm
    let step: RoutineStep
    let stepNumber: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(tm.theme.palette.secondary.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("\(stepNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(tm.theme.palette.secondary)
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(tm.theme.typo.title)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text(step.description)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Step icon
            Image(systemName: step.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.theme.palette.secondary.opacity(0.7))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    @Environment(\.themeManager) private var tm
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Profile Summary")
                .font(tm.theme.typo.h3)
                .foregroundColor(tm.theme.palette.textPrimary)
            
            VStack(spacing: 12) {
                ProfileRow(title: "Skin Type", value: skinType.title, iconName: skinType.iconName)
                ProfileRow(title: "Main Goal", value: mainGoal.title, iconName: mainGoal.iconName)
                
                if !concerns.isEmpty {
                    ProfileRow(
                        title: "Focus Areas",
                        value: "\(concerns.count) selected",
                        iconName: "target"
                    )
                }
            }
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Profile Row

private struct ProfileRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.theme.palette.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
        }
    }
}

// MARK: - Models

struct RoutineStep {
    let title: String
    let description: String
    let iconName: String
}

// MARK: - Routine Result Header

private struct RoutineResultHeader: View {
    @Environment(\.themeManager) private var tm
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Back button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)
            
            // Title
            VStack(spacing: 8) {
                Text("Your personalized routine")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Based on your skin type and selected concerns")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
        }
    }
}

#Preview("NewRoutineResultView") {
    NewRoutineResultView(
        skinType: .combination,
        concerns: [.acne, .redness],
        mainGoal: .reduceBreakouts,
        preferences: nil,
        generatedRoutine: nil,
        onRestart: {},
        onBack: {},
        onContinue: {}
    )
    .themed(ThemeManager())
}
