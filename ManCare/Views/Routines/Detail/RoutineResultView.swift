//
//  RoutineResultView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineResultView: View {
    
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    let preferences: Preferences?
    let generatedRoutine: RoutineResponse?
    let onRestart: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                // Header
                headerView

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Steps Section
                        stepsSection
                        
                        // Start Your Journey Button
                        startJourneyButton
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea(.all, edges: .bottom))
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
                        Text("YOUR PERSONALIZED ROUTINE")
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
                    Text("Based on your skin type and selected concerns")
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
                        Text("Morning Routine")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("\(generateMorningRoutine().count) steps")
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
                        Text("Evening Routine")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("\(generateNightRoutine().count) steps")
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
            
            // Summary card
            RoutineResultSummaryCard(
                skinType: skinType,
                concerns: concerns,
                mainGoal: mainGoal
            )
        }
    }
    
    // MARK: - Start Journey Button
    
    private var startJourneyButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onContinue()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Start Your Journey")
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
        // Use generated routine if available
        if let routine = generatedRoutine {
            return routine.routine.morning.map { apiStep in
                RoutineStep(
                    productType: apiStep.step,
                    title: apiStep.name,
                    instructions: "\(apiStep.why) - \(apiStep.how)"
                )
            }
        }

        // Fallback to hardcoded routine
        var steps: [RoutineStep] = []
        
        // Always start with cleanser
        steps.append(RoutineStep(
            productType: .cleanser,
            title: "Gentle Cleanser",
            instructions: "Oil-free gel cleanser – reduces shine, clears pores"
        ))
        
        // Add treatment based on concerns
        if concerns.contains(.acne) {
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Acne Treatment",
                instructions: "Salicylic acid serum – targets breakouts, prevents new ones"
            ))
        }
        
        if concerns.contains(.redness) {
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Soothing Serum",
                instructions: "Centella serum – calms redness, reduces irritation"
            ))
        }
        
        // Always end with moisturizer and sunscreen
        steps.append(RoutineStep(
            productType: .moisturizer,
            title: "Moisturizer",
            instructions: "Lightweight gel moisturizer – hydrates without greasiness"
        ))
        
        steps.append(RoutineStep(
            productType: .sunscreen,
            title: "Sunscreen",
            instructions: "SPF 30+ broad spectrum – protects against sun damage"
        ))
        
        return steps
    }
    
    private func generateNightRoutine() -> [RoutineStep] {
        // Use generated routine if available
        if let routine = generatedRoutine {
            return routine.routine.evening.map { apiStep in
                RoutineStep(
                    productType: apiStep.step,
                    title: apiStep.name,
                    instructions: "\(apiStep.why) - \(apiStep.how)"
                )
            }
        }

        // Fallback to hardcoded routine
        var steps: [RoutineStep] = []
        
        // Always start with cleanser
        steps.append(RoutineStep(
            productType: .cleanser,
            title: "Gentle Cleanser",
            instructions: "Oil-free gel cleanser – removes daily buildup"
        ))
        
        // Add treatment based on main goal
        switch mainGoal {
        case .reduceBreakouts:
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Retinol Treatment",
                instructions: "Low-strength retinol – unclogs pores, reduces breakouts"
            ))
        case .sootheIrritation:
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Repair Serum",
                instructions: "Ceramide serum – strengthens skin barrier"
            ))
        case .preventAging:
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Anti-aging Serum",
                instructions: "Peptide serum – boosts collagen, reduces fine lines"
            ))
        default:
            steps.append(RoutineStep(
                productType: .faceSerum,
                title: "Treatment Serum",
                instructions: "Vitamin C serum – brightens, evens skin tone"
            ))
        }
        
        // Always end with moisturizer
        steps.append(RoutineStep(
            productType: .moisturizer,
            title: "Night Moisturizer",
            instructions: "Rich cream moisturizer – repairs while you sleep"
        ))
        
        return steps
    }
}

// MARK: - Preview

#Preview("RoutineResultView") {
    RoutineResultView(
        skinType: .combination,
        concerns: [.acne, .redness],
        mainGoal: .reduceBreakouts,
        preferences: nil,
        generatedRoutine: nil,
        onRestart: {},
        onContinue: {}
    )
}