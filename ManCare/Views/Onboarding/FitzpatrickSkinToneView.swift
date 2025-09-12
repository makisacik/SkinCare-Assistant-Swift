//
//  FitzpatrickSkinToneView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct FitzpatrickSkinToneView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs
    
    @State private var selection: FitzpatrickSkinTone? = nil
    @State private var sliderValue: Double = 0
    var onContinue: (FitzpatrickSkinTone) -> Void
    var onBack: () -> Void
    
    private let skinTones = FitzpatrickSkinTone.allCases
    
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
                Text("What's your skin tone?")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("This helps us recommend the right SPF and UV protection for your skin.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
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
                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                    )
                    
                    // Selection indicator
                    if let selectedTone = selection,
                       let selectedIndex = skinTones.firstIndex(of: selectedTone) {
                        GeometryReader { geometry in
                            Circle()
                                .fill(tm.theme.palette.accent)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
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
                        .accentColor(tm.theme.palette.accent)
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
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
                        Spacer()
                        Text("Darkest")
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
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
                Text(selection == nil ? "Continue" : "Continue with \(selection!.title)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.7 : 1.0)
        }
        .padding(20)
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { tm.refreshForSystemChange($0) }
        .onAppear {
            // Set initial selection to Type III (middle)
            selection = .type3
            sliderValue = 2
        }
    }
}

// MARK: - Detail Card

private struct FitzpatrickSkinToneDetailCard: View {
    @Environment(\.themeManager) private var tm
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
                                .stroke(tm.theme.palette.separator, lineWidth: 2)
                        )
                    Image(systemName: skinTone.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(skinTone.textColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skinTone.title)
                        .font(tm.theme.typo.title)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text(skinTone.description)
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
                
                Spacer()
            }
            
            // UV Protection Info
            VStack(alignment: .leading, spacing: 12) {
                Text("UV Protection")
                    .font(tm.theme.typo.body.weight(.semibold))
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 14))
                                .foregroundColor(tm.theme.palette.accent)
                            Text("UV Sensitivity")
                                .font(tm.theme.typo.caption.weight(.medium))
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                        Text(skinTone.uvSensitivity)
                            .font(tm.theme.typo.body)
                            .foregroundColor(tm.theme.palette.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Recommended SPF")
                                .font(tm.theme.typo.caption.weight(.medium))
                                .foregroundColor(tm.theme.palette.textSecondary)
                            Image(systemName: "shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(tm.theme.palette.accent)
                        }
                        Text("SPF \(skinTone.recommendedSPF)+")
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(tm.theme.palette.accent)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tm.theme.palette.card.opacity(0.5))
            )
        }
        .padding(tm.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: tm.theme.cardRadius, style: .continuous)
                .fill(tm.theme.palette.card)
                .shadow(color: tm.theme.palette.shadow, radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                        .stroke(tm.theme.palette.accent.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview("FitzpatrickSkinToneView - Light") {
    FitzpatrickSkinToneView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.light)
}

#Preview("FitzpatrickSkinToneView - Dark") {
    FitzpatrickSkinToneView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.dark)
}
