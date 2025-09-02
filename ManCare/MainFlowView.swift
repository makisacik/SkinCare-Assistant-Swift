//
//  MainFlowView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MainFlowView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs
    
    @State private var currentStep: FlowStep = .skinType
    @State private var selectedSkinType: SkinType?
    @State private var selectedConcerns: Set<Concern> = []
    @State private var lifestyleAnswers: LifestyleAnswers?
    
    enum FlowStep {
        case skinType
        case concerns
        case lifestyle
        case loading
        case results
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            Group {
                switch currentStep {
                case .skinType:
                    SkinTypeSelectionView { skinType in
                        print("DEBUG: Skin type selected: \(skinType)")
                        selectedSkinType = skinType
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .concerns
                        }
                        print("DEBUG: Transitioned to concerns")
                    }
                    
                case .concerns:
                    ConcernSelectionView(
                        onContinue: { concerns in
                            print("DEBUG: Concerns selected: \(concerns)")
                            selectedConcerns = concerns
                            print("DEBUG: About to transition to lifestyle")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .lifestyle
                            }
                            print("DEBUG: Transitioned to lifestyle, currentStep: \(currentStep)")
                        },
                        onBack: {
                            print("DEBUG: Going back to skin type")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .skinType
                            }
                        }
                    )
                    
                case .lifestyle:
                    LifestyleQuestionsView(
                        onContinue: { answers in
                            print("DEBUG: Lifestyle answers received: \(answers)")
                            lifestyleAnswers = answers
                            print("DEBUG: About to transition to loading")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .loading
                            }
                            print("DEBUG: Transitioned to loading, currentStep: \(currentStep)")
                        },
                        onSkip: {
                            print("DEBUG: Skipping lifestyle questions")
                            lifestyleAnswers = nil
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .loading
                            }
                        },
                        onBack: {
                            print("DEBUG: Going back to concerns")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .concerns
                            }
                        }
                    )
                    
                case .loading:
                    LoadingView(
                        statuses: [
                            "Analyzing your skin type…",
                            "Processing your concerns…",
                            "Evaluating lifestyle factors…",
                            "Preparing routine results…",
                            "Selecting targeted tips…",
                            "Optimizing for your goals…"
                        ],
                        stepInterval: 2.0, // Make it slower so you can see it
                        autoFinish: true,
                        onFinished: {
                            print("DEBUG: Loading finished, going to results")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .results
                            }
                        },
                        onBack: {
                            print("DEBUG: Going back to lifestyle")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .lifestyle
                            }
                        }
                    )
                    
                case .results:
                    RoutineResultView(
                        skinType: selectedSkinType ?? .normal,
                        concerns: selectedConcerns,
                        lifestyleAnswers: lifestyleAnswers,
                        onRestart: {
                            // Reset to start
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .skinType
                                selectedSkinType = nil
                                selectedConcerns = []
                                lifestyleAnswers = nil
                            }
                        },
                        onBack: {
                            print("DEBUG: Going back to loading")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .loading
                            }
                        }
                    )
                }
            }
        }
        .themed(tm)
        .onAppear {
            tm.refreshForSystemChange(cs)
            print("DEBUG: MainFlowView appeared, currentStep: \(currentStep)")
        }
        .onChange(of: cs) { newScheme in
            tm.refreshForSystemChange(newScheme)
        }
        .onChange(of: currentStep) { newStep in
            print("DEBUG: Step changed to: \(newStep)")
        }
    }
}

// MARK: - Progress Indicator

private struct ProgressIndicator: View {
    @Environment(\.themeManager) private var tm
    let currentStep: MainFlowView.FlowStep
    
