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
    @State private var showingDatePicker = false
    @State private var selectedTab = 0
    @State private var selectedDate = DateUtils.todayStartOfDay
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
            // Spacing for buttons
            Spacer()
                .frame(height: 50)

            // Calendar Strip (only shown for Timeline tab)
            if selectedTab == 0 {
                calendarSection
            } else {
                // Empty space to maintain same header height
                Color.clear
                    .frame(height: 74) // Same height as calendarSection
            }
        }
        .background(
            GeometryReader { geometry in
                Image("night-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea(.all, edges: .top)
        )
        .overlay(alignment: .topLeading) {
            if selectedTab == 0 {
                datePickerButton
            }
        }
        .overlay(alignment: .topTrailing) {
            settingsMenuButton
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
        .sheet(isPresented: $showingDatePicker) {
            DatePickerBottomSheet(
                selectedDate: $selectedDate,
                onDismiss: { showingDatePicker = false }
            )
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
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
    private var datePickerButton: some View {
        Button {
            showingDatePicker = true
        } label: {
            Image(systemName: "calendar")
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
        .padding(.leading, 10)
    }

    @ViewBuilder
    private var calendarSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(weekDays, id: \.self) { date in
                    dayButton(for: date)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }

    private func dayButton(for date: Date) -> some View {
        let calendar = DateUtils.localCalendar
        let isSelected = DateUtils.isDate(date, inSameDayAs: selectedDate)
        let dayNumber = calendar.component(.day, from: date)
        let dayAbbr = dayAbbreviation(for: date)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                // Normalize the selected date to start of day in local timezone
                selectedDate = DateUtils.startOfDay(for: date)
                print("📅 Selected date: \(DateUtils.formatForLog(selectedDate))")
            }
        } label: {
            VStack(spacing: 4) {
                Text(dayAbbr)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))

                Text("\(dayNumber)")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
            }
        }
        .frame(width: 40, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? ThemeManager.shared.theme.palette.textInverse.opacity(0.2) : Color.clear)
        )
        .buttonStyle(PlainButtonStyle())
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
            HStack(spacing: 6) {
                Image(systemName: iconForTab(tab))
                    .font(.system(size: 16, weight: .medium))

                Text(tab)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textSecondary)
            .padding(.horizontal, 12)
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
                InsightsTabView(selectedDate: selectedDate, completionViewModel: completionViewModel)
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
        let calendar = DateUtils.localCalendar
        let today = selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
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

// MARK: - ProductType Color Extension

extension ProductType {
    var swiftUIColor: Color {
        switch color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "purple": return .purple
        case "indigo": return .indigo
        case "orange": return .orange
        case "pink": return .pink
        case "brown": return .brown
        case "cyan": return .cyan
        case "mint": return .mint
        case "red": return .red
        case "gray": return .gray
        default: return .blue
        }
    }
}

// MARK: - Timeline Tab View

