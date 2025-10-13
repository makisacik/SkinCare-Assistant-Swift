//
//  PersonalizedRoutineFlow.swift
//  ManCare
//
//  Simplified personalized routine creation using existing models
//

import SwiftUI

// MARK: - Personalized Routine Request

struct PersonalizedRoutineRequest {
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    let routineDepth: RoutineDepth?
    let customDetails: String
}

// MARK: - Personalized Routine Generation Service

class PersonalizedRoutineService {
    private let gptService: GPTService

    init() {
        self.gptService = GPTService.createRoutineService(apiKey: Config.openAIAPIKey)
    }

    func generatePersonalizedRoutine(request: PersonalizedRoutineRequest) async throws -> RoutineResponse {
        print("🤖 PersonalizedRoutineService: Converting request...")
        print("   - Skin Type: \(request.skinType.rawValue)")
        print("   - Concerns: \(request.concerns.map { $0.rawValue })")
        print("   - Main Goal: \(request.mainGoal.rawValue)")
        print("   - Routine Depth: \(request.routineDepth?.rawValue ?? "default")")
        print("   - Custom Details: \(request.customDetails)")

        // Convert PersonalizedRoutineRequest to ManCareRoutineRequest
        let manCareRequest = ManCareRoutineRequest(
            selectedSkinType: request.skinType.rawValue,
            selectedConcerns: request.concerns.map { $0.rawValue },
            selectedMainGoal: request.mainGoal.rawValue,
            fitzpatrickSkinTone: "type3", // Default - could be made configurable
            ageRange: "twenties", // Default - could be made configurable
            region: "temperate", // Default - could be made configurable
            routineDepth: request.routineDepth?.rawValue ?? "intermediate", // Use selected depth or default
            selectedPreferences: nil,
            lifestyle: nil,
            locale: "en-US",
            customDetails: request.customDetails.isEmpty ? nil : request.customDetails
        )

        print("🤖 PersonalizedRoutineService: Calling GPT service...")
        // Call the existing GPT service
        let result = try await gptService.generateRoutine(for: manCareRequest)
        print("🤖 PersonalizedRoutineService: GPT call completed successfully!")
        return result
    }
}

// MARK: - Personalized Routine Flow Wrapper

struct PersonalizedRoutineFlowWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: PersonalizedRoutineStep = .preferences
    @State private var request: PersonalizedRoutineRequest?
    @State private var generatedRoutine: RoutineResponse?
    @State private var routineName: String = ""

    let onComplete: (RoutineResponse, String) -> Void

    enum PersonalizedRoutineStep {
        case preferences
        case loading
        case results
    }

    var body: some View {
        NavigationView {
            ZStack {
                switch currentStep {
                case .preferences:
                    PersonalizedRoutinePreferencesView { req in
                        print("📝 Preferences collected, transitioning to loading...")
                        print("   - Request: \(req)")
                        request = req
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .loading
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                case .loading:
                    RoutineLoadingView(
                        statuses: [
                            "Analyzing your preferences...",
                            "Processing custom details...",
                            "Generating personalized routine...",
                            "Optimizing for your skin type...",
                            "Finalizing recommendations..."
                        ],
                        stepInterval: 1.6,
                        autoFinish: false,
                        onFinished: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .results
                            }
                        }
                    )
                    .transition(.opacity)
                    .onAppear {
                        print("🔄 Loading view appeared, starting routine generation...")
                        generateRoutine()
                    }

                case .results:
                    if let req = request, let routine = generatedRoutine {
                        PersonalizedRoutineResultView(
                            request: req,
                            generatedRoutine: routine,
                            routineName: $routineName,
                            onSave: { name in
                                onComplete(routine, name)
                                dismiss()
                            },
                            onRestart: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = .preferences
                                    request = nil
                                    generatedRoutine = nil
                                    routineName = ""
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }

    private func generateRoutine() {
        guard let req = request else { return }

        Task {
            do {
                print("🚀 Starting personalized routine generation...")
                let service = PersonalizedRoutineService()
                let routine = try await service.generatePersonalizedRoutine(request: req)
                print("✅ Routine generated successfully!")

                await MainActor.run {
                    generatedRoutine = routine
                    // Manually trigger the transition to results
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .results
                    }
                }
            } catch {
                print("❌ Error generating routine: \(error)")
                // Handle error - use fallback routine
                await MainActor.run {
                    generatedRoutine = createFallbackRoutine(for: req)
                    // Manually trigger the transition to results
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .results
                    }
                }
            }
        }
    }

    private func createFallbackRoutine(for request: PersonalizedRoutineRequest) -> RoutineResponse {
        // Create a simple fallback routine based on the request
        let morningSteps = [
            APIRoutineStep(
                step: .cleanser,
                name: "Gentle Cleanser",
                why: "Removes dirt and oil without stripping skin",
                how: "Apply to wet face, massage gently, rinse thoroughly",
                constraints: Constraints()
            ),
            APIRoutineStep(
                step: .moisturizer,
                name: "Daily Moisturizer",
                why: "Hydrates and protects skin",
                how: "Apply evenly to face and neck",
                constraints: Constraints()
            ),
            APIRoutineStep(
                step: .sunscreen,
                name: "Sunscreen SPF 30+",
                why: "Protects against UV damage",
                how: "Apply liberally to all exposed areas",
                constraints: Constraints()
            )
        ]

        let eveningSteps = [
            APIRoutineStep(
                step: .cleanser,
                name: "Night Cleanser",
                why: "Removes makeup and daily buildup",
                how: "Apply to dry face first, then wet and massage",
                constraints: Constraints()
            ),
            APIRoutineStep(
                step: .moisturizer,
                name: "Night Moisturizer",
                why: "Nourishes skin overnight",
                how: "Apply generously to face and neck",
                constraints: Constraints()
            )
        ]

        return RoutineResponse(
            version: "1.0",
            locale: "en-US",
            summary: Summary(title: "Personalized Routine", oneLiner: "Tailored for your skin"),
            routine: Routine(
                depth: .simple,
                morning: morningSteps,
                evening: eveningSteps,
                weekly: nil
            ),
            guardrails: Guardrails(
                cautions: ["Patch test new products before full application"],
                whenToStop: ["Stop if you experience irritation"],
                sunNotes: "Always wear sunscreen during the day"
            ),
            adaptation: Adaptation(
                forSkinType: request.skinType.rawValue,
                forConcerns: request.concerns.map { $0.rawValue },
                forPreferences: []
            ),
            productSlots: []
        )
    }
}

// MARK: - Personalized Routine Result View

struct PersonalizedRoutineResultView: View {
    let request: PersonalizedRoutineRequest
    let generatedRoutine: RoutineResponse
    @Binding var routineName: String
    let onSave: (String) -> Void
    let onRestart: () -> Void

    var body: some View {
        RoutineResultView(
            skinType: request.skinType,
            concerns: request.concerns,
            mainGoal: request.mainGoal,
            preferences: nil,
            generatedRoutine: generatedRoutine,
            cycleData: nil,
            onRestart: onRestart,
            onContinue: {
                // Save with the provided name
                onSave(routineName.isEmpty ? "My Personalized Routine" : routineName)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(routineName.isEmpty ? "My Personalized Routine" : routineName)
                }
                .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
            }
        }
        .onAppear {
            if routineName.isEmpty {
                routineName = "My Personalized Routine"
            }
        }
    }
}

// MARK: - Personalized Routine Preferences View

