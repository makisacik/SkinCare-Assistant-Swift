//
//  ProductService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Product Service

/// Service for managing products with the new taxonomy system
class ProductService: ObservableObject {
    @Published var products: [Product] = []
    @Published var userProducts: [Product] = []
    
    private let userDefaults = UserDefaults.standard
    private let userProductsKey = "user_products"
    
    // Shared instance for the entire app
    static let shared = ProductService()

    init() {
        loadUserProducts()
    }
    
    // MARK: - User Products Management
    
    /// Add a product to user's collection
    func addUserProduct(_ product: Product) {
        print("📦 ProductService: Adding product to collection")
        print("   Product ID: \(product.id)")
        print("   Display Name: \(product.displayName)")
        print("   Product Type: \(product.tagging.productType.displayName)")
        print("   Brand: \(product.brand ?? "Unknown")")
        print("   Current collection size: \(userProducts.count)")
        
        userProducts.append(product)
        saveUserProducts()
        
        print("✅ ProductService: Product added successfully")
        print("   New collection size: \(userProducts.count)")
    }
    
    /// Remove a product from user's collection
    func removeUserProduct(withId id: String) {
        userProducts.removeAll { $0.id == id }
        saveUserProducts()
    }
    
    /// Update a user product
    func updateUserProduct(_ product: Product) {
        if let index = userProducts.firstIndex(where: { $0.id == product.id }) {
            userProducts[index] = product
            saveUserProducts()
        }
    }
    
    /// Get user products for a specific product type
    func getUserProducts(for productType: ProductType) -> [Product] {
        return userProducts.filter { $0.tagging.productType == productType }
    }
    
    /// Get user products matching constraints
    func getUserProducts(matching constraints: Constraints) -> [Product] {
        return userProducts.filter { product in
            matchesConstraints(product.tagging, constraints: constraints)
        }
    }
    
    // MARK: - Product Search and Filtering
    
    /// Search products by name, brand, or ingredients
    func searchProducts(query: String) -> [Product] {
        let lowercaseQuery = query.lowercased()
        return userProducts.filter { product in
            product.displayName.lowercased().contains(lowercaseQuery) ||
            product.brand?.lowercased().contains(lowercaseQuery) == true ||
            product.tagging.ingredients.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    /// Filter products by product type
    func filterProducts(by productType: ProductType) -> [Product] {
        return userProducts.filter { $0.tagging.productType == productType }
    }
    
    /// Filter products by category
    func filterProducts(by category: ProductCategory) -> [Product] {
        return userProducts.filter { $0.tagging.productType.category == category }
    }
    
    
    /// Filter products by claims
    func filterProducts(by claims: [String]) -> [Product] {
        return userProducts.filter { product in
            claims.allSatisfy { claim in
                product.tagging.claims.contains(claim)
            }
        }
    }
    
    // MARK: - Product Recommendations
    
    /// Get product recommendations for a product type
    func getRecommendations(for productType: ProductType, constraints: Constraints = Constraints()) -> [Product] {
        var candidates = userProducts.filter { $0.tagging.productType == productType }
        
        // Apply constraints
        candidates = candidates.filter { product in
            matchesConstraints(product.tagging, constraints: constraints)
        }
        
        return candidates
    }
    
    /// Create a product from a name with automatic tagging
    func createProductFromName(_ name: String, brand: String? = nil, additionalInfo: [String: Any] = [:]) -> Product {
        let productType = ProductAliasMapping.normalize(name)
        
        // Extract ingredients and claims from additional info
        let ingredients = additionalInfo["ingredients"] as? [String] ?? []
        let claims = additionalInfo["claims"] as? [String] ?? []
        
        let tagging = ProductTagging(
            productType: productType,
            ingredients: ingredients,
            claims: claims
        )
        
        return Product(
            id: UUID().uuidString,
            displayName: name,
            tagging: tagging,
            brand: brand,
            size: additionalInfo["size"] as? String,
            description: additionalInfo["description"] as? String
        )
    }
    
    // MARK: - Private Methods
    
    private func saveUserProducts() {
        print("💾 ProductService: Saving \(userProducts.count) products to UserDefaults")
        if let data = try? JSONEncoder().encode(userProducts) {
            userDefaults.set(data, forKey: userProductsKey)
            print("✅ ProductService: Products saved successfully")
        } else {
            print("❌ ProductService: Failed to encode products")
        }
    }
    
    private func loadUserProducts() {
        print("📂 ProductService: Loading products from UserDefaults")
        if let data = userDefaults.data(forKey: userProductsKey),
           let products = try? JSONDecoder().decode([Product].self, from: data) {
            self.userProducts = products
            print("✅ ProductService: Loaded \(products.count) products from storage")
        } else {
            print("ℹ️ ProductService: No saved products found, starting with empty collection")
        }
    }
    
    
    private func matchesConstraints(_ tagging: ProductTagging, constraints: Constraints) -> Bool {
        // Check SPF requirement
        if let requiredSPF = constraints.spf, requiredSPF > 0 {
            // For now, assume all sunscreens meet SPF requirements
            // In a real app, you'd check the actual SPF value
            if tagging.productType != .sunscreen && tagging.productType != .faceSunscreen && tagging.productType != .bodySunscreen {
                return false
            }
        }
        
        // Check fragrance free requirement
        if let fragranceFree = constraints.fragranceFree, fragranceFree {
            if !tagging.claims.contains("fragranceFree") {
                return false
            }
        }
        
        // Check sensitive safe requirement
        if let sensitiveSafe = constraints.sensitiveSafe, sensitiveSafe {
            if !tagging.claims.contains("sensitiveSafe") {
                return false
            }
        }
        
        // Check vegan requirement
        if let vegan = constraints.vegan, vegan {
            if !tagging.claims.contains("vegan") {
                return false
            }
        }
        
        // Check cruelty free requirement
        if let crueltyFree = constraints.crueltyFree, crueltyFree {
            if !tagging.claims.contains("crueltyFree") {
                return false
            }
        }
        
        // Check avoid ingredients
        if let avoidIngredients = constraints.avoidIngredients {
            for ingredient in avoidIngredients {
                if tagging.ingredients.contains(where: { $0.lowercased().contains(ingredient.lowercased()) }) {
                    return false
                }
            }
        }
        
        // Check prefer ingredients (at least one should match)
        if let preferIngredients = constraints.preferIngredients, !preferIngredients.isEmpty {
            let hasPreferredIngredient = preferIngredients.contains { ingredient in
                tagging.ingredients.contains { $0.lowercased().contains(ingredient.lowercased()) }
            }
            if !hasPreferredIngredient {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Product Management Extensions

extension ProductService {
    /// Get statistics about user's product collection
    var productStats: ProductStats {
        let totalProducts = userProducts.count
        let productsByType = Dictionary(grouping: userProducts, by: { $0.tagging.productType })
        
        return ProductStats(
            totalProducts: totalProducts,
            productsByType: productsByType
        )
    }
}

struct ProductStats {
    let totalProducts: Int
    let productsByType: [ProductType: [Product]]
}