struct TimelineTabView: View {
    let selectedDate: Date
    @ObservedObject var completionViewModel: RoutineCompletionViewModel
    @State private var completedSteps: Set<String> = []
    @State private var completedStepDetails: [SavedStepDetailModel] = []
    @State private var hasMorningCompletion = false
    @State private var hasEveningCompletion = false
    @State private var isLoading = true
    @State private var loadTask: Task<Void, Never>?

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
            await loadTimelineData(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            print("📅 Timeline: Date changed to \(DateUtils.formatForLog(newDate)), cancelling previous load...")
            // Cancel any pending load task
            loadTask?.cancel()
            // Start a new load task with the NEW date explicitly
            loadTask = Task {
                await loadTimelineData(for: newDate)
            }
        }
        .onChange(of: completionViewModel.activeRoutine?.id) { _ in
            print("📋 Timeline: Active routine changed, reloading...")
            loadTask?.cancel()
            loadTask = Task {
                await loadTimelineData(for: selectedDate)
            }
        }
        .onReceive(completionViewModel.completionChangesStream) { changedDate in
            // Only reload if the changed date matches our selected date
            let normalizedSelectedDate = DateUtils.startOfDay(for: selectedDate)
            let normalizedChangedDate = DateUtils.startOfDay(for: changedDate)

            if normalizedSelectedDate == normalizedChangedDate {
                print("📡 Timeline: Received completion change for current date, reloading...")
                loadTask?.cancel()
                loadTask = Task {
                    await loadTimelineData(for: selectedDate)
                }
            } else {
                print("📡 Timeline: Received completion change for \(DateUtils.formatForLog(normalizedChangedDate)), but current date is \(DateUtils.formatForLog(normalizedSelectedDate)) - ignoring")
            }
        }
    }

    @ViewBuilder
    private var productsUsedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products used")
                .font(ThemeManager.shared.theme.typo.h3.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            if completedStepDetails.isEmpty {
                emptyStateView(
                    icon: "drop.circle",
                    title: "No products used",
                    subtitle: "Complete your routine steps to see them here"
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(completedStepDetails, id: \.id) { step in
                        productUsedRow(step: step)
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

            if !hasMorningCompletion && !hasEveningCompletion {
                emptyStateView(
                    icon: "checkmark.circle",
                    title: "No routines completed",
                    subtitle: "Complete your routine steps to see them here"
                )
            } else {
                LazyVStack(spacing: 8) {
                    if hasMorningCompletion {
                        routineCompletedRow(
                            icon: "sun.max.fill",
                            title: "Morning routine",
                            color: ThemeManager.shared.theme.palette.warning
                        )
                    }

                    if hasEveningCompletion {
                        routineCompletedRow(
                            icon: "moon.fill",
                            title: "Evening routine",
                            color: ThemeManager.shared.theme.palette.info
                        )
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
    private func productUsedRow(step: SavedStepDetailModel) -> some View {
        let productType = ProductType(rawValue: step.stepType) ?? .moisturizer

        HStack(spacing: 12) {
            // Product icon
            Image(productType: productType)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text(step.timeOfDay.capitalized)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            Spacer()

            Circle()
                .fill(ThemeManager.shared.theme.palette.success)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func routineCompletedRow(icon: String, title: String, color: Color) -> some View {
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

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.theme.palette.success)
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

    // MARK: - Data Loading

    private func loadTimelineData(for date: Date) async {
        print("🔍 Timeline: loadTimelineData called for date: \(DateUtils.formatForLog(date))")

        await MainActor.run {
            isLoading = true
        }

        // Check if task was cancelled
        guard !Task.isCancelled else {
            print("⏹️ Timeline: Load cancelled before starting")
            await MainActor.run { isLoading = false }
            return
        }

        // Normalize the date to start of day for consistent comparison
        let normalizedDate = DateUtils.startOfDay(for: date)
        let today = DateUtils.todayStartOfDay

        // Don't load completion data for future dates
        if normalizedDate > today {
            print("⚠️ Timeline: Skipping load for future date \(DateUtils.formatForLog(normalizedDate))")
            await MainActor.run {
                self.completedSteps = []
                self.completedStepDetails = []
                self.hasMorningCompletion = false
                self.hasEveningCompletion = false
                self.isLoading = false
            }
            return
        }

        // Get completed step IDs for the normalized date
        let steps = await completionViewModel.getCompletedSteps(for: normalizedDate)

        // Check if cancelled after async call
        guard !Task.isCancelled else {
            print("⏹️ Timeline: Load cancelled after fetching steps")
            await MainActor.run { isLoading = false }
            return
        }

        print("📊 Timeline loading for \(DateUtils.formatForLog(normalizedDate)): Found \(steps.count) completed steps")

        // Get the actual step details from the active routine
        let routine = completionViewModel.activeRoutine
        let stepDetails: [SavedStepDetailModel]
        let morningComplete: Bool
        let eveningComplete: Bool

        if let routine = routine {
            stepDetails = routine.stepDetails.filter { step in
                steps.contains(step.id.uuidString)
            }

            // Check if at least one step is completed for morning/evening
            // Only show as completed if there are actual completed steps (not for future dates)
            let morningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .morning }
            let eveningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .evening }

            let completedMorningSteps = stepDetails.filter { $0.timeOfDayEnum == .morning }
            let completedEveningSteps = stepDetails.filter { $0.timeOfDayEnum == .evening }

            // Show as completed if at least 1 step is done for that time of day
            morningComplete = !completedMorningSteps.isEmpty && !morningSteps.isEmpty
            eveningComplete = !completedEveningSteps.isEmpty && !eveningSteps.isEmpty

            print("📊 Timeline: \(stepDetails.count) steps matched, Morning: \(completedMorningSteps.count)/\(morningSteps.count), Evening: \(completedEveningSteps.count)/\(eveningSteps.count)")
        } else {
            stepDetails = []
            morningComplete = false
            eveningComplete = false
            print("⚠️ Timeline: No active routine found")
        }

        // Final check before updating state
        guard !Task.isCancelled else {
            print("⏹️ Timeline: Load cancelled before updating state")
            await MainActor.run { isLoading = false }
            return
        }

        // Update state on main thread
        await MainActor.run {
            self.completedSteps = steps
            self.completedStepDetails = stepDetails
            self.hasMorningCompletion = morningComplete
            self.hasEveningCompletion = eveningComplete
            self.isLoading = false
            print("✅ Timeline: State updated successfully for \(DateUtils.formatForLog(normalizedDate))")
        }
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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Insights Tab View

struct InsightsTabView: View {
    let selectedDate: Date
    @StateObject private var viewModel: InsightsViewModel
    @ObservedObject var completionViewModel: RoutineCompletionViewModel

    init(selectedDate: Date, completionViewModel: RoutineCompletionViewModel) {
        self.selectedDate = selectedDate
        self.completionViewModel = completionViewModel
        self._viewModel = StateObject(wrappedValue: InsightsViewModel(completionViewModel: completionViewModel))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                loadingView
            } else {
                LazyVStack(spacing: 16) {
                    // Header
                    insightsHeaderSection

                    // Streak Card
                    streakCard

                    // Completion Stats Section
                    completionRatesSection

                    // Morning/Evening Completion
                    routineTimeCompletionSection

                    // Most Consistent Period
                    if !viewModel.mostConsistentPeriod.isEmpty {
                        consistencyInsightCard
                    }

                    // Most Used Products
                    mostUsedProductsSection

                    // Tag Trends (if user has journal entries)
                    if !viewModel.tagFrequencies.isEmpty {
                        tagTrendsSection
                    }

                    // Adaptation Impact (if enabled)
                    if let impact = viewModel.adaptationImpact {
                        adaptationImpactCard(impact: impact)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .task {
            await viewModel.loadAllInsights()
        }
    }

    // MARK: - Loading View

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading insights...")
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Header Section

    @ViewBuilder
    private var insightsHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Insights")
                    .font(ThemeManager.shared.theme.typo.h2.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text("Last 30 days")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Streak Card

    @ViewBuilder
    private var streakCard: some View {
        InsightStatCard(
            icon: "flame.fill",
            title: "Current Streak",
            value: "\(viewModel.currentStreak)",
            subtitle: viewModel.currentStreak == 1 ? "Day in a row" : "Days in a row",
            iconColor: ThemeManager.shared.theme.palette.success,
            showGradient: true
        )
    }

    // MARK: - Completion Rates Section

    @ViewBuilder
    private var completionRatesSection: some View {
        HStack(spacing: 12) {
            completionRateCard(
                title: "Weekly",
                rate: viewModel.weeklyCompletionRate,
                totalDays: 7,
                color: ThemeManager.shared.theme.palette.primary
            )

            completionRateCard(
                title: "Monthly",
                rate: viewModel.monthlyCompletionRate,
                totalDays: 30,
                color: ThemeManager.shared.theme.palette.secondary
            )
        }
    }

    @ViewBuilder
    private func completionRateCard(title: String, rate: Double, totalDays: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Text("\(Int(rate * 100))%")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(ThemeManager.shared.theme.palette.border.opacity(0.3))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(0, CGFloat(rate) * (UIScreen.main.bounds.width - 64) / 2), height: 8)
            }

            Text("Last \(totalDays) days")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }

    // MARK: - Routine Time Completion Section

    @ViewBuilder
    private var routineTimeCompletionSection: some View {
        HStack(spacing: 12) {
            timeCompletionCard(
                icon: "sun.max.fill",
                title: "Morning",
                count: viewModel.morningCompletionCount,
                total: viewModel.morningTotal,
                color: ThemeManager.shared.theme.palette.warning
            )

            timeCompletionCard(
                icon: "moon.fill",
                title: "Evening",
                count: viewModel.eveningCompletionCount,
                total: viewModel.eveningTotal,
                color: ThemeManager.shared.theme.palette.info
            )
        }
    }

    @ViewBuilder
    private func timeCompletionCard(icon: String, title: String, count: Int, total: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)

                Text(title)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }

            Text("\(count) of \(total)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Text("days completed")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }

    // MARK: - Consistency Insight Card

    @ViewBuilder
    private var consistencyInsightCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 28))
                .foregroundColor(ThemeManager.shared.theme.palette.warning)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.warning.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("Consistency Insight")
                    .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text(viewModel.mostConsistentPeriod)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
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
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }

    // MARK: - Most Used Products Section

    @ViewBuilder
    private var mostUsedProductsSection: some View {
        MostUsedProductsCard(products: viewModel.mostUsedProducts)
    }

    // MARK: - Tag Trends Section

    @ViewBuilder
    private var tagTrendsSection: some View {
        TagTrendsCard(tagFrequencies: viewModel.tagFrequencies)
    }

    // MARK: - Adaptation Impact Card

    @ViewBuilder
    private func adaptationImpactCard(impact: Double) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundColor(ThemeManager.shared.theme.palette.secondaryLight)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondaryLight.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("Adaptation Impact")
                    .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                let sign = impact >= 0 ? "+" : ""
                let color = impact >= 0 ? ThemeManager.shared.theme.palette.success : ThemeManager.shared.theme.palette.error

                HStack(spacing: 4) {
                    Text("\(sign)\(Int(impact))%")
                        .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                        .foregroundColor(color)

                    Text("this week vs last week")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
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
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }
}

// MARK: - Date Picker Bottom Sheet

struct DatePickerBottomSheet: View {
    @Binding var selectedDate: Date
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Date")
                        .font(ThemeManager.shared.theme.typo.h2.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("View your timeline for any date")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .padding(.top, 20)

                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 20)
                .onChange(of: selectedDate) { newDate in
                    // Normalize to start of day in local timezone
                    selectedDate = DateUtils.startOfDay(for: newDate)

                    // Automatically dismiss when date changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }

                // Today Button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDate = DateUtils.todayStartOfDay
                    }
                    onDismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 16, weight: .semibold))

                        Text("Go to Today")
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.theme.palette.primary)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(ThemeManager.shared.theme.palette.background)
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
