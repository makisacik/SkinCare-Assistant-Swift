//
//  AgeRangeView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AgeRangeView: View {
    
    @Environment(\.colorScheme) private var cs
    
    @State private var selection: AgeRange? = nil
    var onContinue: (AgeRange) -> Void
    var onBack: () -> Void
    
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
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
                Text("What's your age range?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("This helps us tailor the routine to your skin's current needs.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            // Grid of age ranges
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AgeRange.allCases) { ageRange in
                    AgeRangeCard(ageRange: ageRange, selected: selection == ageRange)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                selection = ageRange
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(ageRange.title))
                        .accessibilityHint(Text("Tap to select"))
                        .accessibilityAddTraits(selection == ageRange ? .isSelected : [])
                }
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
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Card

private struct AgeRangeCard: View {
    
    let ageRange: AgeRange
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: ageRange.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 20, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(ageRange.title)
                .font(ThemeManager.shared.theme.typo.title)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(2)
            
            Text(ageRange.description)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(3)
        }
        .padding(ThemeManager.shared.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(selected ? ThemeManager.shared.theme.palette.cardBackground.opacity(0.98) : ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(1.0)
                                        : ThemeManager.shared.theme.palette.shadow,
                        radius: selected ? 14 : 10, x: 0, y: selected ? 8 : 6)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(selected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.18), value: selected)
    }
}

#Preview("AgeRangeView - Light") {
    AgeRangeView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.light)
}

#Preview("AgeRangeView - Dark") {
    AgeRangeView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.dark)
}
