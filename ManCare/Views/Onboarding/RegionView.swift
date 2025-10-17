//
//  RegionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RegionView: View {
    
    @Environment(\.colorScheme) private var cs

    @State private var selection: Region? = nil
    var onContinue: (Region) -> Void

    private let regions = Region.allCases
    private let columns = [GridItem(.flexible(), spacing: 8),
                           GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Onboarding.Region.title)
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        Text(L10n.Onboarding.Region.subtitle)
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    // Grid of climate regions
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(regions) { region in
                            RegionCard(region: region, selected: selection == region)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selection = region
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text(region.title))
                                .accessibilityHint(Text(L10n.Onboarding.SkinType.tapToSelect))
                                .accessibilityAddTraits(selection == region ? .isSelected : [])
                        }
                    }
                    
                    Spacer(minLength: 8)
                    
                    // Continue button
                    Button {
                        guard let picked = selection else { return }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onContinue(picked)
                    } label: {
                        Text(L10n.Onboarding.Region.continue)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selection == nil)
                    .opacity(selection == nil ? 0.7 : 1.0)
                }
                .padding(16)
            }
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Card

private struct RegionCard: View {
    
    let region: Region
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(region.climateColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: region.iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(region.climateColor)
                }
                
                Spacer()
                
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 16, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(region.title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.8)
            
            Text(region.description)
                .font(.system(size: 11))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .frame(height: 85)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(selected ? ThemeManager.shared.theme.palette.cardBackground.opacity(0.98) : ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(0.3)
                                        : ThemeManager.shared.theme.palette.shadow.opacity(0.15),
                        radius: selected ? 8 : 4, x: 0, y: selected ? 4 : 2)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(selected ? region.climateColor : ThemeManager.shared.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .scaleEffect(selected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
    }
}

#Preview("RegionView - Light") {
    RegionView(onContinue: { _ in })
        .preferredColorScheme(.light)
}

#Preview("RegionView - Dark") {
    RegionView(onContinue: { _ in })
        .preferredColorScheme(.dark)
}
