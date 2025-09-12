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
    @State private var selectedBudget: Budget = .mid
    @State private var ingredients: [String] = []
    @State private var claims: Set<String> = []
    @State private var price = ""
    @State private var size = ""
    @State private var description = ""
    @State private var newIngredient = ""
    @State private var newClaim = ""
    @State private var showingProductTypeSelector = false
    @State private var showingProductScanner = false

    let onProductAdded: (Product) -> Void

    private let availableClaims = ["fragranceFree", "sensitiveSafe", "vegan", "crueltyFree", "dermatologistTested", "nonComedogenic"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(tm.theme.palette.secondary.opacity(0.15))
                                    .frame(width: 60, height: 60)

                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(tm.theme.palette.secondary)
                            }

                            Spacer()
                        }

                        VStack(spacing: 8) {
                            Text("Add New Product")
                                .font(tm.theme.typo.h1)
                                .foregroundColor(tm.theme.palette.textPrimary)

                            Text("Add a product to your collection")
                                .font(tm.theme.typo.sub)
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                    }
                    .padding(.top, 20)

                    VStack(spacing: 20) {
                        // Scan Product Section
                        ProductFormSection(title: "Quick Add") {
                            VStack(spacing: 16) {
                                Button {
                                    showingProductScanner = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Scan Product Label")
                                                .font(tm.theme.typo.body.weight(.semibold))
                                                .foregroundColor(.white)

                                            Text("Take a photo to automatically extract product information")
                                                .font(tm.theme.typo.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }

                                        Spacer()

                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(tm.theme.palette.secondary)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        // Basic Information
                        ProductFormSection(title: "Basic Information") {
                            VStack(spacing: 16) {
                                FormField(title: "Product Name", text: $productName, placeholder: "e.g., Gentle Foaming Cleanser")
                                FormField(title: "Brand", text: $brand, placeholder: "e.g., CeraVe")
                                FormField(title: "Price", text: $price, placeholder: "e.g., 12.99")
                                FormField(title: "Size", text: $size, placeholder: "e.g., 150ml")
                            }
                        }

                        // Product Category
                        ProductFormSection(title: "Product Category") {
                            VStack(spacing: 16) {
                                ProductTypeSelectorButton(selectedProductType: $selectedProductType) {
                                    showingProductTypeSelector = true
                                }
                                BudgetSelector(selectedBudget: $selectedBudget)
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
        .sheet(isPresented: $showingProductScanner) {
            ProductScanView { extractedText in
                // Process the extracted text and populate form fields
                processExtractedText(extractedText)
            }
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
                budget: selectedBudget
            ),
            brand: brand.isEmpty ? nil : brand,
            price: Double(price),
            size: size.isEmpty ? nil : size,
            description: description.isEmpty ? nil : description
        )

        productService.addUserProduct(product)
        onProductAdded(product)
        dismiss()
    }

    private func processExtractedText(_ text: String) {
        // Print the extracted text as requested
        print("🔹 Step 1 — OCR (front photo → raw text)")
        print("Extracted text: \(text)")

        // Basic text processing to extract product information
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Try to extract product name (usually the first or largest text)
        if productName.isEmpty && !lines.isEmpty {
            // Use the first non-empty line as product name
            productName = lines[0]
        }

        // Try to extract brand (look for common brand patterns)
        if brand.isEmpty {
            for line in lines {
                // Look for lines that might be brand names (usually shorter, all caps, or title case)
                if line.count < 20 && (line == line.uppercased() || line == line.capitalized) {
                    brand = line
                    break
                }
            }
        }

        // Try to extract size (look for volume/weight indicators)
        if size.isEmpty {
            for line in lines {
                if line.contains("ml") || line.contains("oz") || line.contains("g") || line.contains("fl oz") {
                    size = line
                    break
                }
            }
        }

        // Try to extract price (look for $ or currency symbols)
        if price.isEmpty {
            for line in lines {
                if line.contains("$") || line.contains("€") || line.contains("£") {
                    // Extract just the number part
                    let priceString = line.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                    if !priceString.isEmpty {
                        price = priceString
                        break
                    }
                }
            }
        }

        // Auto-detect product type from the extracted text
        selectedProductType = ProductAliasMapping.normalize(text)

        // Store the full extracted text in description for reference
        if description.isEmpty {
            description = "Scanned text: \(text)"
        }
    }
}


// MARK: - Preview

#Preview("AddProductView") {
    AddProductView(productService: ProductService.shared) { product in
        print("Added product: \(product.displayName)")
    }
}
