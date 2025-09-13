//
//  ProductDetailView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(\.themeManager) private var tm
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
                        Image(systemName: product.tagging.productType.iconName)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(tm.theme.palette.secondary)
                            .frame(width: 80, height: 80)
                            .background(tm.theme.palette.secondary.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(spacing: 4) {
                            Text(product.displayName)
                                .font(tm.theme.typo.h2)
                                .foregroundColor(tm.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            if let brand = product.brand {
                                Text(brand)
                                    .font(tm.theme.typo.title)
                                    .foregroundColor(tm.theme.palette.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Basic Information
                        ProductDetailSection(title: "Basic Information") {
                            VStack(spacing: 12) {
                                DetailRow(label: "Product Type", value: product.tagging.productType.displayName)
                                
                                if let size = product.size {
                                    DetailRow(label: "Size", value: size)
                                }
                                
                                if let description = product.description {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Description")
                                            .font(tm.theme.typo.body.weight(.semibold))
                                            .foregroundColor(tm.theme.palette.textPrimary)
                                        
                                        Text(description)
                                            .font(tm.theme.typo.body)
                                            .foregroundColor(tm.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        
                        // Ingredients
                        if !product.tagging.ingredients.isEmpty {
                            ProductDetailSection(title: "Ingredients") {
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
                            ProductDetailSection(title: "Product Claims") {
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
            .background(tm.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(tm.theme.typo.body.weight(.medium))
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditView = true
                        } label: {
                            Label("Edit Product", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Product", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(tm.theme.palette.textPrimary)
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
        .alert("Delete Product", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteProduct(product)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(product.displayName)\"? This action cannot be undone.")
        }
    }
}

// MARK: - Product Detail Section

struct ProductDetailSection<Content: View>: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(tm.theme.typo.title.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            content
        }
        .padding(16)
        .background(tm.theme.palette.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tm.theme.palette.separator, lineWidth: 1)
        )
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    @Environment(\.themeManager) private var tm
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(tm.theme.typo.body.weight(.medium))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
        }
    }
}

// MARK: - Edit Product View

struct EditProductView: View {
    @Environment(\.themeManager) private var tm
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
                        Text("Edit Product")
                            .font(tm.theme.typo.h1)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Text("Update product information")
                            .font(tm.theme.typo.sub)
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Basic Information
                        ProductFormSection(title: "Basic Information") {
                            VStack(spacing: 16) {
                                FormField(title: "Product Name", text: $productName, placeholder: "e.g., Gentle Foaming Cleanser")
                                FormField(title: "Brand", text: $brand, placeholder: "e.g., CeraVe")
                                FormField(title: "Size", text: $size, placeholder: "e.g., 150ml")
                            }
                        }
                        
                        // Product Category
                        ProductFormSection(title: "Product Category") {
                            VStack(spacing: 16) {
                                ProductTypeSelectorButton(selectedProductType: $selectedProductType) {
                                    showingProductTypeSelector = true
                                }
                            }
                        }
                        
                        // Ingredients
                        ProductFormSection(title: "Ingredients") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    TextField("Add ingredient", text: $newIngredient)
                                        .font(tm.theme.typo.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(tm.theme.palette.accentBackground)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                                        )
                                    
                                    Button {
                                        if !newIngredient.isEmpty {
                                            ingredients.append(newIngredient)
                                            newIngredient = ""
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(tm.theme.palette.secondary)
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
                        ProductFormSection(title: "Product Claims") {
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
                        ProductFormSection(title: "Description") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Product Description")
                                    .font(tm.theme.typo.body.weight(.semibold))
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                
                                TextEditor(text: $description)
                                    .font(tm.theme.typo.body)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .background(tm.theme.palette.accentBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(tm.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(tm.theme.typo.body.weight(.medium))
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProduct()
                    } label: {
                        Text("Save")
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(productName.isEmpty ? tm.theme.palette.textMuted : tm.theme.palette.secondary)
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
