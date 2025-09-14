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
        case .oily: return "Oily"
        case .dry: return "Dry"
        case .combination: return "Combination"
        case .normal: return "Normal"
        }
    }

    var subtitle: String {
        switch self {
        case .oily: return "Shiny, enlarged pores"
        case .dry: return "Tightness, flakiness"
        case .combination: return "Oily T-zone, dry cheeks"
        case .normal: return "Balanced skin"
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
        VStack(alignment: .leading, spacing: 20) {

            // Başlık
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your skin type?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("Select your base type to build a simple routine.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .padding(.top, 8)

            // Grid seçim
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(SkinType.allCases) { type in
                    SkinTypeCard(type: type,
                                 selected: selection == type)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            selection = type
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("\(type.title)"))
                    .accessibilityHint(Text("Tap to select"))
                    .accessibilityAddTraits(selection == type ? .isSelected : [])
                }
            }

            Spacer(minLength: 8)

            // Devam butonu
            Button {
                guard let picked = selection else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue(picked)
            } label: {
                Text(selection == nil ? "Continue" : "Continue with \(selection!.title)")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.7 : 1.0)

        }
        .padding(20)
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: type.iconName)
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

            Text(type.title)
                .font(ThemeManager.shared.theme.typo.title)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Text(type.subtitle)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(2)
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
