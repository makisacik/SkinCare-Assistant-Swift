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
    
    private var productColor: Color {
        switch product.tagging.productType {
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
                VStack(spacing: 16) {
                    // Compact Product Header Card
                    VStack(spacing: 16) {
                        // Icon and Basic Info
                        HStack(alignment: .top, spacing: 16) {
                            // Product Icon
                            Image(product.tagging.productType.customIconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .background(productColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Product Info
                            VStack(alignment: .leading, spacing: 6) {
                                // Brand and Badge
                                HStack {
                                    if let brand = product.localizedBrand {
                                        Text(brand)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Product type badge
                                    Text(product.tagging.productType.displayName)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(productColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(productColor.opacity(0.1))
                                        )
                                }
                                
                                // Product Name
                                Text(product.localizedDisplayName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    .lineLimit(2)
                                
                                // Size
                                if let size = product.size {
                                    HStack(spacing: 4) {
                                        Image(systemName: "cube.box")
                                            .font(.system(size: 10))
                                        Text(size)
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeManager.shared.theme.palette.surface)
                            .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // Description Card
                    if let description = product.localizedDescription {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.info)
                                
                                Text(L10n.Products.Detail.description)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Ingredients Card
                    if !product.tagging.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.success)
                                
                                Text(L10n.Products.Form.ingredients)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            // Ingredients list
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(product.tagging.ingredients, id: \.self) { ingredient in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(ThemeManager.shared.theme.palette.success)
                                            .frame(width: 5, height: 5)
                                        
                                        Text(ingredient)
                                            .font(.system(size: 13))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Claims Card
                    if !product.tagging.claims.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(productColor)
                                
                                Text(L10n.Products.Form.productClaims)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            }
                            
                            // Claims list
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(product.tagging.claims, id: \.self) { claim in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(productColor)
                                        
                                        Text(claim)
                                            .font(.system(size: 13))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(productColor.opacity(0.08))
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
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
            .toolbarBackground(ThemeManager.shared.theme.palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
            Text(L10n.Products.Detail.deleteConfirmMessage(product.localizedDisplayName))
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
