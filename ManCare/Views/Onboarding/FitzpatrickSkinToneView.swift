//
//  FitzpatrickSkinToneView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct FitzpatrickSkinToneView: View {
    
    @Environment(\.colorScheme) private var cs
    
    @State private var selection: FitzpatrickSkinTone? = nil
    @State private var sliderValue: Double = 0
    var onContinue: (FitzpatrickSkinTone) -> Void
    
    private let skinTones = FitzpatrickSkinTone.allCases
    
    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your skin tone?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("This helps us recommend the right SPF and UV protection for your skin.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            // Skin tone slider
            VStack(spacing: 16) {
                // Skin color gradient bar
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(Array(skinTones.enumerated()), id: \.offset) { index, skinTone in
                            Rectangle()
                                .fill(skinTone.skinColor)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    // Type labels
                                    VStack {
                                        Spacer()
                                        Text("\(index + 1)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(skinTone.textColor)
                                    }
                                    .padding(.bottom, 4)
                                )
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selection = skinTone
                                        sliderValue = Double(index)
                                    }
                                }
                        }
                    }
                    .frame(height: 40)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                    )
                    
                    // Selection indicator
                    if let selectedTone = selection,
                       let selectedIndex = skinTones.firstIndex(of: selectedTone) {
                        GeometryReader { geometry in
                            Circle()
                                .fill(ThemeManager.shared.theme.palette.primary)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(ThemeManager.shared.theme.palette.primary, lineWidth: 2)
                                )
                                .position(
                                    x: (CGFloat(selectedIndex) + 0.5) * (geometry.size.width / 6),
                                    y: geometry.size.height / 2
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedIndex)
                        }
                        .frame(height: 40)
                    }
                }
                
                // Slider
                VStack(spacing: 8) {
                    Slider(value: $sliderValue, in: 0...5, step: 1)
                        .accentColor(ThemeManager.shared.theme.palette.primary)
                        .onChange(of: sliderValue) { newValue in
                            let index = Int(newValue)
                            if index < skinTones.count {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    selection = skinTones[index]
                                }
                            }
                        }
                    
                    // Slider labels
                    HStack {
                        Text("Lightest")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        Spacer()
                        Text("Darkest")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                }
            }
            
            // Selected skin tone card
            if let selectedTone = selection {
                FitzpatrickSkinToneDetailCard(skinTone: selectedTone)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer(minLength: 8)
            
            // Continue button
            Button {
                guard let picked = selection else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue(picked)
            } label: {
                Text("Continue")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.7 : 1.0)
            }
            .padding(20)
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
        .onAppear {
            // Set initial selection to Type III (middle)
            selection = .type3
            sliderValue = 2
        }
    }
}

// MARK: - Detail Card

private struct FitzpatrickSkinToneDetailCard: View {
    
    let skinTone: FitzpatrickSkinTone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with skin color circle
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(skinTone.skinColor)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 2)
                        )
                    Image(systemName: skinTone.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(skinTone.textColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skinTone.title)
                        .font(ThemeManager.shared.theme.typo.title)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text(skinTone.description)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                
                Spacer()
            }
            
            // UV Protection Info
            VStack(alignment: .leading, spacing: 12) {
                Text("UV Protection")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            Text("UV Sensitivity")
                                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                        Text(skinTone.uvSensitivity)
                            .font(ThemeManager.shared.theme.typo.body)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Recommended SPF")
                                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            Image(systemName: "shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        }
                        Text("SPF \(skinTone.recommendedSPF)+")
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.cardBackground.opacity(0.5))
            )
        }
        .padding(ThemeManager.shared.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.2), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(ThemeManager.shared.theme.palette.primary.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview("FitzpatrickSkinToneView - Light") {
    FitzpatrickSkinToneView(onContinue: { _ in })
        .preferredColorScheme(.light)
}

#Preview("FitzpatrickSkinToneView - Dark") {
    FitzpatrickSkinToneView(onContinue: { _ in })
        .preferredColorScheme(.dark)
}
