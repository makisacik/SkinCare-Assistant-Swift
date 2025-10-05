import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab: CurrentTab = .routines
    @State private var showingAddProduct = false
    @State private var showingScanProduct = false
    @State private var showingTestSheet = false
    @State private var selectedProduct: Product?
    @StateObject private var scanManager = ProductScanManager.shared
    let generatedRoutine: RoutineResponse?

    enum CurrentTab: String, CaseIterable, Hashable {
        case routines = "Routines"
        case discover = "Discover"
        case products = "My Products"

        var icon: String {
            switch self {
            case .routines: return "list.bullet.rectangle"
            case .discover: return "sparkles"
            case .products: return "bag.fill"
            }
        }
    }

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView(selection: $selectedTab) {
                    Tab(value: CurrentTab.routines) {
                        RoutineHomeView(
                            generatedRoutine: generatedRoutine,
                            selectedTab: $selectedTab,
                            routineService: ServiceFactory.shared.createRoutineService()
                        )
                    } label: {
                        Label("Routines", systemImage: "list.bullet.rectangle")
                    }

                    Tab(value: CurrentTab.discover) {
                        DiscoverView()
                    } label: {
                        Label("Discover", systemImage: "sparkles")
                    }

                    Tab(value: CurrentTab.products) {
                        productsContent
                    } label: {
                        Label("My Products", systemImage: "bag.fill")
                    }
                }
                .tint(ThemeManager.shared.theme.palette.secondary)
                .onAppear { resetTabBarForModernGlass() }

            } else {
                // ✅ iOS 15–17: classic .tabItem + UIKit appearance
                LegacyTabView(
                    selectedTab: $selectedTab,
                    productsContent: productsContent
                )
                .tint(ThemeManager.shared.theme.palette.secondary)
                .onAppear { setupLegacyTabBarAppearance() }
            }
        }
        .fullScreenCover(isPresented: $showingAddProduct) {
            AddProductView(productService: ProductService.shared) { product in
                print("Added product: \(product.displayName)")
            }
        }
        .fullScreenCover(isPresented: $showingScanProduct) {
            ProductScanView { text in
                print("Scanned product text: \(text)")
            }
        }
        .fullScreenCover(item: $selectedProduct) { product in
            ProductDetailView(
                product: product,
                onEditProduct: { ProductService.shared.updateUserProduct($0) },
                onDeleteProduct: { ProductService.shared.removeUserProduct(withId: $0.id) }
            )
        }
        .sheet(isPresented: $showingTestSheet) {
            // Mock UI tester
            let mockExtractedText = "mia klinika RELAIC ACID SERUN NIACINAMION ZING TEA TREE GLYCINE"
            let mockNormalizedProduct = ProductNormalizationResponse(
                brand: "mia klinika",
                productName: "RELAIC ACID SERUN",
                productType: "faceSerum",
                confidence: 0.85,
                size: nil,
                ingredients: ["Niacinamion", "Zing", "Tea Tree", "Glycine"]
            )
            ProductSummaryView(
                extractedText: mockExtractedText,
                normalizedProduct: mockNormalizedProduct,
                productService: ProductService.shared,
                onProductAdded: { _ in showingTestSheet = false },
                onCancel: { showingTestSheet = false }
            )
        }
        .onChange(of: scanManager.shouldNavigateToProducts) { shouldNavigate in
            if shouldNavigate { selectedTab = .products }
        }
    }

    // MARK: - Shared content

    @ViewBuilder
    private var productsContent: some View {
        if let scanned = scanManager.scannedProductData {
            ProductSummaryView(
                extractedText: scanned.extractedText,
                normalizedProduct: scanned.normalizedProduct,
                productService: ProductService.shared,
                onProductAdded: { _ in scanManager.clearScannedProduct() },
                onCancel: { scanManager.clearScannedProduct() }
            )
        } else {
            ProductSlotsView(
                onAddProductTapped: { showingAddProduct = true },
                onScanProductTapped: { showingScanProduct = true },
                onTestSheetTapped: { showingTestSheet = true },
                onProductTapped: { selectedProduct = $0 }
            )
        }
    }
}

// MARK: - iOS 15–17 implementation
private struct LegacyTabView: View {
    @Binding var selectedTab: MainTabView.CurrentTab
    let productsContent: AnyView

    init(selectedTab: Binding<MainTabView.CurrentTab>, productsContent: some View) {
        _selectedTab = selectedTab
        self.productsContent = AnyView(productsContent)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RoutineHomeView(
                generatedRoutine: nil,
                selectedTab: $selectedTab,
                routineService: ServiceFactory.shared.createRoutineService()
            )
            .tabItem {
                Image(systemName: MainTabView.CurrentTab.routines.icon)
                Text(MainTabView.CurrentTab.routines.rawValue)
            }
            .tag(MainTabView.CurrentTab.routines)

            DiscoverView()
                .tabItem {
                    Image(systemName: MainTabView.CurrentTab.discover.icon)
                    Text(MainTabView.CurrentTab.discover.rawValue)
                }
                .tag(MainTabView.CurrentTab.discover)

            productsContent
                .tabItem {
                    Image(systemName: MainTabView.CurrentTab.products.icon)
                    Text(MainTabView.CurrentTab.products.rawValue)
                }
                .tag(MainTabView.CurrentTab.products)
        }
    }
}

extension MainTabView {
    /// Reset tab bar to default glass appearance for iOS 18+. Call this once at app start.
    @MainActor
    private func resetTabBarForModernGlass() {
        guard #available(iOS 18.0, *) else { return }
        let appearance = UITabBarAppearance()          // default (no opaque config)
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    /// Only called on iOS 15–17. Avoid calling this on iOS 18+, or you'll kill Liquid Glass.
    private func setupLegacyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        // A soft, semi-transparent look for older iOS; feels "glassy" without iOS 18's Liquid Glass
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        appearance.backgroundColor = UIColor(ThemeManager.shared.theme.palette.tabBarBackground)
            .withAlphaComponent(0.65)

        // Normal item state
        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor(ThemeManager.shared.theme.palette.textMuted)
        normal.titleTextAttributes = [.foregroundColor: UIColor(ThemeManager.shared.theme.palette.textMuted)]

        // Selected item state
        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = UIColor(ThemeManager.shared.theme.palette.secondary)
        selected.titleTextAttributes = [.foregroundColor: UIColor(ThemeManager.shared.theme.palette.secondary)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
