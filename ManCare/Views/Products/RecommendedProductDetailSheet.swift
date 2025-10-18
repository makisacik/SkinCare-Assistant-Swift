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
                VStack(alignment: .leading, spacing: 24) {
                    // Product Header
                    VStack(alignment: .leading, spacing: 12) {
                        // Product Icon with rounded corners (matching ProductCard)
                        Image(product.productType.customIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .background(productColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Brand & Price Tier
                        HStack {
                            Text(product.brand)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            
                            Spacer()
                            
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
                        
                        // Product Name
                        Text(product.localizedDisplayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        // Size
                        if let size = product.size {
                            Text(size)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                        
                        // Product Type
                        HStack(spacing: 6) {
                            Image(systemName: "tag")
                                .font(.system(size: 12))
                            
                            Text(product.productType.displayName)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Why We Recommend
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            
                            Text("Why We Recommend This")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        }
                        
                        Text(product.localizedRecommendationReason)
                            .font(.system(size: 15))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    // Description
                    if let description = product.localizedDescription {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Product")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            Text(description)
                                .font(.system(size: 15))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Key Ingredients
                    if !product.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(ThemeManager.shared.theme.palette.success)
                                
                                Text("Key Ingredients")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(product.localizedIngredients, id: \.self) { ingredient in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(ThemeManager.shared.theme.palette.primary)
                                            .frame(width: 6, height: 6)
                                        
                                        Text(ingredient)
                                            .font(.system(size: 14))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Purchase Link Button
                    if let purchaseLink = product.purchaseLink, let url = URL(string: purchaseLink) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("View on Store")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.primary, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
                            
                            Text(showingAddedConfirmation ? "Added to Products!" : "Add to My Products")
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

