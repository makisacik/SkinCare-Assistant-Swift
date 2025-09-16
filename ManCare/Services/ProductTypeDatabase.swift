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
        "gentle_foaming_cleanser": ProductTypeInfo(
            name: "Gentle Foaming Cleanser",
            description: "Gentle foaming cleanser that cleans without irritation",
            iconName: "drop.fill",
            why: "Provides effective cleansing with a gentle formula that won't irritate sensitive skin",
            how: "Wet face, apply cleanser, massage gently in circular motions, rinse thoroughly",
            timeOfDay: "both"
        ),
        "water_based_cleanser": ProductTypeInfo(
            name: "Water-based Cleanser",
            description: "Gentle water-based cleanser for second cleansing step",
            iconName: "drop.fill",
            why: "Removes remaining impurities and prepares skin for treatment products",
            how: "Apply to damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "water_cleanser": ProductTypeInfo(
            name: "Water Cleanser",
            description: "Gentle water-based cleanser for second cleansing step",
            iconName: "drop.fill",
            why: "Removes remaining impurities and prepares skin for treatment products",
            how: "Apply to damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "gel_cleanser": ProductTypeInfo(
            name: "Gel Cleanser",
            description: "Lightweight gel cleanser that removes excess oil without over-drying",
            iconName: "drop.fill",
            why: "Effectively removes oil and impurities while maintaining skin's natural balance",
            how: "Apply to wet skin, massage gently, rinse thoroughly",
            timeOfDay: "both"
        ),
        "cream_cleanser": ProductTypeInfo(
            name: "Cream Cleanser",
            description: "Gentle cream cleanser that cleanses without stripping moisture",
            iconName: "drop.fill",
            why: "Provides gentle cleansing while maintaining skin's natural moisture barrier",
            how: "Apply to dry or damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "balancing_cleanser": ProductTypeInfo(
            name: "Balancing Cleanser",
            description: "Multi-purpose cleanser that balances different skin zones",
            iconName: "drop.fill",
            why: "Cleanses effectively without over-drying oily areas or stripping dry areas",
            how: "Apply to damp skin, massage gently, rinse thoroughly",
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
        "toner": ProductTypeInfo(
            name: "Toner",
            description: "Balancing toner that prepares skin for next steps",
            iconName: "drop.circle",
            why: "Restores skin's natural pH balance and enhances product absorption",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "soothing_toner": ProductTypeInfo(
            name: "Soothing Toner",
            description: "Calming toner that reduces irritation and redness",
            iconName: "drop.circle",
            why: "Soothes sensitive skin and reduces inflammation and redness",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "salicylic_acid_toner": ProductTypeInfo(
            name: "Salicylic Acid Toner",
            description: "BHA toner that unclogs pores and prevents breakouts",
            iconName: "drop.circle",
            why: "Penetrates pores to remove dead skin cells and prevent acne",
            how: "Apply with cotton pad, avoid eye area, use daily or as directed",
            timeOfDay: "both"
        ),
        "bha_toner": ProductTypeInfo(
            name: "BHA Toner",
            description: "Beta hydroxy acid toner that unclogs pores and smooths texture",
            iconName: "drop.circle",
            why: "Exfoliates inside pores to prevent breakouts and improve skin texture",
            how: "Apply with cotton pad, avoid eye area, start with 2-3 times per week",
            timeOfDay: "both"
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
        "serum": ProductTypeInfo(
            name: "Serum",
            description: "Concentrated treatment serum for targeted skin concerns",
            iconName: "star.fill",
            why: "Delivers active ingredients deep into skin for maximum effectiveness",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "face_serum": ProductTypeInfo(
            name: "Face Serum",
            description: "Targeted serum for your specific skin concerns",
            iconName: "star.fill",
            why: "Delivers active ingredients deep into skin for maximum effectiveness",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "hyaluronic_acid": ProductTypeInfo(
            name: "Hyaluronic Acid",
            description: "Intensive hydrating serum that plumps and smooths skin",
            iconName: "star.fill",
            why: "Attracts and retains moisture, plumping skin and reducing fine lines",
            how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
            timeOfDay: "both"
        ),
        "rich_serum": ProductTypeInfo(
            name: "Rich Serum",
            description: "Nourishing serum with concentrated active ingredients",
            iconName: "star.fill",
            why: "Provides intensive treatment with high concentrations of beneficial ingredients",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "lightweight_serum": ProductTypeInfo(
            name: "Lightweight Serum",
            description: "Fast-absorbing serum that doesn't feel heavy on skin",
            iconName: "star.fill",
            why: "Provides effective treatment without leaving a heavy or sticky feeling",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "peptide_complex": ProductTypeInfo(
            name: "Peptide Complex",
            description: "Advanced peptide treatment for skin structure support",
            iconName: "star.fill",
            why: "Supports skin's natural structure and improves firmness and elasticity",
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
        "moisturizer": ProductTypeInfo(
            name: "Moisturizer",
            description: "Essential moisturizer that hydrates and protects skin",
            iconName: "drop.circle.fill",
            why: "Maintains skin's moisture barrier and prevents water loss",
            how: "Apply a pea-sized amount, massage in upward circular motions",
            timeOfDay: "both"
        ),
        "heavy_moisturizer": ProductTypeInfo(
            name: "Heavy Moisturizer",
            description: "Rich, intensive moisturizer for deep hydration",
            iconName: "drop.circle.fill",
            why: "Provides maximum hydration for dry or mature skin",
            how: "Apply generously to face and neck, massage gently until absorbed",
            timeOfDay: "both"
        ),
        "adaptive_moisturizer": ProductTypeInfo(
            name: "Adaptive Moisturizer",
            description: "Versatile moisturizer that adapts to different skin zones",
            iconName: "drop.circle.fill",
            why: "Provides appropriate hydration for both oily and dry areas",
            how: "Apply more to dry areas, less to oily areas, massage gently",
            timeOfDay: "both"
        ),
        "barrier_repair_cream": ProductTypeInfo(
            name: "Barrier Repair Cream",
            description: "Specialized cream that strengthens the skin's protective barrier",
            iconName: "drop.circle.fill",
            why: "Repairs and strengthens the skin's natural protective barrier",
            how: "Apply to clean skin, massage gently until absorbed",
            timeOfDay: "both"
        ),
        "luxury_moisturizer": ProductTypeInfo(
            name: "Luxury Moisturizer",
            description: "Premium moisturizer with advanced anti-aging ingredients",
            iconName: "drop.circle.fill",
            why: "Provides luxurious hydration with high-end anti-aging benefits",
            how: "Apply generously to face and neck, massage in upward motions",
            timeOfDay: "both"
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
        "sunscreen": ProductTypeInfo(
            name: "Sunscreen",
            description: "Essential daily sunscreen for UV protection",
            iconName: "sun.max.fill",
            why: "Protects against harmful UV rays and prevents premature aging",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "oil_free_sunscreen": ProductTypeInfo(
            name: "Oil-free Sunscreen",
            description: "Non-greasy sunscreen that won't clog pores",
            iconName: "sun.max.fill",
            why: "Provides protection without adding shine or clogging pores",
            how: "Apply generously, blend well, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "broad_spectrum_sunscreen": ProductTypeInfo(
            name: "Broad Spectrum Sunscreen",
            description: "Complete UV protection against UVA and UVB rays",
            iconName: "sun.max.fill",
            why: "Protects against both aging UVA rays and burning UVB rays",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "anti_aging_sunscreen": ProductTypeInfo(
            name: "Anti-aging Sunscreen",
            description: "Sunscreen with additional anti-aging benefits",
            iconName: "sun.max.fill",
            why: "Provides UV protection while delivering anti-aging ingredients",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
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
        ),

        // Korean Skincare
        "essence": ProductTypeInfo(
            name: "Essence",
            description: "Lightweight hydrating essence that preps skin for treatment",
            iconName: "drop.circle",
            why: "Provides lightweight hydration and enhances absorption of subsequent products",
            how: "Apply with hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "treatment_essence": ProductTypeInfo(
            name: "Treatment Essence",
            description: "Advanced essence with concentrated active ingredients",
            iconName: "drop.circle",
            why: "Delivers high concentrations of beneficial ingredients in a lightweight format",
            how: "Apply with hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "ampoule": ProductTypeInfo(
            name: "Ampoule",
            description: "Highly concentrated treatment with maximum active ingredients",
            iconName: "star.fill",
            why: "Provides intensive treatment with the highest concentration of active ingredients",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "sheet_mask": ProductTypeInfo(
            name: "Sheet Mask",
            description: "Intensive treatment mask for deep hydration and nourishment",
            iconName: "face.smiling",
            why: "Provides intensive treatment with concentrated serum for maximum benefits",
            how: "Apply to clean skin, leave on for 15-20 minutes, remove and pat in remaining serum",
            timeOfDay: "weekly"
        ),
        "exfoliant": ProductTypeInfo(
            name: "Exfoliant",
            description: "Gentle chemical exfoliant that removes dead skin cells",
            iconName: "sparkles",
            why: "Removes dead skin cells and reveals brighter, smoother skin",
            how: "Apply to clean skin, avoid eye area, use 2-3 times per week",
            timeOfDay: "evening"
        ),

        // Eye Care
        "eye_cream": ProductTypeInfo(
            name: "Eye Cream",
            description: "Specialized cream for the delicate eye area",
            iconName: "eye.circle",
            why: "Targets fine lines, dark circles, and puffiness in the delicate eye area",
            how: "Apply a small amount with ring finger, pat gently around eye area",
            timeOfDay: "both"
        ),
        "rich_eye_cream": ProductTypeInfo(
            name: "Rich Eye Cream",
            description: "Intensive eye cream for mature or dry eye area",
            iconName: "eye.circle",
            why: "Provides intensive hydration and anti-aging benefits for the eye area",
            how: "Apply a small amount with ring finger, pat gently around eye area",
            timeOfDay: "both"
        ),

        // Facial Oils
        "facial_oil": ProductTypeInfo(
            name: "Facial Oil",
            description: "Nourishing facial oil for extra hydration and glow",
            iconName: "drop.triangle",
            why: "Provides deep nourishment and creates a healthy glow",
            how: "Apply 2-3 drops to face and neck, massage gently until absorbed",
            timeOfDay: "evening"
        ),

        // Retinol Treatments
        "retinol_treatment": ProductTypeInfo(
            name: "Retinol Treatment",
            description: "Anti-aging retinol treatment for skin renewal",
            iconName: "star.fill",
            why: "Stimulates cell turnover and collagen production for younger-looking skin",
            how: "Start with 2-3 times per week, apply at night, avoid eye area",
            timeOfDay: "evening"
        ),

        // Zone-specific Treatments
        "zone_specific_treatment": ProductTypeInfo(
            name: "Zone-specific Treatment",
            description: "Targeted treatment for different skin zones",
            iconName: "target",
            why: "Addresses different concerns in different areas of the face",
            how: "Apply to specific areas as needed, follow product instructions",
            timeOfDay: "both"
        )
    ]
    
    // MARK: - Helper Methods
    
    static func getInfo(for stepName: String) -> ProductTypeInfo {
        let lowercased = stepName.lowercased()
        
        // Try exact matches first
        if let info = productTypes[lowercased] {
            return info
        }
        
        // Try specific keyword matching first (more specific patterns)
        if lowercased.contains("eye") && lowercased.contains("cream") {
            if lowercased.contains("rich") {
                return productTypes["rich_eye_cream"] ?? getDefaultInfo(for: "eye_cream")
            } else {
                return productTypes["eye_cream"] ?? getDefaultInfo(for: "eye_cream")
            }
        } else if lowercased.contains("sheet") && lowercased.contains("mask") {
            return productTypes["sheet_mask"] ?? getDefaultInfo(for: "mask")
        } else if lowercased.contains("facial") && lowercased.contains("oil") {
            return productTypes["facial_oil"] ?? getDefaultInfo(for: "facial_oil")
        } else if lowercased.contains("zone") && lowercased.contains("specific") {
            return productTypes["zone_specific_treatment"] ?? getDefaultInfo(for: "treatment")
        } else if lowercased.contains("spot") || lowercased.contains("acne") {
            return productTypes["spot_treatment"] ?? getDefaultInfo(for: "treatment")
        } else if lowercased.contains("retinol") && lowercased.contains("treatment") {
            return productTypes["retinol_treatment"] ?? getDefaultInfo(for: "treatment")
        } else if lowercased.contains("peptide") && lowercased.contains("complex") {
            return productTypes["peptide_complex"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("broad") && lowercased.contains("spectrum") {
            return productTypes["broad_spectrum_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("oil") && lowercased.contains("free") && lowercased.contains("sunscreen") {
            return productTypes["oil_free_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("anti") && lowercased.contains("aging") && lowercased.contains("sunscreen") {
            return productTypes["anti_aging_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("barrier") && lowercased.contains("repair") {
            return productTypes["barrier_repair_cream"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("water") && lowercased.contains("based") && lowercased.contains("cleanser") {
            return productTypes["water_based_cleanser"] ?? getDefaultInfo(for: "cleanser")
        } else if lowercased.contains("gentle") && lowercased.contains("foaming") {
            return productTypes["gentle_foaming_cleanser"] ?? getDefaultInfo(for: "cleanser")
        } else if lowercased.contains("oil") && lowercased.contains("cleanser") {
            return productTypes["oil_cleanser"] ?? getDefaultInfo(for: "cleanser")
        } else if lowercased.contains("salicylic") && lowercased.contains("acid") {
            return productTypes["salicylic_acid_toner"] ?? getDefaultInfo(for: "toner")
        } else if lowercased.contains("treatment") && lowercased.contains("essence") {
            return productTypes["treatment_essence"] ?? getDefaultInfo(for: "essence")
        } else if lowercased.contains("face") && lowercased.contains("serum") {
            return productTypes["face_serum"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("vitamin c") || lowercased.contains("vitamin_c") {
            return productTypes["vitamin_c_serum"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("hyaluronic") {
            return productTypes["hyaluronic_acid"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("peptide") && lowercased.contains("serum") {
            return productTypes["peptide_serum"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("retinol") && lowercased.contains("treatment") {
            return productTypes["retinol_treatment"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("rich") && lowercased.contains("eye") {
            return productTypes["rich_eye_cream"] ?? getDefaultInfo(for: "eye_cream")
        } else if lowercased.contains("rich") && lowercased.contains("serum") {
            return productTypes["rich_serum"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("rich") && lowercased.contains("moisturizer") {
            return productTypes["rich_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("lightweight") && lowercased.contains("serum") {
            return productTypes["lightweight_serum"] ?? getDefaultInfo(for: "serum")
        } else if lowercased.contains("lightweight") && lowercased.contains("moisturizer") {
            return productTypes["lightweight_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("heavy") && lowercased.contains("moisturizer") {
            return productTypes["heavy_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("luxury") && lowercased.contains("moisturizer") {
            return productTypes["luxury_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("adaptive") && lowercased.contains("moisturizer") {
            return productTypes["adaptive_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
        } else if lowercased.contains("soothing") && lowercased.contains("toner") {
            return productTypes["soothing_toner"] ?? getDefaultInfo(for: "toner")
        } else if lowercased.contains("hydrating") && lowercased.contains("toner") {
            return productTypes["hydrating_toner"] ?? getDefaultInfo(for: "toner")
        } else if lowercased.contains("hydrating") && lowercased.contains("mask") {
            return productTypes["hydrating_mask"] ?? getDefaultInfo(for: "mask")
        } else if lowercased.contains("exfoliating") && lowercased.contains("toner") {
            return productTypes["exfoliating_toner"] ?? getDefaultInfo(for: "toner")
        } else if lowercased.contains("exfoliating") && lowercased.contains("mask") {
            return productTypes["exfoliating_mask"] ?? getDefaultInfo(for: "mask")
        } else if lowercased.contains("clay") && lowercased.contains("mask") {
            return productTypes["clay_mask"] ?? getDefaultInfo(for: "mask")
        } else if lowercased.contains("mineral") && lowercased.contains("sunscreen") {
            return productTypes["mineral_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("daily") && lowercased.contains("sunscreen") {
            return productTypes["daily_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
        } else if lowercased.contains("night") && lowercased.contains("cream") {
            return productTypes["night_cream"] ?? getDefaultInfo(for: "moisturizer")
        }

        // Try partial matches (less specific)
        for (key, info) in productTypes {
            if lowercased.contains(key) || key.contains(lowercased) {
                return info
            }
        }
        
        // Try keyword matching with improved logic
        if lowercased.contains("cleanser") || lowercased.contains("cleanse") {
            if lowercased.contains("water") && lowercased.contains("based") {
                return productTypes["water_based_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else if lowercased.contains("water") && !lowercased.contains("based") {
                return productTypes["water_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else if lowercased.contains("foam") || lowercased.contains("foaming") {
                return productTypes["foaming_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else if lowercased.contains("gel") {
                return productTypes["gel_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else if lowercased.contains("cream") {
                return productTypes["cream_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else if lowercased.contains("balancing") {
                return productTypes["balancing_cleanser"] ?? getDefaultInfo(for: "cleanser")
            } else {
            return productTypes["gentle_cleanser"] ?? getDefaultInfo(for: "cleanser")
            }
        } else if lowercased.contains("toner") {
            if lowercased.contains("salicylic") {
                return productTypes["salicylic_acid_toner"] ?? getDefaultInfo(for: "toner")
            } else if lowercased.contains("bha") {
                return productTypes["bha_toner"] ?? getDefaultInfo(for: "toner")
            } else if lowercased.contains("soothing") {
                return productTypes["soothing_toner"] ?? getDefaultInfo(for: "toner")
            } else if lowercased.contains("hydrating") {
            return productTypes["hydrating_toner"] ?? getDefaultInfo(for: "toner")
            } else {
                return productTypes["toner"] ?? getDefaultInfo(for: "toner")
            }
        } else if lowercased.contains("essence") {
            if lowercased.contains("treatment") {
                return productTypes["treatment_essence"] ?? getDefaultInfo(for: "essence")
            } else {
                return productTypes["essence"] ?? getDefaultInfo(for: "essence")
            }
        } else if lowercased.contains("ampoule") {
            return productTypes["ampoule"] ?? getDefaultInfo(for: "ampoule")
        } else if lowercased.contains("serum") || lowercased.contains("treatment") {
            if lowercased.contains("niacinamide") {
                return productTypes["niacinamide_serum"] ?? getDefaultInfo(for: "serum")
            } else if lowercased.contains("peptide") {
                if lowercased.contains("complex") {
                    return productTypes["peptide_complex"] ?? getDefaultInfo(for: "serum")
                } else {
                    return productTypes["peptide_serum"] ?? getDefaultInfo(for: "serum")
                }
            } else if lowercased.contains("rich") {
                return productTypes["rich_serum"] ?? getDefaultInfo(for: "serum")
            } else if lowercased.contains("lightweight") {
                return productTypes["lightweight_serum"] ?? getDefaultInfo(for: "serum")
            } else if lowercased.contains("face") {
                return productTypes["face_serum"] ?? getDefaultInfo(for: "serum")
            } else {
                return productTypes["serum"] ?? getDefaultInfo(for: "serum")
            }
        } else if lowercased.contains("moisturizer") || lowercased.contains("moisturiser") || lowercased.contains("cream") {
            if lowercased.contains("heavy") {
                return productTypes["heavy_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("rich") {
                return productTypes["rich_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("luxury") {
                return productTypes["luxury_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("adaptive") {
                return productTypes["adaptive_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("lightweight") {
                return productTypes["lightweight_moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("night") {
                return productTypes["night_cream"] ?? getDefaultInfo(for: "moisturizer")
            } else if lowercased.contains("barrier") && lowercased.contains("repair") {
                return productTypes["barrier_repair_cream"] ?? getDefaultInfo(for: "moisturizer")
            } else {
                return productTypes["moisturizer"] ?? getDefaultInfo(for: "moisturizer")
            }
        } else if lowercased.contains("sunscreen") || lowercased.contains("spf") {
            if lowercased.contains("mineral") {
                return productTypes["mineral_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
            } else if lowercased.contains("oil") && lowercased.contains("free") {
                return productTypes["oil_free_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
            } else if lowercased.contains("broad") && lowercased.contains("spectrum") {
                return productTypes["broad_spectrum_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
            } else if lowercased.contains("anti") && lowercased.contains("aging") {
                return productTypes["anti_aging_sunscreen"] ?? getDefaultInfo(for: "sunscreen")
            } else {
                return productTypes["sunscreen"] ?? getDefaultInfo(for: "sunscreen")
            }
        } else if lowercased.contains("mask") {
            if lowercased.contains("clay") {
                return productTypes["clay_mask"] ?? getDefaultInfo(for: "mask")
            } else if lowercased.contains("hydrating") {
                return productTypes["hydrating_mask"] ?? getDefaultInfo(for: "mask")
            } else if lowercased.contains("exfoliating") {
                return productTypes["exfoliating_mask"] ?? getDefaultInfo(for: "mask")
            } else {
                return productTypes["hydrating_mask"] ?? getDefaultInfo(for: "mask")
            }
        } else if lowercased.contains("exfoliant") {
            return productTypes["exfoliant"] ?? getDefaultInfo(for: "exfoliant")
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
        case "face_serum":
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
        case "essence":
            return ProductTypeInfo(
                name: "Essence",
                description: "Lightweight hydrating essence that preps skin for treatment",
                iconName: "drop.circle",
                why: "Provides lightweight hydration and enhances absorption of subsequent products",
                how: "Apply with hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "ampoule":
            return ProductTypeInfo(
                name: "Ampoule",
                description: "Highly concentrated treatment with maximum active ingredients",
                iconName: "star.fill",
                why: "Provides intensive treatment with the highest concentration of active ingredients",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "exfoliant":
            return ProductTypeInfo(
                name: "Exfoliant",
                description: "Gentle chemical exfoliant that removes dead skin cells",
                iconName: "sparkles",
                why: "Removes dead skin cells and reveals brighter, smoother skin",
                how: "Apply to clean skin, avoid eye area, use 2-3 times per week",
                timeOfDay: "evening"
            )
        case "eye_cream":
            return ProductTypeInfo(
                name: "Eye Cream",
                description: "Specialized cream for the delicate eye area",
                iconName: "eye.circle",
                why: "Targets fine lines, dark circles, and puffiness in the delicate eye area",
                how: "Apply a small amount with ring finger, pat gently around eye area",
                timeOfDay: "both"
            )
        case "facial_oil":
            return ProductTypeInfo(
                name: "Facial Oil",
                description: "Nourishing facial oil for extra hydration and glow",
                iconName: "drop.triangle",
                why: "Provides deep nourishment and creates a healthy glow",
                how: "Apply 2-3 drops to face and neck, massage gently until absorbed",
                timeOfDay: "evening"
            )
        case "treatment":
            return ProductTypeInfo(
                name: "Treatment",
                description: "Targeted treatment for specific skin concerns",
                iconName: "target",
                why: "Addresses specific skin concerns with concentrated active ingredients",
                how: "Apply as directed, follow product instructions for best results",
                timeOfDay: "both"
            )
        case "water_cleanser":
            return ProductTypeInfo(
                name: "Water Cleanser",
                description: "Gentle water-based cleanser for second cleansing step",
                iconName: "drop.fill",
                why: "Removes remaining impurities and prepares skin for treatment products",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "gel_cleanser":
            return ProductTypeInfo(
                name: "Gel Cleanser",
                description: "Lightweight gel cleanser that removes excess oil without over-drying",
                iconName: "drop.fill",
                why: "Effectively removes oil and impurities while maintaining skin's natural balance",
                how: "Apply to wet skin, massage gently, rinse thoroughly",
                timeOfDay: "both"
            )
        case "cream_cleanser":
            return ProductTypeInfo(
                name: "Cream Cleanser",
                description: "Gentle cream cleanser that cleanses without stripping moisture",
                iconName: "drop.fill",
                why: "Provides gentle cleansing while maintaining skin's natural moisture barrier",
                how: "Apply to dry or damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "balancing_cleanser":
            return ProductTypeInfo(
                name: "Balancing Cleanser",
                description: "Multi-purpose cleanser that balances different skin zones",
                iconName: "drop.fill",
                why: "Cleanses effectively without over-drying oily areas or stripping dry areas",
                how: "Apply to damp skin, massage gently, rinse thoroughly",
                timeOfDay: "both"
            )
        case "soothing_toner":
            return ProductTypeInfo(
                name: "Soothing Toner",
                description: "Calming toner that reduces irritation and redness",
                iconName: "drop.circle",
                why: "Soothes sensitive skin and reduces inflammation and redness",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "salicylic_acid_toner":
            return ProductTypeInfo(
                name: "Salicylic Acid Toner",
                description: "BHA toner that unclogs pores and prevents breakouts",
                iconName: "drop.circle",
                why: "Penetrates pores to remove dead skin cells and prevent acne",
                how: "Apply with cotton pad, avoid eye area, use daily or as directed",
                timeOfDay: "both"
            )
        case "bha_toner":
            return ProductTypeInfo(
                name: "BHA Toner",
                description: "Beta hydroxy acid toner that unclogs pores and smooths texture",
                iconName: "drop.circle",
                why: "Exfoliates inside pores to prevent breakouts and improve skin texture",
                how: "Apply with cotton pad, avoid eye area, start with 2-3 times per week",
                timeOfDay: "both"
            )
        case "treatment_essence":
            return ProductTypeInfo(
                name: "Treatment Essence",
                description: "Advanced essence with concentrated active ingredients",
                iconName: "drop.circle",
                why: "Delivers high concentrations of beneficial ingredients in a lightweight format",
                how: "Apply with hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "rich_serum":
            return ProductTypeInfo(
                name: "Rich Serum",
                description: "Nourishing serum with concentrated active ingredients",
                iconName: "star.fill",
                why: "Provides intensive treatment with high concentrations of beneficial ingredients",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "lightweight_serum":
            return ProductTypeInfo(
                name: "Lightweight Serum",
                description: "Fast-absorbing serum that doesn't feel heavy on skin",
                iconName: "star.fill",
                why: "Provides effective treatment without leaving a heavy or sticky feeling",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "peptide_complex":
            return ProductTypeInfo(
                name: "Peptide Complex",
                description: "Advanced peptide treatment for skin structure support",
                iconName: "star.fill",
                why: "Supports skin's natural structure and improves firmness and elasticity",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "heavy_moisturizer":
            return ProductTypeInfo(
                name: "Heavy Moisturizer",
                description: "Rich, intensive moisturizer for deep hydration",
                iconName: "drop.circle.fill",
                why: "Provides maximum hydration for dry or mature skin",
                how: "Apply generously to face and neck, massage gently until absorbed",
                timeOfDay: "both"
            )
        case "adaptive_moisturizer":
            return ProductTypeInfo(
                name: "Adaptive Moisturizer",
                description: "Versatile moisturizer that adapts to different skin zones",
                iconName: "drop.circle.fill",
                why: "Provides appropriate hydration for both oily and dry areas",
                how: "Apply more to dry areas, less to oily areas, massage gently",
                timeOfDay: "both"
            )
        case "barrier_repair_cream":
            return ProductTypeInfo(
                name: "Barrier Repair Cream",
                description: "Specialized cream that strengthens the skin's protective barrier",
                iconName: "drop.circle.fill",
                why: "Repairs and strengthens the skin's natural protective barrier",
                how: "Apply to clean skin, massage gently until absorbed",
                timeOfDay: "both"
            )
        case "luxury_moisturizer":
            return ProductTypeInfo(
                name: "Luxury Moisturizer",
                description: "Premium moisturizer with advanced anti-aging ingredients",
                iconName: "drop.circle.fill",
                why: "Provides luxurious hydration with high-end anti-aging benefits",
                how: "Apply generously to face and neck, massage in upward motions",
                timeOfDay: "both"
            )
        case "oil_free_sunscreen":
            return ProductTypeInfo(
                name: "Oil-free Sunscreen",
                description: "Non-greasy sunscreen that won't clog pores",
                iconName: "sun.max.fill",
                why: "Provides protection without adding shine or clogging pores",
                how: "Apply generously, blend well, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "broad_spectrum_sunscreen":
            return ProductTypeInfo(
                name: "Broad Spectrum Sunscreen",
                description: "Complete UV protection against UVA and UVB rays",
                iconName: "sun.max.fill",
                why: "Protects against both aging UVA rays and burning UVB rays",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "anti_aging_sunscreen":
            return ProductTypeInfo(
                name: "Anti-aging Sunscreen",
                description: "Sunscreen with additional anti-aging benefits",
                iconName: "sun.max.fill",
                why: "Provides UV protection while delivering anti-aging ingredients",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "rich_eye_cream":
            return ProductTypeInfo(
                name: "Rich Eye Cream",
                description: "Intensive eye cream for mature or dry eye area",
                iconName: "eye.circle",
                why: "Provides intensive hydration and anti-aging benefits for the eye area",
                how: "Apply a small amount with ring finger, pat gently around eye area",
                timeOfDay: "both"
            )
        case "sheet_mask":
            return ProductTypeInfo(
                name: "Sheet Mask",
                description: "Intensive treatment mask for deep hydration and nourishment",
                iconName: "face.smiling",
                why: "Provides intensive treatment with concentrated serum for maximum benefits",
                how: "Apply to clean skin, leave on for 15-20 minutes, remove and pat in remaining serum",
                timeOfDay: "weekly"
            )
        case "retinol_treatment":
            return ProductTypeInfo(
                name: "Retinol Treatment",
                description: "Anti-aging retinol treatment for skin renewal",
                iconName: "star.fill",
                why: "Stimulates cell turnover and collagen production for younger-looking skin",
                how: "Start with 2-3 times per week, apply at night, avoid eye area",
                timeOfDay: "evening"
            )
        case "zone_specific_treatment":
            return ProductTypeInfo(
                name: "Zone-specific Treatment",
                description: "Targeted treatment for different skin zones",
                iconName: "target",
                why: "Addresses different concerns in different areas of the face",
                how: "Apply to specific areas as needed, follow product instructions",
                timeOfDay: "both"
            )
        case "gentle_cleanser":
            return ProductTypeInfo(
                name: "Gentle Cleanser",
                description: "Oil-free gel cleanser that removes impurities without stripping the skin",
                iconName: "drop.fill",
                why: "Removes overnight oil buildup, makeup, and daily pollutants while maintaining skin's natural moisture barrier",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "foaming_cleanser":
            return ProductTypeInfo(
                name: "Foaming Cleanser",
                description: "Lightweight foaming cleanser for deep pore cleansing",
                iconName: "drop.fill",
                why: "Creates rich lather to remove excess oil and unclog pores without over-drying",
                how: "Wet face, apply cleanser, massage in circular motions, rinse thoroughly",
                timeOfDay: "both"
            )
        case "gentle_foaming_cleanser":
            return ProductTypeInfo(
                name: "Gentle Foaming Cleanser",
                description: "Gentle foaming cleanser that cleans without irritation",
                iconName: "drop.fill",
                why: "Provides effective cleansing with a gentle formula that won't irritate sensitive skin",
                how: "Wet face, apply cleanser, massage gently in circular motions, rinse thoroughly",
                timeOfDay: "both"
            )
        case "water_based_cleanser":
            return ProductTypeInfo(
                name: "Water-based Cleanser",
                description: "Gentle water-based cleanser for second cleansing step",
                iconName: "drop.fill",
                why: "Removes remaining impurities and prepares skin for treatment products",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "oil_cleanser":
            return ProductTypeInfo(
                name: "Oil Cleanser",
                description: "Gentle oil-based cleanser for effective makeup and sunscreen removal",
                iconName: "drop.fill",
                why: "Oil dissolves oil, making it perfect for removing waterproof makeup and sunscreen",
                how: "Apply to dry skin, massage gently, add water to emulsify, rinse completely",
                timeOfDay: "evening"
            )
        case "hydrating_toner":
            return ProductTypeInfo(
                name: "Hydrating Toner",
                description: "Alcohol-free toner that balances pH and provides instant hydration",
                iconName: "drop.circle",
                why: "Restores skin's natural pH balance and prepares skin for better product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "exfoliating_toner":
            return ProductTypeInfo(
                name: "Exfoliating Toner",
                description: "Gentle exfoliating toner with AHA/BHA for smoother skin texture",
                iconName: "drop.circle",
                why: "Removes dead skin cells and unclogs pores for brighter, smoother skin",
                how: "Apply with cotton pad, avoid eye area, use 2-3 times per week",
                timeOfDay: "evening"
            )
        case "niacinamide_serum":
            return ProductTypeInfo(
                name: "Niacinamide Serum",
                description: "Vitamin B3 serum that minimizes pores and controls oil production",
                iconName: "star.fill",
                why: "Reduces pore size, controls sebum production, and improves skin texture",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "vitamin_c_serum":
            return ProductTypeInfo(
                name: "Vitamin C Serum",
                description: "Antioxidant serum that brightens skin and protects against environmental damage",
                iconName: "star.fill",
                why: "Neutralizes free radicals, brightens skin tone, and boosts collagen production",
                how: "Apply 2-3 drops in the morning, pat gently, follow with sunscreen",
                timeOfDay: "morning"
            )
        case "hyaluronic_acid_serum":
            return ProductTypeInfo(
                name: "Hyaluronic Acid Serum",
                description: "Intensive hydrating serum that plumps and smooths skin",
                iconName: "star.fill",
                why: "Attracts and retains moisture, plumping skin and reducing fine lines",
                how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
                timeOfDay: "both"
            )
        case "retinol_serum":
            return ProductTypeInfo(
                name: "Retinol Serum",
                description: "Anti-aging serum that promotes cell turnover and reduces signs of aging",
                iconName: "star.fill",
                why: "Stimulates collagen production, reduces fine lines, and improves skin texture",
                how: "Start with 2-3 times per week, apply at night, avoid eye area",
                timeOfDay: "evening"
            )
        case "peptide_serum":
            return ProductTypeInfo(
                name: "Peptide Serum",
                description: "Anti-aging serum with peptides for firmer, more youthful skin",
                iconName: "star.fill",
                why: "Stimulates collagen production and improves skin firmness and elasticity",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "lightweight_moisturizer":
            return ProductTypeInfo(
                name: "Lightweight Moisturizer",
                description: "Oil-free gel moisturizer that hydrates without clogging pores",
                iconName: "drop.circle.fill",
                why: "Provides essential hydration while maintaining a matte finish",
                how: "Apply a pea-sized amount, massage in upward circular motions",
                timeOfDay: "both"
            )
        case "rich_moisturizer":
            return ProductTypeInfo(
                name: "Rich Moisturizer",
                description: "Nourishing cream moisturizer for deep hydration and skin repair",
                iconName: "drop.circle.fill",
                why: "Provides intensive hydration and supports overnight skin repair",
                how: "Apply generously to face and neck, massage gently until absorbed",
                timeOfDay: "evening"
            )
        case "night_cream":
            return ProductTypeInfo(
                name: "Night Cream",
                description: "Intensive night cream that repairs and rejuvenates while you sleep",
                iconName: "moon.circle.fill",
                why: "Works with your skin's natural repair cycle to restore and rejuvenate",
                how: "Apply generously before bed, massage in upward motions",
                timeOfDay: "evening"
            )
        case "daily_sunscreen":
            return ProductTypeInfo(
                name: "Daily Sunscreen",
                description: "Broad spectrum SPF 30+ sunscreen for daily protection",
                iconName: "sun.max.fill",
                why: "Protects against UVA/UVB rays, prevents premature aging and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "mineral_sunscreen":
            return ProductTypeInfo(
                name: "Mineral Sunscreen",
                description: "Physical sunscreen with zinc oxide for sensitive skin protection",
                iconName: "sun.max.fill",
                why: "Provides immediate protection and is gentle on sensitive skin",
                how: "Apply generously, blend well to avoid white cast",
                timeOfDay: "morning"
            )
        case "spot_treatment":
            return ProductTypeInfo(
                name: "Spot Treatment",
                description: "Targeted treatment for blemishes and acne spots",
                iconName: "target",
                why: "Reduces inflammation and speeds up healing of individual blemishes",
                how: "Apply a small amount directly to blemishes, avoid surrounding skin",
                timeOfDay: "evening"
            )
        case "exfoliating_mask":
            return ProductTypeInfo(
                name: "Exfoliating Mask",
                description: "Weekly mask that removes dead skin cells and improves texture",
                iconName: "face.smiling",
                why: "Deep cleanses pores and reveals smoother, brighter skin",
                how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
                timeOfDay: "weekly"
            )
        case "hydrating_mask":
            return ProductTypeInfo(
                name: "Hydrating Mask",
                description: "Intensive hydrating mask for plump, dewy skin",
                iconName: "face.smiling",
                why: "Provides deep hydration and improves skin's moisture retention",
                how: "Apply to clean skin, leave on for 15-20 minutes, rinse or remove",
                timeOfDay: "weekly"
            )
        case "clay_mask":
            return ProductTypeInfo(
                name: "Clay Mask",
                description: "Purifying clay mask that draws out impurities and tightens pores",
                iconName: "face.smiling",
                why: "Absorbs excess oil and unclogs pores for clearer, tighter skin",
                how: "Apply to clean skin, leave on until dry, rinse with warm water",
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
