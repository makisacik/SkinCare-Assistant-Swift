//
//  ProductRecommendationStore.swift
//  ManCare
//
//  Core Data store for product recommendations
//

import Foundation
import CoreData

final class ProductRecommendationStore {
    // MARK: - Singleton
    
    static let shared = ProductRecommendationStore()
    
    private let persistenceController = PersistenceController.shared
    
    private init() {}
    
    // MARK: - Context
    
    private var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // MARK: - Save Recommendations
    
    func saveRecommendations(_ recommendations: [RecommendedProduct], for routineId: UUID) async throws {
        print("💾 ProductRecommendationStore: Saving \(recommendations.count) recommendations for routine \(routineId)")
        
        try await context.perform {
            // Delete existing recommendations for this routine
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecommendedProductEntity")
            fetchRequest.predicate = NSPredicate(format: "routineId == %@", routineId as CVarArg)
            
            do {
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try self.context.execute(deleteRequest)
                print("🗑️ Deleted existing recommendations")
            } catch {
                print("⚠️ Error deleting old recommendations (might be first run): \(error)")
            }

            // Create new entities
            print("💾 Creating \(recommendations.count) Core Data entities...")
            for (index, recommendation) in recommendations.enumerated() {
                print("   Creating entity \(index + 1)/\(recommendations.count): \(recommendation.brand) - \(recommendation.displayName)")
                let entity = RecommendedProductEntity(context: self.context)
                entity.id = recommendation.id
                entity.routineId = routineId
                entity.routineStepId = recommendation.routineStepId
                entity.productType = recommendation.productType.rawValue
                entity.brand = recommendation.brand
                entity.displayName = recommendation.displayName
                entity.displayNameLocale = recommendation.displayNameLocale
                entity.ingredientsJSON = try? JSONEncoder().encode(recommendation.ingredients)
                entity.ingredientsLocaleJSON = recommendation.ingredientsLocale.flatMap { try? JSONEncoder().encode($0) }
                entity.recommendationReason = recommendation.recommendationReason
                entity.recommendationReasonLocale = recommendation.recommendationReasonLocale
                entity.size = recommendation.size
                entity.purchaseLink = recommendation.purchaseLink
                entity.descriptionText = recommendation.descriptionText
                entity.descriptionLocale = recommendation.descriptionLocale
                entity.locale = recommendation.locale
                entity.createdAt = recommendation.createdAt
            }
            
            // Save context
            if self.context.hasChanges {
                do {
                    try self.context.save()
                    print("✅ Core Data context saved successfully!")
                    print("✅ Saved \(recommendations.count) product recommendations for routine \(routineId)")
                } catch {
                    print("❌ CRITICAL: Failed to save Core Data context: \(error)")
                    print("❌ Error details: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("❌ NSError domain: \(nsError.domain), code: \(nsError.code)")
                        print("❌ UserInfo: \(nsError.userInfo)")
                    }
                    throw error
                }
            } else {
                print("⚠️ No changes to save in Core Data context")
            }
        }
    }
    
    // MARK: - Fetch Recommendations
    
    func fetchRecommendations(for routineId: UUID) async throws -> [RecommendedProduct] {
        print("📂 ProductRecommendationStore: Fetching recommendations for routine \(routineId)")
        
        return try await context.perform {
            do {
                let fetchRequest: NSFetchRequest<RecommendedProductEntity> = RecommendedProductEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "routineId == %@", routineId as CVarArg)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \RecommendedProductEntity.productType, ascending: true),
                    NSSortDescriptor(keyPath: \RecommendedProductEntity.brand, ascending: true)
                ]

                let entities = try self.context.fetch(fetchRequest)
                print("📂 Found \(entities.count) entities in Core Data for routine \(routineId)")
                
                if entities.isEmpty {
                    print("⚠️ No entities found - this could mean:")
                    print("   1. Recommendations haven't been generated yet")
                    print("   2. App was deleted and reinstalled (Core Data cleared)")
                    print("   3. Core Data model changed and needs migration")
                }
                
                let products = entities.compactMap { self.toRecommendedProduct($0) }
                print("📂 Successfully converted \(products.count)/\(entities.count) to RecommendedProduct models")
                
                return products
            } catch {
                print("❌ Error fetching recommendations: \(error)")
                print("❌ This might indicate Core Data entity doesn't exist")
                print("❌ Solution: Delete app from simulator and reinstall")
                throw error
            }
        }
    }
    
    // MARK: - Has Recommendations
    
    func hasRecommendations(for routineId: UUID) async throws -> Bool {
        return try await context.perform {
            let fetchRequest: NSFetchRequest<RecommendedProductEntity> = RecommendedProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "routineId == %@", routineId as CVarArg)
            fetchRequest.fetchLimit = 1
            
            let count = try self.context.count(for: fetchRequest)
            return count > 0
        }
    }
    
    // MARK: - Delete Recommendations
    
    func deleteRecommendations(for routineId: UUID) async throws {
        try await context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecommendedProductEntity")
            fetchRequest.predicate = NSPredicate(format: "routineId == %@", routineId as CVarArg)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try self.context.execute(deleteRequest)
            
            print("🗑️ Deleted recommendations for routine \(routineId)")
        }
    }
    
    // MARK: - Conversion
    
    private func toRecommendedProduct(_ entity: RecommendedProductEntity) -> RecommendedProduct? {
        guard let id = entity.id,
              let routineStepId = entity.routineStepId,
              let productTypeString = entity.productType,
              let productType = ProductType(rawValue: productTypeString),
              let brand = entity.brand,
              let displayName = entity.displayName,
              let reason = entity.recommendationReason,
              let locale = entity.locale,
              let createdAt = entity.createdAt else {
            print("⚠️ Missing required fields in RecommendedProductEntity")
            return nil
        }
        
        // Decode ingredients
        var ingredients: [String] = []
        if let ingredientsData = entity.ingredientsJSON {
            ingredients = (try? JSONDecoder().decode([String].self, from: ingredientsData)) ?? []
        }
        
        var ingredientsLocale: [String]?
        if let ingredientsLocaleData = entity.ingredientsLocaleJSON {
            ingredientsLocale = try? JSONDecoder().decode([String].self, from: ingredientsLocaleData)
        }
        
        return RecommendedProduct(
            id: id,
            routineStepId: routineStepId,
            productType: productType,
            brand: brand,
            displayName: displayName,
            displayNameLocale: entity.displayNameLocale,
            ingredients: ingredients,
            ingredientsLocale: ingredientsLocale,
            recommendationReason: reason,
            recommendationReasonLocale: entity.recommendationReasonLocale,
            size: entity.size,
            purchaseLink: entity.purchaseLink,
            descriptionText: entity.descriptionText,
            descriptionLocale: entity.descriptionLocale,
            locale: locale,
            createdAt: createdAt
        )
    }
}

