//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Measuring support for dynamic card height
private struct CardHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

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
    
    // Pagination state
    @State private var currentPage = 0
    private let productsPerPage = 4
    // Layout constants for paginated product cards
    private let cardSpacing: CGFloat = 12
    @State private var measuredCardHeight: CGFloat = 0
    
    // Filtering state
    @State private var isFilterSheetPresented = false
    @State private var tempSelectedProductType: ProductType = .cleanser
    @State private var activeFilter: ProductType? = nil
    
    // Computed properties for pagination
    // Products to display (after filter if active)
    private var displayedProducts: [Product] {
        if let filter = activeFilter {
            return productService.userProducts.filter { $0.tagging.productType == filter }
        }
        return productService.userProducts
    }

    private var totalPages: Int {
        guard !displayedProducts.isEmpty else { return 0 }
        return Int(ceil(Double(displayedProducts.count) / Double(productsPerPage)))
    }
    
    private var paginatedProducts: [[Product]] {
        stride(from: 0, to: displayedProducts.count, by: productsPerPage).map {
            Array(displayedProducts[$0..<min($0 + productsPerPage, displayedProducts.count)])
        }
    }
    
    // Safe count for current page to avoid out-of-bounds and allow precise height
    private var currentPageCount: Int {
        guard currentPage >= 0 && currentPage < paginatedProducts.count else { return 0 }
        return paginatedProducts[currentPage].count
    }
    
    private var tabHeight: CGFloat {
        let h = measuredCardHeight == 0 ? 140 : measuredCardHeight
        return (h * CGFloat(currentPageCount)) + (cardSpacing * CGFloat(max(0, currentPageCount - 1)))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    // Title + Add button row
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

                    // Filter row just below subtitle
                    HStack(spacing: 12) {
                        Button {
                            tempSelectedProductType = activeFilter ?? .cleanser
                            isFilterSheetPresented = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(activeFilter == nil ? L10n.Products.Filters.filter : L10n.Products.Filters.change)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(ThemeManager.shared.theme.palette.surface)
                            )
                        }
                        .buttonStyle(.plain)

                        if let filter = activeFilter {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    activeFilter = nil
                                    currentPage = 0
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(filter.displayName)
                                        .font(.system(size: 12, weight: .semibold))
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(ThemeManager.shared.theme.palette.surface))
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // Products List + Recommendations
                ScrollView {
                    VStack(spacing: 8) {
                        // User's Products Section
                        if displayedProducts.isEmpty {
                            EmptyProductsView()
                                .padding(.horizontal, 20)
                        } else if displayedProducts.count <= productsPerPage {
                            // Show all products without pagination if 4 or fewer
                            ForEach(displayedProducts, id: \.id) { product in
                                ProductCard(product: product) {
                                    onProductTapped(product)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // Use pagination for more than 4 products
                            VStack(spacing: 0) {
                                // The TabView takes only the space it truly needs
                                TabView(selection: $currentPage) {
                                    ForEach(0..<paginatedProducts.count, id: \.self) { pageIndex in
                                        VStack(spacing: cardSpacing) {
                                            ForEach(paginatedProducts[pageIndex], id: \.id) { product in
                                                ProductCard(product: product) {
                                                    onProductTapped(product)
                                                }
                                                .background(
                                                    GeometryReader { geo in
                                                        Color.clear
                                                            .preference(key: CardHeightKey.self, value: geo.size.height)
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .tag(pageIndex)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: tabHeight)
                                .animation(.easeInOut(duration: 0.25), value: tabHeight)
                                .onPreferenceChange(CardHeightKey.self) { measuredCardHeight = $0 }

                                // Pager controls placed BELOW the cards
                                HStack(spacing: 20) {
                                    // Previous button
                                    Button {
                                        withAnimation { currentPage = max(0, currentPage - 1) }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(currentPage > 0 ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textMuted)
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(ThemeManager.shared.theme.palette.surface))
                                    }
                                    .disabled(currentPage <= 0)
                                    
                                    // Page dots
                                    HStack(spacing: 8) {
                                        ForEach(0..<totalPages, id: \.self) { index in
                                            Circle()
                                                .fill(index == currentPage ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textMuted.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    
                                    // Next button
                                    Button {
                                        withAnimation { currentPage = min(totalPages - 1, currentPage + 1) }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(currentPage < totalPages - 1 ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.textMuted)
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(ThemeManager.shared.theme.palette.surface))
                                    }
                                    .disabled(currentPage >= totalPages - 1)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                        }

                        // Recommendations Section
                        if recommendationService.isGenerating {
                            RecommendationsLoadingCard()
                                .padding(.horizontal, 20)
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
        .sheet(isPresented: $isFilterSheetPresented) {
            ProductTypeSelectorSheet(selectedProductType: $tempSelectedProductType)
                .onDisappear {
                    // Apply filter when sheet closes (animate layout change)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        activeFilter = tempSelectedProductType
                        currentPage = 0
                    }
                }
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
