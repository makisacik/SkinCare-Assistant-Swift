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

    // ✅ Use a simple boolean for sheet presentation
    @State private var showingAddProduct = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                .padding(.bottom, 16)

                // Products List
                if productService.userProducts.isEmpty {
                    EmptyProductsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(productService.userProducts, id: \.id) { product in
                                SimpleProductRow(product: product)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                // Add Product Button
                VStack {
                    Button {
                        showingAddProduct = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .medium))

                            Text("Add Product")
                                .font(tm.theme.typo.body.weight(.semibold))

                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(tm.theme.palette.secondary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductView(productService: productService) { product in
                // Product is already added in AddProductView.saveProduct(), no need to add again
                print("Added product: \(product.displayName)")
                showingAddProduct = false
            }
        }
    }
}


// MARK: - Preview

#Preview("ProductSlotsView") {
    ProductSlotsView()
}
