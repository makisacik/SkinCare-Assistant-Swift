//  ConcernSelectionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

enum Concern: String, CaseIterable, Identifiable, Codable {
    case acne, redness, pores, postShaveIrritation
    var id: String { rawValue }

    var title: String {
        switch self {
        case .acne:                return "Acne"
        case .redness:             return "Redness"
        case .pores:               return "Large Pores"
        case .postShaveIrritation: return "Post-Shave Irritation"
        }
    }

    var subtitle: String {
        switch self {
        case .acne:                return "Breakouts, blackheads"
        case .redness:             return "Sensitivity, flushing"
        case .pores:               return "Texture, oil build-up"
        case .postShaveIrritation: return "Razor burn, ingrowns"
        }
    }

    var iconName: String {
        switch self {
        case .acne:                return "circle.grid.cross.left.fill" // blemish vibe
        case .redness:             return "thermometer.sun"             // heat/redness
        case .pores:               return "circle.dashed.inset.filled"  // texture/pores
        case .postShaveIrritation: return "scissors"                       // SF Symbols 16+
        }
    }
}

// MARK: - View

struct ConcernSelectionView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme)  private var cs

    @State private var selections: Set<Concern> = []
    /// Called when user taps Continue with current selections
    var onContinue: (Set<Concern>) -> Void = { _ in }
    /// Called when user wants to go back to skin type selection
    var onBack: (() -> Void)? = nil

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Header with back button
            HStack {
                if let onBack = onBack {
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
                }
                Spacer()
            }
            .padding(.top, 8)

            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("Select Your Concerns")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("Pick what you want to focus on. You can change this anytime.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }

            // Grid of concerns
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Concern.allCases) { c in
                    ConcernCard(concern: c, selected: selections.contains(c))
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                toggle(c)
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(c.title))
                        .accessibilityHint(Text("Tap to select"))
                        .accessibilityAddTraits(selections.contains(c) ? .isSelected : [])
                }
            }

            Spacer(minLength: 8)

            // Continue
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue(selections)
            } label: {
                Text(selections.isEmpty
                     ? "Continue"
                     : "Continue with \(selections.count) Selected")
            }
            .buttonStyle(PrimaryButtonStyle())

            // Optional: Clear selection / Skip
            Button("Skip for now") {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onContinue([])
            }
            .buttonStyle(GhostButtonStyle())

        }
        .padding(20)
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { newScheme in
            tm.refreshForSystemChange(newScheme)
        }    }

    private func toggle(_ c: Concern) {
        if selections.contains(c) { selections.remove(c) } else { selections.insert(c) }
    }
}

// MARK: - Card

private struct ConcernCard: View {
    @Environment(\.themeManager) private var tm
    let concern: Concern
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: concern.iconName)
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

            Text(concern.title)
                .font(tm.theme.typo.title)
                .foregroundColor(tm.theme.palette.textPrimary)

            Text(concern.subtitle)
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

#Preview("ConcernSelection – Light") {
    let tm = ThemeManager()
    ConcernSelectionView { _ in }
        .themed(tm)
        .preferredColorScheme(.light)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}

#Preview("ConcernSelection – Dark") {
    let tm = ThemeManager()
    ConcernSelectionView { _ in }
        .themed(tm)
        .preferredColorScheme(.dark)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}
