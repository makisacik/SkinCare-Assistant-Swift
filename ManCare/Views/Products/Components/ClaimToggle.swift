//
//  ClaimToggle.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ClaimToggle: View {
    
    let claim: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(L10n.Products.Claim.displayName(for: claim))
            .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.accentBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator, lineWidth: 1)
            )
            .onTapGesture {
                onTap()
            }
    }
}

#Preview("ClaimToggle") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
        ClaimToggle(claim: "fragranceFree", isSelected: true) {
            print("Toggle claim")
        }
        ClaimToggle(claim: "vegan", isSelected: false) {
            print("Toggle claim")
        }
        ClaimToggle(claim: "sensitiveSafe", isSelected: true) {
            print("Toggle claim")
        }
    }
    .padding()
}
