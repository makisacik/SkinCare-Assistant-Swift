//
//  ProductCard.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    private var productColor: Color {
        switch product.tagging.productType {
        case .cleanser: return ThemeManager.shared.theme.palette.info
        case .faceSerum: return ThemeManager.shared.theme.palette.primary
        case .moisturizer: return ThemeManager.shared.theme.palette.success
        case .sunscreen: return ThemeManager.shared.theme.palette.warning
        case .faceSunscreen: return ThemeManager.shared.theme.palette.warning
        case .toner: return ThemeManager.shared.theme.palette.secondary
        case .exfoliator: return ThemeManager.shared.theme.palette.error
        case .faceMask: return ThemeManager.shared.theme.palette.primary
        case .facialOil: return ThemeManager.shared.theme.palette.warning
        default: return ThemeManager.shared.theme.palette.textMuted
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Product image/icon with rounded corners
                Group {
                    if let imageURL = product.imageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(product.tagging.productType.customIconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 40, height: 40)
                        .background(productColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(product.tagging.productType.customIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .background(productColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Product information
                VStack(alignment: .leading, spacing: 4) {
                    // Header with name and type badge
                    HStack {
                        Text(product.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Product type badge
                        Text(product.tagging.productType.displayName)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(productColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(productColor.opacity(0.1))
                            )
                    }
                    
                    // Brand and size
                    HStack(spacing: 6) {
                        if let brand = product.brand {
                            Text(brand)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                        
                        if let size = product.size {
                            Text("• \(size)")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                    }
                    
                    // Description or key ingredients
                    if let description = product.description {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else if !product.tagging.ingredients.isEmpty {
                        Text("Key ingredients: \(product.tagging.ingredients.prefix(2).joined(separator: ", "))")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Claims and features
                    if !product.tagging.claims.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(product.tagging.claims.prefix(3), id: \.self) { claim in
                                    Text(claim.displayName)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.success)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(ThemeManager.shared.theme.palette.success.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                }
                
                // Chevron arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.shared.theme.palette.surface,
                                ThemeManager.shared.theme.palette.surface.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(
                        color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extension to format claim names
extension String {
    var displayName: String {
        switch self.lowercased() {
        case "fragrancefree":
            return "Fragrance Free"
        case "sensitivesafe":
            return "Sensitive Safe"
        case "vegan":
            return "Vegan"
        case "crueltyfree":
            return "Cruelty Free"
        case "parabenfree":
            return "Paraben Free"
        case "sulfatefree":
            return "Sulfate Free"
        case "oilfree":
            return "Oil Free"
        case "noncomedogenic":
            return "Non-comedogenic"
        default:
            return self.capitalized
        }
    }
}

#Preview("ProductCard") {
    let sampleProduct = Product(
        id: "sample",
        displayName: "Gentle Foaming Cleanser",
        tagging: ProductTagging(
            productType: .cleanser,
            ingredients: ["Hyaluronic Acid", "Ceramides", "Niacinamide"],
            claims: ["fragranceFree", "sensitiveSafe", "oilfree"]
        ),
        brand: "CeraVe",
        size: "150ml",
        description: "A gentle cleanser for sensitive skin with ceramides and hyaluronic acid"
    )
    
    LazyVStack(spacing: 16) {
        ProductCard(product: sampleProduct) {
            print("Product tapped")
        }
        ProductCard(product: sampleProduct) {
            print("Product tapped")
        }
    }
    .padding()
}
