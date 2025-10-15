//
//  MyselfView.swift
//  ManCare
//
//  Created by AI Assistant on 6.10.2025.
//

import SwiftUI

struct MyselfView: View {
    @StateObject private var profileStore = UserProfileStore.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showingEdit = false
    @State private var showingGenerateConfirm = false
    @State private var selectedTab = 0
    @State private var selectedDate = Date()
    @StateObject private var completionViewModel = RoutineCompletionViewModel(routineService: ServiceFactory.shared.createRoutineService())

    let routineService: RoutineServiceProtocol
    let onRoutineGenerated: (RoutineResponse) -> Void

    private let tabs = ["Timeline", "Journal", "Insights"]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Tab Selection and Content (separated from header)
            VStack(spacing: 0) {
                // Tab Selection
                tabSelectionSection

                // Content
                contentSection
            }
            .background(ThemeManager.shared.theme.palette.background)
        }
        .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            completionViewModel.onAppear()
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Night background image header - extends into safe area
            ZStack {
                // Night background image
                Image("night-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all, edges: .top) // Extend into safe area

                VStack(spacing: 8) {
                    // Logo
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.2))
                        )
                        .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.top, -18)

                    // Current Date
                    Text(Date(), style: .date)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                        .textCase(.uppercase)

                    // Greeting
                    Text(greetingText)
                        .font(ThemeManager.shared.theme.typo.h2.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        .multilineTextAlignment(.center)
                        .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 2, x: 0, y: 1)

                    // Calendar Section
                    calendarSection
                        .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
            .frame(height: 190)
            .overlay(alignment: .topTrailing) {
                settingsMenuButton
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditProfileView(
                initialProfile: profileStore.currentProfile,
                onCancel: { showingEdit = false },
                onSave: { profile in
                    profileStore.setProfile(profile)
                    showingEdit = false
                }
            )
        }
    }

    @ViewBuilder
    private var settingsMenuButton: some View {
        Menu {
            Button {
                showingEdit = true
            } label: {
                Label("Edit Profile", systemImage: "person.circle")
            }

            Button {
                if premiumManager.isPremium {
                    premiumManager.revokePremium()
                } else {
                    premiumManager.grantPremium()
                }
            } label: {
                Label(
                    premiumManager.isPremium ? "Disable Premium (Test)" : "Enable Premium (Test)",
                    systemImage: premiumManager.isPremium ? "crown.fill" : "crown"
                )
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20))
                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.15))
                )
                .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 10)
        .padding(.trailing, 10)
    }

    @ViewBuilder
    private var calendarSection: some View {
        VStack(spacing: 8) {
            // Week view
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.self) { date in
                    dayButton(for: date)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    @ViewBuilder
    private func dayButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let dayNumber = Calendar.current.component(.day, from: date)
        let dayAbbr = dayAbbreviation(for: date)

        VStack(spacing: 4) {
            Text(dayAbbr)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))

            Text("\(dayNumber)")
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? ThemeManager.shared.theme.palette.textInverse.opacity(0.2) : Color.clear)
                )
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        }
    }

    @ViewBuilder
    private var tabSelectionSection: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                tabButton(for: tab, index: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func tabButton(for tab: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconForTab(tab))
                    .font(.system(size: 16, weight: .medium))

                Text(tab)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
            }
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.surface : Color.clear)
            )
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        Group {
            switch selectedTab {
            case 0:
                TimelineTabView(selectedDate: selectedDate, completionViewModel: completionViewModel)
            case 1:
                JournalTabView(selectedDate: selectedDate)
            case 2:
                InsightsTabView(selectedDate: selectedDate)
            default:
                TimelineTabView(selectedDate: selectedDate, completionViewModel: completionViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }

    // MARK: - Helper Methods

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = "Alex" // You can get this from user profile later

        switch hour {
        case 5..<12:
            return "Good Morning, \(name)!"
        case 12..<17:
            return "Good Afternoon, \(name)!"
        case 17..<22:
            return "Good Evening, \(name)!"
        default:
            return "Good Night, \(name)!"
        }
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let day = formatter.string(from: date)
        return String(day.prefix(2)) // Get first 2 characters (Mo, Tu, We, etc.)
    }

    private func iconForTab(_ tab: String) -> String {
        switch tab {
        case "Timeline":
            return "calendar"
        case "Journal":
            return "book.fill"
        case "Insights":
            return "lightbulb"
        default:
            return "circle"
        }
    }

    private func hasActivity(for date: Date) -> Bool {
        // This would check if there are any completed steps or activities for this date
        // For now, we'll simulate with a simple check
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }

    // MARK: - Old Code (Kept for reference if needed)

    @ViewBuilder
    private var profileHeader: some View {
        HStack(alignment: .center) {
            Text("Profile")
                .font(ThemeManager.shared.theme.typo.h2.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Spacer()

            Button {
                showingEdit = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Edit")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                }
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ThemeManager.shared.theme.palette.primary.opacity(0.12))
                .cornerRadius(20)
            }
        }
    }

    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            statsGrid
        }
    }

    @ViewBuilder
    private var statsGrid: some View {
        let profile = profileStore.currentProfile

        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            if let skinType = profile?.skinType {
                statCard(icon: "drop.fill", title: "Skin Type", value: skinType.title, color: .blue)
            }

            if let ageRange = profile?.ageRange {
                statCard(icon: "calendar", title: "Age Range", value: ageRange.title, color: .purple)
            }

            if let tone = profile?.fitzpatrickSkinTone {
                statCard(icon: "sun.max.fill", title: "Skin Tone", value: tone.title, color: tone.skinColor)
            }

            if let region = profile?.region {
                statCard(icon: region.iconName, title: "Climate", value: region.title, color: region.climateColor)
            }
        }
    }

    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

                Text(value)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }

    @ViewBuilder
    private var smartInsights: some View {
        let profile = profileStore.currentProfile
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights & Tips")
                .font(ThemeManager.shared.theme.typo.h2.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            if let profile {
                VStack(spacing: 12) {
                    climateTipCard(for: profile)

                    if profile.skinType == .combination && profile.concerns.contains(.largePores) {
                        insightCard(
                            icon: "sparkles",
                            title: "Combination + Large Pores",
                            body: "Look for niacinamide and BHA to refine texture.",
                            color: .purple
                        )
                    }

                    if let prefs = profile.preferences, prefs.hasAnyPreferences {
                        preferencesCard(preferences: prefs)
                    }
                }
            } else {
                insightCard(
                    icon: "info.circle.fill",
                    title: "Complete your profile",
                    body: "Add your details to get personalized skincare tips.",
                    color: .blue
                )
            }
        }
    }

    private func insightCard(icon: String, title: String, body: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text(body)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }

    @ViewBuilder
    private func climateTipCard(for profile: UserProfile) -> some View {
        let spf = profile.fitzpatrickSkinTone.recommendedSPF
        let region = profile.region
        let text = "You're in a \(region.temperatureLevel.lowercased()) climate. Aim for SPF \(spf)+ daily protection."

        insightCard(
            icon: "sun.max.fill",
            title: "Climate Tip",
            body: text,
            color: .orange
        )
    }

    @ViewBuilder
    private func preferencesCard(preferences: Preferences) -> some View {
        let activePrefs = buildActivePreferences(preferences)

        if !activePrefs.isEmpty {
            insightCard(
                icon: "heart.fill",
                title: "Your Preferences",
                body: activePrefs.joined(separator: " • "),
                color: .pink
            )
        }
    }

    private func buildActivePreferences(_ preferences: Preferences) -> [String] {
        var activePrefs: [String] = []
        if preferences.fragranceFreeOnly { activePrefs.append("Fragrance-free") }
        if preferences.suitableForSensitiveSkin { activePrefs.append("Sensitive skin") }
        if preferences.naturalIngredients { activePrefs.append("Natural") }
        if preferences.crueltyFree { activePrefs.append("Cruelty-free") }
        if preferences.veganFriendly { activePrefs.append("Vegan") }
        return activePrefs
    }

    @ViewBuilder
    private var createRoutineButton: some View {
        Button {
            showingGenerateConfirm = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20))
                Text("Create New Routine")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(18)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primary,
                        ThemeManager.shared.theme.palette.secondary
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }

    private func generateRoutineIfPossible() async {
        guard let profile = profileStore.currentProfile else { return }
        do {
            let response = try await routineService.generateRoutine(
                skinType: profile.skinType,
                concerns: profile.concerns,
                mainGoal: profile.mainGoal,
                fitzpatrickSkinTone: profile.fitzpatrickSkinTone,
                ageRange: profile.ageRange,
                region: profile.region,
                routineDepth: nil, // Use default (intermediate) when generating from profile
                preferences: profile.preferences,
                lifestyle: nil
            )
            onRoutineGenerated(response)
        } catch {
            print("❌ Failed to generate routine from profile: \(error)")
        }
    }
}

