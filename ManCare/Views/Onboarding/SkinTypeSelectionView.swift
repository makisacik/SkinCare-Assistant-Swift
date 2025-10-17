//
//  SkinTypeSelectionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

enum SkinType: String, CaseIterable, Identifiable, Codable {
    case oily, dry, combination, normal
    var id: String { rawValue }

    var title: String {
        switch self {
        case .oily: return L10n.Onboarding.SkinType.oily
        case .dry: return L10n.Onboarding.SkinType.dry
        case .combination: return L10n.Onboarding.SkinType.combination
        case .normal: return L10n.Onboarding.SkinType.normal
        }
    }

    var subtitle: String {
        switch self {
        case .oily: return L10n.Onboarding.SkinType.oilySubtitle
        case .dry: return L10n.Onboarding.SkinType.drySubtitle
        case .combination: return L10n.Onboarding.SkinType.combinationSubtitle
        case .normal: return L10n.Onboarding.SkinType.normalSubtitle
        }
    }

    var iconName: String {
        switch self {
        case .oily: return "drop.fill"
        case .dry: return "wind"
        case .combination: return "circle.grid.2x1.left.filled"
        case .normal: return "checkmark.seal.fill"
        }
    }
}


// MARK: - View

struct SkinTypeSelectionView: View {
    
    @Environment(\.colorScheme)  private var cs

    @State private var selection: SkinType? = nil
    var onContinue: (SkinType) -> Void = { _ in }

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
                        Text(L10n.Onboarding.SkinType.title)
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .padding(.top, 44) // Add top padding to align with pages that have back button
                        Text(L10n.Onboarding.SkinType.subtitle)
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    // Grid of skin types
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(SkinType.allCases) { type in
                            SkinTypeCard(type: type, selected: selection == type)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selection = type
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text(type.title))
                                .accessibilityHint(Text(L10n.Onboarding.SkinType.tapToSelect))
                                .accessibilityAddTraits(selection == type ? .isSelected : [])
                        }
                    }
                    
                    Spacer(minLength: 8)
                    
                    // Continue button
                    Button {
                        guard let picked = selection else { return }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onContinue(picked)
                    } label: {
                        Text(L10n.Onboarding.SkinType.continue)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selection == nil)
                    .opacity(selection == nil ? 0.7 : 1.0)
                }
                .padding(20)
            }
        }
        .onChange(of: cs) { newScheme in
            ThemeManager.shared.refreshForSystemChange(newScheme)
        }
    }
}

// MARK: - Card

private struct SkinTypeCard: View {
    
    var type: SkinType
    var selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: type.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 18, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(type.title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.9)
            
            Text(type.subtitle)
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

// MARK: - Preview

#Preview("SkinTypeSelectionView – Light") {
    SkinTypeSelectionView { _ in }
        .preferredColorScheme(.light)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}

#Preview("SkinTypeSelectionView – Dark") {
    SkinTypeSelectionView { _ in }
        .preferredColorScheme(.dark)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}
