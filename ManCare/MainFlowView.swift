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
    @State private var generatedRoutine: RoutineResponse?
    @State private var isLoadingRoutine = false
    @State private var routineError: Error?
    
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
                    autoFinish: false,
                    onFinished: {
                        // This will be called when loading completes
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
                .onAppear {
                    generateRoutine()
                }
                .onTapGesture {
                    // Debug: Tap to retry routine generation
                    print("🔄 Retrying routine generation...")
                    generateRoutine()
                }

            case .results:
                NewRoutineResultView(
                    skinType: selectedSkinType ?? .normal,
                    concerns: selectedConcerns,
                    mainGoal: selectedMainGoal ?? .healthierOverall,
                    preferences: selectedPreferences,
                    generatedRoutine: generatedRoutine,
                    onRestart: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .welcome
                            selectedSkinType = nil
                            selectedConcerns = []
                            selectedMainGoal = nil
                            selectedPreferences = nil
                            generatedRoutine = nil
                            routineError = nil
                            isLoadingRoutine = false
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

    // MARK: - Routine Generation

    private func generateRoutine() {
        guard !isLoadingRoutine else { return }
        guard let skinType = selectedSkinType,
              let mainGoal = selectedMainGoal else {
            routineError = GPTService.GPTServiceError.requestFailed(-1, "Missing required data")
            return
        }

        guard Config.hasValidAPIKey else {
            print("❌ API key not configured")
            routineError = GPTService.GPTServiceError.requestFailed(-1, "API key not configured")
            // Still transition to results to show fallback routine
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .results
            }
            return
        }
        
        print("✅ API key is configured")

        isLoadingRoutine = true
        routineError = nil

        Task {
            do {
                print("🚀 Starting routine generation...")
                // Create GPTService instance
                let gptService = GPTService(apiKey: Config.openAIAPIKey)

                // Create the request using convenience method
                let request = GPTService.createRequest(
                    skinType: skinType,
                    concerns: selectedConcerns,
                    mainGoal: mainGoal,
                    preferences: selectedPreferences,
                    lifestyle: nil, // TODO: Add lifestyle collection
                    locale: "en-US"
                )

                // Generate routine using GPTService with timeout
                print("📡 Calling GPT API...")
                print("📋 Request details:")
                print("   - Skin Type: \(request.selectedSkinType)")
                print("   - Concerns: \(request.selectedConcerns)")
                print("   - Main Goal: \(request.selectedMainGoal)")
                if let prefs = request.selectedPreferences {
                    print("   - Preferences: fragranceFree=\(prefs.fragranceFreeOnly), sensitive=\(prefs.suitableForSensitiveSkin), natural=\(prefs.naturalIngredients), crueltyFree=\(prefs.crueltyFree), vegan=\(prefs.veganFriendly)")
                } else {
                    print("   - Preferences: None")
                }
                if let lifestyle = request.lifestyle {
                    print("   - Lifestyle: sleep=\(lifestyle.sleepQuality ?? "nil"), exercise=\(lifestyle.exerciseFrequency ?? "nil"), depth=\(lifestyle.routineDepthPreference ?? "nil")")
                } else {
                    print("   - Lifestyle: None")
                }
                
                let routine = try await withTimeout(seconds: 30) {
                    try await gptService.generateRoutine(for: request)
                }
                
                print("✅ Routine generated successfully!")
                print("📄 API Response:")
                print("   - Version: \(routine.version)")
                print("   - Locale: \(routine.locale)")
                print("   - Summary: \(routine.summary.title) - \(routine.summary.oneLiner)")
                print("   - Routine Depth: \(routine.routine.depth)")
                print("   - Morning Steps: \(routine.routine.morning.count)")
                print("   - Evening Steps: \(routine.routine.evening.count)")
                print("   - Weekly Steps: \(routine.routine.weekly?.count ?? 0)")
                print("   - Product Slots: \(routine.productSlots.count)")
                
                // Print detailed routine steps
                print("🌅 Morning Routine:")
                for (index, step) in routine.routine.morning.enumerated() {
                    print("   \(index + 1). \(step.name) (\(step.step.rawValue))")
                    print("      Why: \(step.why)")
                    print("      How: \(step.how)")
                }
                
                print("🌙 Evening Routine:")
                for (index, step) in routine.routine.evening.enumerated() {
                    print("   \(index + 1). \(step.name) (\(step.step.rawValue))")
                    print("      Why: \(step.why)")
                    print("      How: \(step.how)")
                }
                
                if let weeklySteps = routine.routine.weekly, !weeklySteps.isEmpty {
                    print("📅 Weekly Routine:")
                    for (index, step) in weeklySteps.enumerated() {
                        print("   \(index + 1). \(step.name) (\(step.step.rawValue))")
                        print("      Why: \(step.why)")
                        print("      How: \(step.how)")
                    }
                }
                
                print("⚠️ Guardrails:")
                print("   - Cautions: \(routine.guardrails.cautions)")
                print("   - When to Stop: \(routine.guardrails.whenToStop)")
                print("   - Sun Notes: \(routine.guardrails.sunNotes)")
                
                print("🎯 Adaptation:")
                print("   - For Skin Type: \(routine.adaptation.forSkinType)")
                print("   - For Concerns: \(routine.adaptation.forConcerns)")
                print("   - For Preferences: \(routine.adaptation.forPreferences)")

                await MainActor.run {
                    self.generatedRoutine = routine
                    self.isLoadingRoutine = false
                    // Transition to results page
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.currentStep = .results
                    }
                }
            } catch {
                print("❌ Error generating routine: \(error)")
                await MainActor.run {
                    self.routineError = error
                    self.isLoadingRoutine = false
                    // Transition to results page even with error (fallback routine will be shown)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.currentStep = .results
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Timeout Error

private struct TimeoutError: Error {
    let message = "Request timed out"
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
        generatedRoutine: nil,
        onRestart: {},
        onBack: {}
    )
    .themed(ThemeManager())
}