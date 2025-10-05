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
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Spacer().frame(height: 60)
                        
                        ShimmerText(
                            text: "Glowie",
                            baseColor: ThemeManager.shared.theme.palette.secondary
                        )
                        .font(.system(size: 42, weight: .light, design: .serif))
                        .padding(.horizontal, 20)
                        
                        Text("Transform your skincare routine with personalized recommendations")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .frame(minHeight: 60)
                            .padding(.horizontal, 40)
                    }
                    .frame(height: 200)
                    .padding(.bottom, 20)
                    
                    // IMAGE GROUP that scales with button width and keeps 1:1 ratio
                    let buttonWidth = geometry.size.width - 40 // since .padding(.horizontal, 20)
                    
                    HStack(alignment: .top, spacing: 16) {
                        Image("onboarding-left")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: buttonWidth * 0.48, height: buttonWidth * 0.48 * 2 + 16) // matches right side total height
                            .clipped()
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 16) {
                            Image("onboarding-right-1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: buttonWidth * 0.48, height: buttonWidth * 0.48)
                                .clipped()
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            Image("onboarding-right-2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: buttonWidth * 0.48, height: buttonWidth * 0.48)
                                .clipped()
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                    }
                    .frame(width: buttonWidth, height: buttonWidth) // ⬅️ ensures square group
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Button (reference width)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                }
            }

            // Skip to Home button overlay (development only)
            if let onSkipToHome = onSkipToHome {
                VStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onSkipToHome()
                    } label: {
                        Text("Skip to Home")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
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
