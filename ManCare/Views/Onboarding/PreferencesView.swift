//
//  PreferencesView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct PreferencesView: View {
    
    @Environment(\.colorScheme) private var cs

    @State private var fragranceFreeOnly = false
    @State private var suitableForSensitiveSkin = false
    @State private var naturalIngredients = false
    @State private var crueltyFree = false
    @State private var veganFriendly = false

    var onContinue: (Preferences) -> Void
    var onSkip: () -> Void
    var onContinueWithoutAPI: () -> Void

    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.Onboarding.Preferences.title)
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text(L10n.Onboarding.Preferences.subtitle)
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            // Preferences toggles
            VStack(spacing: 16) {
                PreferenceToggle(
                    title: L10n.Onboarding.Preferences.FragranceFree.title,
                    subtitle: L10n.Onboarding.Preferences.FragranceFree.subtitle,
                    iconName: "leaf.fill",
                    isOn: $fragranceFreeOnly
                )

                PreferenceToggle(
                    title: L10n.Onboarding.Preferences.SensitiveSkin.title,
                    subtitle: L10n.Onboarding.Preferences.SensitiveSkin.subtitle,
                    iconName: "heart.fill",
                    isOn: $suitableForSensitiveSkin
                )

                PreferenceToggle(
                    title: L10n.Onboarding.Preferences.Natural.title,
                    subtitle: L10n.Onboarding.Preferences.Natural.subtitle,
                    iconName: "leaf.circle.fill",
                    isOn: $naturalIngredients
                )

                PreferenceToggle(
                    title: L10n.Onboarding.Preferences.CrueltyFree.title,
                    subtitle: L10n.Onboarding.Preferences.CrueltyFree.subtitle,
                    iconName: "pawprint.fill",
                    isOn: $crueltyFree
                )

                PreferenceToggle(
                    title: L10n.Onboarding.Preferences.Vegan.title,
                    subtitle: L10n.Onboarding.Preferences.Vegan.subtitle,
                    iconName: "leaf.arrow.circlepath",
                    isOn: $veganFriendly
                )
            }

            Spacer(minLength: 8)

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    let preferences = Preferences(
                        fragranceFreeOnly: fragranceFreeOnly,
                        suitableForSensitiveSkin: suitableForSensitiveSkin,
                        naturalIngredients: naturalIngredients,
                        crueltyFree: crueltyFree,
                        veganFriendly: veganFriendly
                    )
                    onContinue(preferences)
                } label: {
                    Text(L10n.Onboarding.Preferences.continueWithPreferences)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSkip()
                } label: {
                    Text(L10n.Onboarding.Preferences.skipForNow)
                }
                .buttonStyle(GhostButtonStyle())
                
                // Testing button - skip API call and go directly to results
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onContinueWithoutAPI()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(L10n.Onboarding.Preferences.continueWithoutAPI)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .buttonStyle(PlainButtonStyle())
            }
            }
            .padding(20)
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Preference Toggle

private struct PreferenceToggle: View {
    
    let title: String
    let subtitle: String
    let iconName: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
            }

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ThemeManager.shared.theme.typo.title)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text(subtitle)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: ThemeManager.shared.theme.palette.secondary))
                .labelsHidden()
        }
        .padding(16)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(ThemeManager.shared.theme.cardRadius)
        .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.15), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Preferences Model

struct Preferences: Codable {
    let fragranceFreeOnly: Bool
    let suitableForSensitiveSkin: Bool
    let naturalIngredients: Bool
    let crueltyFree: Bool
    let veganFriendly: Bool

    var hasAnyPreferences: Bool {
        fragranceFreeOnly || suitableForSensitiveSkin || naturalIngredients || crueltyFree || veganFriendly
    }
}

#Preview("PreferencesView - Light") {
    PreferencesView(onContinue: { _ in }, onSkip: {}, onContinueWithoutAPI: {})
        .preferredColorScheme(.light)
}

#Preview("PreferencesView - Dark") {
    PreferencesView(onContinue: { _ in }, onSkip: {}, onContinueWithoutAPI: {})
        .preferredColorScheme(.dark)
}
