//
//  ProductDetailView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let product: Product
    let onEditProduct: (Product) -> Void
    let onDeleteProduct: (Product) -> Void
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(product.tagging.productType.customIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .background(ThemeManager.shared.theme.palette.secondary.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(spacing: 4) {
                            Text(product.displayName)
                                .font(ThemeManager.shared.theme.typo.h2)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            if let brand = product.brand {
                                Text(brand)
                                    .font(ThemeManager.shared.theme.typo.title)
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Basic Information
                        ProductDetailSection(title: L10n.Products.Form.basicInfo) {
                            VStack(spacing: 12) {
                                DetailRow(label: L10n.Products.Detail.productType, value: product.tagging.productType.displayName)
                                
                                if let size = product.size {
                                    DetailRow(label: L10n.Products.Detail.size, value: size)
                                }
                                
                                if let description = product.description {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L10n.Products.Detail.description)
                                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                        
                                        Text(description)
                                            .font(ThemeManager.shared.theme.typo.body)
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        
                        // Ingredients
                        if !product.tagging.ingredients.isEmpty {
                            ProductDetailSection(title: L10n.Products.Form.ingredients) {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                    ForEach(product.tagging.ingredients, id: \.self) { ingredient in
                                        IngredientTag(ingredient: ingredient) {
                                            // Read-only in detail view
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Claims
                        if !product.tagging.claims.isEmpty {
                            ProductDetailSection(title: L10n.Products.Form.productClaims) {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                                    ForEach(product.tagging.claims, id: \.self) { claim in
                                        ClaimToggle(claim: claim, isSelected: true) {
                                            // Read-only in detail view
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.Products.Detail.close)
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditView = true
                        } label: {
                            Label(L10n.Products.Detail.editProduct, systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label(L10n.Products.Detail.deleteProduct, systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditProductView(
                product: product,
                onProductUpdated: { updatedProduct in
                    onEditProduct(updatedProduct)
                    showingEditView = false
                }
            )
        }
        .alert(L10n.Products.Detail.deleteConfirmTitle, isPresented: $showingDeleteAlert) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Common.delete, role: .destructive) {
                onDeleteProduct(product)
                dismiss()
            }
        } message: {
            Text(L10n.Products.Detail.deleteConfirmMessage(product.displayName))
        }
    }
}

// MARK: - Product Detail Section

struct ProductDetailSection<Content: View>: View {
    
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            content
        }
        .padding(16)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
        )
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
    }
}

// MARK: - Edit Product View

struct EditProductView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let product: Product
    let onProductUpdated: (Product) -> Void
    
    @State private var productName: String
    @State private var brand: String
    @State private var selectedProductType: ProductType
    @State private var ingredients: [String]
    @State private var claims: Set<String>
    @State private var size: String
    @State private var description: String
    @State private var newIngredient = ""
    @State private var showingProductTypeSelector = false
    
    private let availableClaims = ["fragranceFree", "sensitiveSafe", "vegan", "crueltyFree", "dermatologistTested", "nonComedogenic"]
    
    init(product: Product, onProductUpdated: @escaping (Product) -> Void) {
        self.product = product
        self.onProductUpdated = onProductUpdated
        
        // Initialize state with current product values
        self._productName = State(initialValue: product.displayName)
        self._brand = State(initialValue: product.brand ?? "")
        self._selectedProductType = State(initialValue: product.tagging.productType)
        self._ingredients = State(initialValue: product.tagging.ingredients)
        self._claims = State(initialValue: Set(product.tagging.claims))
        self._size = State(initialValue: product.size ?? "")
        self._description = State(initialValue: product.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(L10n.Products.Detail.editProduct)
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Text(L10n.Products.Detail.updateInfo)
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Basic Information
                        ProductFormSection(title: L10n.Products.Form.basicInfo) {
                            VStack(spacing: 16) {
                                FormField(title: L10n.Products.Form.productName, text: $productName, placeholder: L10n.Products.Form.productNamePlaceholder)
                                FormField(title: L10n.Products.Form.brand, text: $brand, placeholder: L10n.Products.Form.brandPlaceholder)
                                FormField(title: L10n.Products.Form.size, text: $size, placeholder: L10n.Products.Form.sizePlaceholder)
                            }
                        }
                        
                        // Product Category
                        ProductFormSection(title: L10n.Products.Form.productCategory) {
                            VStack(spacing: 16) {
                                ProductTypeSelectorButton(selectedProductType: $selectedProductType) {
                                    showingProductTypeSelector = true
                                }
                            }
                        }
                        
                        // Ingredients
                        ProductFormSection(title: L10n.Products.Form.ingredients) {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    TextField(L10n.Products.Form.addIngredient, text: $newIngredient)
                                        .font(ThemeManager.shared.theme.typo.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(ThemeManager.shared.theme.palette.accentBackground)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                        )
                                    
                                    Button {
                                        if !newIngredient.isEmpty {
                                            ingredients.append(newIngredient)
                                            newIngredient = ""
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                                    }
                                    .disabled(newIngredient.isEmpty)
                                }
                                
                                if !ingredients.isEmpty {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                        ForEach(ingredients, id: \.self) { ingredient in
                                            IngredientTag(ingredient: ingredient) {
                                                ingredients.removeAll { $0 == ingredient }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Claims
                        ProductFormSection(title: L10n.Products.Form.productClaims) {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                                    ForEach(availableClaims, id: \.self) { claim in
                                        ClaimToggle(claim: claim, isSelected: claims.contains(claim)) {
                                            if claims.contains(claim) {
                                                claims.remove(claim)
                                            } else {
                                                claims.insert(claim)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Description
                        ProductFormSection(title: L10n.Products.Form.description) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.Products.Form.productDescription)
                                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                TextEditor(text: $description)
                                    .font(ThemeManager.shared.theme.typo.body)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .background(ThemeManager.shared.theme.palette.accentBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.Products.Action.cancel)
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProduct()
                    } label: {
                        Text(L10n.Products.Action.save)
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(productName.isEmpty ? ThemeManager.shared.theme.palette.textMuted : ThemeManager.shared.theme.palette.secondary)
                    }
                    .disabled(productName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingProductTypeSelector) {
            ProductTypeSelectorSheet(selectedProductType: $selectedProductType)
        }
    }
    
    private func saveProduct() {
        let updatedProduct = Product(
            id: product.id, // Keep the same ID
            displayName: productName,
            tagging: ProductTagging(
                productType: selectedProductType,
                ingredients: ingredients,
                claims: Array(claims),
            ),
            brand: brand.isEmpty ? nil : brand,
            size: size.isEmpty ? nil : size,
            description: description.isEmpty ? nil : description
        )
        
        onProductUpdated(updatedProduct)
    }
}

// MARK: - Preview

#Preview("ProductDetailView") {
    let sampleProduct = Product(
        id: "sample",
        displayName: "Gentle Foaming Cleanser",
        tagging: ProductTagging(
            productType: .cleanser,
            ingredients: ["Hyaluronic Acid", "Ceramides", "Niacinamide"],
            claims: ["fragranceFree", "sensitiveSafe"]
        ),
        brand: "CeraVe",
        size: "150ml",
        description: "A gentle cleanser for sensitive skin that removes dirt and makeup without stripping the skin of its natural moisture."
    )
    
    ProductDetailView(
        product: sampleProduct,
        onEditProduct: { _ in },
        onDeleteProduct: { _ in }
    )
}
