//
//  ProductRecommendationsView.swift
//  ManCare
//
//  Full view showing all product recommendations grouped by routine step
//

import SwiftUI

struct ProductRecommendationsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var recommendationService = ProductRecommendationService.shared
    
    let recommendations: [RecommendedProduct]
    let onProductTapped: (RecommendedProduct) -> Void
    let onAddProduct: (RecommendedProduct) -> Void
    
    // Group recommendations by product type
    private var groupedRecommendations: [(ProductType, [RecommendedProduct])] {
        let grouped = Dictionary(grouping: recommendations) { $0.productType }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Grouped Recommendations (as expandable cards)
                    ForEach(groupedRecommendations, id: \.0.rawValue) { productType, products in
                        ProductTypeRecommendationSection(
                            productType: productType,
                            products: products,
                            onProductTapped: onProductTapped,
                            onAddProduct: onAddProduct
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("Recommended Products")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Helper to Get Product Color

extension ProductType {
    var productColor: Color {
        switch self {
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
}

// MARK: - Product Type Section (Expandable Card)

private struct ProductTypeRecommendationSection: View {
    let productType: ProductType
    let products: [RecommendedProduct]
    let onProductTapped: (RecommendedProduct) -> Void
    let onAddProduct: (RecommendedProduct) -> Void
    
    @State private var isExpanded = false
    
    // Sort products by brand name
    private var sortedProducts: [RecommendedProduct] {
        products.sorted { $0.brand < $1.brand }
    }
    
    private var productColor: Color {
        switch productType {
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
        VStack(alignment: .leading, spacing: 0) {
            // Expandable Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Product Type Icon with rounded corners
                    Image(productType.customIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .background(productColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(productType.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(16)
            }
            
            // Products (collapsible)
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(sortedProducts) { product in
                        RecommendedProductCard(
                            product: product,
                            onTap: { onProductTapped(product) },
                            onAdd: { onAddProduct(product) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemeManager.shared.theme.palette.border.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Recommended Product Card

private struct RecommendedProductCard: View {
    let product: RecommendedProduct
    let onTap: () -> Void
    let onAdd: () -> Void
    
    @State private var isExpanded = false
    
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
        VStack(alignment: .leading, spacing: 12) {
            // Header - Always Visible
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Product Icon with rounded corners (matching ProductCard)
                    Image(product.productType.customIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .background(productColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(product.brand)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            
                            // Product type badge (inline style)
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
                        
                        Text(product.localizedDisplayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
            }
            
            // Recommendation Reason
            Text(product.localizedRecommendationReason)
                .font(.system(size: 14))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .lineLimit(isExpanded ? nil : 2)
            
            // Key Ingredients
            if !product.ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Key Ingredients:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(product.localizedIngredients.prefix(5), id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(ThemeManager.shared.theme.palette.surface)
                                    )
                            }
                        }
                    }
                }
            }
            
            // Add to Products Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onAdd()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Add to My Products")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ThemeManager.shared.theme.palette.primary)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.surface)
        )
    }
}

// MARK: - Preview

#Preview("ProductRecommendationsView") {
    let sampleProducts = [
        RecommendedProduct(
            routineStepId: "1",
            productType: .cleanser,
            brand: "CeraVe",
            displayName: "Hydrating Facial Cleanser",
            ingredients: ["Ceramides", "Hyaluronic Acid", "Glycerin"],
            recommendationReason: "Gentle, non-foaming formula that cleanses without stripping moisture",
            size: "236ml",
            locale: "en-US"
        ),
        RecommendedProduct(
            routineStepId: "1",
            productType: .cleanser,
            brand: "La Roche-Posay",
            displayName: "Toleriane Hydrating Gentle Cleanser",
            ingredients: ["Ceramide-3", "Niacinamide", "Glycerin"],
            recommendationReason: "Dermatologist-recommended for sensitive skin",
            size: "200ml",
            locale: "en-US"
        ),
        RecommendedProduct(
            routineStepId: "1",
            productType: .cleanser,
            brand: "SK-II",
            displayName: "Facial Treatment Gentle Cleanser",
            ingredients: ["Pitera", "Glycerin", "Butylene Glycol"],
            recommendationReason: "Luxurious formula with SK-II's signature Pitera essence",
            size: "120g",
            locale: "en-US"
        )
    ]
    
    ProductRecommendationsView(
        recommendations: sampleProducts,
        onProductTapped: { print("Product tapped: \($0.displayName)") },
        onAddProduct: { print("Add product: \($0.displayName)") }
    )
}

