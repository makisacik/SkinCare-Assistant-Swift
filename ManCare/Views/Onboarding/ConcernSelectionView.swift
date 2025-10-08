//  ConcernSelectionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

enum Concern: String, CaseIterable, Identifiable, Codable {
    case acne, redness, blackheads, largePores, postShaveIrritation, none
    var id: String { rawValue }

    var title: String {
        switch self {
        case .acne:                return "Acne"
        case .redness:             return "Redness"
        case .blackheads:          return "Blackheads"
        case .largePores:          return "Large Pores"
        case .postShaveIrritation: return "Post-Shave Irritation"
        case .none:                return "None"
        }
    }

    var subtitle: String {
        switch self {
        case .acne:                return "Breakouts, whiteheads"
        case .redness:             return "Sensitivity, flushing"
        case .blackheads:          return "Clogged pores, oil build-up"
        case .largePores:          return "Texture, visible pores"
        case .postShaveIrritation: return "Razor burn, ingrowns"
        case .none:                return "No specific concerns"
        }
    }

    var iconName: String {
        switch self {
        case .acne:                return "circle.grid.cross.left.fill" // blemish vibe
        case .redness:             return "thermometer.sun"             // heat/redness
        case .blackheads:          return "circle.dashed.inset.filled"  // texture/pores
        case .largePores:          return "circle.dashed.inset.filled"  // texture/pores
        case .postShaveIrritation: return "scissors"                       // SF Symbols 16+
        case .none:                return "checkmark.circle.fill"        // no concerns
        }
    }
}

// MARK: - View

struct ConcernSelectionView: View {
    
    @Environment(\.colorScheme)  private var cs

    @State private var selections: Set<Concern> = []
    @State private var customConcern: String = ""
    @State private var isEditingCustomConcern: Bool = false
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
                                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.top, 8)

            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("What concerns you?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("Pick what you want to focus on.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            // Grid of concerns
            LazyVGrid(columns: columns, spacing: 10) {
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
            
            // Custom concern input
            HStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isEditingCustomConcern || !customConcern.isEmpty ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.secondary)
                
                TextField("Type your own concern...", text: $customConcern, onEditingChanged: { editing in
                    isEditingCustomConcern = editing
                })
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.done)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                    .fill(ThemeManager.shared.theme.palette.cardBackground)
                    .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(isEditingCustomConcern ? 0.8 : 0.5), radius: isEditingCustomConcern ? 10 : 4, x: 0, y: isEditingCustomConcern ? 6 : 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                            .stroke(isEditingCustomConcern || !customConcern.isEmpty ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.separator, lineWidth: isEditingCustomConcern || !customConcern.isEmpty ? 2 : 1)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isEditingCustomConcern)
            .animation(.easeInOut(duration: 0.2), value: customConcern.isEmpty)

            Spacer(minLength: 8)

            // Action buttons
            VStack(spacing: 12) {
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

                // Optional: Skip
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onContinue([])
                } label: {
                    Text("Skip for now")
                }
                .buttonStyle(GhostButtonStyle())
            }

        }
        .padding(20)
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .onChange(of: cs) { newScheme in
            ThemeManager.shared.refreshForSystemChange(newScheme)
        }    }

    private func toggle(_ c: Concern) {
        if c == .none {
            // If selecting "None", clear all other selections
            if selections.contains(.none) {
                selections.remove(.none)
            } else {
                selections.removeAll()
                selections.insert(.none)
            }
        } else {
            // If selecting any other concern, remove "None" if it's selected
            if selections.contains(.none) {
                selections.remove(.none)
            }
            
            if selections.contains(c) {
                selections.remove(c)
            } else {
                selections.insert(c)
            }
        }
    }
}

// MARK: - Card

private struct ConcernCard: View {
    
    let concern: Concern
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: concern.iconName)
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

            Text(concern.title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text(concern.subtitle)
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
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(1.0)
                                        : ThemeManager.shared.theme.palette.shadow,
                        radius: selected ? 12 : 8, x: 0, y: selected ? 6 : 4)
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

#Preview("ConcernSelection – Light") {
    ConcernSelectionView { _ in }
        .preferredColorScheme(.light)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}

#Preview("ConcernSelection – Dark") {
    ConcernSelectionView { _ in }
        .preferredColorScheme(.dark)
        .frame(maxHeight: 640)
        .padding(.vertical, 8)
}
