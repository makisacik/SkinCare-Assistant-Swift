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

        }
        .padding(.vertical, 8)
    }

}

#Preview("SimpleProductRow") {
    let sampleProduct = Product(
        id: "sample",
        displayName: "Gentle Foaming Cleanser",
        tagging: ProductTagging(
            productType: .cleanser,
            ingredients: ["Hyaluronic Acid", "Ceramides"],
            claims: ["fragranceFree", "sensitiveSafe"]
        ),
        brand: "CeraVe",
        size: "150ml",
        description: "A gentle cleanser for sensitive skin"
    )
    
    SimpleProductRow(product: sampleProduct)
        .padding()
}
