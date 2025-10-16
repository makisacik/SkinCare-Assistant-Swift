//
//  AddProductView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AddProductView: View {
    
    @Environment(\.dismiss) private var dismiss

    // ✅ Inject the existing ProductService instead of creating a new instance
    let productService: ProductService
    let initialProductType: ProductType?

    @State private var productName = ""
    @State private var brand = ""
    @State private var selectedProductType: ProductType = .cleanser
    @State private var ingredients: [String] = []
    @State private var claims: Set<String> = []
    @State private var sizeValue = ""
    @State private var selectedSizeUnit: SizeUnit = .mL
    @State private var description = ""
    @State private var newIngredient = ""
    @State private var newClaim = ""
    @State private var showingProductTypeSelector = false
    @State private var hasManuallySelectedProductType = false

    let onProductAdded: (Product) -> Void

    init(productService: ProductService, initialProductType: ProductType? = nil, onProductAdded: @escaping (Product) -> Void) {
        self.productService = productService
        self.initialProductType = initialProductType
        self.onProductAdded = onProductAdded
    }

    private let availableClaims = ["fragranceFree", "sensitiveSafe", "vegan", "crueltyFree", "dermatologistTested", "nonComedogenic"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Add New Product")
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("Add a product to your collection")
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 20) {
                        // Basic Information
                        ProductFormSection(title: "Basic Information") {
                            VStack(spacing: 16) {
                                FormField(title: "Product Name", text: $productName, placeholder: "e.g., Gentle Foaming Cleanser")
                                FormField(title: "Brand", text: $brand, placeholder: "e.g., CeraVe")
                                SizeField(title: "Size", sizeValue: $sizeValue, selectedUnit: $selectedSizeUnit, placeholder: "e.g., 150")
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
                                        .font(ThemeManager.shared.theme.typo.body)
                                        .colorScheme(.light)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                                )
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
                                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                VStack(alignment: .leading, spacing: 6) {
                                    ZStack(alignment: .topLeading) {
                                        TextEditor(text: $description)
                                            .font(ThemeManager.shared.theme.typo.body)
                                            .colorScheme(.light)
                                            .frame(minHeight: 100)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                                    )
                                            )
                                            .onChange(of: description) { newValue in
                                                if newValue.count > 150 {
                                                    description = String(newValue.prefix(150))
                                                }
                                            }

                                        if description.isEmpty {
                                            Text("e.g., Key benefits, texture, how it feels, any notable notes...")
                                                .font(ThemeManager.shared.theme.typo.body)
                                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .allowsHitTesting(false)
                                        }
                                    }

                                    HStack {
                                        Spacer()
                                        Text("\(description.count)/150")
                                            .font(.system(size: 12))
                                            .foregroundColor(description.count > 135 ? ThemeManager.shared.theme.palette.error : ThemeManager.shared.theme.palette.textMuted)
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
                        Text("Cancel")
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProduct()
                    } label: {
                        Text("Save")
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(productName.isEmpty ? ThemeManager.shared.theme.palette.textMuted : ThemeManager.shared.theme.palette.secondary)
                    }
                    .disabled(productName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingProductTypeSelector) {
            ProductTypeSelectorSheet(selectedProductType: $selectedProductType)
                .onDisappear {
                    // Mark as manually selected when user closes the selector
                    hasManuallySelectedProductType = true
                }
        }
        .onAppear {
            // Set initial product type if provided
            if let initialType = initialProductType {
                selectedProductType = initialType
            } else if !productName.isEmpty {
                // Auto-detect product type from product name
                selectedProductType = ProductAliasMapping.normalize(productName)
            }
        }
        .onChange(of: productName) { newValue in
            // Auto-detect product type only if user hasn't manually selected one
            if !newValue.isEmpty && !hasManuallySelectedProductType {
                selectedProductType = ProductAliasMapping.normalize(newValue)
            }
        }
    }

    private func saveProduct() {
        // Combine size value and unit
        let sizeString = sizeValue.isEmpty ? nil : "\(sizeValue)\(selectedSizeUnit.rawValue)"

        let product = Product(
            id: UUID().uuidString,
            displayName: productName,
            tagging: ProductTagging(
                productType: selectedProductType,
                ingredients: ingredients,
                claims: Array(claims),
            ),
            brand: brand.isEmpty ? nil : brand,
            size: sizeString,
            description: description.isEmpty ? nil : description
        )

        productService.addUserProduct(product)
        onProductAdded(product)
        dismiss()
    }

}


// MARK: - Preview

#Preview("AddProductView") {
    AddProductView(productService: ProductService.shared, initialProductType: nil) { product in
        print("Added product: \(product.displayName)")
    }
}
