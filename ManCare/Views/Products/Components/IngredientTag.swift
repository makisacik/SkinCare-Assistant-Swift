//
//  IngredientTag.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct IngredientTag: View {
    
    let ingredient: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(ingredient)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(ThemeManager.shared.theme.palette.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview("IngredientTag") {
    HStack {
        IngredientTag(ingredient: "Hyaluronic Acid") {
            print("Remove ingredient")
        }
        IngredientTag(ingredient: "Ceramides") {
            print("Remove ingredient")
        }
    }
    .padding()
}
