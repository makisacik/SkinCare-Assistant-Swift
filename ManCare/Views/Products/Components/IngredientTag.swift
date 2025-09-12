//
//  IngredientTag.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct IngredientTag: View {
    @Environment(\.themeManager) private var tm
    let ingredient: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(ingredient)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textPrimary)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(tm.theme.palette.textMuted)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tm.theme.palette.secondary.opacity(0.1))
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
