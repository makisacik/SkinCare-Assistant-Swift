//
//  RecommendationsPreviewCard.swift
//  ManCare
//
//  Preview card showing first 3 product recommendations
//

import SwiftUI

struct RecommendationsPreviewCard: View {
    let products: [RecommendedProduct]
    let totalCount: Int
    let onViewAll: () -> Void
    let onProductTapped: (RecommendedProduct) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended Products")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("Budget & premium options for each step")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }
            
            // Product Preview Grid (3 products max)
            LazyVStack(spacing: 12) {
                ForEach(products.prefix(3)) { product in
                    RecommendationPreviewItem(
                        product: product,
                        onTap: { onProductTapped(product) }
                    )
                }
            }
            
            // View All Button
            Button {
                onViewAll()
            } label: {
                HStack {
                    Text("View All")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                )
            }
        }
        .padding(16)
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
}

// MARK: - Preview Item

private struct RecommendationPreviewItem: View {
    let product: RecommendedProduct
    let onTap: () -> Void
    
    private var productColor: Color {
        switch product.productType {
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
                // Product Icon with rounded corners (matching ProductCard exactly)
                Image(product.productType.customIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .background(productColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Product information (matching ProductCard layout)
                VStack(alignment: .leading, spacing: 4) {
                    // Header with name and product type badge
                    HStack {
                        Text(product.localizedDisplayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Product type badge (matching ProductCard badge style)
                        Text(product.productType.displayName)
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
                        Text(product.brand)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        
                        if let size = product.size {
                            Text("• \(size)")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                    }
                    
                    // Recommendation reason (matching ProductCard description style)
                    Text(product.localizedRecommendationReason)
                        .font(.system(size: 12))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Chevron arrow (matching ProductCard)
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


// MARK: - Loading State

struct RecommendationsLoadingCard: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                ProgressView()
                    .tint(ThemeManager.shared.theme.palette.primary)
            }
            
            // Text
            VStack(spacing: 8) {
                Text("Preparing Your Recommendations")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text("We're finding the best products for your routine...")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview("RecommendationsPreviewCard") {
    let sampleProducts = [
        RecommendedProduct(
            routineStepId: "1",
            productType: .cleanser,
            brand: "CeraVe",
            displayName: "Hydrating Facial Cleanser",
            ingredients: ["Ceramides", "Hyaluronic Acid"],
            recommendationReason: "Gentle and hydrating for daily use",
            size: "236ml",
            locale: "en-US"
        ),
        RecommendedProduct(
            routineStepId: "2",
            productType: .moisturizer,
            brand: "La Roche-Posay",
            displayName: "Toleriane Double Repair Face Moisturizer",
            ingredients: ["Niacinamide", "Ceramide-3"],
            recommendationReason: "Restores skin barrier",
            size: "75ml",
            locale: "en-US"
        ),
        RecommendedProduct(
            routineStepId: "3",
            productType: .sunscreen,
            brand: "EltaMD",
            displayName: "UV Clear Broad-Spectrum SPF 46",
            ingredients: ["Zinc Oxide", "Niacinamide"],
            recommendationReason: "Excellent protection without white cast",
            size: "48g",
            locale: "en-US"
        )
    ]
    
    VStack(spacing: 20) {
        RecommendationsPreviewCard(
            products: sampleProducts,
            totalCount: 15,
            onViewAll: { print("View all tapped") },
            onProductTapped: { print("Product tapped: \($0.displayName)") }
        )
        
        RecommendationsLoadingCard()
    }
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}

