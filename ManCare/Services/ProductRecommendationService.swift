//
//  ProductRecommendationService.swift
//  ManCare
//
//  Service for managing product recommendations
//

import Foundation
import Combine

final class ProductRecommendationService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = ProductRecommendationService()
    
    // MARK: - Published State
    
    @Published var isGenerating: Bool = false
    @Published var recommendations: [RecommendedProduct] = []
    @Published var error: Error?
    
    // MARK: - Dependencies
    
    private let gptService: GPTService
    private let store: ProductRecommendationStore
    
    // MARK: - Initialization
    
    private init(
        gptService: GPTService = .shared,
        store: ProductRecommendationStore = .shared
    ) {
        self.gptService = gptService
        self.store = store
    }
    
    // MARK: - Public API
    
    /// Generate product recommendations for a routine
    func generateRecommendations(for routine: SavedRoutineModel) async throws {
        print("🛍️ ProductRecommendationService: Starting generation for routine \(routine.id)")
        
        await MainActor.run {
            self.isGenerating = true
            self.error = nil
        }
        
        do {
            // Get app's current language from LocalizationManager
            let locale = LocalizationManager.shared.currentLanguage
            print("🌍 Using locale from LocalizationManager: \(locale)")

            // Call GPT to generate recommendations
            print("📡 Calling GPT service...")
            let response = try await gptService.generateProductRecommendations(
                for: routine,
                locale: locale
            )
            print("📦 GPT Response received with \(response.recommendations.count) step recommendations")

            // Convert response to RecommendedProduct models
            var allProducts: [RecommendedProduct] = []

            for stepRecommendation in response.recommendations {
                print("🔄 Processing recommendations for step: \(stepRecommendation.stepId) (type: \(stepRecommendation.productType))")
                print("   GPT returned \(stepRecommendation.products.count) products for this step")
                
                // Find matching product type
                guard let productType = ProductType(rawValue: stepRecommendation.productType) else {
                    print("⚠️ Unknown product type: \(stepRecommendation.productType), skipping...")
                    continue
                }

                // Convert each product
                for (index, gptProduct) in stepRecommendation.products.enumerated() {
                    print("   Converting product \(index + 1): \(gptProduct.brand) - \(gptProduct.name)")
                    if let product = gptProduct.toRecommendedProduct(
                        routineStepId: stepRecommendation.stepId,
                        productType: productType,
                        locale: locale
                    ) {
                        allProducts.append(product)
                        print("   ✅ Successfully converted product \(index + 1)")
                    } else {
                        print("   ❌ Failed to convert product \(index + 1)")
                    }
                }
            }

            print("✅ Generated \(allProducts.count) product recommendations total")
            print("📋 Breakdown by step:")
            let grouped = Dictionary(grouping: allProducts) { $0.productType }
            for (type, products) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                print("   - \(type.displayName): \(products.count) products")
            }
            
            // Save to Core Data
            try await store.saveRecommendations(allProducts, for: routine.id)
            
            // Update state and post notification on main thread
            await MainActor.run {
                self.recommendations = allProducts
                self.isGenerating = false
                
                // Post notification on main thread
                print("📢 Posting notification: productRecommendationsGenerated")
                NotificationCenter.default.post(
                    name: .productRecommendationsGenerated,
                    object: nil,
                    userInfo: ["routineId": routine.id]
                )
            }
            
        } catch {
            print("❌ Failed to generate recommendations: \(error)")
            await MainActor.run {
                self.error = error
                self.isGenerating = false
            }
            throw error
        }
    }
    
    /// Fetch recommendations from storage
    func fetchRecommendations(for routine: SavedRoutineModel) async throws -> [RecommendedProduct] {
        print("📦 Fetching recommendations from storage for routine: \(routine.id)")
        let products = try await store.fetchRecommendations(for: routine.id)
        print("✅ Fetched \(products.count) recommendations from storage")

        await MainActor.run {
            self.recommendations = products
            print("📱 Updated UI state with \(products.count) recommendations")
        }

        return products
    }
    
    /// Check if recommendations exist for a routine
    func hasRecommendations(for routine: SavedRoutineModel) async throws -> Bool {
        return try await store.hasRecommendations(for: routine.id)
    }
    
    /// Delete recommendations for a routine
    func deleteRecommendations(for routine: SavedRoutineModel) async throws {
        try await store.deleteRecommendations(for: routine.id)
        
        await MainActor.run {
            self.recommendations = []
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get recommendations grouped by product type
    func recommendationsByProductType() -> [ProductType: [RecommendedProduct]] {
        Dictionary(grouping: recommendations) { $0.productType }
    }
    
    /// Get first 3 recommendations for preview (mix of budget and premium from different steps)
    func previewRecommendations() -> [RecommendedProduct] {
        // Try to show a diverse mix: different product types
        var preview: [RecommendedProduct] = []
        var seenTypes: Set<ProductType> = []
        
        // First pass: try to get unique types
        for product in recommendations {
            if !seenTypes.contains(product.productType) {
                preview.append(product)
                seenTypes.insert(product.productType)
                
                if preview.count >= 3 {
                    break
                }
            }
        }
        
        // Second pass: if we don't have 3 yet, add products with unique types
        if preview.count < 3 {
            for product in recommendations {
                if !seenTypes.contains(product.productType) {
                    preview.append(product)
                    seenTypes.insert(product.productType)
                    if preview.count >= 3 {
                        break
                    }
                }
            }
        }
        
        // Final pass: just add any products to reach 3
        if preview.count < 3 {
            for product in recommendations {
                if !preview.contains(where: { $0.id == product.id }) {
                    preview.append(product)
                    if preview.count >= 3 {
                        break
                    }
                }
            }
        }
        
        return preview
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let productRecommendationsGenerated = Notification.Name("productRecommendationsGenerated")
}

