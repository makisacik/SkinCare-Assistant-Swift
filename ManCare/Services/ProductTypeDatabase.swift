//
//  ProductTypeDatabase.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Product Type Database

struct ProductTypeDatabase {
    
    // MARK: - Product Type Information
    
    struct ProductTypeInfo {
        let name: String
        let description: String
        let iconName: String
        let why: String
        let how: String
        let timeOfDay: String
    }
    
    // MARK: - Database
    
    static let productTypes: [String: ProductTypeInfo] = [
        // Cleansers
        "gentle_cleanser": ProductTypeInfo(
            name: "Gentle Cleanser",
            description: "Oil-free gel cleanser that removes impurities without stripping the skin",
            iconName: "drop.fill",
            why: "Removes overnight oil buildup, makeup, and daily pollutants while maintaining skin's natural moisture barrier",
            how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "foaming_cleanser": ProductTypeInfo(
            name: "Foaming Cleanser",
            description: "Lightweight foaming cleanser for deep pore cleansing",
            iconName: "drop.fill",
            why: "Creates rich lather to remove excess oil and unclog pores without over-drying",
            how: "Wet face, apply cleanser, massage in circular motions, rinse thoroughly",
            timeOfDay: "both"
        ),
        "oil_cleanser": ProductTypeInfo(
            name: "Oil Cleanser",
            description: "Gentle oil-based cleanser for effective makeup and sunscreen removal",
            iconName: "drop.fill",
            why: "Oil dissolves oil, making it perfect for removing waterproof makeup and sunscreen",
            how: "Apply to dry skin, massage gently, add water to emulsify, rinse completely",
            timeOfDay: "evening"
        ),
        
        // Toners
        "hydrating_toner": ProductTypeInfo(
            name: "Hydrating Toner",
            description: "Alcohol-free toner that balances pH and provides instant hydration",
            iconName: "drop.circle",
            why: "Restores skin's natural pH balance and prepares skin for better product absorption",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "exfoliating_toner": ProductTypeInfo(
            name: "Exfoliating Toner",
            description: "Gentle exfoliating toner with AHA/BHA for smoother skin texture",
            iconName: "drop.circle",
            why: "Removes dead skin cells and unclogs pores for brighter, smoother skin",
            how: "Apply with cotton pad, avoid eye area, use 2-3 times per week",
            timeOfDay: "evening"
        ),
        
        // Serums
        "niacinamide_serum": ProductTypeInfo(
            name: "Niacinamide Serum",
            description: "Vitamin B3 serum that minimizes pores and controls oil production",
            iconName: "star.fill",
            why: "Reduces pore size, controls sebum production, and improves skin texture",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "vitamin_c_serum": ProductTypeInfo(
            name: "Vitamin C Serum",
            description: "Antioxidant serum that brightens skin and protects against environmental damage",
            iconName: "star.fill",
            why: "Neutralizes free radicals, brightens skin tone, and boosts collagen production",
            how: "Apply 2-3 drops in the morning, pat gently, follow with sunscreen",
            timeOfDay: "morning"
        ),
        "hyaluronic_acid_serum": ProductTypeInfo(
            name: "Hyaluronic Acid Serum",
            description: "Intensive hydrating serum that plumps and smooths skin",
            iconName: "star.fill",
            why: "Attracts and retains moisture, plumping skin and reducing fine lines",
            how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
            timeOfDay: "both"
        ),
        "retinol_serum": ProductTypeInfo(
            name: "Retinol Serum",
            description: "Anti-aging serum that promotes cell turnover and reduces signs of aging",
            iconName: "star.fill",
            why: "Stimulates collagen production, reduces fine lines, and improves skin texture",
            how: "Start with 2-3 times per week, apply at night, avoid eye area",
            timeOfDay: "evening"
        ),
        "peptide_serum": ProductTypeInfo(
            name: "Peptide Serum",
            description: "Anti-aging serum with peptides for firmer, more youthful skin",
            iconName: "star.fill",
            why: "Stimulates collagen production and improves skin firmness and elasticity",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        
        // Moisturizers
        "lightweight_moisturizer": ProductTypeInfo(
            name: "Lightweight Moisturizer",
            description: "Oil-free gel moisturizer that hydrates without clogging pores",
            iconName: "drop.circle.fill",
            why: "Provides essential hydration while maintaining a matte finish",
            how: "Apply a pea-sized amount, massage in upward circular motions",
            timeOfDay: "both"
        ),
        "rich_moisturizer": ProductTypeInfo(
            name: "Rich Moisturizer",
            description: "Nourishing cream moisturizer for deep hydration and skin repair",
            iconName: "drop.circle.fill",
            why: "Provides intensive hydration and supports overnight skin repair",
            how: "Apply generously to face and neck, massage gently until absorbed",
            timeOfDay: "evening"
        ),
        "night_cream": ProductTypeInfo(
            name: "Night Cream",
            description: "Intensive night cream that repairs and rejuvenates while you sleep",
            iconName: "moon.circle.fill",
            why: "Works with your skin's natural repair cycle to restore and rejuvenate",
            how: "Apply generously before bed, massage in upward motions",
            timeOfDay: "evening"
        ),
        
        // Sunscreens
        "daily_sunscreen": ProductTypeInfo(
            name: "Daily Sunscreen",
            description: "Broad spectrum SPF 30+ sunscreen for daily protection",
            iconName: "sun.max.fill",
            why: "Protects against UVA/UVB rays, prevents premature aging and skin cancer",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "mineral_sunscreen": ProductTypeInfo(
            name: "Mineral Sunscreen",
            description: "Physical sunscreen with zinc oxide for sensitive skin protection",
            iconName: "sun.max.fill",
            why: "Provides immediate protection and is gentle on sensitive skin",
            how: "Apply generously, blend well to avoid white cast",
            timeOfDay: "morning"
        ),
        
        // Treatments
        "spot_treatment": ProductTypeInfo(
            name: "Spot Treatment",
            description: "Targeted treatment for blemishes and acne spots",
            iconName: "target",
            why: "Reduces inflammation and speeds up healing of individual blemishes",
            how: "Apply a small amount directly to blemishes, avoid surrounding skin",
            timeOfDay: "evening"
        ),
        "exfoliating_mask": ProductTypeInfo(
            name: "Exfoliating Mask",
            description: "Weekly mask that removes dead skin cells and improves texture",
            iconName: "face.smiling",
            why: "Deep cleanses pores and reveals smoother, brighter skin",
            how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
            timeOfDay: "weekly"
        ),
        "hydrating_mask": ProductTypeInfo(
            name: "Hydrating Mask",
            description: "Intensive hydrating mask for plump, dewy skin",
            iconName: "face.smiling",
            why: "Provides deep hydration and improves skin's moisture retention",
            how: "Apply to clean skin, leave on for 15-20 minutes, rinse or remove",
            timeOfDay: "weekly"
        ),
        "clay_mask": ProductTypeInfo(
            name: "Clay Mask",
            description: "Purifying clay mask that draws out impurities and tightens pores",
            iconName: "face.smiling",
            why: "Absorbs excess oil and unclogs pores for clearer, tighter skin",
            how: "Apply to clean skin, leave on until dry, rinse with warm water",
            timeOfDay: "weekly"
        )
    ]
    
    // MARK: - Helper Methods
    
    static func getInfo(for stepName: String) -> ProductTypeInfo {
        let lowercased = stepName.lowercased()
        
        // Try exact matches first
        if let info = productTypes[lowercased] {
            return info
        }
        
        // Try partial matches
        for (key, info) in productTypes {
            if lowercased.contains(key) || key.contains(lowercased) {
                return info
            }
        }
        
        // Try keyword matching
        if lowercased.contains("cleanser") || lowercased.contains("cleanse") {
            return productTypes["gentle_cleanser"] ?? getDefaultInfo(for: "cleanser")
        } else if lowercased.contains("toner") {
            return productTypes["hydrating_toner"] ?? getDefaultInfo(for: "toner")
        } else if lowercased.contains("serum") || lowercased.contains("treatment") {
            if lowercased.contains("niacinamide") {
                return productTypes["niacinamide_serum"] ?? getDefaultInfo(for: "serum")
            } else if lowercased.contains("vitamin c") || lowercased.contains("vitamin_c") {
                return productTypes["vitamin_c_serum"] ?? getDefaultInfo(for: "serum")
            } else if lowercased.contains("retinol") {
                return productTypes["retinol_serum"] ?? getDefaultInfo(for: "serum")
            } else {
                return productTypes["niacinamide_serum"] ?? getDefaultInfo(for: "serum")
            }
        } else if lowercased.contains("moisturizer") || lowercased.contains("cream") {
            if lowercased.contains("night") {
                return productTypes["night_cream"] ?? getDefaultInfo(for: "moisturizer")
            } else {
                return productTypes["lightweight_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            }
        } else if lowercased.contains("sunscreen") || lowercased.contains("spf") {
            return productTypes["daily_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("mask") {
            if lowercased.contains("clay") {
                return productTypes["clay_mask"] ?? getDefaultInfo(for: "mask")
            } else {
                return productTypes["hydrating_mask"] ?? getDefaultInfo(for: "mask")
            }
        }
        
        // Default fallback
        return getDefaultInfo(for: "serum")
    }
    
    private static func getDefaultInfo(for type: String) -> ProductTypeInfo {
        switch type {
        case "cleanser":
            return ProductTypeInfo(
                name: "Cleanser",
                description: "Gentle cleanser that removes impurities and prepares skin",
                iconName: "drop.fill",
                why: "Removes dirt, oil, and makeup while maintaining skin's natural balance",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "toner":
            return ProductTypeInfo(
                name: "Toner",
                description: "Balancing toner that prepares skin for next steps",
                iconName: "drop.circle",
                why: "Restores pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "serum":
            return ProductTypeInfo(
                name: "Face Serum",
                description: "Targeted serum for your specific skin concerns",
                iconName: "star.fill",
                why: "Delivers active ingredients deep into the skin for maximum benefits",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "moisturizer":
            return ProductTypeInfo(
                name: "Moisturizer",
                description: "Hydrating moisturizer that locks in moisture",
                iconName: "drop.circle.fill",
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions",
                timeOfDay: "both"
            )
        case "sunscreen":
            return ProductTypeInfo(
                name: "Sunscreen",
                description: "Broad spectrum sunscreen for daily protection",
                iconName: "sun.max.fill",
                why: "Protects against UV damage and prevents premature aging",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "mask":
            return ProductTypeInfo(
                name: "Face Mask",
                description: "Weekly treatment mask for enhanced skin care",
                iconName: "face.smiling",
                why: "Provides intensive treatment and addresses specific skin concerns",
                how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
                timeOfDay: "weekly"
            )
        default:
            return ProductTypeInfo(
                name: "Skincare Step",
                description: "Important step in your skincare routine",
                iconName: "star.fill",
                why: "Part of your personalized skincare routine",
                how: "Follow the routine as recommended",
                timeOfDay: "both"
            )
        }
    }
    
    static func getIconName(for stepName: String) -> String {
        return getInfo(for: stepName).iconName
    }
    
    static func getStepType(for stepName: String) -> String {
        let lowercased = stepName.lowercased()
        if lowercased.contains("cleanser") || lowercased.contains("cleanse") {
            return "cleanser"
        } else if lowercased.contains("toner") {
            return "faceSerum"
        } else if lowercased.contains("serum") || lowercased.contains("treatment") {
            return "faceSerum"
        } else if lowercased.contains("moisturizer") || lowercased.contains("cream") {
            return "moisturizer"
        } else if lowercased.contains("sunscreen") || lowercased.contains("spf") {
            return "sunscreen"
        } else {
            return "faceSerum"
        }
    }
    
    static func getTimeOfDay(for stepName: String, index: Int, totalSteps: Int) -> String {
        let info = getInfo(for: stepName)
        if info.timeOfDay != "both" {
            return info.timeOfDay
        }
        
        // If it's a "both" product, determine based on position
        if index < totalSteps / 2 {
            return "morning"
        } else {
            return "evening"
        }
    }
}
