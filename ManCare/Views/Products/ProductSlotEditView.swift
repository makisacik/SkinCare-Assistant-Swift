//
//  ProductSlotEditView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotEditView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let slot: ProductSlot
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Product Slot")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Text("This feature will allow you to edit the product slot: \(slot.step.rawValue)")
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Slot")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
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
            budget: .mid,
            notes: "Choose a gentle formula that suits normal skin."
        )
    )
}
