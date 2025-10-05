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
        ScrollView {
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 60)
                    
                    ShimmerText(
                        text: "Glowie",
                        baseColor: ThemeManager.shared.theme.palette.secondary
                    )
                    .font(.system(size: 42, weight: .light, design: .serif))
                    .padding(.horizontal, 20)

                    
                    // Descriptive text
                    Text("Transform your skincare routine with personalized recommendations")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Image cards section
                HStack(alignment: .top, spacing: 16) {
                    // Left card - spans full height of right cards
                    Image("onboarding-left")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 336) // Height = (160 + 16 + 160) to match right side total
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    // Right cards (two stacked, 1:1 aspect ratio)
                    VStack(spacing: 16) {
                        // Top right card
                        Image("onboarding-right-1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160) // 1:1 aspect ratio
                            .clipped()
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        // Bottom right card
                        Image("onboarding-right-2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160) // 1:1 aspect ratio
                            .clipped()
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 60)
                
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
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.94).ignoresSafeArea()) // Light beige background
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
