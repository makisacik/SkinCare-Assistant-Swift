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
    
    init() {
        loadUserProducts()
    }
    
    // MARK: - User Products Management
    
    /// Add a product to user's collection
    func addUserProduct(_ product: Product) {
        userProducts.append(product)
        saveUserProducts()
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
    
    /// Get user products for a specific slot
    func getUserProducts(for slot: SlotType) -> [Product] {
        return userProducts.filter { $0.tagging.slot == slot }
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
    
    /// Filter products by slot type
    func filterProducts(by slot: SlotType) -> [Product] {
        return userProducts.filter { $0.tagging.slot == slot }
    }
    
    /// Filter products by subtype
    func filterProducts(by subtype: ProductSubtype) -> [Product] {
        return userProducts.filter { $0.tagging.subtypes.contains(subtype) }
    }
    
    /// Filter products by budget
    func filterProducts(by budget: Budget) -> [Product] {
        return userProducts.filter { $0.tagging.budget == budget }
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
    
    /// Get product recommendations for a slot
    func getRecommendations(for slot: SlotType, constraints: Constraints = Constraints(), budget: Budget? = nil) -> [Product] {
        var candidates = userProducts.filter { $0.tagging.slot == slot }
        
        // Apply constraints
        candidates = candidates.filter { product in
            matchesConstraints(product.tagging, constraints: constraints)
        }
        
        // Apply budget filter if specified
        if let budget = budget {
            candidates = candidates.filter { $0.tagging.budget == budget }
        }
        
        return candidates
    }
    
    /// Create a product from a name with automatic tagging
    func createProductFromName(_ name: String, brand: String? = nil, budget: Budget = .mid, additionalInfo: [String: Any] = [:]) -> Product {
        let (slot, subtype) = ProductAliasMapping.normalize(name)
        let subtypes = subtype.map { [$0] } ?? []
        
        // Extract ingredients and claims from additional info
        let ingredients = additionalInfo["ingredients"] as? [String] ?? []
        let claims = additionalInfo["claims"] as? [String] ?? []
        
        let tagging = ProductTagging(
            slot: slot,
            subtypes: subtypes,
            ingredients: ingredients,
            claims: claims,
            budget: budget
        )
        
        return Product(
            id: UUID().uuidString,
            displayName: name,
            tagging: tagging,
            brand: brand,
            price: additionalInfo["price"] as? Double,
            size: additionalInfo["size"] as? String,
            description: additionalInfo["description"] as? String
        )
    }
    
    // MARK: - Private Methods
    
    private func saveUserProducts() {
        if let data = try? JSONEncoder().encode(userProducts) {
            userDefaults.set(data, forKey: userProductsKey)
        }
    }
    
    private func loadUserProducts() {
        if let data = userDefaults.data(forKey: userProductsKey),
           let products = try? JSONDecoder().decode([Product].self, from: data) {
            self.userProducts = products
        }
    }
    
    
    private func matchesConstraints(_ tagging: ProductTagging, constraints: Constraints) -> Bool {
        // Check SPF requirement
        if let requiredSPF = constraints.spf, requiredSPF > 0 {
            // For now, assume all sunscreens meet SPF requirements
            // In a real app, you'd check the actual SPF value
            if tagging.slot != .sunscreen {
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
        let productsBySlot = Dictionary(grouping: userProducts, by: { $0.tagging.slot })
        let productsByBudget = Dictionary(grouping: userProducts, by: { $0.tagging.budget })
        
        return ProductStats(
            totalProducts: totalProducts,
            productsBySlot: productsBySlot,
            productsByBudget: productsByBudget,
            averagePrice: userProducts.compactMap { $0.price }.reduce(0, +) / Double(max(userProducts.count, 1))
        )
    }
}

struct ProductStats {
    let totalProducts: Int
    let productsBySlot: [SlotType: [Product]]
    let productsByBudget: [Budget: [Product]]
    let averagePrice: Double
}
