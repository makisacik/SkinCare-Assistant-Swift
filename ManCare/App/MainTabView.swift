//
//  MainTabView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .routines
    @State private var showingAddProduct = false
    @State private var showingScanProduct = false
    @State private var showingTestSheet = false
    @State private var selectedProduct: Product?
    @StateObject private var scanManager = ProductScanManager.shared
    let generatedRoutine: RoutineResponse?
    
    enum Tab: String, CaseIterable {
        case routines = "Routines"
        case discover = "Discover"
        case products = "My Products"
        
        var iconName: String {
            switch self {
            case .routines:
                return "list.bullet.rectangle"
            case .discover:
                return "sparkles"
            case .products:
                return "bag.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Routines Tab
                RoutineHomeView(generatedRoutine: generatedRoutine, selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: Tab.routines.iconName)
                        Text(Tab.routines.rawValue)
                    }
                    .tag(Tab.routines)
                
                // Discover Tab
                DiscoverView()
                    .tabItem {
                        Image(systemName: Tab.discover.iconName)
                        Text(Tab.discover.rawValue)
                    }
                    .tag(Tab.discover)
                // Products Tab
                Group {
                    if let scannedData = scanManager.scannedProductData {
                        ProductSummaryView(
                            extractedText: scannedData.extractedText,
                            normalizedProduct: scannedData.normalizedProduct,
                            productService: ProductService.shared,
                            onProductAdded: { product in
                                print("✅ Product added successfully: \(product.displayName)")
                                scanManager.clearScannedProduct()
                            },
                            onCancel: {
                                print("❌ User cancelled product addition")
                                scanManager.clearScannedProduct()
                            }
                        )
                    } else {
                        ProductSlotsView(
                            onAddProductTapped: { showingAddProduct = true },
                            onScanProductTapped: { showingScanProduct = true },
                            onTestSheetTapped: { showingTestSheet = true },
                            onProductTapped: { product in selectedProduct = product }
                        )
                    }
                }
                .tabItem {
                    Image(systemName: Tab.products.iconName)
                    Text(Tab.products.rawValue)
                }
                .tag(Tab.products)
            }
            .accentColor(ThemeManager.shared.theme.palette.secondary)
            .onAppear {
                // Set up tab bar appearance
                setupTabBarAppearance()
            }
            .onChange(of: scanManager.shouldNavigateToProducts) { shouldNavigate in
                if shouldNavigate {
                    selectedTab = .products
                }
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
                onEditProduct: { updatedProduct in
                    ProductService.shared.updateUserProduct(updatedProduct)
                },
                onDeleteProduct: { productToDelete in
                    ProductService.shared.removeUserProduct(withId: productToDelete.id)
                }
            )
        }
        .sheet(isPresented: $showingTestSheet) {
            // Mock product summary for UI testing - using real API response data
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
                onProductAdded: { product in
                    print("✅ Mock product added successfully: \(product.displayName)")
                    showingTestSheet = false
                },
                onCancel: {
                    print("❌ Mock product cancelled")
                    showingTestSheet = false
                }
            )
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(ThemeManager.shared.theme.palette.tabBarBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(ThemeManager.shared.theme.palette.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(ThemeManager.shared.theme.palette.textMuted)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(ThemeManager.shared.theme.palette.secondary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(ThemeManager.shared.theme.palette.secondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


// MARK: - Preview

#Preview("Main Tab View") {
    MainTabView(generatedRoutine: nil)
}
