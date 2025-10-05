//
//  DiscoverProgressView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct DiscoverProgressView: View {
    @Environment(\.colorScheme) private var cs
    
    var onGetStarted: () -> Void
    var onPrevious: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed header section
                VStack(spacing: 16) {
                    // Spacer removed - now handled by page indicator in OnboardingFlowView
                    
                    // Main headline
                    Text("Discover & Track")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Descriptive text with fixed height
                    Text("Find new skincare routines, learn from others, and watch your glow evolve over time.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4) // Limit to 4 lines to prevent overflow
                        .frame(minHeight: 80) // Fixed minimum height
                        .padding(.horizontal, 40)
                }
                .frame(height: 200) // Fixed header height
                
                // Fixed image section
                Image("onboarding-discover")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 336, height: 336) // Same size as combined three images (160+16+160 = 336 width, 336 height)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .frame(height: 336) // Fixed image height
                
                Spacer() // Push button to bottom
                
                // Fixed button section
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
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

#Preview("DiscoverProgressView - Light") {
    DiscoverProgressView(
        onGetStarted: {},
        onPrevious: {}
    )
    .preferredColorScheme(.light)
}

#Preview("DiscoverProgressView - Dark") {
    DiscoverProgressView(
        onGetStarted: {},
        onPrevious: {}
    )
    .preferredColorScheme(.dark)
}
