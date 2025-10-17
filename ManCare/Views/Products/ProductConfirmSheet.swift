//
//  ProductConfirmSheet.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Product Confirmation Sheet

/// Sheet for user to confirm which product they scanned
struct ProductConfirmSheet: View {
    let candidates: [ProductCandidate]
    var onPick: (ProductCandidate?) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(candidates) { c in
                    Button {
                        onPick(c)
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: c.imageURL) { phase in
                                switch phase {
                                case .success(let img): img.resizable()
                                default: Color.secondary.opacity(0.15)
                                }
                            }
                            .frame(width: 64, height: 64).clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading) {
                                Text(c.title).font(.headline)
                                Text(c.subtitle).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                            }
                            Spacer()
                            Text(String(format: "%.0f%%", c.score * 100)).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    Button(role: .cancel) { onPick(nil) } label: { Text(L10n.Products.Confirm.noneOfThese) }
                }
            }
            .navigationTitle(L10n.Products.Confirm.title)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(L10n.Common.cancel) { onPick(nil) } } }
        }
    }
}

// MARK: - Preview

#Preview {
    ProductConfirmSheet(
        candidates: [
            ProductCandidate(
                title: "Hydrating Cleanser",
                subtitle: "CeraVe • 236 ml",
                imageURL: nil,
                score: 0.85,
                raw: OBFProduct(
                    code: "123",
                    brands: "CeraVe",
                    product_name: "Hydrating Cleanser",
                    quantity: "236 ml",
                    ingredients_text: "Water, Ceramides",
                    image_url: nil,
                    image_front_small_url: nil
                )
            ),
            ProductCandidate(
                title: "Foaming Facial Cleanser",
                subtitle: "CeraVe • 236 ml",
                imageURL: nil,
                score: 0.72,
                raw: OBFProduct(
                    code: "456",
                    brands: "CeraVe",
                    product_name: "Foaming Facial Cleanser",
                    quantity: "236 ml",
                    ingredients_text: "Water, Foaming Agents",
                    image_url: nil,
                    image_front_small_url: nil
                )
            )
        ]
    ) { _ in }
}
