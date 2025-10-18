//
//  ProductRecommendation.swift
//  ManCare
//
//  Product recommendation models for AI-powered suggestions
//

import Foundation


// MARK: - Recommended Product (Swift Model)

struct RecommendedProduct: Identifiable, Codable, Equatable {
    let id: UUID
    let routineStepId: String
    let productType: ProductType
    let brand: String
    let displayName: String
    let displayNameLocale: String?
    let ingredients: [String]
    let ingredientsLocale: [String]?
    let recommendationReason: String
    let recommendationReasonLocale: String?
    let size: String?
    let purchaseLink: String?
    let descriptionText: String?
    let descriptionLocale: String?
    let locale: String
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        routineStepId: String,
        productType: ProductType,
        brand: String,
        displayName: String,
        displayNameLocale: String? = nil,
        ingredients: [String],
        ingredientsLocale: [String]? = nil,
        recommendationReason: String,
        recommendationReasonLocale: String? = nil,
        size: String? = nil,
        purchaseLink: String? = nil,
        descriptionText: String? = nil,
        descriptionLocale: String? = nil,
        locale: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.routineStepId = routineStepId
        self.productType = productType
        self.brand = brand
        self.displayName = displayName
        self.displayNameLocale = displayNameLocale
        self.ingredients = ingredients
        self.ingredientsLocale = ingredientsLocale
        self.recommendationReason = recommendationReason
        self.recommendationReasonLocale = recommendationReasonLocale
        self.size = size
        self.purchaseLink = purchaseLink
        self.descriptionText = descriptionText
        self.descriptionLocale = descriptionLocale
        self.locale = locale
        self.createdAt = createdAt
    }
    
    // MARK: - Localized Properties
    
    var localizedDisplayName: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        #if DEBUG
        print("🌍 [RecommendedProduct] localizedDisplayName:")
        print("   Current language: \(currentLanguage)")
        print("   Has displayNameLocale: \(displayNameLocale != nil)")
        if let localeVersion = displayNameLocale {
            print("   Locale name: \(localeVersion)")
        }
        print("   English name: \(displayName)")
        #endif
        
        if currentLanguage != "en", let localeVersion = displayNameLocale {
            return localeVersion
        }
        return displayName
    }
    
    var localizedIngredients: [String] {
        // Ingredients use INCI/scientific names which are universal (not translated)
        return ingredients
    }
    
    var localizedRecommendationReason: String {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        if currentLanguage != "en", let localeVersion = recommendationReasonLocale {
            return localeVersion
        }
        return recommendationReason
    }
    
    var localizedDescription: String? {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        #if DEBUG
        print("🌍 [RecommendedProduct] localizedDescription:")
        print("   Current language: \(currentLanguage)")
        print("   Has descriptionLocale: \(descriptionLocale != nil)")
        print("   Has descriptionText: \(descriptionText != nil)")
        if let localeVersion = descriptionLocale {
            print("   Locale description: \(localeVersion.prefix(50))...")
        }
        if let englishVersion = descriptionText {
            print("   English description: \(englishVersion.prefix(50))...")
        }
        #endif
        
        if currentLanguage != "en", let localeVersion = descriptionLocale {
            return localeVersion
        }
        return descriptionText
    }
    
    // MARK: - Conversion to Product
    
    /// Convert a recommended product to a regular Product for adding to user's product list
    func toProduct() -> Product {
        let tagging = ProductTagging(
            productType: productType,
            ingredients: ingredients,
            claims: []
        )
        
        return Product(
            id: UUID().uuidString,
            displayName: displayName,                    // Keep English for business logic
            displayNameLocale: displayNameLocale,        // Localized for user-facing text
            tagging: tagging,
            brand: brand,                                // Keep English for business logic
            brandLocale: nil,                            // No localized brand in recommendations
            link: purchaseLink.flatMap { URL(string: $0) },
            imageURL: nil,
            size: size,
            description: descriptionText,                // Keep English for business logic
            descriptionLocale: descriptionLocale,        // Localized for user-facing text
            enrichedINCI: nil
        )
    }
}

// MARK: - GPT Request Models

struct ProductRecommendationRequest: Codable {
    let routineSteps: [RoutineStepRequest]
    let locale: String
    let country: String
    
    struct RoutineStepRequest: Codable {
        let stepId: String
        let productType: String
        let stepTitle: String
        let stepDescription: String
    }
}

// MARK: - GPT Response Models

struct ProductRecommendationResponse: Codable {
    let recommendations: [StepRecommendations]
    
    struct StepRecommendations: Codable {
        let stepId: String
        let productType: String
        let products: [ProductRecommendation]
    }
    
    struct ProductRecommendation: Codable {
        let brand: String
        let name: String
        let nameTranslated: String?
        let ingredients: [String]
        let ingredientsTranslated: [String]?
        let reason: String
        let reasonTranslated: String?
        let size: String?
        let purchaseLink: String?
        let description: String?
        let descriptionTranslated: String?
    }
}

// MARK: - Extension to Map Response to Model

extension ProductRecommendationResponse.ProductRecommendation {
    func toRecommendedProduct(
        routineStepId: String,
        productType: ProductType,
        locale: String
    ) -> RecommendedProduct? {
        return RecommendedProduct(
            routineStepId: routineStepId,
            productType: productType,
            brand: brand,
            displayName: name,
            displayNameLocale: nameTranslated,
            ingredients: ingredients,
            ingredientsLocale: ingredientsTranslated,
            recommendationReason: reason,
            recommendationReasonLocale: reasonTranslated,
            size: size,
            purchaseLink: purchaseLink,
            descriptionText: description,
            descriptionLocale: descriptionTranslated,
            locale: locale
        )
    }
}

