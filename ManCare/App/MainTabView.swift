import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab: CurrentTab = .routines
    @State private var showingAddProduct = false
    @State private var showingScanProduct = false
    @State private var selectedProduct: Product?
    @StateObject private var scanManager = ProductScanManager.shared
    let generatedRoutine: RoutineResponse?
    @State private var tempGeneratedRoutine: RoutineResponse?

    enum CurrentTab: String, CaseIterable, Hashable {
        case routines = "Routines"
        case discover = "Discover"
        case products = "My Products"
        case myself = "Myself"

        var icon: String {
            switch self {
            case .routines: return "list.bullet.rectangle"
            case .discover: return "sparkles"
            case .products: return "bag.fill"
            case .myself: return "person.crop.circle"
            }
        }
    }

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView(selection: $selectedTab) {
                    Tab(value: CurrentTab.routines) {
                        RoutineHomeView(
                            generatedRoutine: tempGeneratedRoutine ?? generatedRoutine,
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

                    Tab(value: CurrentTab.myself) {
                        MyselfView(
                            routineService: ServiceFactory.shared.createRoutineService(),
                            onRoutineGenerated: { response in
                                tempGeneratedRoutine = response
                                selectedTab = .routines
                            }
                        )
                    } label: {
                        Label("Myself", systemImage: "person.crop.circle")
                    }
                }
                .tint(ThemeManager.shared.theme.palette.secondary)
            } else {
                // ✅ iOS 15–17: classic .tabItem + UIKit appearance
                LegacyTabView(
                    selectedTab: $selectedTab,
                    productsContent: productsContent,
                    initialRoutine: tempGeneratedRoutine ?? generatedRoutine,
                    onRoutineGenerated: { response in
                        tempGeneratedRoutine = response
                        selectedTab = .routines
                    }
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
                onProductTapped: { selectedProduct = $0 }
            )
        }
    }
}

// MARK: - iOS 15–17 implementation
private struct LegacyTabView: View {
    @Binding var selectedTab: MainTabView.CurrentTab
    let productsContent: AnyView
    let initialRoutine: RoutineResponse?
    let onRoutineGenerated: (RoutineResponse) -> Void

    init(selectedTab: Binding<MainTabView.CurrentTab>, productsContent: some View, initialRoutine: RoutineResponse?, onRoutineGenerated: @escaping (RoutineResponse) -> Void) {
        _selectedTab = selectedTab
        self.productsContent = AnyView(productsContent)
        self.initialRoutine = initialRoutine
        self.onRoutineGenerated = onRoutineGenerated
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RoutineHomeView(
                generatedRoutine: initialRoutine,
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

            MyselfView(
                routineService: ServiceFactory.shared.createRoutineService(),
                onRoutineGenerated: onRoutineGenerated
            )
            .tabItem {
                Image(systemName: MainTabView.CurrentTab.myself.icon)
                Text(MainTabView.CurrentTab.myself.rawValue)
            }
            .tag(MainTabView.CurrentTab.myself)
        }
    }
}

extension MainTabView {
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
