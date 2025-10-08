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
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)

            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("Any preferences?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("These are optional but help us personalize your routine better.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSkip()
                } label: {
                    Text("Skip for now")
                }
                .buttonStyle(GhostButtonStyle())
                
                // Debug button - only show in development
                #if DEBUG
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onContinueWithoutAPI()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Continue without API call")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .buttonStyle(PlainButtonStyle())
                #endif
            }
        }
        .padding(20)
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
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
        .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.5), radius: 4, x: 0, y: 2)
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
