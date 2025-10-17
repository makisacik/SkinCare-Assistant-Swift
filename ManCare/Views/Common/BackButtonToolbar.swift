//
//  BackButtonToolbar.swift
//  ManCare
//
//  A reusable toolbar modifier for back button navigation
//

import SwiftUI

/// A toolbar-style back button that can be used without NavigationStack
/// This modifier adds a fixed-position back button using safeAreaInset
struct BackButtonToolbar: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        action()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text(L10n.Common.back)
                                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .frame(height: 44) // Fixed height - this is the key to consistent positioning
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .background(ThemeManager.shared.theme.palette.accentBackground)
            }
    }
}

extension View {
    /// Adds a toolbar-style back button at the top of the view
    func backButtonToolbar(action: @escaping () -> Void) -> some View {
        modifier(BackButtonToolbar(action: action))
    }
}
