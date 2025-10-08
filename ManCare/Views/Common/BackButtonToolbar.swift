//
//  BackButtonToolbar.swift
//  ManCare
//
//  A reusable toolbar modifier for back button navigation
//

import SwiftUI

/// A toolbar-style back button that can be used without NavigationStack
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
                            Text("Back")
                                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 45)
                .padding(.bottom, 12)
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
