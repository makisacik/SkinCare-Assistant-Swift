//
//  SimpleProductRow.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct SimpleProductRow: View {
    
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            Image(product.tagging.productType.customIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.localizedDisplayName)
                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                HStack(spacing: 8) {
                    if let brand = product.localizedBrand {
                        Text(brand)
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }

                    Text(product.tagging.productType.displayName)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
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
