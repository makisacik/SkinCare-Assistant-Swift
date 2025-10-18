//
//  RecommendationDebugHelper.swift
//  ManCare
//
//  Debug utilities for product recommendations
//

import Foundation

struct RecommendationDebugHelper {
    /// Print all recommendations in Core Data
    static func printAllRecommendations() async {
        let store = ProductRecommendationStore.shared
        let routineStore = RoutineStore()
        
        do {
            // Get active routine
            if let activeRoutine = try await routineStore.fetchActiveRoutine() {
                print("🔍 ========== RECOMMENDATION DEBUG ==========")
                print("Active Routine: \(activeRoutine.title)")
                print("Routine ID: \(activeRoutine.id)")
                
                // Check if has recommendations
                let hasRecs = try await store.hasRecommendations(for: activeRoutine.id)
                print("Has Recommendations: \(hasRecs)")
                
                if hasRecs {
                    // Fetch recommendations
                    let recs = try await store.fetchRecommendations(for: activeRoutine.id)
                    print("Total Recommendations: \(recs.count)")
                    
                    // Group by product type
                    let grouped = Dictionary(grouping: recs) { $0.productType }
                    for (type, products) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                        print("\n\(type.displayName) (\(products.count) products):")
                        for product in products {
                            print("  • \(product.brand) - \(product.displayName)")
                            print("    Size: \(product.size ?? "N/A")")
                            print("    Ingredients: \(product.ingredients.prefix(3).joined(separator: ", "))...")
                        }
                    }
                } else {
                    print("⚠️ No recommendations found in Core Data")
                }
                
                print("==========================================")
            } else {
                print("⚠️ No active routine found")
            }
        } catch {
            print("❌ Debug helper error: \(error)")
        }
    }
    
    /// Reset all recommendation data (for testing)
    static func resetAllRecommendations() async {
        print("🔄 Resetting all recommendation data...")
        
        BackgroundRecommendationManager.shared.resetGenerationState()
        
        let routineStore = RoutineStore()
        do {
            if let activeRoutine = try await routineStore.fetchActiveRoutine() {
                let store = ProductRecommendationStore.shared
                try await store.deleteRecommendations(for: activeRoutine.id)
                print("✅ Deleted all recommendations for active routine")
            }
        } catch {
            print("❌ Error resetting recommendations: \(error)")
        }
    }
}