struct PersonalizedRoutinePreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userProfileStore = UserProfileStore.shared

    @State private var skinType: SkinType = .combination
    @State private var selectedConcerns: Set<Concern> = []
    @State private var mainGoal: MainGoal = .reduceBreakouts
    @State private var routineDepth: RoutineDepth? = .intermediate // Default to intermediate
    @State private var customDetails: String = ""

    // Section visibility states
    @State private var showSkinTypeSection: Bool = false
    @State private var showConcernsSection: Bool = false
    @State private var showGoalSection: Bool = false
    @State private var showRoutineDepthSection: Bool = false
    @State private var showCustomDetailsSection: Bool = true

    let onGenerate: (PersonalizedRoutineRequest) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        skinTypeSection
                        concernsSection
                        goalSection
                        routineDepthSection
                        customDetailsSection
                        generateButton
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
            }
            .onAppear {
                loadUserPreferences()
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.shared.theme.palette.background,
                ThemeManager.shared.theme.palette.surface.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)

                Text("Create Your Personalized Routine")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Spacer()
            }

            Text("Customize your preferences below, or skip sections you don't want to change. Tap anywhere on a section card to expand it.")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .multilineTextAlignment(.leading)
        }
    }

    private var skinTypeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header - fully tappable
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSkinTypeSection.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skin Type")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Currently: \(skinType.title)")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showSkinTypeSection ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: showSkinTypeSection ? 16 : 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Collapsible content
            if showSkinTypeSection {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(SkinType.allCases, id: \.self) { type in
                            Button(action: { skinType = type }) {
                                VStack(spacing: 8) {
                                    Image(systemName: type.iconName)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(skinType == type ? .white : ThemeManager.shared.theme.palette.primary)

                                    Text(type.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(skinType == type ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(skinType == type ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(skinType == type ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: skinType == type ? 0 : 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var concernsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header - fully tappable
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showConcernsSection.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skin Concerns")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Selected: \(selectedConcerns.isEmpty ? "None" : selectedConcerns.map { $0.title }.joined(separator: ", "))")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showConcernsSection ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Collapsible content
            if showConcernsSection {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(Concern.allCases, id: \.self) { concern in
                            Button(action: {
                                toggleConcern(concern)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: concern.iconName)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(selectedConcerns.contains(concern) ? .white : ThemeManager.shared.theme.palette.primary)

                                    Text(concern.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedConcerns.contains(concern) ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedConcerns.contains(concern) ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedConcerns.contains(concern) ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: selectedConcerns.contains(concern) ? 0 : 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header - fully tappable
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showGoalSection.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Main Goal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Currently: \(mainGoal.title)")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showGoalSection ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Collapsible content
            if showGoalSection {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(MainGoal.allCases, id: \.self) { goal in
                            Button(action: { mainGoal = goal }) {
                                VStack(spacing: 8) {
                                    Image(systemName: goal.iconName)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(mainGoal == goal ? .white : ThemeManager.shared.theme.palette.primary)

                                    Text(goal.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(mainGoal == goal ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(mainGoal == goal ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(mainGoal == goal ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: mainGoal == goal ? 0 : 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var routineDepthSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header - fully tappable
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showRoutineDepthSection.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Routine Complexity")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Selected: \(routineDepth?.title ?? "Not selected")")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showRoutineDepthSection ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Collapsible content
            if showRoutineDepthSection {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ForEach(RoutineDepth.allCases, id: \.self) { depth in
                            Button(action: {
                                routineDepth = depth
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(depth.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(routineDepth == depth ? .white : ThemeManager.shared.theme.palette.textPrimary)

                                        Text(depth.subtitle)
                                            .font(.system(size: 14))
                                            .foregroundColor(routineDepth == depth ? .white.opacity(0.8) : ThemeManager.shared.theme.palette.textSecondary)

                                        Text(depth.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(routineDepth == depth ? .white.opacity(0.7) : ThemeManager.shared.theme.palette.textMuted)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if routineDepth == depth {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(routineDepth == depth ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(routineDepth == depth ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: routineDepth == depth ? 0 : 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var customDetailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header - fully tappable
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCustomDetailsSection.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Additional Details")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Custom notes: \(customDetails.isEmpty ? "None" : "\(customDetails.count) characters")")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showCustomDetailsSection ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Collapsible content
            if showCustomDetailsSection {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)

                    Text("Share any specific concerns, allergies, or preferences to help us create the perfect routine for you")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .padding(.horizontal, 20)

                    TextEditor(text: $customDetails)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surfaceAlt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                )
                        )
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var generateButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            let request = PersonalizedRoutineRequest(
                skinType: skinType,
                concerns: selectedConcerns,
                mainGoal: mainGoal,
                routineDepth: routineDepth,
                customDetails: customDetails
            )

            onGenerate(request)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .semibold))

                Text("Generate My Routine")
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
        .disabled(false) // Always enabled since "None" is a valid selection
        .opacity(1.0)
    }

    // MARK: - User Preferences Loading

    private func loadUserPreferences() {
        guard let profile = userProfileStore.currentProfile else {
            print("📝 No user profile found, using defaults")
            return
        }

        print("📝 Loading user preferences from profile")

        // Load skin type
        skinType = profile.skinType

        // Load concerns
        selectedConcerns = profile.concerns

        // Load main goal
        mainGoal = profile.mainGoal

        // Set section visibility based on whether we have data
        showSkinTypeSection = true // Always show since we have data
        showConcernsSection = !selectedConcerns.isEmpty // Show if user has concerns
        showGoalSection = true // Always show since we have data

        // Routine depth defaults to intermediate, but user can change it
        showRoutineDepthSection = false // Collapsed by default, user can expand if needed

        print("📝 Loaded preferences: SkinType=\(skinType.title), Concerns=\(selectedConcerns.count), Goal=\(mainGoal.title)")
    }

    // MARK: - Helper Functions

    private func toggleConcern(_ concern: Concern) {
        if concern == .none {
            // If selecting "None", clear all other selections
            if selectedConcerns.contains(.none) {
                selectedConcerns.remove(.none)
            } else {
                selectedConcerns.removeAll()
                selectedConcerns.insert(.none)
            }
        } else {
            // If selecting any other concern, remove "None" if it's selected
            if selectedConcerns.contains(.none) {
                selectedConcerns.remove(.none)
            }

            if selectedConcerns.contains(concern) {
                selectedConcerns.remove(concern)
            } else {
                selectedConcerns.insert(concern)
            }
        }
    }
}


#Preview {
    PersonalizedRoutinePreferencesView { request in
        print("Generated request: \(request)")
    }
}
