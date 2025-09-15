//
//  ProductSummaryView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSummaryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let extractedText: String
    let normalizedProduct: ProductNormalizationResponse
    let productService: ProductService
    let onProductAdded: (Product) -> Void
    let onCancel: () -> Void
    
    // Editable fields
    @State private var productName: String
    @State private var brand: String
    @State private var selectedProductType: ProductType
    @State private var sizeValue: String
    @State private var selectedSizeUnit: SizeUnit = .mL
    @State private var description: String
    @State private var ingredients: [String] = []
    @State private var claims: Set<String> = []
    @State private var newIngredient = ""
    @State private var showingProductTypeSelector = false
    @State private var isAdding = false
    
    private let availableClaims = ["fragranceFree", "sensitiveSafe", "vegan", "crueltyFree", "dermatologistTested", "nonComedogenic"]
    
    init(extractedText: String, normalizedProduct: ProductNormalizationResponse, productService: ProductService, onProductAdded: @escaping (Product) -> Void, onCancel: @escaping () -> Void) {
        self.extractedText = extractedText
        self.normalizedProduct = normalizedProduct
        self.productService = productService
        self.onProductAdded = onProductAdded
        self.onCancel = onCancel
        
        // Initialize editable fields with normalized data
        self._productName = State(initialValue: normalizedProduct.productName)
        self._brand = State(initialValue: normalizedProduct.brand ?? "")
        self._selectedProductType = State(initialValue: normalizedProduct.toProductType())
        
        // Parse size from normalized product
        let (sizeValue, sizeUnit) = Self.parseSize(normalizedProduct.size)
        self._sizeValue = State(initialValue: sizeValue)
        self._selectedSizeUnit = State(initialValue: sizeUnit)
        
        self._description = State(initialValue: "")
        
        // Initialize ingredients from normalized product
        self._ingredients = State(initialValue: normalizedProduct.ingredients)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.success)
                        
                        Text("Product Summary")
                            .font(ThemeManager.shared.theme.typo.h2)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Text("Review and edit the extracted product information")
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Editable Product Information
                    VStack(spacing: 20) {
                        // Basic Information
                        ProductFormSection(title: "Product Information") {
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
                    .padding(.bottom, 20)
                }
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                    .disabled(isAdding)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addProduct()
                    } label: {
                        HStack(spacing: 4) {
                            if isAdding {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isAdding ? "Adding..." : "Confirm Product")
                        }
                    }
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(productName.isEmpty || isAdding ? ThemeManager.shared.theme.palette.textMuted : ThemeManager.shared.theme.palette.secondary)
                    .disabled(productName.isEmpty || isAdding)
                }
            }
            .onTapGesture {
                // Hide keyboard when tapping outside of text fields
                hideKeyboard()
            }
        }
        .sheet(isPresented: $showingProductTypeSelector) {
            ProductTypeSelectorSheet(selectedProductType: $selectedProductType)
        }
    }
    
    private func addProduct() {
        guard !productName.isEmpty else { return }
        
        isAdding = true
        
        // Combine size value and unit
        let sizeString = sizeValue.isEmpty ? nil : "\(sizeValue)\(selectedSizeUnit.rawValue)"
        
        let product = Product(
            id: UUID().uuidString,
            displayName: productName,
            tagging: ProductTagging(
                productType: selectedProductType,
                ingredients: ingredients,
                claims: Array(claims)
            ),
            brand: brand.isEmpty ? nil : brand,
            size: sizeString,
            description: description.isEmpty ? nil : description
        )
        
        productService.addUserProduct(product)
        onProductAdded(product)
        dismiss()
    }
    
    /// Parse size string to extract value and unit
    private static func parseSize(_ sizeString: String?) -> (value: String, unit: SizeUnit) {
        guard let sizeString = sizeString, !sizeString.isEmpty else {
            return ("", .mL)
        }
        
        let lowercaseSize = sizeString.lowercased()
        
        // Check for mL
        if lowercaseSize.contains("ml") {
            let value = sizeString.replacingOccurrences(of: "ml", with: "", options: [.caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (value, .mL)
        }
        
        // Check for oz
        if lowercaseSize.contains("oz") {
            let value = sizeString.replacingOccurrences(of: "oz", with: "", options: [.caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (value, .oz)
        }
        
        // Check for fl oz
        if lowercaseSize.contains("fl oz") {
            let value = sizeString.replacingOccurrences(of: "fl oz", with: "", options: [.caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (value, .oz)
        }
        
        // Default to mL if no unit found
        return (sizeString, .mL)
    }
    
    /// Hide the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview("ProductSummaryView") {
    let sampleResponse = ProductNormalizationResponse(
        brand: "CeraVe",
        productName: "Foaming Facial Cleanser",
        productType: "cleanser",
        confidence: 0.95,
        size: "150ml",
        ingredients: ["Ceramides", "Hyaluronic Acid"]
    )
    
    ProductSummaryView(
        extractedText: "CeraVe Foaming Facial Cleanser 150ml",
        normalizedProduct: sampleResponse,
        productService: ProductService.shared,
        onProductAdded: { product in
            print("Added product: \(product.displayName)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