// MARK: - Timeline Tab View

struct TimelineTabView: View {
    let selectedDate: Date
    @ObservedObject var completionViewModel: RoutineCompletionViewModel
    @State private var completedSteps: Set<String> = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .padding(.vertical, 40)
                } else {
                    // Products used section
                    productsUsedSection

                    // Routines completed section
                    routinesCompletedSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .task {
            await loadTimelineData()
        }
        .onChange(of: selectedDate) { _ in
            Task {
                await loadTimelineData()
            }
        }
    }

    @ViewBuilder
    private var productsUsedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products used")
                .font(ThemeManager.shared.theme.typo.h3.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            if completedSteps.isEmpty {
                emptyStateView(
                    icon: "drop.circle",
                    title: "No products used today",
                    subtitle: "Complete your routine steps to see them here"
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(completedSteps), id: \.self) { stepId in
                        productUsedRow(stepId: stepId)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var routinesCompletedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Routines completed")
                .font(ThemeManager.shared.theme.typo.h3.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            LazyVStack(spacing: 8) {
                routineCompletedRow(
                    icon: "sun.max.fill",
                    title: "Morning routine",
                    isCompleted: hasMorningCompletion,
                    color: ThemeManager.shared.theme.palette.warning
                )

                routineCompletedRow(
                    icon: "moon.fill",
                    title: "Evening routine",
                    isCompleted: hasEveningCompletion,
                    color: ThemeManager.shared.theme.palette.info
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private func productUsedRow(stepId: String) -> some View {
        HStack(spacing: 12) {
            // Product icon placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                )

            Text("Cleanser") // This would be the actual step title
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Spacer()

            Circle()
                .fill(ThemeManager.shared.theme.palette.success)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func routineCompletedRow(icon: String, title: String, isCompleted: Bool, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )

            Text(title)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.shared.theme.palette.success)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

            Text(title)
                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

            Text(subtitle)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Computed Properties

    private var hasMorningCompletion: Bool {
        // This would check if morning routine is completed
        return !completedSteps.isEmpty
    }

    private var hasEveningCompletion: Bool {
        // This would check if evening routine is completed
        return completedSteps.count > 1
    }

    // MARK: - Data Loading

    private func loadTimelineData() async {
        isLoading = true
        completedSteps = await completionViewModel.getCompletedSteps(for: selectedDate)
        isLoading = false
    }
}

// MARK: - Journal Tab View

struct JournalTabView: View {
    let selectedDate: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Skin Journal Card
                SkinJournalCard()
                    .padding(.top, 8)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Insights Tab View

struct InsightsTabView: View {
    let selectedDate: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Placeholder content for Insights tab
                VStack(spacing: 16) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ThemeManager.shared.theme.palette.warning)

                    Text("Smart Insights")
                        .font(ThemeManager.shared.theme.typo.h2.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Get personalized insights about your skincare routine and recommendations for improvement.")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Simple flow layout for chips

struct ChipFlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], alignment: alignment, spacing: spacing) {
            content
        }
    }
}
