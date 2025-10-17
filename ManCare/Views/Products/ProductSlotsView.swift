//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @ObservedObject private var productService = ProductService.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Callbacks for sheet presentation (handled at root level)
    let onAddProductTapped: () -> Void
    let onScanProductTapped: () -> Void
    let onProductTapped: (Product) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Products.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text(L10n.Products.subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()
                    
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)

            // Products List
            if productService.userProducts.isEmpty {
                EmptyProductsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(productService.userProducts, id: \.id) { product in
                            ProductCard(product: product) {
                                onProductTapped(product)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }

            Spacer()

            VStack(spacing: 20) {
                Text(L10n.Products.Add.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                HStack(spacing: 16) {
                    // Scan Product Card
                    Button {
                        onScanProductTapped()
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.shared.theme.palette.primary.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }

                            VStack(spacing: 4) {
                                Text(L10n.Products.Add.scanOption)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                Text(L10n.Products.Add.scanDescription)
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }

                            HStack(spacing: 4) {
                                Text(L10n.Products.Add.getStarted)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ThemeManager.shared.theme.palette.surface,
                                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ThemeManager.shared.theme.palette.primary.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(
                                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Add Manually Card
                    Button {
                        onAddProductTapped()
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                            }

                            VStack(spacing: 4) {
                                Text(L10n.Products.Add.manualOption)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                                Text(L10n.Products.Add.manualDescription)
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }

                            HStack(spacing: 4) {
                                Text(L10n.Products.Add.getStarted)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ThemeManager.shared.theme.palette.surface,
                                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ThemeManager.shared.theme.palette.secondary.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(
                                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
    }
}


// MARK: - Preview

#Preview("ProductSlotsView") {
    ProductSlotsView(
        onAddProductTapped: { print("Add product tapped") },
        onScanProductTapped: { print("Scan product tapped") },
        onProductTapped: { product in print("Product tapped: \(product.displayName)") }
    )
}
