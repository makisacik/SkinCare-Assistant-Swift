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
    @Environment(\.themeManager) private var tm
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
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("Select your base type to build a simple routine.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
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
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { newScheme in
            tm.refreshForSystemChange(newScheme)
        }
    }
}

// MARK: - Card

private struct SkinTypeCard: View {
    @Environment(\.themeManager) private var tm
    var type: SkinType
    var selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: type.iconName)
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

            Text(type.title)
                .font(tm.theme.typo.title)
                .foregroundColor(tm.theme.palette.textPrimary)

            Text(type.subtitle)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textMuted)
                .lineLimit(2)
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

// MARK: - Preview

#Preview("SkinTypeSelectionView – Light") {
    let tm = ThemeManager()
    SkinTypeSelectionView { _ in }
        .themed(tm)
        .preferredColorScheme(.light)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}

#Preview("SkinTypeSelectionView – Dark") {
    let tm = ThemeManager()
    SkinTypeSelectionView { _ in }
        .themed(tm)
        .preferredColorScheme(.dark)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}
