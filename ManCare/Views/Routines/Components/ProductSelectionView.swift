//
//  ProductSelectionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    @StateObject private var productService = ProductService.shared
    @State private var searchText = ""
    @State private var selectedProduct: Product?
    @State private var showingAddProduct = false
    
    var filteredProducts: [Product] {
        let compatibleProducts = step.getCompatibleProducts(from: productService)
        
        if searchText.isEmpty {
            return compatibleProducts
        } else {
            return compatibleProducts.filter { product in
                product.displayName.lowercased().contains(searchText.lowercased()) ||
                product.brand?.lowercased().contains(searchText.lowercased()) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Attach Product")
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("Choose a product for your \(step.title) step")
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    
                    TextField("Search products...", text: $searchText)
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Products list
                if filteredProducts.isEmpty {
                    EmptyProductsState(
                        step: step,
                        onAddProduct: {
                            showingAddProduct = true
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProducts, id: \.id) { product in
                                ProductSelectionCard(
                                    product: product,
                                    step: step,
                                    isSelected: selectedProduct?.id == product.id,
                                    onSelect: {
                                        selectedProduct = product
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    if let selectedProduct = selectedProduct {
                        Button {
                            editingService.attachProduct(selectedProduct, to: step)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Attach \(selectedProduct.displayName)")
                                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            }
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.theme.palette.secondary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button {
                        showingAddProduct = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add New Product")
                                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ThemeManager.shared.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductView(
                productService: productService,
                onProductAdded: { _ in
                    // Product added, sheet will dismiss automatically
                }
            )
        }
    }
}

// MARK: - Product Selection Card

private struct ProductSelectionCard: View {
    
    let product: Product
    let step: EditableRoutineStep
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // Product icon
                ZStack {
                    Circle()
                        .fill(Color(product.tagging.productType.color).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: product.tagging.productType.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(product.tagging.productType.color))
                }
                
                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(ThemeManager.shared.theme.typo.title)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if let brand = product.brand {
                        Text(brand)
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    // Product type and compatibility
                    HStack(spacing: 8) {
                        Text(product.tagging.productType.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(product.tagging.productType.color))
                            .cornerRadius(6)
                        
                        if product.tagging.productType == step.stepType {
                            Text("Perfect Match")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ThemeManager.shared.theme.palette.success)
                                .cornerRadius(6)
                        }
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.secondary.opacity(0.1) : ThemeManager.shared.theme.palette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Products State

private struct EmptyProductsState: View {
    
    let step: EditableRoutineStep
    let onAddProduct: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text("No Compatible Products")
                .font(ThemeManager.shared.theme.typo.h3)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text("You don't have any \(step.stepType.displayName.lowercased()) products in your collection yet. Add one to attach it to this step.")
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                onAddProduct()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add \(step.stepType.displayName)")
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                }
                                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(ThemeManager.shared.theme.palette.secondary)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview("ProductSelectionView") {
    let mockStep = EditableRoutineStep(
        id: "test_step",
        title: "Gentle Cleanser",
        description: "Removes dirt, oil, and makeup without stripping skin",
        stepType: .cleanser,
        timeOfDay: .morning,
        why: "Essential for removing daily buildup",
        how: "Apply to damp skin, massage gently, rinse thoroughly",
        isEnabled: true,
        frequency: .daily,
        customInstructions: nil,
        isLocked: true,
        originalStep: true,
        order: 0,
        morningEnabled: true,
        eveningEnabled: false,
        attachedProductId: nil,
        productConstraints: nil
    )
    
    ProductSelectionView(
        step: mockStep,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            completionViewModel: RoutineCompletionViewModel.preview
        )
    )
}
