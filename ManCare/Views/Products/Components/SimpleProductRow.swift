//
//  SimpleProductRow.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct SimpleProductRow: View {
    @Environment(\.themeManager) private var tm
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: product.tagging.productType.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.theme.palette.secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(tm.theme.palette.textPrimary)

                HStack(spacing: 8) {
                    if let brand = product.brand {
                        Text(brand)
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
                    }

                    Text(product.tagging.productType.displayName)
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let price = product.price {
                    Text("$\(String(format: "%.2f", price))")
                        .font(tm.theme.typo.caption.weight(.semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                Text(budgetTitle(product.tagging.budget))
                    .font(tm.theme.typo.caption.weight(.semibold))
                    .foregroundColor(budgetColor(product.tagging.budget))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(budgetColor(product.tagging.budget).opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    private func budgetTitle(_ budget: Budget) -> String {
        switch budget {
        case .low:
            return "Budget"
        case .mid:
            return "Mid"
        case .high:
            return "Premium"
        }
    }

    private func budgetColor(_ budget: Budget) -> Color {
        switch budget {
        case .low:
            return .green
        case .mid:
            return .orange
        case .high:
            return .red
        }
    }
}

#Preview("SimpleProductRow") {
    let sampleProduct = Product(
        id: "sample",
        displayName: "Gentle Foaming Cleanser",
        tagging: ProductTagging(
            productType: .cleanser,
            ingredients: ["Hyaluronic Acid", "Ceramides"],
            claims: ["fragranceFree", "sensitiveSafe"],
            budget: .mid
        ),
        brand: "CeraVe",
        price: 12.99,
        size: "150ml",
        description: "A gentle cleanser for sensitive skin"
    )
    
    SimpleProductRow(product: sampleProduct)
        .padding()
        .themed(ThemeManager())
}
