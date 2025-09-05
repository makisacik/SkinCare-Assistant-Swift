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

    @StateObject private var productService = ProductService()

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
}

// MARK: - Form Components

private struct ProductFormSection<Content: View>: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(tm.theme.typo.title.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            content
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

private struct FormField: View {
    @Environment(\.themeManager) private var tm
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            TextField(placeholder, text: $text)
                .font(tm.theme.typo.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(tm.theme.palette.bg)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
        }
    }
}

private struct ProductTypeSelectorButton: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedProductType: ProductType
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Type")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Product Type Icon
                    Image(systemName: selectedProductType.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(tm.theme.palette.secondary)
                        .frame(width: 32, height: 32)
                        .background(tm.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)

                    // Product Type Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedProductType.displayName)
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(tm.theme.palette.textPrimary)
                            .lineLimit(1)

                        Text("Tap to change product type")
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
                    }

                    Spacer()

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(tm.theme.palette.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(tm.theme.palette.bg)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct ProductTypeCard: View {
    @Environment(\.themeManager) private var tm
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: productType.iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.secondary)

            Text(productType.displayName)
                .font(tm.theme.typo.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.bg)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}


private struct BudgetSelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedBudget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Range")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            HStack(spacing: 12) {
                ForEach(Budget.allCases, id: \.self) { budget in
                    BudgetCard(budget: budget, isSelected: selectedBudget == budget) {
                        selectedBudget = budget
                    }
                }
            }
        }
    }
}

private struct BudgetCard: View {
    @Environment(\.themeManager) private var tm
    let budget: Budget
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text(budgetTitle(budget))
                .font(tm.theme.typo.caption.weight(.semibold))
                .foregroundColor(isSelected ? .white : budgetColor(budget))

            Text(budgetDescription(budget))
                .font(.system(size: 10))
                .foregroundColor(isSelected ? .white.opacity(0.8) : tm.theme.palette.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? budgetColor(budget) : tm.theme.palette.bg)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? budgetColor(budget) : tm.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }

    private func budgetTitle(_ budget: Budget) -> String {
        switch budget {
        case .low: return "Budget"
        case .mid: return "Mid"
        case .high: return "Premium"
        }
    }

    private func budgetDescription(_ budget: Budget) -> String {
        switch budget {
        case .low: return "$5-15"
        case .mid: return "$15-40"
        case .high: return "$40+"
        }
    }

    private func budgetColor(_ budget: Budget) -> Color {
        switch budget {
        case .low: return .green
        case .mid: return .orange
        case .high: return .red
        }
    }
}

private struct IngredientTag: View {
    @Environment(\.themeManager) private var tm
    let ingredient: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(ingredient)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textPrimary)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(tm.theme.palette.textMuted)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tm.theme.palette.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct ClaimToggle: View {
    @Environment(\.themeManager) private var tm
    let claim: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(claimDisplayName(claim))
            .font(tm.theme.typo.caption.weight(.medium))
            .foregroundColor(isSelected ? .white : tm.theme.palette.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.bg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
            )
            .onTapGesture {
                onTap()
            }
    }

    private func claimDisplayName(_ claim: String) -> String {
        switch claim {
        case "fragranceFree": return "Fragrance Free"
        case "sensitiveSafe": return "Sensitive Safe"
        case "vegan": return "Vegan"
        case "crueltyFree": return "Cruelty Free"
        case "dermatologistTested": return "Dermatologist Tested"
        case "nonComedogenic": return "Non-Comedogenic"
        default: return claim
        }
    }
}

// MARK: - Product Type Selector Sheet

private struct ProductTypeSelectorSheet: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedProductType: ProductType
    @State private var searchText = ""

    var filteredProductTypes: [ProductType] {
        if searchText.isEmpty {
            return ProductType.allCases
        } else {
            return ProductType.allCases.filter { productType in
                productType.displayName.localizedCaseInsensitiveContains(searchText) ||
                productType.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Select Product Type")
                            .font(tm.theme.typo.h2)
                            .foregroundColor(tm.theme.palette.textPrimary)

                        Spacer()
                    }

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(tm.theme.palette.textMuted)

                        TextField("Search product types...", text: $searchText)
                            .font(tm.theme.typo.body)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(tm.theme.palette.card)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Product Types List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            let categoryProducts = filteredProductTypes.filter { $0.category == category }
                            if !categoryProducts.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Category Header
                                    HStack {
                                        Image(systemName: category.iconName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(tm.theme.palette.secondary)

                                        Text(category.rawValue)
                                            .font(tm.theme.typo.title.weight(.semibold))
                                            .foregroundColor(tm.theme.palette.textPrimary)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)

                                    // Product Types in Category
                                    VStack(spacing: 8) {
                                        ForEach(categoryProducts) { productType in
                                            ProductTypeRow(
                                                productType: productType,
                                                isSelected: selectedProductType == productType
                                            ) {
                                                selectedProductType = productType
                                                dismiss()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(tm.theme.typo.body.weight(.semibold))
                    .foregroundColor(tm.theme.palette.secondary)
                }
            }
        }
    }
}

// MARK: - Product Type Row

private struct ProductTypeRow: View {
    @Environment(\.themeManager) private var tm
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: productType.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : tm.theme.palette.secondary)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.secondary.opacity(0.1))
                    .cornerRadius(6)

                // Name
                Text(productType.displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.card)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

// MARK: - Preview

#Preview("AddProductView") {
    AddProductView { product in
        print("Added product: \(product.displayName)")
    }
    .themed(ThemeManager())
}
