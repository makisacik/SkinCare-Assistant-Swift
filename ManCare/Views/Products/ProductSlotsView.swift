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
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)

                    Spacer()
                    
                    // Test Sheet Button
                    Button("Test Sheet") {
                        onTestSheetTapped()
                    }
                    .font(.caption)
                    .foregroundColor(tm.theme.palette.secondary)
                }

                Text("Store and manage your own products")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
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
                                .foregroundColor(Color.white)

                            VStack(spacing: 2) {
                                Text("Scan Product")
                                    .font(tm.theme.typo.body.weight(.semibold))
                                    .foregroundColor(Color.white)

                                Text("Take a photo to automatically extract product information")
                                    .font(tm.theme.typo.caption)
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(tm.theme.palette.secondary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Or Text
                    VStack {
                        Text("Or")
                            .font(tm.theme.typo.caption.weight(.medium))
                            .foregroundColor(tm.theme.palette.textSecondary)
                            .padding(.vertical, 8)
                    }

                    // Add Manually Card
                    Button {
                        onAddProductTapped()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color.white)

                            VStack(spacing: 2) {
                                Text("Add Manually")
                                    .font(tm.theme.typo.body.weight(.semibold))
                                    .foregroundColor(Color.white)

                                Text("Enter product details manually")
                                    .font(tm.theme.typo.caption)
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(tm.theme.palette.secondary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
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
