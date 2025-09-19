//
//  ProductTaxonomyDemo.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

/// Demo class to showcase the new product taxonomy system
class ProductTaxonomyDemo {
    
    static func runDemo() {
        print("🧴 ManCare Product Taxonomy Demo")
        print("=" * 50)
        
        // 1. Demonstrate slot type system
        print("\n1. PRODUCT TYPES (Comprehensive product categories)")
        print("-" * 30)
        for productType in ProductType.allCases {
            print("• \(productType.displayName) (\(productType.rawValue))")
            print("  Icon: \(productType.iconName)")
            print("  Optional: \(productType.isOptional)")
            print("  Default Frequency: \(productType.defaultFrequency.displayName)")
        }
        
        // 2. Demonstrate product alias mapping
        print("\n2. PRODUCT ALIAS MAPPING (Flexible names → Canonical product types)")
        print("-" * 30)
        let testNames = [
            "Gentle Foaming Cleanser",
            "Niacinamide Serum",
            "Vitamin C Essence",
            "SPF 50 Sunscreen",
            "Clay Face Mask",
            "Aftershave Balm",
            "Face Oil",
            "Chemical Peel"
        ]
        
        for name in testNames {
            let productType = ProductAliasMapping.normalize(name)
            print("• '\(name)' → \(productType.displayName)")
        }
        
        // 3. Demonstrate product creation
        print("\n3. PRODUCT CREATION (Automatic tagging)")
        print("-" * 30)
        let products = [
            Product.fromName("CeraVe Foaming Facial Cleanser", brand: "CeraVe"),
            Product.fromName("The Ordinary Niacinamide 10% + Zinc 1%", brand: "The Ordinary"),
            Product.fromName("EltaMD UV Clear Broad-Spectrum SPF 46", brand: "EltaMD"),
            Product.fromName("Paula's Choice 2% BHA Liquid Exfoliant", brand: "Paula's Choice")
        ]
        
        for product in products {
            print("• \(product.displayName)")
            print("  Brand: \(product.brand ?? "Unknown")")
            print("  Product Type: \(product.tagging.productType.displayName)")
            print("  Ingredients: \(product.tagging.ingredients.joined(separator: ", "))")
        }
        
        // 4. Demonstrate constraint matching
        print("\n4. CONSTRAINT MATCHING (Product filtering)")
        print("-" * 30)
        let constraints = Constraints(
            spf: nil,
            fragranceFree: true,
            sensitiveSafe: true,
            vegan: nil,
            crueltyFree: nil,
            avoidIngredients: ["alcohol", "fragrance"],
            preferIngredients: ["niacinamide", "ceramides"]
        )
        
        print("Constraints: Fragrance-free, Sensitive-safe, Avoid alcohol/fragrance, Prefer niacinamide/ceramides")
        
        // Create some test products with different properties
        let testProducts = [
            Product(
                id: "1",
                displayName: "Gentle Cleanser",
                tagging: ProductTagging(
                    productType: .cleanser,
                    ingredients: ["ceramides", "hyaluronic acid"],
                    claims: ["fragranceFree", "sensitiveSafe"],
                ),
                brand: "Test Brand"
            ),
            Product(
                id: "2",
                displayName: "Harsh Cleanser",
                tagging: ProductTagging(
                    productType: .cleanser,
                    ingredients: ["alcohol", "fragrance"],
                    claims: [],
                ),
                brand: "Test Brand"
            )
        ]
        
        for product in testProducts {
            let matches = matchesConstraints(product.tagging, constraints: constraints)
            print("• \(product.displayName): \(matches ? "✅ MATCHES" : "❌ NO MATCH")")
        }
        
        // 5. Demonstrate frequency system
        print("\n5. FREQUENCY SYSTEM (Flexible scheduling)")
        print("-" * 30)
        let frequencies: [Frequency] = [
            .dailyAM,
            .dailyPM,
            .both,
            .weekly(times: 2),
            .custom(["Mon", "Wed", "Fri"])
        ]
        
        for frequency in frequencies {
            print("• \(frequency.displayName): \(frequency.description)")
        }
        
        // 6. Backward compatibility removed; using ProductType directly

        print("\n" + "=" * 50)
        print("✅ Demo completed! The new taxonomy system is working.")
    }
    
    // Helper function to demonstrate constraint matching
    private static func matchesConstraints(_ tagging: ProductTagging, constraints: Constraints) -> Bool {
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

// MARK: - String Extension for Demo

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
