//
//  MainTabView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.themeManager) private var tm
    @State private var selectedTab: Tab = .routines
    @State private var showingAddProduct = false
    @State private var showingScanProduct = false
    @State private var showingTestSheet = false
    @State private var selectedProduct: Product?
    let generatedRoutine: RoutineResponse?
    
    enum Tab: String, CaseIterable {
        case routines = "Routines"
        case products = "My Products"
        
        var iconName: String {
            switch self {
            case .routines:
                return "list.bullet.rectangle"
            case .products:
                return "bag.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Routines Tab
                RoutineHomeView(generatedRoutine: generatedRoutine)
                    .tabItem {
                        Image(systemName: Tab.routines.iconName)
                        Text(Tab.routines.rawValue)
                    }
                    .tag(Tab.routines)
                
                // Products Tab
                ProductSlotsView(
                    onAddProductTapped: { showingAddProduct = true },
                    onScanProductTapped: { showingScanProduct = true },
                    onTestSheetTapped: { showingTestSheet = true },
                    onProductTapped: { product in selectedProduct = product }
                )
                .tabItem {
                    Image(systemName: Tab.products.iconName)
                    Text(Tab.products.rawValue)
                }
                .tag(Tab.products)
            }
            .accentColor(tm.theme.palette.secondary)
            .onAppear {
                // Set up tab bar appearance
                setupTabBarAppearance()
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
        .fullScreenCover(isPresented: $showingTestSheet) {
            VStack(spacing: 20) {
                Text("Test Sheet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This is a simple test sheet to verify smooth presentation.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Dismiss") {
                    showingTestSheet = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(30)
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(tm.theme.palette.bg)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(tm.theme.palette.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(tm.theme.palette.textMuted)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(tm.theme.palette.secondary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(tm.theme.palette.secondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


// MARK: - Preview

#Preview("Main Tab View") {
    MainTabView(generatedRoutine: nil)
}
