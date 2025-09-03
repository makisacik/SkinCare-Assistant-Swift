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
    
    @State private var currentStep: FlowStep = .welcome
    @State private var selectedSkinType: SkinType?
    @State private var selectedConcerns: Set<Concern> = []
    @State private var selectedMainGoal: MainGoal?
    @State private var selectedPreferences: Preferences?
    
    enum FlowStep {
        case welcome
        case skinType
        case concerns
        case mainGoal
        case preferences
        case loading
        case results
    }
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .skinType
                    }
                }
                .transition(.opacity)

            case .skinType:
                SkinTypeSelectionView { skinType in
                    selectedSkinType = skinType
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .concerns
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .concerns:
                ConcernSelectionView(
                    onContinue: { concerns in
                        selectedConcerns = concerns
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .mainGoal
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .skinType
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .mainGoal:
                MainGoalView(
                    onContinue: { mainGoal in
                        selectedMainGoal = mainGoal
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .preferences
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .concerns
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .preferences:
                PreferencesView(
                    onContinue: { preferences in
                        selectedPreferences = preferences
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .loading
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .mainGoal
                        }
                    },
                    onSkip: {
                        selectedPreferences = nil
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .loading
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .loading:
                LoadingView(
                    statuses: [
                        "Analyzing your skin type…",
                        "Processing your concerns…",
                        "Evaluating your main goal…",
                        "Preparing routine results…",
                        "Selecting targeted products…",
                        "Optimizing for your preferences…"
                    ],
                    stepInterval: 2.0,
                    autoFinish: true,
                    onFinished: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .results
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .preferences
                        }
                    }
                )
                .transition(.opacity) // loading can just fade

            case .results:
                NewRoutineResultView(
                    skinType: selectedSkinType ?? .normal,
                    concerns: selectedConcerns,
                    mainGoal: selectedMainGoal ?? .healthierOverall,
                    preferences: selectedPreferences,
                    onRestart: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .welcome
                            selectedSkinType = nil
                            selectedConcerns = []
                            selectedMainGoal = nil
                            selectedPreferences = nil
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .loading
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .background(tm.theme.palette.bg.ignoresSafeArea()) // keep root bg painted
        // Prevent theme changes from causing a flash:
        .transaction { t in t.disablesAnimations = true } // disables implicit animations
        .onChange(of: cs) { tm.refreshForSystemChange($0) }
    }
}

// MARK: - Progress Indicator

private struct ProgressIndicator: View {
    @Environment(\.themeManager) private var tm
    let currentStep: MainFlowView.FlowStep
    
    private var stepNumber: Int {
        switch currentStep {
        case .welcome: return 1
        case .skinType: return 2
        case .concerns: return 3
        case .mainGoal: return 4
        case .preferences: return 5
        case .loading: return 6
        case .results: return 7
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case .welcome: return "Welcome"
        case .skinType: return "Skin Type"
        case .concerns: return "Concerns"
        case .mainGoal: return "Main Goal"
        case .preferences: return "Preferences"
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
            Text("\(stepNumber) of 7")
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

// MARK: - Preview

#Preview("Main Flow") {
    MainFlowView()
        .themed(ThemeManager())
}

#Preview("Routine Result") {
    NewRoutineResultView(
        skinType: .combination,
        concerns: [.acne, .redness],
        mainGoal: .reduceBreakouts,
        preferences: nil,
        onRestart: {},
        onBack: {}
    )
    .themed(ThemeManager())
}