//
//  ProductIconManager.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Product Icon Manager

/// Manages custom product icons for different product types
class ProductIconManager {
    
    // MARK: - Product Type to Asset Mapping
    
    /// Maps ProductType to specific asset names
    private static let productTypeAssetMapping: [ProductType: String] = [
        // Most commonly used (daily essentials)
        .cleanser: "bottle-cleanser-blue",
        .moisturizer: "jar-moisturizer-green",
        .sunscreen: "sun-screen-yellow",
        .toner: "toner-bottle-purple",

        // Treatment products
        .faceSerum: "serum-indigo",
        .exfoliator: "exfoliator-orange",
        .faceMask: "face-mask-jar-pink",
        .facialOil: "facial-oil-brown",

        // Specialized products
        .facialMist: "facial-mist-cyan",
        .eyeCream: "eye-cream-mint",
        .spotTreatment: "spot-treatment-red",
        .retinol: "retinol-green",
        .vitaminC: "vitamic-c-yellow",
        .niacinamide: "niacinamide-blue",

        // Sun protection variations
        .faceSunscreen: "face-sun-screen-yellow",
        .bodySunscreen: "body-sun-screen-yellow",
        .lipBalm: "lip-balm-pink",

        // Shaving products
        .shaveCream: "shaving-cream-gray",
        .aftershave: "after-shave-blue",
        .shaveGel: "shaving-gel-cyan",

        // Body care
        .bodyLotion: "body-lotion-green",
        .bodyWash: "body-wash-blue",
        .handCream: "hand-cream-mint",

        // Hair care
        .shampoo: "shampoo-gray",
        .conditioner: "conditioner-brown",
        .hairOil: "hair-oil-yellow",
        .hairMask: "hair-mask-brown",

        // Specialized treatments
        .chemicalPeel: "chemical-peel-red",
        .micellarWater: "micellar-cleansing-water-blue",
        .makeupRemover: "make-up-remover-pink",
        .faceWash: "face-wash-blue",
        .cleansingOil: "cleansing-oil-yellow",
        .cleansingBalm: "cleansing-balm-gray"
    ]

    /// Fallback asset name for unknown product types
    private static let fallbackAsset = "after-shave-blue"

    // MARK: - Public Methods

    /// Get icon name for a ProductType - uses specific asset mapping
    static func getIconName(for productType: ProductType) -> String {
        return productTypeAssetMapping[productType] ?? fallbackAsset
    }

    /// Get a consistent icon name for any string input (step names, etc.)
    /// Uses deterministic hashing to ensure the same input always gets the same icon
    static func getIconName(for input: String) -> String {
        // First try to match as a ProductType
        if let productType = ProductType(rawValue: input) {
            return getIconName(for: productType)
        }

        // For other inputs, use deterministic hashing with all available assets
        let allAssets = Array(productTypeAssetMapping.values) + [fallbackAsset]
        let hash = input.hashValue
        let index = abs(hash) % allAssets.count
        return allAssets[index]
    }
    
    /// Get icon name for a step name
    static func getIconNameForStepName(_ stepName: String) -> String {
        return getIconName(for: stepName)
    }
    
    /// Get icon name for routine step based on step content
    static func getStepIconName(for step: String) -> String {
        return getIconName(for: step)
    }
    
    /// Get all available asset names
    static func getAllAssetNames() -> [String] {
        return Array(productTypeAssetMapping.values) + [fallbackAsset]
    }
    
    /// Get the fallback icon
    static func getFallbackIcon() -> String {
        return fallbackAsset
    }
    
}

// MARK: - SwiftUI Image Extension

extension Image {
    /// Create an Image from a ProductType using custom icons
    init(productType: ProductType) {
        let iconName = ProductIconManager.getIconName(for: productType)
        self.init(iconName)
    }
    
    /// Create an Image from a step name using custom icons
    init(stepName: String) {
        let iconName = ProductIconManager.getIconNameForStepName(stepName)
        self.init(iconName)
    }
    
    /// Create an Image for product/step icons - uses specific assets for ProductTypes
    /// For system UI icons, use Image(systemName:) directly
    static func productIcon(for input: String) -> Image {
        // System icons that should stay as system icons
        let systemIcons = [
            "sun.max.fill", "moon.fill", "moon.circle.fill", "moon.stars.fill",
            "calendar", "chevron.right", "chevron.left", "chevron.up", "chevron.down",
            "checkmark", "checkmark.circle.fill", "xmark.circle.fill", "plus.circle.fill",
            "minus.circle.fill", "play.circle.fill", "pause.circle.fill", "arrow.right",
            "arrow.left", "arrow.clockwise", "camera.viewfinder", "text.viewfinder",
            "magnifyingglass", "slider.horizontal.3", "timer", "forward.fill",
            "pause.fill", "play.fill", "lightbulb.fill", "party.popper.fill",
            "bookmark", "clock", "list.bullet", "bell.fill", "pencil",
            "line.3.horizontal", "link.badge.minus", "link.badge.plus", "plus",
            "brain.head.profile", "text.badge.checkmark", "camera.badge.ellipsis",
            "text.magnifyingglass", "photo.on.rectangle", "flashlight.on.fill", "flashlight.off.fill",
            "trash"
        ]
        
        if systemIcons.contains(input) {
            return Image(systemName: input)
        } else {
            // For products/steps, use specific assets or fallback
            let iconName = ProductIconManager.getIconName(for: input)
            return Image(iconName)
        }
    }
    
    /// Create an Image for product/step icons from ProductType
    static func productIcon(for productType: ProductType) -> Image {
        let iconName = ProductIconManager.getIconName(for: productType)
        return Image(iconName)
    }
    
}

// MARK: - ProductType Extension

extension ProductType {
    /// Get custom icon name for this product type
    var customIconName: String {
        return ProductIconManager.getIconName(for: self)
    }
}
