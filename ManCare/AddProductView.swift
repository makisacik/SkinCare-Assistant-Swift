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
    @State private var selectedSlot: SlotType = .cleanser
    @State private var selectedSubtypes: Set<ProductSubtype> = []
    @State private var selectedBudget: Budget = .mid
    @State private var ingredients: [String] = []
    @State private var claims: Set<String> = []
    @State private var price = ""
    @State private var size = ""
    @State private var description = ""
    @State private var newIngredient = ""
    @State private var newClaim = ""
    
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
                                FormField(title: "Price", text: $price, placeholder: "e.g., 12.99")
                                FormField(title: "Size", text: $size, placeholder: "e.g., 150ml")
                            }
                        }
                        
                        // Product Category
                        ProductFormSection(title: "Product Category") {
                            VStack(spacing: 16) {
                                SlotTypeSelector(selectedSlot: $selectedSlot)
                                
                                if !selectedSlot.subtypes.isEmpty {
                                    SubtypeSelector(
                                        selectedSubtypes: $selectedSubtypes,
                                        availableSubtypes: selectedSlot.subtypes
                                    )
                                }
                                
                                BudgetSelector(selectedBudget: $selectedBudget)
                            }
                        }
                        
                        // Ingredients
                        ProductFormSection(title: "Ingredients") {
                            VStack(spacing: 16) {
                                HStack {
                                    TextField("Add ingredient", text: $newIngredient)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button("Add") {
                                        if !newIngredient.isEmpty {
                                            ingredients.append(newIngredient)
                                            newIngredient = ""
                                        }
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
                                    .frame(minHeight: 80)
                                    .padding(8)
                                    .background(tm.theme.palette.bg)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
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
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .disabled(productName.isEmpty)
                }
            }
        }
        .onAppear {
            // Auto-detect slot type from product name
            if !productName.isEmpty {
                let (detectedSlot, detectedSubtype) = ProductAliasMapping.normalize(productName)
                selectedSlot = detectedSlot
                if let subtype = detectedSubtype {
                    selectedSubtypes = [subtype]
                }
            }
        }
        .onChange(of: productName) { newValue in
            // Auto-detect slot type when product name changes
            if !newValue.isEmpty {
                let (detectedSlot, detectedSubtype) = ProductAliasMapping.normalize(newValue)
                selectedSlot = detectedSlot
                if let subtype = detectedSubtype {
                    selectedSubtypes = [subtype]
                }
            }
        }
    }
    
    private func saveProduct() {
        let product = Product(
            id: UUID().uuidString,
            displayName: productName,
            tagging: ProductTagging(
                slot: selectedSlot,
                subtypes: Array(selectedSubtypes),
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
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

private struct SlotTypeSelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedSlot: SlotType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Type")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(SlotType.allCases) { slot in
                    SlotTypeCard(slot: slot, isSelected: selectedSlot == slot) {
                        selectedSlot = slot
                    }
                }
            }
        }
    }
}

private struct SlotTypeCard: View {
    @Environment(\.themeManager) private var tm
    let slot: SlotType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: slot.iconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.secondary)
            
            Text(slot.displayName)
                .font(tm.theme.typo.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.bg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

private struct SubtypeSelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedSubtypes: Set<ProductSubtype>
    let availableSubtypes: [ProductSubtype]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subtype (Optional)")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(availableSubtypes) { subtype in
                    SubtypeToggle(
                        subtype: subtype,
                        isSelected: selectedSubtypes.contains(subtype)
                    ) {
                        if selectedSubtypes.contains(subtype) {
                            selectedSubtypes.remove(subtype)
                        } else {
                            selectedSubtypes.insert(subtype)
                        }
                    }
                }
            }
        }
    }
}

private struct SubtypeToggle: View {
    @Environment(\.themeManager) private var tm
    let subtype: ProductSubtype
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(subtype.displayName)
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

// MARK: - Extensions

extension SlotType {
    /// Get available subtypes for this slot type
    var subtypes: [ProductSubtype] {
        return ProductSubtype.allCases.filter { $0.primarySlot == self }
    }
}

// MARK: - Preview

#Preview("AddProductView") {
    AddProductView { product in
        print("Added product: \(product.displayName)")
    }
    .themed(ThemeManager())
}
