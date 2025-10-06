//
//  RoutineCreatorFlow.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineCreatorFlow: View {
    @Environment(\.colorScheme) private var cs
    
    let onComplete: (RoutineResponse?) -> Void

    @State private var currentStep: FlowStep = .skinType
    @State private var selectedSkinType: SkinType?
    @State private var selectedConcerns: Set<Concern> = []
    @State private var selectedMainGoal: MainGoal?
    @State private var selectedFitzpatrickSkinTone: FitzpatrickSkinTone?
    @State private var selectedAgeRange: AgeRange?
    @State private var selectedRegion: Region?
    @State private var selectedPreferences: Preferences?
    @State private var generatedRoutine: RoutineResponse?
    @State private var isLoadingRoutine = false
    @State private var routineError: Error?

    enum FlowStep {
        case skinType
        case concerns
        case mainGoal
        case fitzpatrickSkinTone
        case ageRange
        case region
        case preferences
        case loading
        case results
    }

    var body: some View {
        ZStack {
            switch currentStep {
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
                            currentStep = .fitzpatrickSkinTone
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

            case .fitzpatrickSkinTone:
                FitzpatrickSkinToneView(
                    onContinue: { skinTone in
                        selectedFitzpatrickSkinTone = skinTone
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .ageRange
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .mainGoal
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .ageRange:
                AgeRangeView(
                    onContinue: { ageRange in
                        selectedAgeRange = ageRange
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .region
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .fitzpatrickSkinTone
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            case .region:
                RegionView(
                    onContinue: { region in
                        selectedRegion = region
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .preferences
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .ageRange
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
                            currentStep = .region
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
                RoutineResultView(
                    skinType: selectedSkinType ?? .normal,
                    concerns: selectedConcerns,
                    mainGoal: selectedMainGoal ?? .healthierOverall,
                    preferences: selectedPreferences,
                    generatedRoutine: generatedRoutine,
                    onRestart: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .skinType
                            selectedSkinType = nil
                            selectedConcerns = []
                            selectedMainGoal = nil
                            selectedFitzpatrickSkinTone = nil
                            selectedAgeRange = nil
                            selectedRegion = nil
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
                        onComplete(generatedRoutine)
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea()) // keep root bg painted
        .onChange(of: cs) { newColorScheme in
            // Only disable animations during theme changes to prevent flashing
            withAnimation(.none) {
                ThemeManager.shared.refreshForSystemChange(newColorScheme)
            }
        }
    }

    // MARK: - Routine Generation

    private func generateRoutine() {
        guard !isLoadingRoutine else { return }
        guard let skinType = selectedSkinType,
              let mainGoal = selectedMainGoal,
              let fitzpatrickSkinTone = selectedFitzpatrickSkinTone,
              let ageRange = selectedAgeRange,
              let region = selectedRegion else {
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
            // Create the request outside try-catch so it's accessible in error handling
            let request = ManCareRoutineRequest(
                selectedSkinType: skinType.rawValue,
                selectedConcerns: selectedConcerns.map { $0.rawValue },
                selectedMainGoal: mainGoal.rawValue,
                fitzpatrickSkinTone: fitzpatrickSkinTone.rawValue,
                ageRange: ageRange.rawValue,
                region: region.rawValue,
                selectedPreferences: selectedPreferences.map { prefs in
                    PreferencesPayload(
                        fragranceFreeOnly: prefs.fragranceFreeOnly,
                        suitableForSensitiveSkin: prefs.suitableForSensitiveSkin,
                        naturalIngredients: prefs.naturalIngredients,
                        crueltyFree: prefs.crueltyFree,
                        veganFriendly: prefs.veganFriendly
                    )
                },
                lifestyle: nil, // TODO: Add lifestyle collection
                locale: "en-US"
            )

            do {
                print("🚀 Starting routine generation...")
                // Use the routine service (GPT-3.5-turbo for routine generation)
                let gptService = GPTService.routineService

                // Generate routine using GPTService with timeout
                print("📡 Calling GPT API...")
                print("📋 Request details:")
                print("   - Skin Type: \(request.selectedSkinType)")
                print("   - Concerns: \(request.selectedConcerns)")
                print("   - Main Goal: \(request.selectedMainGoal)")
                print("   - Fitzpatrick Skin Tone: \(request.fitzpatrickSkinTone)")
                print("   - Age Range: \(request.ageRange)")
                print("   - Region: \(request.region)")
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
                    try await gptService.generateRoutine(for: request, enhanceWithProductInfo: false)
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

                // Enhance routine with product info asynchronously in background
                Task {
                    let enhancedRoutine = await gptService.enhanceRoutineAsync(routine)
                    await MainActor.run {
                        self.generatedRoutine = enhancedRoutine
                        print("✅ Routine enhanced with product information")
                    }
                }
            } catch {
                print("❌ Error generating routine: \(error)")
                await MainActor.run {
                    self.routineError = error
                    self.isLoadingRoutine = false

                    // Create a fallback routine for better UX
                    if self.generatedRoutine == nil {
                        self.generatedRoutine = self.createFallbackRoutine(for: request)
                    }

                    // Transition to results page even with error (fallback routine will be shown)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.currentStep = .results
                    }
                }
            }
        }
    }

    // MARK: - Fallback Functions

    private func createFallbackRoutine(for request: ManCareRoutineRequest) -> RoutineResponse {
        // Create a simple fallback routine based on the request
        let skinType = request.selectedSkinType
        let concerns = request.selectedConcerns
        let mainGoal = request.selectedMainGoal

        // Basic routine based on skin type
        var morningSteps: [APIRoutineStep] = []
        var eveningSteps: [APIRoutineStep] = []

        // Morning routine
        morningSteps.append(APIRoutineStep(
            step: .cleanser,
            name: "Gentle Cleanser",
            why: "Removes overnight oil buildup and prepares skin for the day",
            how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
            constraints: Constraints(spf: 0, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: [])
        ))

        if skinType == "dry" {
            morningSteps.append(APIRoutineStep(
                step: .moisturizer,
                name: "Hydrating Moisturizer",
                why: "Provides essential hydration for dry skin",
                how: "Apply to face and neck, massage gently until absorbed",
                constraints: Constraints(spf: 0, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: ["hyaluronic acid", "ceramides"])
            ))
        }

        morningSteps.append(APIRoutineStep(
            step: .sunscreen,
            name: "Daily Sunscreen",
            why: "Protects skin from harmful UV rays and prevents premature aging",
            how: "Apply liberally to face and neck, reapply every 2 hours if outdoors",
            constraints: Constraints(spf: 30, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: ["zinc oxide", "titanium dioxide"])
        ))

        // Evening routine
        eveningSteps.append(APIRoutineStep(
            step: .cleanser,
            name: "Gentle Cleanser",
            why: "Removes makeup, sunscreen, and daily pollutants",
            how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
            constraints: Constraints(spf: 0, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: [])
        ))

        if concerns.contains("largePores") {
            eveningSteps.append(APIRoutineStep(
                step: .faceSerum,
                name: "Pore-Minimizing Serum",
                why: "Helps reduce the appearance of large pores",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                constraints: Constraints(spf: 0, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: ["niacinamide", "salicylic acid"])
            ))
        }

        eveningSteps.append(APIRoutineStep(
            step: .moisturizer,
            name: "Night Moisturizer",
            why: "Provides overnight hydration and skin repair",
            how: "Apply to face and neck, massage gently until absorbed",
            constraints: Constraints(spf: 0, fragranceFree: true, sensitiveSafe: true, vegan: true, crueltyFree: true, avoidIngredients: [], preferIngredients: ["retinol", "peptides"])
        ))

        let routine = Routine(
            depth: .standard,
            morning: morningSteps,
            evening: eveningSteps,
            weekly: nil
        )

        return RoutineResponse(
            version: "1.0",
            locale: request.locale,
            summary: Summary(
                title: "Basic Skincare Routine",
                oneLiner: "A simple, effective routine tailored to your skin type and concerns"
            ),
            routine: routine,
            guardrails: Guardrails(
                cautions: ["Start slowly with new products", "Patch test before full application"],
                whenToStop: ["If you experience irritation or allergic reactions"],
                sunNotes: "Always wear sunscreen during the day"
            ),
            adaptation: Adaptation(
                forSkinType: "Tailored for \(skinType) skin",
                forConcerns: concerns,
                forPreferences: []
            ),
            productSlots: []
        )
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
                "step": "faceSerum",
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
                "step": "faceSerum",
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
                "step": "faceSerum",
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
              "notes": "Choose a gentle formula that suits normal skin."
            },
            {
              "slot_id": "2",
              "step": "faceSerum",
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
              "notes": "Use the same gentle cleanser as in the morning."
            },
            {
              "slot_id": "6",
              "step": "faceSerum",
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
              "notes": "Opt for a nourishing night cream."
            },
            {
              "slot_id": "8",
              "step": "faceSerum",
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
    let currentStep: RoutineCreatorFlow.FlowStep

    private var stepNumber: Int {
        switch currentStep {
        case .skinType: return 1
        case .concerns: return 2
        case .mainGoal: return 3
        case .fitzpatrickSkinTone: return 4
        case .ageRange: return 5
        case .region: return 6
        case .preferences: return 7
        case .loading: return 8
        case .results: return 9
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case .skinType: return "Skin Type"
        case .concerns: return "Concerns"
        case .mainGoal: return "Main Goal"
        case .fitzpatrickSkinTone: return "Skin Tone"
        case .ageRange: return "Age Range"
        case .region: return "Region"
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
                    .fill(ThemeManager.shared.theme.palette.secondary)
                    .frame(width: 32, height: 32)
                Text("\(stepNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
            }

            // Step title
            Text(stepTitle)
                .font(ThemeManager.shared.theme.typo.title)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Spacer()

            // Progress text
            Text("\(stepNumber) of 9")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(ThemeManager.shared.theme.cardRadius)
        .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("Routine Creator Flow") {
    RoutineCreatorFlow(onComplete: { _ in })
}

#Preview("Routine Result") {
    RoutineResultView(
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