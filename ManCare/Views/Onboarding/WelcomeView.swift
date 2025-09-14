//
//  WelcomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) private var cs
    
    var onGetStarted: () -> Void
    var onSkipToHome: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main content
            VStack(spacing: 24) {
                // App icon or logo placeholder
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
                
                // Headline
                Text("Simple skincare, made for men.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Subtitle
                Text("Start in just 3 steps.")
                    .font(ThemeManager.shared.theme.typo.h3)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // CTA Buttons
            VStack(spacing: 16) {
                // Main CTA Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onGetStarted()
                } label: {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ThemeManager.shared.theme.palette.secondary)
                    .cornerRadius(ThemeManager.shared.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())
                // Testing Button (only show if onSkipToHome is provided)
                if let onSkipToHome = onSkipToHome {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onSkipToHome()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Skip to Home (Testing)")
                                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(ThemeManager.shared.theme.palette.accentBackground)
                        .cornerRadius(ThemeManager.shared.theme.cardRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

#Preview("WelcomeView - Light") {
    WelcomeView(
        onGetStarted: {},
        onSkipToHome: {}
    )
    .preferredColorScheme(.light)
}

#Preview("WelcomeView - Dark") {
    WelcomeView(
        onGetStarted: {},
        onSkipToHome: {}
    )
    .preferredColorScheme(.dark)
}
