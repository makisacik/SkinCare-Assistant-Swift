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
        case home
    }

    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(
                    onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .skinType
                        }
                    },
                    onSkipToHome: {
                        // Set up sample data for testing
                        selectedSkinType = .normal
                        selectedConcerns = [.largePores]
                        selectedMainGoal = .healthierOverall
                        selectedPreferences = nil
                        generatedRoutine = createMockRoutineResponse()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .home
                        }
                    }
                )
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
                    },
                    onContinueWithoutAPI: {
                        // Use mock data instead of API call
                        print("🚀 Using mock routine data for testing...")
                        generatedRoutine = createMockRoutineResponse()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .results
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
                        "Creating product slots…",
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
                    },
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .home
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .home:
                MainTabView(generatedRoutine: generatedRoutine)
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

                let routine = try await withTimeout(seconds: 60) {
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

    // MARK: - Mock Data Functions

    private func createMockRoutineResponse() -> RoutineResponse {
        let mockJSON = """
        {
          "version": "1.0",
          "locale": "en-US",
          "summary": {
            "title": "Skincare Routine for Normal Skin",
            "one_liner": "A simple routine to prevent aging and minimize large pores."
          },
          "routine": {
            "depth": "standard",
            "morning": [
              {
                "step": "cleanser",
                "name": "Gentle Cleanser",
                "why": "To remove impurities and excess oil without stripping the skin.",
                "how": "Apply to damp skin, massage gently, and rinse with lukewarm water.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["salicylic acid", "niacinamide"]
                }
              },
              {
                "step": "treatment",
                "name": "Niacinamide Serum",
                "why": "To minimize the appearance of pores and provide anti-aging benefits.",
                "how": "Apply a few drops to clean skin and gently pat until absorbed.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["niacinamide"]
                }
              },
              {
                "step": "moisturizer",
                "name": "Lightweight Moisturizer",
                "why": "To hydrate the skin without clogging pores.",
                "how": "Apply a small amount to face and neck, massaging gently.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["hyaluronic acid"]
                }
              },
              {
                "step": "sunscreen",
                "name": "Broad Spectrum SPF 30",
                "why": "To protect the skin from UV damage and prevent aging.",
                "how": "Apply generously to all exposed skin 15 minutes before sun exposure.",
                "constraints": {
                  "spf": 30,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": []
                }
              }
            ],
            "evening": [
              {
                "step": "cleanser",
                "name": "Gentle Cleanser",
                "why": "To remove makeup and impurities accumulated throughout the day.",
                "how": "Apply to damp skin, massage gently, and rinse with lukewarm water.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["salicylic acid", "niacinamide"]
                }
              },
              {
                "step": "treatment",
                "name": "Retinol Treatment",
                "why": "To promote cell turnover and reduce the signs of aging.",
                "how": "Apply a small amount to clean skin, avoiding the eye area.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["retinol"]
                }
              },
              {
                "step": "moisturizer",
                "name": "Night Cream",
                "why": "To provide overnight hydration and support skin repair.",
                "how": "Apply a small amount to face and neck, massaging gently.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["peptides"]
                }
              }
            ],
            "weekly": [
              {
                "step": "optional",
                "name": "Exfoliating Mask",
                "why": "To remove dead skin cells and improve skin texture.",
                "how": "Apply to clean skin, leave on for the recommended time, then rinse.",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": false,
                  "sensitive_safe": false,
                  "vegan": true,
                  "cruelty_free": false,
                  "avoid_ingredients": [],
                  "prefer_ingredients": ["AHA", "BHA"]
                }
              }
            ]
          },
          "guardrails": {
            "cautions": ["Introduce new products gradually to avoid irritation.", "Use sunscreen daily when using retinol."],
            "when_to_stop": ["If irritation occurs, discontinue use of the product.", "If excessive dryness or peeling happens, reduce frequency."],
            "sun_notes": "Always apply sunscreen in the morning, even on cloudy days."
          },
          "adaptation": {
            "for_skin_type": "normal",
            "for_concerns": ["largePores"],
            "for_preferences": ["veganFriendly"]
          },
          "product_slots": [
            {
              "slot_id": "1",
              "step": "cleanser",
              "time": "AM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["salicylic acid", "niacinamide"]
              },
              "budget": "mid",
              "notes": "Choose a gentle formula that suits normal skin."
            },
            {
              "slot_id": "2",
              "step": "treatment",
              "time": "AM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["niacinamide"]
              },
              "budget": "mid",
              "notes": "Focus on pore-minimizing ingredients."
            },
            {
              "slot_id": "3",
              "step": "moisturizer",
              "time": "AM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["hyaluronic acid"]
              },
              "budget": "mid",
              "notes": "Look for lightweight options."
            },
            {
              "slot_id": "4",
              "step": "sunscreen",
              "time": "AM",
              "constraints": {
                "spf": 30,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": []
              },
              "budget": "mid",
              "notes": "Ensure broad-spectrum protection."
            },
            {
              "slot_id": "5",
              "step": "cleanser",
              "time": "PM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["salicylic acid", "niacinamide"]
              },
              "budget": "mid",
              "notes": "Use the same gentle cleanser as in the morning."
            },
            {
              "slot_id": "6",
              "step": "treatment",
              "time": "PM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["retinol"]
              },
              "budget": "mid",
              "notes": "Retinol should be introduced gradually."
            },
            {
              "slot_id": "7",
              "step": "moisturizer",
              "time": "PM",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["peptides"]
              },
              "budget": "mid",
              "notes": "Opt for a nourishing night cream."
            },
            {
              "slot_id": "8",
              "step": "optional",
              "time": "Weekly",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": [],
                "prefer_ingredients": ["AHA", "BHA"]
              },
              "budget": "mid",
              "notes": "Use an exfoliating mask to enhance skin texture."
            }
          ]
        }
        """

        do {
            let data = mockJSON.data(using: .utf8)!
            let routine = try JSONDecoder().decode(RoutineResponse.self, from: data)
            print("✅ Successfully decoded RoutineResponse")
            print("   - Version: \(routine.version)")
            print("   - Locale: \(routine.locale)")
            print("   - Summary: \(routine.summary.title)")
            print("   - Morning steps: \(routine.routine.morning.count)")
            print("   - Evening steps: \(routine.routine.evening.count)")
            print("   - Weekly steps: \(routine.routine.weekly?.count ?? 0)")
            print("✅ Routine generated successfully!")
            return routine
        } catch {
            print("❌ Error decoding mock routine: \(error)")
            fatalError("Failed to decode mock routine response")
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
        case .home: return 8
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
        case .home: return "Home"
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
            Text("\(stepNumber) of 8")
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
}

#Preview("Routine Result") {
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
}