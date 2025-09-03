//
//  WelcomeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs
    
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main content
            VStack(spacing: 24) {
                // App icon or logo placeholder
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                // Headline
                Text("Simple skincare, made for men.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Subtitle
                Text("Start in just 3 steps.")
                    .font(tm.theme.typo.h3)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // CTA Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onGetStarted()
            } label: {
                HStack(spacing: 8) {
                    Text("Get Started")
                        .font(tm.theme.typo.title.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(tm.theme.palette.secondary)
                .cornerRadius(tm.theme.cardRadius)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { tm.refreshForSystemChange($0) }
    }
}

#Preview("WelcomeView - Light") {
    WelcomeView(onGetStarted: {})
        .themed(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("WelcomeView - Dark") {
    WelcomeView(onGetStarted: {})
        .themed(ThemeManager())
        .preferredColorScheme(.dark)
}
