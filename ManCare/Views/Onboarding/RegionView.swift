//
//  RegionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RegionView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs
    
    @State private var selection: Region? = nil
    var onContinue: (Region) -> Void
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
                Text("Where do you spend most of your time?")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("Climate affects your skin's needs for UV protection and hydration.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }
            
            // Grid of regions
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Region.allCases) { region in
                    RegionCard(region: region, selected: selection == region)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                selection = region
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(region.title))
                        .accessibilityHint(Text("Tap to select"))
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
    }
}

// MARK: - Card

private struct RegionCard: View {
    @Environment(\.themeManager) private var tm
    let region: Region
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: region.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(tm.theme.palette.accent)
                        .font(.system(size: 20, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(region.title)
                .font(tm.theme.typo.title)
                .foregroundColor(tm.theme.palette.textPrimary)
                .lineLimit(2)
            
            Text(region.description)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textMuted)
                .lineLimit(2)
            
            // Climate info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 10))
                        .foregroundColor(tm.theme.palette.textMuted)
                    Text(region.averageUVIndex)
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
                HStack(spacing: 4) {
                    Image(systemName: "humidity.fill")
                        .font(.system(size: 10))
                        .foregroundColor(tm.theme.palette.textMuted)
                    Text("Humidity: \(region.humidityLevel)")
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
            }
        }
        .padding(tm.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: tm.theme.cardRadius, style: .continuous)
                .fill(selected ? tm.theme.palette.card.opacity(0.98) : tm.theme.palette.card)
                .shadow(color: selected ? tm.theme.palette.shadow.opacity(1.0)
                                        : tm.theme.palette.shadow,
                        radius: selected ? 14 : 10, x: 0, y: selected ? 8 : 6)
                .overlay(
                    RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                        .stroke(selected ? tm.theme.palette.secondary : tm.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.18), value: selected)
    }
}

#Preview("RegionView - Light") {
    RegionView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.light)
}

#Preview("RegionView - Dark") {
    RegionView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.dark)
}
