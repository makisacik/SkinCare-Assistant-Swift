//
//  AddProductView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss

    // ✅ Inject the existing ProductService instead of creating a new instance
    let productService: ProductService

    @State private var productName = ""
    @State private var brand = ""
    @State private var selectedProductType: ProductType = .cleanser
    @State private var ingredients: [String] = []
    @State private var claims: Set<String> = []
    @State private var size = ""
    @State private var description = ""
    @State private var newIngredient = ""
    @State private var newClaim = ""
    @State private var showingProductTypeSelector = false

    let onProductAdded: (Product) -> Void

    private let availableClaims = ["fragranceFree", "sensitiveSafe", "vegan", "crueltyFree", "dermatologistTested", "nonComedogenic"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Add New Product")
                            .font(tm.theme.typo.h1)
                            .foregroundColor(tm.theme.palette.textPrimary)

                        Text("Add a product to your collection")
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
                                        .background(tm.theme.palette.bg)
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
                                    .background(tm.theme.palette.bg)
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
            .background(tm.theme.palette.bg.ignoresSafeArea())
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
        .onAppear {
            // Auto-detect product type from product name
            if !productName.isEmpty {
                selectedProductType = ProductAliasMapping.normalize(productName)
            }
        }
        .onChange(of: productName) { newValue in
            // Auto-detect product type when product name changes
            if !newValue.isEmpty {
                selectedProductType = ProductAliasMapping.normalize(newValue)
            }
        }
    }

    private func saveProduct() {
        let product = Product(
            id: UUID().uuidString,
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

        productService.addUserProduct(product)
        onProductAdded(product)
        dismiss()
    }

}


// MARK: - Preview

#Preview("AddProductView") {
    AddProductView(productService: ProductService.shared) { product in
        print("Added product: \(product.displayName)")
    }
}
