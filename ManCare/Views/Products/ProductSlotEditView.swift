//
//  ProductSlotEditView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let slot: ProductSlot
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.Products.Slot.Edit.title)
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text(L10n.Products.Slot.Edit.subtitle(slot.step.displayName))
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle(L10n.Products.Slot.Edit.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("ProductSlotEditView") {
    ProductSlotEditView(
        slot: ProductSlot(
            slotID: "1",
            step: .cleanser,
            time: .AM,
            constraints: Constraints(
                spf: 0,
                fragranceFree: true,
                sensitiveSafe: true,
                vegan: true,
                crueltyFree: true,
                avoidIngredients: [],
                preferIngredients: ["salicylic acid", "niacinamide"]
            ),
            notes: "Choose a gentle formula that suits normal skin."
        )
    )
}
