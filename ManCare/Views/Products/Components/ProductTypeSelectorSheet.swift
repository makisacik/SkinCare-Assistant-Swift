//
//  ProductTypeSelectorSheet.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductTypeSelectorSheet: View {
    
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
        VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text(L10n.Products.ProductType.selectType)
                            .font(ThemeManager.shared.theme.typo.h2)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Spacer()
                    }

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                        TextField(L10n.Products.ProductType.searchPlaceholder, text: $searchText)
                            .font(ThemeManager.shared.theme.typo.body)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(ThemeManager.shared.theme.palette.cardBackground)
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
                                            .foregroundColor(ThemeManager.shared.theme.palette.secondary)

                                        Text(category.displayName)
                                            .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

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
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.Common.done) {
                    dismiss()
                }
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.secondary)
            }
        }
    }
}

#Preview("ProductTypeSelectorSheet") {
    ProductTypeSelectorSheet(selectedProductType: .constant(.cleanser))
}
