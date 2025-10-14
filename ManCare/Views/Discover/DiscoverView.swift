//
//  DiscoverView.swift
//  ManCare
//
//  Transformed with dynamic content feed
//

import SwiftUI

// MARK: - Navigation Destination

struct AllRoutinesDestination: Hashable {}

struct DiscoverView: View {
    @StateObject private var viewModel: DiscoverViewModel
    @StateObject private var listViewModel: RoutineListViewModel
    @State private var showingRoutineDetail: RoutineTemplate?
    @State private var showingGuideDetail: Guide?
    @State private var showConfetti = false
    @State private var navigationPath = NavigationPath()
    @State private var showingPersonalizedRoutinePreferences = false

    init() {
        let contentService = DiscoverContentService()
        let routineStore = RoutineStore()
        let routineService = ServiceFactory.shared.createRoutineService()

        _viewModel = StateObject(wrappedValue: DiscoverViewModel(
            contentService: contentService,
            routineStore: routineStore
        ))
        _listViewModel = StateObject(wrappedValue: RoutineListViewModel(
            routineService: routineService
        ))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundGradient

                ScrollView {
                    LazyVStack(spacing: 32) {
                        // Fresh Drops Section
                        if !viewModel.freshRoutines.isEmpty {
                            freshDropsSection
                        }

                        // Personalized Routine Card
                        personalizedRoutineCard

                        // Mini Guides Section
                        if !viewModel.miniGuides.isEmpty {
                            miniGuidesSection
                        }

                        // Inspirational Quotes Section
                        if !viewModel.inspirationalQuotes.isEmpty {
                            inspirationalQuotesSection
                        }

                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await viewModel.refreshContent()
                }

                // Confetti overlay
                if showConfetti {
                    ConfettiEffect(trigger: showConfetti)
                        .allowsHitTesting(false)
                }

                // Loading overlay
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationDestination(for: AllRoutinesDestination.self) { _ in
                AllRoutinesSheet(listViewModel: listViewModel) { routine in
                    navigationPath.removeLast()
                    showingRoutineDetail = routine
                }
            }
            .task {
                await viewModel.loadContent()
            }
            .sheet(item: $showingRoutineDetail) { routine in
                RoutineDetailSheet(routine: routine, listViewModel: listViewModel)
            }
            .sheet(item: $showingGuideDetail) { guide in
                GuideDetailView(guide: guide)
            }
            .fullScreenCover(isPresented: $showingPersonalizedRoutinePreferences) {
                PersonalizedRoutineFlowWrapper(
                    onComplete: { routine, name in
                        // Save the routine and show success
                        handlePersonalizedRoutineComplete(routine: routine, name: name)
                    }
                )
            }
            .onAppear {
                // Any setup needed
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("Retry") {
                    Task {
                        await viewModel.retry()
                    }
                }
                Button("Dismiss") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        GeometryReader { geometry in
            Image("cloudy-background")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expert-curated routines and trending favorites")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Personalized Routine Card

    private var personalizedRoutineCard: some View {
        HStack {
            PersonalizedRoutineCard {
                showingPersonalizedRoutinePreferences = true
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Fresh Drops Section

    private var freshDropsSection: some View {
        FreshDropsSection(
            freshRoutines: viewModel.freshRoutines,
            getRoutineTemplate: { freshRoutine in
                viewModel.getRoutineTemplate(for: freshRoutine)
            },
            onRoutineTap: { routine in
                showingRoutineDetail = routine
            },
            onSaveTap: { routine in
                handleSaveRoutine(routine)
            },
            onViewAll: {
                navigationPath.append(AllRoutinesDestination())
            }
        )
    }

    // MARK: - Mini Guides Section

    private var miniGuidesSection: some View {
        MiniGuidesSection(
            guides: viewModel.miniGuides,
            onTap: { miniGuide in
                let guideContentService = GuideContentService()
                showingGuideDetail = guideContentService.getGuide(for: miniGuide)
            }
        )
    }

    // MARK: - Inspirational Quotes Section

    private var inspirationalQuotesSection: some View {
        InspirationalQuotesSection(quotes: viewModel.inspirationalQuotes)
    }

    // MARK: - Helper Methods

    private func handleSaveRoutine(_ routine: RoutineTemplate) {
        listViewModel.saveRoutineTemplate(routine)

        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Show confetti
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showConfetti = false
        }
    }

    // MARK: - Personalized Routine Completion Handler

    private func handlePersonalizedRoutineComplete(routine: RoutineResponse, name: String) {
        // Save the routine to the routine store
        Task {
            // Convert RoutineResponse to a saveable format
            let routineTemplate = RoutineTemplate(
                id: UUID(),
                title: name,
                description: "Your personalized skincare routine",
                category: .combination, // Use existing category since .personalized doesn't exist
                duration: "5-10 minutes",
                difficulty: .beginner,
                tags: ["personalized", "custom"],
                morningSteps: routine.routine.morning.map { step in
                    TemplateRoutineStep(
                        title: step.name,
                        why: step.why,
                        how: step.how
                    )
                },
                eveningSteps: routine.routine.evening.map { step in
                    TemplateRoutineStep(
                        title: step.name,
                        why: step.why,
                        how: step.how
                    )
                },
                benefits: ["Personalized for your skin", "Custom routine"],
                isFeatured: false,
                isPremium: false,
                imageName: "routine_placeholder"
            )

            // Save to routine store
            listViewModel.saveRoutineTemplate(routineTemplate)

            // Show success feedback
            await MainActor.run {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
}
