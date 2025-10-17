//
//  CreateRoutineView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct CreateRoutineView: View {
    @Environment(\.colorScheme) private var cs
    
    var onNext: () -> Void
    var onPrevious: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Fixed header section
                    VStack(spacing: 16) {
                        // Spacer removed - now handled by page indicator in OnboardingFlowView
                        
                        // Main headline
                        Text(L10n.Onboarding.CreateRoutine.title)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 120) // Reduced header height since descriptive text moved below
                    
                    // IMAGE that scales with button width and keeps 1:1 ratio
                    let buttonWidth = geometry.size.width - 40 // since .padding(.horizontal, 20)
                    
                    Image("onboarding-routine")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: buttonWidth, height: buttonWidth) // Square aspect ratio matching button width
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    
                    // Descriptive text below image
                    Text(L10n.Onboarding.CreateRoutine.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4) // Limit to 4 lines to prevent overflow
                        .frame(minHeight: 80) // Fixed minimum height
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    
                    Spacer() // Push button to bottom
                    
                    // Button (reference width)
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onNext()
                    } label: {
                        HStack(spacing: 8) {
                            Text(L10n.Onboarding.CreateRoutine.next)
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
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

#Preview("CreateRoutineView - Light") {
    CreateRoutineView(
        onNext: {},
        onPrevious: {}
    )
    .preferredColorScheme(.light)
}

#Preview("CreateRoutineView - Dark") {
    CreateRoutineView(
        onNext: {},
        onPrevious: {}
    )
    .preferredColorScheme(.dark)
}