    private var stepNumber: Int {
        switch currentStep {
        case .skinType: return 1
        case .concerns: return 2
        case .lifestyle: return 3
        case .loading: return 4
        case .results: return 5
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case .skinType: return "Skin Type"
        case .concerns: return "Concerns"
        case .lifestyle: return "Lifestyle"
        case .loading: return "Analyzing"
        case .results: return "Results"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Step number
            ZStack {
                Circle()
                    .fill(tm.theme.palette.secondary)
                    .frame(width: 32, height: 32)
                Text("\(stepNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Step title
            Text(stepTitle)
                .font(tm.theme.typo.title)
                .foregroundColor(tm.theme.palette.textPrimary)
            
            Spacer()
            
            // Progress text
            Text("\(stepNumber) of 5")
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textMuted)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Routine Result View

struct RoutineResultView: View {
    @Environment(\.themeManager) private var tm
    let skinType: SkinType
    let concerns: Set<Concern>
    let lifestyleAnswers: LifestyleAnswers?
    let onRestart: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with back button
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
            
            // Header
            VStack(spacing: 8) {
                Text("Your Personalized Routine")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Based on your \(skinType.title.lowercased()) skin and selected concerns")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Results content
            ScrollView {
                VStack(spacing: 16) {
                    // Skin type summary
                    ResultCard(
                        title: "Skin Type: \(skinType.title)",
                        subtitle: skinType.subtitle,
                        iconName: skinType.iconName
                    )
                    
                    // Selected concerns
                    if !concerns.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Focus Areas")
                                .font(tm.theme.typo.h3)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            ForEach(Array(concerns)) { concern in
                                HStack(spacing: 12) {
                                    Image(systemName: concern.iconName)
                                        .foregroundColor(tm.theme.palette.secondary)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(concern.title)
                                            .font(tm.theme.typo.title)
                                            .foregroundColor(tm.theme.palette.textPrimary)
                                        Text(concern.subtitle)
                                            .font(tm.theme.typo.caption)
                                            .foregroundColor(tm.theme.palette.textMuted)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(tm.theme.palette.card)
                                .cornerRadius(tm.theme.cardRadius)
                            }
                        }
                    }
                    
                    // Lifestyle summary if available
                    if let lifestyle = lifestyleAnswers {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lifestyle Factors")
                                .font(tm.theme.typo.h3)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            VStack(spacing: 8) {
                                if let sleep = lifestyle.sleep {
                                    LifestyleFactorRow(title: "Sleep Quality", value: sleep.label)
                                }
                                if let exercise = lifestyle.exercise {
                                    LifestyleFactorRow(title: "Exercise", value: exercise.label)
                                }
                                if let budget = lifestyle.budget {
                                    LifestyleFactorRow(title: "Budget", value: budget.label)
                                }
                                if let routineDepth = lifestyle.routineDepth {
                                    LifestyleFactorRow(title: "Routine Depth", value: routineDepth.label)
                                }
                                if let sunResponse = lifestyle.sunResponse {
                                    LifestyleFactorRow(title: "Sun Response", value: sunResponse.label)
                                }
                            }
                        }
                        .padding(16)
                        .background(tm.theme.palette.card)
                        .cornerRadius(tm.theme.cardRadius)
                    }
                    
                    // Placeholder for routine recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Routine")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Text("Your personalized routine recommendations will appear here. This is where you'd typically show product suggestions, application order, and timing.")
                            .font(tm.theme.typo.body)
                            .foregroundColor(tm.theme.palette.textSecondary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(tm.theme.palette.card)
                            .cornerRadius(tm.theme.cardRadius)
                    }
                }
                .padding(20)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Start Over") {
                    onRestart()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Save Routine") {
                    // TODO: Implement save functionality
                }
                .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
    }
}

// MARK: - Lifestyle Factor Row

private struct LifestyleFactorRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let value: String
    
    var body: some View {
        HStack {
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

// MARK: - Result Card

private struct ResultCard: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let subtitle: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(tm.theme.palette.secondary.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(tm.theme.palette.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(tm.theme.typo.title)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text(subtitle)
                    .font(tm.theme.typo.caption)
                    .foregroundColor(tm.theme.palette.textMuted)
            }
            
            Spacer()
        }
        .padding(16)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("Main Flow") {
    MainFlowView()
        .themed(ThemeManager())
}

#Preview("Routine Result") {
    RoutineResultView(
        skinType: .combination,
        concerns: [.acne, .redness],
        lifestyleAnswers: LifestyleAnswers(),
        onRestart: {},
        onBack: {}
    )
    .themed(ThemeManager())
}
