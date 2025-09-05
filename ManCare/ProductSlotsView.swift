//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @Environment(\.themeManager) private var tm
    @ObservedObject private var productService = ProductService.shared
    @State private var showingAddProduct = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text("My Products")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)

                    Spacer()
                }

                Text("Store and manage your own products")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Simple list of user products
            List {
                ForEach(productService.userProducts, id: \.id) { product in
                    SimpleProductRow(product: product)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                // Add Product Button
                Button {
                    showingAddProduct = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(tm.theme.palette.secondary)
                        Text("Add Product")
                            .foregroundColor(tm.theme.palette.textPrimary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal, 20)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .sheet(isPresented: $showingAddProduct) {
            AddProductView { product in
                // Product added successfully
                productService.addUserProduct(product)
                print("Added product: \(product.displayName)")
            }
        }
    }
}

// MARK: - Simple Product Row

private struct SimpleProductRow: View {
    @Environment(\.themeManager) private var tm
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: product.tagging.productType.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.theme.palette.secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(tm.theme.palette.textPrimary)

                HStack(spacing: 8) {
                    if let brand = product.brand {
                        Text(brand)
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
                    }

                    Text(product.tagging.productType.displayName)
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let price = product.price {
                    Text("$\(String(format: "%.2f", price))")
                        .font(tm.theme.typo.caption.weight(.semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                Text(budgetTitle(product.tagging.budget))
                    .font(tm.theme.typo.caption.weight(.semibold))
                    .foregroundColor(budgetColor(product.tagging.budget))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(budgetColor(product.tagging.budget).opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    private func budgetTitle(_ budget: Budget) -> String {
        switch budget {
        case .low:
            return "Budget"
        case .mid:
            return "Mid"
        case .high:
            return "Premium"
        }
    }

    private func budgetColor(_ budget: Budget) -> Color {
        switch budget {
        case .low:
            return .green
        case .mid:
            return .orange
        case .high:
            return .red
        }
    }
}


// MARK: - Preview

#Preview("ProductSlotsView") {
    ProductSlotsView()
        .themed(ThemeManager())
}
