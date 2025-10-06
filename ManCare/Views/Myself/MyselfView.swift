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
            VStack(spacing: 16) {
                profileHeader
                smartInsights
            }
            .padding(16)
        }
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .navigationTitle("Myself")
        .toolbar { toolbarButtons }
        .sheet(isPresented: $showingEdit) {
            EditProfileView(
                initialProfile: profileStore.currentProfile,
                onCancel: { showingEdit = false },
                onSave: { profile in
                    profileStore.setProfile(profile)
                    showingEdit = false
                },
                onGenerate: { profile in
                    profileStore.setProfile(profile)
                    showingEdit = false
                    showingGenerateConfirm = true
                }
            )
        }
        .confirmationDialog(
            "Create new personalized routine?",
            isPresented: $showingGenerateConfirm,
            titleVisibility: .visible
        ) {
            Button("Generate from current profile") {
                Task { await generateRoutineIfPossible() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll create a new routine from your profile. It won't auto-link products.")
        }
    }

    @ViewBuilder
    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                avatarView
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(ThemeManager.shared.theme.typo.h2)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    Text(tagline)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            badges

            HStack(spacing: 12) {
                Button("Edit Profile") { showingEdit = true }
                    .buttonStyle(SecondaryButtonStyle())

                Button {
                    showingGenerateConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Create New Routine")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(16)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(ThemeManager.shared.theme.cardRadius)
        .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 6, x: 0, y: 3)
    }

    private var displayName: String {
        // Could expand to nickname/handle later; for now derive from goal
        if let goal = profileStore.currentProfile?.mainGoal {
            return "@" + goal.rawValue
        }
        return "@you"
    }

    private var tagline: String {
        if let goal = profileStore.currentProfile?.mainGoal {
            return goal.subtitle
        }
        return "Your skincare, your vibe."
    }

    @ViewBuilder
    private var badges: some View {
        let profile = profileStore.currentProfile
        let chips: [String] = [
            profile?.skinType.title,
            profile?.mainGoal.title,
            profile?.ageRange.title,
            profile?.region.title
        ].compactMap { $0 }

        VStack(alignment: .leading, spacing: 8) {
            ChipFlowLayout(alignment: .leading, spacing: 8) {
                ForEach(chips, id: \.self) { text in
                    Text(text)
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(ThemeManager.shared.theme.palette.secondary.opacity(0.12))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                        .clipShape(Capsule())
                        .accessibilityLabel(Text(text))
                }
                if let prefs = profile?.preferences, prefs.hasAnyPreferences == false {
                    Text("Add preferences")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(ThemeManager.shared.theme.palette.separator)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .clipShape(Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        let tone = profileStore.currentProfile?.fitzpatrickSkinTone
        ZStack {
            Circle()
                .strokeBorder((tone?.skinColor ?? Color.gray).opacity(0.6), lineWidth: 3)
                .frame(width: 58, height: 58)
            Circle()
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .frame(width: 52, height: 52)
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 42))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .accessibilityLabel(Text("Profile avatar"))
    }

    @ViewBuilder
    private var smartInsights: some View {
        let profile = profileStore.currentProfile
        VStack(alignment: .leading, spacing: 12) {
            if let profile {
                if profile.skinType == .combination && profile.concerns.contains(.largePores) {
                    insightCard(title: "Combination + Large Pores", body: "Look for niacinamide and BHA to refine texture.")
                }
                climateTipCard(for: profile)
            } else {
                insightCard(title: "Complete your profile", body: "Add your details to get tailored tips.")
            }
        }
    }

    private func insightCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.title)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            Text(body)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .padding(16)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(ThemeManager.shared.theme.cardRadius)
        .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func climateTipCard(for profile: UserProfile) -> some View {
        let spf = profile.fitzpatrickSkinTone.recommendedSPF
        let region = profile.region
        let text = "You're in \(region.temperatureLevel). Aim for SPF \(spf)+ daily."
        insightCard(title: "Climate tip", body: text)
    }

    @ToolbarContentBuilder
    private var toolbarButtons: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingEdit = true
            } label: {
                Image(systemName: "pencil")
            }
            .accessibilityLabel(Text("Edit Profile"))
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


