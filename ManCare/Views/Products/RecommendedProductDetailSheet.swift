//
//  RecommendedProductDetailSheet.swift
//  ManCare
//
//  Detail sheet for a recommended product
//

import SwiftUI

struct RecommendedProductDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var productService = ProductService.shared
    
    let product: RecommendedProduct
    let onAddProduct: (RecommendedProduct) -> Void
    var showCloseButton: Bool = true // Show close button by default (for sheet presentation)
    
    @State private var showingAddedConfirmation = false
    
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
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Compact Product Header Card
                    VStack(spacing: 16) {
                        // Icon and Basic Info
                        HStack(alignment: .top, spacing: 16) {
                            // Product Icon
                            Image(product.productType.customIconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .background(productColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Product Info
                            VStack(alignment: .leading, spacing: 6) {
                                // Brand and Badge
                                HStack {
                                    Text(product.brand)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    
                                    Spacer()
                                    
                                    // Product type badge
                                    Text(product.productType.displayName)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(productColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(productColor.opacity(0.1))
                                        )
                                }
                                
                                // Product Name
                                Text(product.localizedDisplayName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    .lineLimit(2)
                                
                                // Size
                                if let size = product.size {
                                    HStack(spacing: 4) {
                                        Image(systemName: "cube.box")
                                            .font(.system(size: 10))
                                        Text(size)
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeManager.shared.theme.palette.surface)
                            .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // Why We Recommend - Compact Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(productColor)
                            
                            Text(L10n.Products.Recommendations.whyRecommend)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        }
                        
                        Text(product.localizedRecommendationReason)
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(productColor.opacity(0.08))
                    )
                    .padding(.horizontal, 16)
                    
                    // Description - Compact Card
                    if let description = product.localizedDescription {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.info)
                                
                                Text(L10n.Products.Recommendations.about)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Key Ingredients - Compact Card
                    if !product.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.success)
                                
                                Text(L10n.Products.Recommendations.keyIngredients)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            // Ingredients list
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(product.localizedIngredients, id: \.self) { ingredient in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(ThemeManager.shared.theme.palette.success)
                                            .frame(width: 5, height: 5)
                                        
                                        Text(ingredient)
                                            .font(.system(size: 13))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Purchase Link Button
                    if let purchaseLink = product.purchaseLink, let url = URL(string: purchaseLink) {
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(L10n.Products.Recommendations.viewProduct)
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(productColor)
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showCloseButton {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    }
                }
            }
            .toolbarBackground(ThemeManager.shared.theme.palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                // Add to Products Button
                VStack(spacing: 0) {
                    Divider()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        addProductToList()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text(showingAddedConfirmation ? L10n.Products.Recommendations.added : L10n.Products.Recommendations.addToProducts)
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(showingAddedConfirmation ? ThemeManager.shared.theme.palette.success : ThemeManager.shared.theme.palette.primary)
                        )
                    }
                    .disabled(showingAddedConfirmation)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(ThemeManager.shared.theme.palette.background)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func addProductToList() {
        onAddProduct(product)
        
        // Show confirmation
        withAnimation {
            showingAddedConfirmation = true
        }
        
        // Auto dismiss after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("RecommendedProductDetailSheet") {
    let sampleProduct = RecommendedProduct(
        routineStepId: "1",
        productType: .cleanser,
        brand: "CeraVe",
        displayName: "Hydrating Facial Cleanser",
        ingredients: [
            "Ceramides",
            "Hyaluronic Acid",
            "Glycerin",
            "MVE Technology",
            "Non-comedogenic"
        ],
        recommendationReason: "This cleanser is perfect for your skin type because it provides gentle cleansing without stripping natural oils. The ceramides help restore your skin barrier while hyaluronic acid provides deep hydration.",
        size: "236ml",
        purchaseLink: "https://www.cerave.com",
        descriptionText: "CeraVe Hydrating Facial Cleanser is developed with dermatologists to effectively cleanse the skin while maintaining its natural protective barrier. This unique formula, with three essential ceramides, hyaluronic acid and MVE technology, works to cleanse, hydrate and help restore the protective skin barrier.",
        locale: "en-US"
    )
    
    RecommendedProductDetailSheet(
        product: sampleProduct,
        onAddProduct: { print("Add product: \($0.displayName)") }
    )
}

