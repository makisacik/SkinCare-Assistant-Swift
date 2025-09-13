//
//  ClaimToggle.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ClaimToggle: View {
    @Environment(\.themeManager) private var tm
    let claim: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(claimDisplayName(claim))
            .font(tm.theme.typo.caption.weight(.medium))
            .foregroundColor(isSelected ? tm.theme.palette.textInverse : tm.theme.palette.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.accentBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
            )
            .onTapGesture {
                onTap()
            }
    }

    private func claimDisplayName(_ claim: String) -> String {
        switch claim {
        case "fragranceFree": return "Fragrance Free"
        case "sensitiveSafe": return "Sensitive Safe"
        case "vegan": return "Vegan"
        case "crueltyFree": return "Cruelty Free"
        case "dermatologistTested": return "Dermatologist Tested"
        case "nonComedogenic": return "Non-Comedogenic"
        default: return claim
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
