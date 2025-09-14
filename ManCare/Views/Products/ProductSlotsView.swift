//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @ObservedObject private var productService = ProductService.shared
    
    // Callbacks for sheet presentation (handled at root level)
    let onAddProductTapped: () -> Void
    let onScanProductTapped: () -> Void
    let onTestSheetTapped: () -> Void
    let onProductTapped: (Product) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text("My Products")
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Spacer()
                    
                    // Test Sheet Button
                    Button("Test Sheet") {
                        onTestSheetTapped()
                    }
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }

                Text("Store and manage your own products")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Products List
            if productService.userProducts.isEmpty {
                EmptyProductsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(productService.userProducts, id: \.id) { product in
                            Button {
                                onProductTapped(product)
                            } label: {
                                SimpleProductRow(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()

            // Add Product Options - Two Cards
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    // Scan Product Card
                    Button {
                        onScanProductTapped()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)

                            VStack(spacing: 2) {
                                Text("Scan Product")
                                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)

                                Text("Take a photo to automatically extract product information")
                                    .font(ThemeManager.shared.theme.typo.caption)
                                    .foregroundColor(ThemeManager.shared.theme.palette.onSecondary.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.theme.palette.secondary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Or Text
                    VStack {
                        Text("Or")
                            .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .padding(.vertical, 8)
                    }

                    // Add Manually Card
                    Button {
                        onAddProductTapped()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)

                            VStack(spacing: 2) {
                                Text("Add Manually")
                                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)

                                Text("Enter product details manually")
                                    .font(ThemeManager.shared.theme.typo.caption)
                                    .foregroundColor(ThemeManager.shared.theme.palette.onSecondary.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.theme.palette.secondary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
    }
}


// MARK: - Preview

#Preview("ProductSlotsView") {
    ProductSlotsView(
        onAddProductTapped: { print("Add product tapped") },
        onScanProductTapped: { print("Scan product tapped") },
        onTestSheetTapped: { print("Test sheet tapped") },
        onProductTapped: { product in print("Product tapped: \(product.displayName)") }
    )
}
