//
//  PreferencesView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct PreferencesView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs

    @State private var fragranceFreeOnly = false
    @State private var suitableForSensitiveSkin = false
    @State private var naturalIngredients = false
    @State private var crueltyFree = false
    @State private var veganFriendly = false

    var onContinue: (Preferences) -> Void
    var onBack: () -> Void
    var onSkip: () -> Void
    var onContinueWithoutAPI: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with back button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)

            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("Any preferences?")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("These are optional but help us personalize your routine better.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }

            // Preferences toggles
            VStack(spacing: 16) {
                PreferenceToggle(
                    title: "Fragrance-free only",
                    subtitle: "Avoid products with added fragrances",
                    iconName: "leaf.fill",
                    isOn: $fragranceFreeOnly
                )

                PreferenceToggle(
                    title: "Suitable for sensitive skin",
                    subtitle: "Gentle, non-irritating formulas",
                    iconName: "heart.fill",
                    isOn: $suitableForSensitiveSkin
                )

                PreferenceToggle(
                    title: "Natural ingredients",
                    subtitle: "Prefer plant-based and natural components",
                    iconName: "leaf.circle.fill",
                    isOn: $naturalIngredients
                )

                PreferenceToggle(
                    title: "Cruelty-free",
                    subtitle: "No animal testing",
                    iconName: "pawprint.fill",
                    isOn: $crueltyFree
                )

                PreferenceToggle(
                    title: "Vegan-friendly",
                    subtitle: "No animal-derived ingredients",
                    iconName: "leaf.arrow.circlepath",
                    isOn: $veganFriendly
                )
            }

            Spacer(minLength: 8)

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onContinueWithoutAPI()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Continue without API call")
                            .font(tm.theme.typo.title.weight(.semibold))
                    }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(tm.theme.palette.accent)
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())

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
                    Text("Continue with Preferences")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSkip()
                } label: {
                    Text("Skip for now")
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
        .padding(20)
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { tm.refreshForSystemChange($0) }
    }
}

// MARK: - Preference Toggle

private struct PreferenceToggle: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let subtitle: String
    let iconName: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(tm.theme.palette.secondary.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(tm.theme.palette.secondary)
            }

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(tm.theme.typo.title)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text(subtitle)
                    .font(tm.theme.typo.caption)
                    .foregroundColor(tm.theme.palette.textMuted)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: tm.theme.palette.secondary))
                .labelsHidden()
        }
        .padding(16)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 4, x: 0, y: 2)
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
    PreferencesView(onContinue: { _ in }, onBack: {}, onSkip: {}, onContinueWithoutAPI: {})
        .preferredColorScheme(.light)
}

#Preview("PreferencesView - Dark") {
    PreferencesView(onContinue: { _ in }, onBack: {}, onSkip: {}, onContinueWithoutAPI: {})
        .preferredColorScheme(.dark)
}
