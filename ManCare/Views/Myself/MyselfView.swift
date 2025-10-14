//
//  MyselfView.swift
//  ManCare
//
//  Created by AI Assistant on 6.10.2025.
//

import SwiftUI

struct MyselfView: View {
    @StateObject private var profileStore = UserProfileStore.shared
    @State private var showingEdit = false
    @State private var showingGenerateConfirm = false
    let routineService: RoutineServiceProtocol
    let onRoutineGenerated: (RoutineResponse) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader

                // Menstruation Cycle Card
                MenstruationCycleCard()
                    .padding(.horizontal, -20) // Compensate for parent padding

                // Skin Journal Card
                SkinJournalCard()
                    .padding(.horizontal, -20) // Compensate for parent padding
            }
            .padding(20)
        }
        .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
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
        // confirmation dialog removed with create routine button
    }

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


