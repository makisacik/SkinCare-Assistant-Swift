//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @ObservedObject private var productService = ProductService.shared
    @ObservedObject private var recommendationService = ProductRecommendationService.shared
    @EnvironmentObject private var localizationManager: LocalizationManager

    // Callbacks for sheet presentation (handled at root level)
    let onAddProductTapped: () -> Void
    let onScanProductTapped: () -> Void
    let onProductTapped: (Product) -> Void

    // State for recommendations
    @State private var showAllRecommendations = false
    @State private var selectedRecommendation: RecommendedProduct?
    @State private var showRecommendationDetail = false

    // Notification observer for recommendations completion
    @State private var notificationObserver: NSObjectProtocol?

    var body: some View {
        ZStack {
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

                        // Add Product Menu Button
                        Menu {
                            Button {
                                onScanProductTapped()
                            } label: {
                                Label(L10n.Products.Add.scanOption, systemImage: "camera.viewfinder")
                            }

                            Button {
                                onAddProductTapped()
                            } label: {
                                Label(L10n.Products.Add.manualOption, systemImage: "plus.circle")
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.shared.theme.palette.primary)
                                    .frame(width: 44, height: 44)

                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // Products List + Recommendations
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // User's Products Section
                        if productService.userProducts.isEmpty {
                            EmptyProductsView()
                                .padding(.horizontal, 20)
                        } else {
                            ForEach(productService.userProducts, id: \.id) { product in
                                ProductCard(product: product) {
                                    onProductTapped(product)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Recommendations Section
                        if recommendationService.isGenerating {
                            RecommendationsLoadingCard()
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                        } else if !recommendationService.recommendations.isEmpty {
                            let previewProducts = recommendationService.previewRecommendations()
                            RecommendationsPreviewCard(
                                products: previewProducts,
                                totalCount: recommendationService.recommendations.count,
                                onViewAll: {
                                    showAllRecommendations = true
                                },
                                onProductTapped: { product in
                                    selectedRecommendation = product
                                    showRecommendationDetail = true
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showAllRecommendations) {
            ProductRecommendationsView(
                recommendations: recommendationService.recommendations,
                onProductTapped: { product in
                    showAllRecommendations = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedRecommendation = product
                        showRecommendationDetail = true
                    }
                },
                onAddProduct: { product in
                    addRecommendedProductToList(product)
                }
            )
        }
        .sheet(item: $selectedRecommendation) { product in
            RecommendedProductDetailSheet(
                product: product,
                onAddProduct: { product in
                    addRecommendedProductToList(product)
                }
            )
        }
        .onAppear {
            setupNotificationListener()
            loadRecommendations()
        }
        .onDisappear {
            removeNotificationListener()
        }
    }

    // MARK: - Helpers

    private func setupNotificationListener() {
        // Remove existing observer if any
        removeNotificationListener()

        // Listen for recommendation completion notifications
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .productRecommendationsGenerated,
            object: nil,
            queue: .main
        ) { _ in
            print("🔔 Received notification: Recommendations generated, refreshing UI...")
            loadRecommendations()
        }
    }

    private func removeNotificationListener() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }

    private func loadRecommendations() {
        Task {
            // Try to fetch existing recommendations from routine store
            let routineStore = RoutineStore()
            do {
                if let activeRoutine = try await routineStore.fetchActiveRoutine() {
                    print("📦 Checking for recommendations for routine: \(activeRoutine.title)")
                    let hasRecs = try await recommendationService.hasRecommendations(for: activeRoutine)
                    if hasRecs {
                        print("✅ Found recommendations, loading...")
                        _ = try await recommendationService.fetchRecommendations(for: activeRoutine)
                    } else {
                        print("ℹ️ No recommendations found yet")
                    }
                }
            } catch {
                print("❌ Failed to load recommendations: \(error)")
            }
        }
    }

    private func addRecommendedProductToList(_ recommendation: RecommendedProduct) {
        let product = recommendation.toProduct()
        productService.addUserProduct(product)
        print("✅ Added recommended product to list: \(product.displayName)")
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
