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
    var onContinue: (FitzpatrickSkinTone) -> Void
    
    private let skinTones = FitzpatrickSkinTone.allCases
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            ScrollView {
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
                    
                    // Grid of skin tones
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(skinTones) { skinTone in
                            FitzpatrickSkinToneCard(skinTone: skinTone, selected: selection == skinTone)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selection = skinTone
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text(skinTone.title))
                                .accessibilityHint(Text("Tap to select"))
                                .accessibilityAddTraits(selection == skinTone ? .isSelected : [])
                        }
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
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Card

private struct FitzpatrickSkinToneCard: View {
    
    let skinTone: FitzpatrickSkinTone
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with skin color circle
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(skinTone.skinColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                    Image(systemName: skinTone.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(skinTone.textColor)
                }
                
                Spacer()
                
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 18, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(skinTone.title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.9)
            
            Text(skinTone.description)
                .font(.system(size: 12))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .frame(height: 110)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(selected ? ThemeManager.shared.theme.palette.cardBackground.opacity(0.98) : ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(0.3)
                                        : ThemeManager.shared.theme.palette.shadow.opacity(0.15),
                        radius: selected ? 8 : 4, x: 0, y: selected ? 4 : 2)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(selected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .scaleEffect(selected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
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
