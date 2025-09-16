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
        let why: String
        let how: String
        let timeOfDay: String
    }

    // MARK: - Caching

    private static var cache: [String: ProductTypeInfo] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.mancare.producttypecache", attributes: .concurrent)

    // MARK: - Database

    static let productTypes: [String: ProductTypeInfo] = [
        // Cleansers
        "gentle_cleanser": ProductTypeInfo(
            name: "Gentle Cleanser",
            description: "Oil-free gel cleanser that removes impurities without stripping the skin",
            why: "Removes overnight oil buildup, makeup, and daily pollutants while maintaining skin's natural moisture barrier",
            how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "foaming_cleanser": ProductTypeInfo(
            name: "Foaming Cleanser",
            description: "Lightweight foaming cleanser for deep pore cleansing",
            why: "Creates rich lather to remove excess oil and unclog pores without over-drying",
            how: "Wet face, apply cleanser, massage in circular motions, rinse thoroughly",
            timeOfDay: "both"
        ),
        "gentle_foaming_cleanser": ProductTypeInfo(
            name: "Gentle Foaming Cleanser",
            description: "Gentle foaming cleanser that cleans without irritation",
            why: "Provides effective cleansing with a gentle formula that won't irritate sensitive skin",
            how: "Wet face, apply cleanser, massage gently in circular motions, rinse thoroughly",
            timeOfDay: "both"
        ),
        "water_based_cleanser": ProductTypeInfo(
            name: "Water-based Cleanser",
            description: "Gentle water-based cleanser for second cleansing step",
            why: "Removes remaining impurities and prepares skin for treatment products",
            how: "Apply to damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "water_cleanser": ProductTypeInfo(
            name: "Water Cleanser",
            description: "Gentle water-based cleanser for second cleansing step",
            why: "Removes remaining impurities and prepares skin for treatment products",
            how: "Apply to damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "gel_cleanser": ProductTypeInfo(
            name: "Gel Cleanser",
            description: "Lightweight gel cleanser that removes excess oil without over-drying",
            why: "Effectively removes oil and impurities while maintaining skin's natural balance",
            how: "Apply to wet skin, massage gently, rinse thoroughly",
            timeOfDay: "both"
        ),
        "cream_cleanser": ProductTypeInfo(
            name: "Cream Cleanser",
            description: "Gentle cream cleanser that cleanses without stripping moisture",
            why: "Provides gentle cleansing while maintaining skin's natural moisture barrier",
            how: "Apply to dry or damp skin, massage gently, rinse with lukewarm water",
            timeOfDay: "both"
        ),
        "balancing_cleanser": ProductTypeInfo(
            name: "Balancing Cleanser",
            description: "Multi-purpose cleanser that balances different skin zones",
            why: "Cleanses effectively without over-drying oily areas or stripping dry areas",
            how: "Apply to damp skin, massage gently, rinse thoroughly",
            timeOfDay: "both"
        ),
        "oil_cleanser": ProductTypeInfo(
            name: "Oil Cleanser",
            description: "Gentle oil-based cleanser for effective makeup and sunscreen removal",
            why: "Oil dissolves oil, making it perfect for removing waterproof makeup and sunscreen",
            how: "Apply to dry skin, massage gently, add water to emulsify, rinse completely",
            timeOfDay: "evening"
        ),

        // Toners
        "hydrating_toner": ProductTypeInfo(
            name: "Hydrating Toner",
            description: "Alcohol-free toner that balances pH and provides instant hydration",
            why: "Restores skin's natural pH balance and prepares skin for better product absorption",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "exfoliating_toner": ProductTypeInfo(
            name: "Exfoliating Toner",
            description: "Gentle exfoliating toner with AHA/BHA for smoother skin texture",
            why: "Removes dead skin cells and unclogs pores for brighter, smoother skin",
            how: "Apply with cotton pad, avoid eye area, use 2-3 times per week",
            timeOfDay: "evening"
        ),
        "toner": ProductTypeInfo(
            name: "Toner",
            description: "Balancing toner that prepares skin for next steps",
            why: "Restores skin's natural pH balance and enhances product absorption",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "soothing_toner": ProductTypeInfo(
            name: "Soothing Toner",
            description: "Calming toner that reduces irritation and redness",
            why: "Soothes sensitive skin and reduces inflammation and redness",
            how: "Apply with cotton pad or hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "salicylic_acid_toner": ProductTypeInfo(
            name: "Salicylic Acid Toner",
            description: "BHA toner that unclogs pores and prevents breakouts",
            why: "Penetrates pores to remove dead skin cells and prevent acne",
            how: "Apply with cotton pad, avoid eye area, use daily or as directed",
            timeOfDay: "both"
        ),
        "bha_toner": ProductTypeInfo(
            name: "BHA Toner",
            description: "Beta hydroxy acid toner that unclogs pores and smooths texture",
            why: "Exfoliates inside pores to prevent breakouts and improve skin texture",
            how: "Apply with cotton pad, avoid eye area, start with 2-3 times per week",
            timeOfDay: "both"
        ),

        // Serums
        "niacinamide_serum": ProductTypeInfo(
            name: "Niacinamide Serum",
            description: "Vitamin B3 serum that minimizes pores and controls oil production",
            why: "Reduces pore size, controls sebum production, and improves skin texture",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "vitamin_c_serum": ProductTypeInfo(
            name: "Vitamin C Serum",
            description: "Antioxidant serum that brightens skin and protects against environmental damage",
            why: "Neutralizes free radicals, brightens skin tone, and boosts collagen production",
            how: "Apply 2-3 drops in the morning, pat gently, follow with sunscreen",
            timeOfDay: "morning"
        ),
        "hyaluronic_acid_serum": ProductTypeInfo(
            name: "Hyaluronic Acid Serum",
            description: "Intensive hydrating serum that plumps and smooths skin",
            why: "Attracts and retains moisture, plumping skin and reducing fine lines",
            how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
            timeOfDay: "both"
        ),
        "retinol_serum": ProductTypeInfo(
            name: "Retinol Serum",
            description: "Anti-aging serum that promotes cell turnover and reduces signs of aging",
            why: "Stimulates collagen production, reduces fine lines, and improves skin texture",
            how: "Start with 2-3 times per week, apply at night, avoid eye area",
            timeOfDay: "evening"
        ),
        "peptide_serum": ProductTypeInfo(
            name: "Peptide Serum",
            description: "Anti-aging serum with peptides for firmer, more youthful skin",
            why: "Stimulates collagen production and improves skin firmness and elasticity",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "serum": ProductTypeInfo(
            name: "Serum",
            description: "Concentrated treatment serum for targeted skin concerns",
            why: "Delivers active ingredients deep into skin for maximum effectiveness",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "face_serum": ProductTypeInfo(
            name: "Face Serum",
            description: "Targeted serum for your specific skin concerns",
            why: "Delivers active ingredients deep into skin for maximum effectiveness",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "hyaluronic_acid": ProductTypeInfo(
            name: "Hyaluronic Acid",
            description: "Intensive hydrating serum that plumps and smooths skin",
            why: "Attracts and retains moisture, plumping skin and reducing fine lines",
            how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
            timeOfDay: "both"
        ),
        "rich_serum": ProductTypeInfo(
            name: "Rich Serum",
            description: "Nourishing serum with concentrated active ingredients",
            why: "Provides intensive treatment with high concentrations of beneficial ingredients",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "lightweight_serum": ProductTypeInfo(
            name: "Lightweight Serum",
            description: "Fast-absorbing serum that doesn't feel heavy on skin",
            why: "Provides effective treatment without leaving a heavy or sticky feeling",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "peptide_complex": ProductTypeInfo(
            name: "Peptide Complex",
            description: "Advanced peptide treatment for skin structure support",
            why: "Supports skin's natural structure and improves firmness and elasticity",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),

        // Moisturizers
        "lightweight_moisturizer": ProductTypeInfo(
            name: "Lightweight Moisturizer",
            description: "Oil-free gel moisturizer that hydrates without clogging pores",
            why: "Provides essential hydration while maintaining a matte finish",
            how: "Apply a pea-sized amount, massage in upward circular motions",
            timeOfDay: "both"
        ),
        "rich_moisturizer": ProductTypeInfo(
            name: "Rich Moisturizer",
            description: "Nourishing cream moisturizer for deep hydration and skin repair",
            why: "Provides intensive hydration and supports overnight skin repair",
            how: "Apply generously to face and neck, massage gently until absorbed",
            timeOfDay: "evening"
        ),
        "night_cream": ProductTypeInfo(
            name: "Night Cream",
            description: "Intensive night cream that repairs and rejuvenates while you sleep",
            why: "Works with your skin's natural repair cycle to restore and rejuvenate",
            how: "Apply generously before bed, massage in upward motions",
            timeOfDay: "evening"
        ),
        "moisturizer": ProductTypeInfo(
            name: "Moisturizer",
            description: "Essential moisturizer that hydrates and protects skin",
            why: "Maintains skin's moisture barrier and prevents water loss",
            how: "Apply a pea-sized amount, massage in upward circular motions",
            timeOfDay: "both"
        ),
        "heavy_moisturizer": ProductTypeInfo(
            name: "Heavy Moisturizer",
            description: "Rich, intensive moisturizer for deep hydration",
            why: "Provides maximum hydration for dry or mature skin",
            how: "Apply generously to face and neck, massage gently until absorbed",
            timeOfDay: "both"
        ),
        "adaptive_moisturizer": ProductTypeInfo(
            name: "Adaptive Moisturizer",
            description: "Versatile moisturizer that adapts to different skin zones",
            why: "Provides appropriate hydration for both oily and dry areas",
            how: "Apply more to dry areas, less to oily areas, massage gently",
            timeOfDay: "both"
        ),
        "barrier_repair_cream": ProductTypeInfo(
            name: "Barrier Repair Cream",
            description: "Specialized cream that strengthens the skin's protective barrier",
            why: "Repairs and strengthens the skin's natural protective barrier",
            how: "Apply to clean skin, massage gently until absorbed",
            timeOfDay: "both"
        ),
        "luxury_moisturizer": ProductTypeInfo(
            name: "Luxury Moisturizer",
            description: "Premium moisturizer with advanced anti-aging ingredients",
            why: "Provides luxurious hydration with high-end anti-aging benefits",
            how: "Apply generously to face and neck, massage in upward motions",
            timeOfDay: "both"
        ),

        // Sunscreens
        "daily_sunscreen": ProductTypeInfo(
            name: "Daily Sunscreen",
            description: "Broad spectrum SPF 30+ sunscreen for daily protection",
            why: "Protects against UVA/UVB rays, prevents premature aging and skin cancer",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "mineral_sunscreen": ProductTypeInfo(
            name: "Mineral Sunscreen",
            description: "Physical sunscreen with zinc oxide for sensitive skin protection",
            why: "Provides immediate protection and is gentle on sensitive skin",
            how: "Apply generously, blend well to avoid white cast",
            timeOfDay: "morning"
        ),
        "sunscreen": ProductTypeInfo(
            name: "Sunscreen",
            description: "Essential daily sunscreen for UV protection",
            why: "Protects against harmful UV rays and prevents premature aging",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "oil_free_sunscreen": ProductTypeInfo(
            name: "Oil-free Sunscreen",
            description: "Non-greasy sunscreen that won't clog pores",
            why: "Provides protection without adding shine or clogging pores",
            how: "Apply generously, blend well, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "broad_spectrum_sunscreen": ProductTypeInfo(
            name: "Broad Spectrum Sunscreen",
            description: "Complete UV protection against UVA and UVB rays",
            why: "Protects against both aging UVA rays and burning UVB rays",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),
        "anti_aging_sunscreen": ProductTypeInfo(
            name: "Anti-aging Sunscreen",
            description: "Sunscreen with additional anti-aging benefits",
            why: "Provides UV protection while delivering anti-aging ingredients",
            how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
            timeOfDay: "morning"
        ),

        // Treatments
        "spot_treatment": ProductTypeInfo(
            name: "Spot Treatment",
            description: "Targeted treatment for blemishes and acne spots",
            why: "Reduces inflammation and speeds up healing of individual blemishes",
            how: "Apply a small amount directly to blemishes, avoid surrounding skin",
            timeOfDay: "evening"
        ),
        "exfoliating_mask": ProductTypeInfo(
            name: "Exfoliating Mask",
            description: "Weekly mask that removes dead skin cells and improves texture",
            why: "Deep cleanses pores and reveals smoother, brighter skin",
            how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
            timeOfDay: "weekly"
        ),
        "hydrating_mask": ProductTypeInfo(
            name: "Hydrating Mask",
            description: "Intensive hydrating mask for plump, dewy skin",
            why: "Provides deep hydration and improves skin's moisture retention",
            how: "Apply to clean skin, leave on for 15-20 minutes, rinse or remove",
            timeOfDay: "weekly"
        ),
        "clay_mask": ProductTypeInfo(
            name: "Clay Mask",
            description: "Purifying clay mask that draws out impurities and tightens pores",
            why: "Absorbs excess oil and unclogs pores for clearer, tighter skin",
            how: "Apply to clean skin, leave on until dry, rinse with warm water",
            timeOfDay: "weekly"
        ),

        // Korean Skincare
        "essence": ProductTypeInfo(
            name: "Essence",
            description: "Lightweight hydrating essence that preps skin for treatment",
            why: "Provides lightweight hydration and enhances absorption of subsequent products",
            how: "Apply with hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "treatment_essence": ProductTypeInfo(
            name: "Treatment Essence",
            description: "Advanced essence with concentrated active ingredients",
            why: "Delivers high concentrations of beneficial ingredients in a lightweight format",
            how: "Apply with hands, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "ampoule": ProductTypeInfo(
            name: "Ampoule",
            description: "Highly concentrated treatment with maximum active ingredients",
            why: "Provides intensive treatment with the highest concentration of active ingredients",
            how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
            timeOfDay: "both"
        ),
        "sheet_mask": ProductTypeInfo(
            name: "Sheet Mask",
            description: "Intensive treatment mask for deep hydration and nourishment",
            why: "Provides intensive treatment with concentrated serum for maximum benefits",
            how: "Apply to clean skin, leave on for 15-20 minutes, remove and pat in remaining serum",
            timeOfDay: "weekly"
        ),
        "exfoliant": ProductTypeInfo(
            name: "Exfoliant",
            description: "Gentle chemical exfoliant that removes dead skin cells",
            why: "Removes dead skin cells and reveals brighter, smoother skin",
            how: "Apply to clean skin, avoid eye area, use 2-3 times per week",
            timeOfDay: "evening"
        ),

        // Eye Care
        "eye_cream": ProductTypeInfo(
            name: "Eye Cream",
            description: "Specialized cream for the delicate eye area",
            why: "Targets fine lines, dark circles, and puffiness in the delicate eye area",
            how: "Apply a small amount with ring finger, pat gently around eye area",
            timeOfDay: "both"
        ),
        "rich_eye_cream": ProductTypeInfo(
            name: "Rich Eye Cream",
            description: "Intensive eye cream for mature or dry eye area",
            why: "Provides intensive hydration and anti-aging benefits for the eye area",
            how: "Apply a small amount with ring finger, pat gently around eye area",
            timeOfDay: "both"
        ),

        // Facial Oils
        "facial_oil": ProductTypeInfo(
            name: "Facial Oil",
            description: "Nourishing facial oil for extra hydration and glow",
            why: "Provides deep nourishment and creates a healthy glow",
            how: "Apply 2-3 drops to face and neck, massage gently until absorbed",
            timeOfDay: "evening"
        ),

        // Retinol Treatments
        "retinol_treatment": ProductTypeInfo(
            name: "Retinol Treatment",
            description: "Anti-aging retinol treatment for skin renewal",
            why: "Stimulates cell turnover and collagen production for younger-looking skin",
            how: "Start with 2-3 times per week, apply at night, avoid eye area",
            timeOfDay: "evening"
        ),

        // Zone-specific Treatments
        "zone_specific_treatment": ProductTypeInfo(
            name: "Zone-specific Treatment",
            description: "Targeted treatment for different skin zones",
            why: "Addresses different concerns in different areas of the face",
            how: "Apply to specific areas as needed, follow product instructions",
            timeOfDay: "both"
        )
    ]

    // MARK: - Helper Methods

    // Create dynamic product info with the actual step name
    private static func createDynamicProductInfo(
        name: String,
        category: String,
        description: String,
        why: String,
        how: String,
        timeOfDay: String
    ) -> ProductTypeInfo {
        return ProductTypeInfo(
            name: name,
            description: description,
            why: why,
            how: how,
            timeOfDay: timeOfDay
        )
    }

    // Cleanser helper functions
    private static func getCleanserDescription(for stepName: String) -> String {
        if stepName.contains("oil") {
            return "Gentle oil-based cleanser for effective makeup and sunscreen removal"
        } else if stepName.contains("water") && stepName.contains("based") {
            return "Gentle water-based cleanser for second cleansing step"
        } else if stepName.contains("foam") || stepName.contains("foaming") {
            return "Lightweight foaming cleanser for deep pore cleansing"
        } else if stepName.contains("gel") {
            return "Lightweight gel cleanser that removes excess oil without over-drying"
        } else if stepName.contains("cream") {
            return "Gentle cream cleanser that cleanses without stripping moisture"
        } else {
            return "Gentle cleanser that removes impurities and prepares skin"
        }
    }

    private static func getCleanserWhy(for stepName: String) -> String {
        if stepName.contains("oil") {
            return "Oil dissolves oil, making it perfect for removing waterproof makeup and sunscreen"
        } else if stepName.contains("foam") || stepName.contains("foaming") {
            return "Creates rich lather to remove excess oil and unclog pores without over-drying"
        } else if stepName.contains("gel") {
            return "Effectively removes oil and impurities while maintaining skin's natural balance"
        } else if stepName.contains("cream") {
            return "Provides gentle cleansing while maintaining skin's natural moisture barrier"
        } else {
            return "Removes dirt, oil, and makeup while maintaining skin's natural balance"
        }
    }

    private static func getCleanserHow(for stepName: String) -> String {
        if stepName.contains("oil") {
            return "Apply to dry skin, massage gently, add water to emulsify, rinse completely"
        } else if stepName.contains("foam") || stepName.contains("foaming") {
            return "Wet face, apply cleanser, massage in circular motions, rinse thoroughly"
        } else if stepName.contains("gel") {
            return "Apply to wet skin, massage gently, rinse thoroughly"
        } else if stepName.contains("cream") {
            return "Apply to dry or damp skin, massage gently, rinse with lukewarm water"
        } else {
            return "Apply to damp skin, massage gently, rinse with lukewarm water"
        }
    }

    private static func getCleanserTimeOfDay(for stepName: String) -> String {
        if stepName.contains("oil") {
            return "evening"
        } else {
            return "both"
        }
    }

    // Toner helper functions
    private static func getTonerDescription(for stepName: String) -> String {
        if stepName.contains("salicylic") || stepName.contains("bha") {
            return "BHA toner that unclogs pores and prevents breakouts"
        } else if stepName.contains("soothing") {
            return "Calming toner that reduces irritation and redness"
        } else if stepName.contains("hydrating") {
            return "Alcohol-free toner that balances pH and provides instant hydration"
        } else if stepName.contains("exfoliating") {
            return "Gentle exfoliating toner with AHA/BHA for smoother skin texture"
        } else {
            return "Balancing toner that prepares skin for next steps"
        }
    }

    private static func getTonerWhy(for stepName: String) -> String {
        if stepName.contains("salicylic") || stepName.contains("bha") {
            return "Penetrates pores to remove dead skin cells and prevent acne"
        } else if stepName.contains("soothing") {
            return "Soothes sensitive skin and reduces inflammation and redness"
        } else if stepName.contains("hydrating") {
            return "Restores skin's natural pH balance and prepares skin for better product absorption"
        } else if stepName.contains("exfoliating") {
            return "Removes dead skin cells and unclogs pores for brighter, smoother skin"
        } else {
            return "Restores pH balance and enhances product absorption"
        }
    }

    private static func getTonerHow(for stepName: String) -> String {
        if stepName.contains("salicylic") || stepName.contains("bha") || stepName.contains("exfoliating") {
            return "Apply with cotton pad, avoid eye area, use 2-3 times per week"
        } else {
            return "Apply with cotton pad or hands, pat gently until absorbed"
        }
    }

    private static func getTonerTimeOfDay(for stepName: String) -> String {
        if stepName.contains("exfoliating") {
            return "evening"
        } else {
            return "both"
        }
    }

    // Serum helper functions
    private static func getSerumDescription(for stepName: String) -> String {
        if stepName.contains("vitamin c") {
            return "Antioxidant serum that brightens skin and protects against environmental damage"
        } else if stepName.contains("hyaluronic") {
            return "Intensive hydrating serum that plumps and smooths skin"
        } else if stepName.contains("niacinamide") {
            return "Vitamin B3 serum that minimizes pores and controls oil production"
        } else if stepName.contains("peptide") {
            return "Anti-aging serum with peptides for firmer, more youthful skin"
        } else if stepName.contains("retinol") {
            return "Anti-aging serum that promotes cell turnover and reduces signs of aging"
        } else {
            return "Concentrated treatment serum for targeted skin concerns"
        }
    }

    private static func getSerumWhy(for stepName: String) -> String {
        if stepName.contains("vitamin c") {
            return "Neutralizes free radicals, brightens skin tone, and boosts collagen production"
        } else if stepName.contains("hyaluronic") {
            return "Attracts and retains moisture, plumping skin and reducing fine lines"
        } else if stepName.contains("niacinamide") {
            return "Reduces pore size, controls sebum production, and improves skin texture"
        } else if stepName.contains("peptide") {
            return "Stimulates collagen production and improves skin firmness and elasticity"
        } else if stepName.contains("retinol") {
            return "Stimulates collagen production, reduces fine lines, and improves skin texture"
        } else {
            return "Delivers active ingredients deep into skin for maximum effectiveness"
        }
    }

    private static func getSerumHow(for stepName: String) -> String {
        if stepName.contains("vitamin c") {
            return "Apply 2-3 drops in the morning, pat gently, follow with sunscreen"
        } else if stepName.contains("hyaluronic") {
            return "Apply to damp skin, pat gently until absorbed, follow with moisturizer"
        } else if stepName.contains("retinol") {
            return "Start with 2-3 times per week, apply at night, avoid eye area"
        } else {
            return "Apply 2-3 drops to clean skin, pat gently until absorbed"
        }
    }

    private static func getSerumTimeOfDay(for stepName: String) -> String {
        if stepName.contains("vitamin c") {
            return "morning"
        } else if stepName.contains("retinol") {
            return "evening"
        } else {
            return "both"
        }
    }

    // Essence helper functions
    private static func getEssenceDescription(for stepName: String) -> String {
        if stepName.contains("treatment") {
            return "Advanced essence with concentrated active ingredients"
        } else {
            return "Lightweight hydrating essence that preps skin for treatment"
        }
    }

    private static func getEssenceWhy(for stepName: String) -> String {
        if stepName.contains("treatment") {
            return "Delivers high concentrations of beneficial ingredients in a lightweight format"
        } else {
            return "Provides lightweight hydration and enhances absorption of subsequent products"
        }
    }

    private static func getEssenceHow(for stepName: String) -> String {
        return "Apply with hands, pat gently until absorbed"
    }

    // Ampoule helper functions
    private static func getAmpouleDescription(for stepName: String) -> String {
        return "Highly concentrated treatment with maximum active ingredients"
    }

    private static func getAmpouleWhy(for stepName: String) -> String {
        return "Provides intensive treatment with the highest concentration of active ingredients"
    }

    private static func getAmpouleHow(for stepName: String) -> String {
        return "Apply 2-3 drops to clean skin, pat gently until absorbed"
    }

    // Moisturizer helper functions
    private static func getMoisturizerDescription(for stepName: String) -> String {
        if stepName.contains("heavy") {
            return "Rich, intensive moisturizer for deep hydration"
        } else if stepName.contains("rich") {
            return "Nourishing cream moisturizer for deep hydration and skin repair"
        } else if stepName.contains("lightweight") {
            return "Oil-free gel moisturizer that hydrates without clogging pores"
        } else if stepName.contains("night") {
            return "Intensive night cream that repairs and rejuvenates while you sleep"
        } else if stepName.contains("barrier") && stepName.contains("repair") {
            return "Specialized cream that strengthens the skin's protective barrier"
        } else {
            return "Hydrating moisturizer that locks in moisture"
        }
    }

    private static func getMoisturizerWhy(for stepName: String) -> String {
        if stepName.contains("heavy") || stepName.contains("rich") {
            return "Provides intensive hydration and supports overnight skin repair"
        } else if stepName.contains("lightweight") {
            return "Provides essential hydration while maintaining a matte finish"
        } else if stepName.contains("night") {
            return "Works with your skin's natural repair cycle to restore and rejuvenate"
        } else if stepName.contains("barrier") && stepName.contains("repair") {
            return "Repairs and strengthens the skin's natural protective barrier"
        } else {
            return "Provides essential hydration and creates a protective barrier"
        }
    }

    private static func getMoisturizerHow(for stepName: String) -> String {
        if stepName.contains("heavy") || stepName.contains("rich") {
            return "Apply generously to face and neck, massage gently until absorbed"
        } else if stepName.contains("night") {
            return "Apply generously before bed, massage in upward motions"
        } else {
            return "Apply a pea-sized amount, massage in upward circular motions"
        }
    }

    private static func getMoisturizerTimeOfDay(for stepName: String) -> String {
        if stepName.contains("night") {
            return "evening"
        } else {
            return "both"
        }
    }

    // Sunscreen helper functions
    private static func getSunscreenDescription(for stepName: String) -> String {
        if stepName.contains("mineral") {
            return "Physical sunscreen with zinc oxide for sensitive skin protection"
        } else if stepName.contains("oil") && stepName.contains("free") {
            return "Non-greasy sunscreen that won't clog pores"
        } else if stepName.contains("broad") && stepName.contains("spectrum") {
            return "Complete UV protection against UVA and UVB rays"
        } else if stepName.contains("anti") && stepName.contains("aging") {
            return "Sunscreen with additional anti-aging benefits"
        } else {
            return "Broad spectrum sunscreen for daily protection"
        }
    }

    private static func getSunscreenWhy(for stepName: String) -> String {
        if stepName.contains("mineral") {
            return "Provides immediate protection and is gentle on sensitive skin"
        } else if stepName.contains("oil") && stepName.contains("free") {
            return "Provides protection without adding shine or clogging pores"
        } else if stepName.contains("broad") && stepName.contains("spectrum") {
            return "Protects against both aging UVA rays and burning UVB rays"
        } else if stepName.contains("anti") && stepName.contains("aging") {
            return "Provides UV protection while delivering anti-aging ingredients"
        } else {
            return "Protects against UVA/UVB rays, prevents premature aging and skin cancer"
        }
    }

    private static func getSunscreenHow(for stepName: String) -> String {
        if stepName.contains("mineral") {
            return "Apply generously, blend well to avoid white cast"
        } else if stepName.contains("oil") && stepName.contains("free") {
            return "Apply generously, blend well, reapply every 2 hours"
        } else {
            return "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
        }
    }

    // Mask helper functions
    private static func getMaskDescription(for stepName: String) -> String {
        if stepName.contains("sheet") {
            return "Intensive treatment mask for deep hydration and nourishment"
        } else if stepName.contains("clay") {
            return "Purifying clay mask that draws out impurities and tightens pores"
        } else if stepName.contains("hydrating") {
            return "Intensive hydrating mask for plump, dewy skin"
        } else if stepName.contains("exfoliating") {
            return "Weekly mask that removes dead skin cells and improves texture"
        } else {
            return "Weekly treatment mask for enhanced skin care"
        }
    }

    private static func getMaskWhy(for stepName: String) -> String {
        if stepName.contains("sheet") {
            return "Provides intensive treatment with concentrated serum for maximum benefits"
        } else if stepName.contains("clay") {
            return "Absorbs excess oil and unclogs pores for clearer, tighter skin"
        } else if stepName.contains("hydrating") {
            return "Provides deep hydration and improves skin's moisture retention"
        } else if stepName.contains("exfoliating") {
            return "Deep cleanses pores and reveals smoother, brighter skin"
        } else {
            return "Provides intensive treatment and addresses specific skin concerns"
        }
    }

    private static func getMaskHow(for stepName: String) -> String {
        if stepName.contains("sheet") {
            return "Apply to clean skin, leave on for 15-20 minutes, remove and pat in remaining serum"
        } else if stepName.contains("clay") {
            return "Apply to clean skin, leave on until dry, rinse with warm water"
        } else if stepName.contains("hydrating") {
            return "Apply to clean skin, leave on for 15-20 minutes, rinse or remove"
        } else {
            return "Apply to clean skin, leave on for recommended time, rinse thoroughly"
        }
    }

    // Exfoliant helper functions
    private static func getExfoliantDescription(for stepName: String) -> String {
        return "Gentle chemical exfoliant that removes dead skin cells"
    }

    private static func getExfoliantWhy(for stepName: String) -> String {
        return "Removes dead skin cells and reveals brighter, smoother skin"
    }

    private static func getExfoliantHow(for stepName: String) -> String {
        return "Apply to clean skin, avoid eye area, use 2-3 times per week"
    }

    // Eye cream helper functions
    private static func getEyeCreamDescription(for stepName: String) -> String {
        if stepName.contains("rich") {
            return "Intensive eye cream for mature or dry eye area"
        } else {
            return "Specialized cream for the delicate eye area"
        }
    }

    private static func getEyeCreamWhy(for stepName: String) -> String {
        if stepName.contains("rich") {
            return "Provides intensive hydration and anti-aging benefits for the eye area"
        } else {
            return "Targets fine lines, dark circles, and puffiness in the delicate eye area"
        }
    }

    private static func getEyeCreamHow(for stepName: String) -> String {
        return "Apply a small amount with ring finger, pat gently around eye area"
    }

    // Facial oil helper functions
    private static func getFacialOilDescription(for stepName: String) -> String {
        return "Nourishing facial oil for extra hydration and glow"
    }

    private static func getFacialOilWhy(for stepName: String) -> String {
        return "Provides deep nourishment and creates a healthy glow"
    }

    private static func getFacialOilHow(for stepName: String) -> String {
        return "Apply 2-3 drops to face and neck, massage gently until absorbed"
    }

    static func getInfo(for stepName: String) -> ProductTypeInfo {
        // Check cache first
        return cacheQueue.sync {
            if let cached = cache[stepName] {
                return cached
            }

            let result = computeProductInfo(for: stepName)
            cache[stepName] = result
            return result
        }
    }

    private static func computeProductInfo(for stepName: String) -> ProductTypeInfo {
        let lowercased = stepName.lowercased()

        // Extract the main product name (before the dash)
        let mainProductName = stepName.components(separatedBy: " - ").first ?? stepName

        // Try exact matches first
        if let info = productTypes[lowercased] {
            return info
        }

        // Determine the main category and create a dynamic ProductTypeInfo
        if lowercased.contains("cleanser") || lowercased.contains("cleanse") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "cleanser",
                description: getCleanserDescription(for: lowercased),
                why: getCleanserWhy(for: lowercased),
                how: getCleanserHow(for: lowercased),
                timeOfDay: getCleanserTimeOfDay(for: lowercased)
            )
        } else if lowercased.contains("toner") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "toner",
                description: getTonerDescription(for: lowercased),
                why: getTonerWhy(for: lowercased),
                how: getTonerHow(for: lowercased),
                timeOfDay: getTonerTimeOfDay(for: lowercased)
            )
        } else if lowercased.contains("serum") || lowercased.contains("treatment") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "serum",
                description: getSerumDescription(for: lowercased),
                why: getSerumWhy(for: lowercased),
                how: getSerumHow(for: lowercased),
                timeOfDay: getSerumTimeOfDay(for: lowercased)
            )
        } else if lowercased.contains("essence") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "essence",
                description: getEssenceDescription(for: lowercased),
                why: getEssenceWhy(for: lowercased),
                how: getEssenceHow(for: lowercased),
                timeOfDay: "both"
            )
        } else if lowercased.contains("ampoule") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "ampoule",
                description: getAmpouleDescription(for: lowercased),
                why: getAmpouleWhy(for: lowercased),
                how: getAmpouleHow(for: lowercased),
                timeOfDay: "both"
            )
        } else if lowercased.contains("eye") && lowercased.contains("cream") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "eye_cream",
                description: getEyeCreamDescription(for: lowercased),
                why: getEyeCreamWhy(for: lowercased),
                how: getEyeCreamHow(for: lowercased),
                timeOfDay: "both"
            )
        } else if lowercased.contains("facial") && lowercased.contains("oil") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "facial_oil",
                description: getFacialOilDescription(for: lowercased),
                why: getFacialOilWhy(for: lowercased),
                how: getFacialOilHow(for: lowercased),
                timeOfDay: "evening"
            )
        } else if lowercased.contains("moisturizer") || lowercased.contains("moisturiser") || lowercased.contains("cream") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "moisturizer",
                description: getMoisturizerDescription(for: lowercased),
                why: getMoisturizerWhy(for: lowercased),
                how: getMoisturizerHow(for: lowercased),
                timeOfDay: getMoisturizerTimeOfDay(for: lowercased)
            )
        } else if lowercased.contains("sunscreen") || lowercased.contains("spf") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "sunscreen",
                description: getSunscreenDescription(for: lowercased),
                why: getSunscreenWhy(for: lowercased),
                how: getSunscreenHow(for: lowercased),
                timeOfDay: "morning"
            )
        } else if lowercased.contains("mask") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "mask",
                description: getMaskDescription(for: lowercased),
                why: getMaskWhy(for: lowercased),
                how: getMaskHow(for: lowercased),
                timeOfDay: "weekly"
            )
        } else if lowercased.contains("exfoliant") {
            return createDynamicProductInfo(
                name: mainProductName,
                category: "exfoliant",
                description: getExfoliantDescription(for: lowercased),
                why: getExfoliantWhy(for: lowercased),
                how: getExfoliantHow(for: lowercased),
                timeOfDay: "evening"
            )
        }

        // Default fallback
        return getDefaultInfo(for: "serum")
    }

    // MARK: - Cache Management

    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            cache.removeAll()
        }
    }

    static func getCacheSize() -> Int {
        return cacheQueue.sync {
            return cache.count
        }
    }

    private static func getDefaultInfo(for type: String) -> ProductTypeInfo {
        switch type {
        case "cleanser":
            return ProductTypeInfo(
                name: "Cleanser",
                description: "Gentle cleanser that removes impurities and prepares skin",
                why: "Removes dirt, oil, and makeup while maintaining skin's natural balance",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "toner":
            return ProductTypeInfo(
                name: "Toner",
                description: "Balancing toner that prepares skin for next steps",
                why: "Restores pH balance and enhances product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "serum":
            return ProductTypeInfo(
                name: "Face Serum",
                description: "Targeted serum for your specific skin concerns",
                why: "Delivers active ingredients deep into the skin for maximum benefits",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "face_serum":
            return ProductTypeInfo(
                name: "Face Serum",
                description: "Targeted serum for your specific skin concerns",
                why: "Delivers active ingredients deep into the skin for maximum benefits",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "moisturizer":
            return ProductTypeInfo(
                name: "Moisturizer",
                description: "Hydrating moisturizer that locks in moisture",
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions",
                timeOfDay: "both"
            )
        case "sunscreen":
            return ProductTypeInfo(
                name: "Sunscreen",
                description: "Broad spectrum sunscreen for daily protection",
                why: "Protects against UV damage and prevents premature aging",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "mask":
            return ProductTypeInfo(
                name: "Face Mask",
                description: "Weekly treatment mask for enhanced skin care",
                why: "Provides intensive treatment and addresses specific skin concerns",
                how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
                timeOfDay: "weekly"
            )
        case "essence":
            return ProductTypeInfo(
                name: "Essence",
                description: "Lightweight hydrating essence that preps skin for treatment",
                why: "Provides lightweight hydration and enhances absorption of subsequent products",
                how: "Apply with hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "ampoule":
            return ProductTypeInfo(
                name: "Ampoule",
                description: "Highly concentrated treatment with maximum active ingredients",
                why: "Provides intensive treatment with the highest concentration of active ingredients",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "exfoliant":
            return ProductTypeInfo(
                name: "Exfoliant",
                description: "Gentle chemical exfoliant that removes dead skin cells",
                why: "Removes dead skin cells and reveals brighter, smoother skin",
                how: "Apply to clean skin, avoid eye area, use 2-3 times per week",
                timeOfDay: "evening"
            )
        case "eye_cream":
            return ProductTypeInfo(
                name: "Eye Cream",
                description: "Specialized cream for the delicate eye area",
                why: "Targets fine lines, dark circles, and puffiness in the delicate eye area",
                how: "Apply a small amount with ring finger, pat gently around eye area",
                timeOfDay: "both"
            )
        case "facial_oil":
            return ProductTypeInfo(
                name: "Facial Oil",
                description: "Nourishing facial oil for extra hydration and glow",
                why: "Provides deep nourishment and creates a healthy glow",
                how: "Apply 2-3 drops to face and neck, massage gently until absorbed",
                timeOfDay: "evening"
            )
        case "treatment":
            return ProductTypeInfo(
                name: "Treatment",
                description: "Targeted treatment for specific skin concerns",
                why: "Addresses specific skin concerns with concentrated active ingredients",
                how: "Apply as directed, follow product instructions for best results",
                timeOfDay: "both"
            )
        case "water_cleanser":
            return ProductTypeInfo(
                name: "Water Cleanser",
                description: "Gentle water-based cleanser for second cleansing step",
                why: "Removes remaining impurities and prepares skin for treatment products",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "gel_cleanser":
            return ProductTypeInfo(
                name: "Gel Cleanser",
                description: "Lightweight gel cleanser that removes excess oil without over-drying",
                why: "Effectively removes oil and impurities while maintaining skin's natural balance",
                how: "Apply to wet skin, massage gently, rinse thoroughly",
                timeOfDay: "both"
            )
        case "cream_cleanser":
            return ProductTypeInfo(
                name: "Cream Cleanser",
                description: "Gentle cream cleanser that cleanses without stripping moisture",
                why: "Provides gentle cleansing while maintaining skin's natural moisture barrier",
                how: "Apply to dry or damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "balancing_cleanser":
            return ProductTypeInfo(
                name: "Balancing Cleanser",
                description: "Multi-purpose cleanser that balances different skin zones",
                why: "Cleanses effectively without over-drying oily areas or stripping dry areas",
                how: "Apply to damp skin, massage gently, rinse thoroughly",
                timeOfDay: "both"
            )
        case "soothing_toner":
            return ProductTypeInfo(
                name: "Soothing Toner",
                description: "Calming toner that reduces irritation and redness",
                why: "Soothes sensitive skin and reduces inflammation and redness",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "salicylic_acid_toner":
            return ProductTypeInfo(
                name: "Salicylic Acid Toner",
                description: "BHA toner that unclogs pores and prevents breakouts",
                why: "Penetrates pores to remove dead skin cells and prevent acne",
                how: "Apply with cotton pad, avoid eye area, use daily or as directed",
                timeOfDay: "both"
            )
        case "bha_toner":
            return ProductTypeInfo(
                name: "BHA Toner",
                description: "Beta hydroxy acid toner that unclogs pores and smooths texture",
                why: "Exfoliates inside pores to prevent breakouts and improve skin texture",
                how: "Apply with cotton pad, avoid eye area, start with 2-3 times per week",
                timeOfDay: "both"
            )
        case "treatment_essence":
            return ProductTypeInfo(
                name: "Treatment Essence",
                description: "Advanced essence with concentrated active ingredients",
                why: "Delivers high concentrations of beneficial ingredients in a lightweight format",
                how: "Apply with hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "rich_serum":
            return ProductTypeInfo(
                name: "Rich Serum",
                description: "Nourishing serum with concentrated active ingredients",
                why: "Provides intensive treatment with high concentrations of beneficial ingredients",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "lightweight_serum":
            return ProductTypeInfo(
                name: "Lightweight Serum",
                description: "Fast-absorbing serum that doesn't feel heavy on skin",
                why: "Provides effective treatment without leaving a heavy or sticky feeling",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "peptide_complex":
            return ProductTypeInfo(
                name: "Peptide Complex",
                description: "Advanced peptide treatment for skin structure support",
                why: "Supports skin's natural structure and improves firmness and elasticity",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "heavy_moisturizer":
            return ProductTypeInfo(
                name: "Heavy Moisturizer",
                description: "Rich, intensive moisturizer for deep hydration",
                why: "Provides maximum hydration for dry or mature skin",
                how: "Apply generously to face and neck, massage gently until absorbed",
                timeOfDay: "both"
            )
        case "adaptive_moisturizer":
            return ProductTypeInfo(
                name: "Adaptive Moisturizer",
                description: "Versatile moisturizer that adapts to different skin zones",
                why: "Provides appropriate hydration for both oily and dry areas",
                how: "Apply more to dry areas, less to oily areas, massage gently",
                timeOfDay: "both"
            )
        case "barrier_repair_cream":
            return ProductTypeInfo(
                name: "Barrier Repair Cream",
                description: "Specialized cream that strengthens the skin's protective barrier",
                why: "Repairs and strengthens the skin's natural protective barrier",
                how: "Apply to clean skin, massage gently until absorbed",
                timeOfDay: "both"
            )
        case "luxury_moisturizer":
            return ProductTypeInfo(
                name: "Luxury Moisturizer",
                description: "Premium moisturizer with advanced anti-aging ingredients",
                why: "Provides luxurious hydration with high-end anti-aging benefits",
                how: "Apply generously to face and neck, massage in upward motions",
                timeOfDay: "both"
            )
        case "oil_free_sunscreen":
            return ProductTypeInfo(
                name: "Oil-free Sunscreen",
                description: "Non-greasy sunscreen that won't clog pores",
                why: "Provides protection without adding shine or clogging pores",
                how: "Apply generously, blend well, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "broad_spectrum_sunscreen":
            return ProductTypeInfo(
                name: "Broad Spectrum Sunscreen",
                description: "Complete UV protection against UVA and UVB rays",
                why: "Protects against both aging UVA rays and burning UVB rays",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "anti_aging_sunscreen":
            return ProductTypeInfo(
                name: "Anti-aging Sunscreen",
                description: "Sunscreen with additional anti-aging benefits",
                why: "Provides UV protection while delivering anti-aging ingredients",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "rich_eye_cream":
            return ProductTypeInfo(
                name: "Rich Eye Cream",
                description: "Intensive eye cream for mature or dry eye area",
                why: "Provides intensive hydration and anti-aging benefits for the eye area",
                how: "Apply a small amount with ring finger, pat gently around eye area",
                timeOfDay: "both"
            )
        case "sheet_mask":
            return ProductTypeInfo(
                name: "Sheet Mask",
                description: "Intensive treatment mask for deep hydration and nourishment",
                why: "Provides intensive treatment with concentrated serum for maximum benefits",
                how: "Apply to clean skin, leave on for 15-20 minutes, remove and pat in remaining serum",
                timeOfDay: "weekly"
            )
        case "retinol_treatment":
            return ProductTypeInfo(
                name: "Retinol Treatment",
                description: "Anti-aging retinol treatment for skin renewal",
                why: "Stimulates cell turnover and collagen production for younger-looking skin",
                how: "Start with 2-3 times per week, apply at night, avoid eye area",
                timeOfDay: "evening"
            )
        case "zone_specific_treatment":
            return ProductTypeInfo(
                name: "Zone-specific Treatment",
                description: "Targeted treatment for different skin zones",
                why: "Addresses different concerns in different areas of the face",
                how: "Apply to specific areas as needed, follow product instructions",
                timeOfDay: "both"
            )
        case "gentle_cleanser":
            return ProductTypeInfo(
                name: "Gentle Cleanser",
                description: "Oil-free gel cleanser that removes impurities without stripping the skin",
                why: "Removes overnight oil buildup, makeup, and daily pollutants while maintaining skin's natural moisture barrier",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "foaming_cleanser":
            return ProductTypeInfo(
                name: "Foaming Cleanser",
                description: "Lightweight foaming cleanser for deep pore cleansing",
                why: "Creates rich lather to remove excess oil and unclog pores without over-drying",
                how: "Wet face, apply cleanser, massage in circular motions, rinse thoroughly",
                timeOfDay: "both"
            )
        case "gentle_foaming_cleanser":
            return ProductTypeInfo(
                name: "Gentle Foaming Cleanser",
                description: "Gentle foaming cleanser that cleans without irritation",
                why: "Provides effective cleansing with a gentle formula that won't irritate sensitive skin",
                how: "Wet face, apply cleanser, massage gently in circular motions, rinse thoroughly",
                timeOfDay: "both"
            )
        case "water_based_cleanser":
            return ProductTypeInfo(
                name: "Water-based Cleanser",
                description: "Gentle water-based cleanser for second cleansing step",
                why: "Removes remaining impurities and prepares skin for treatment products",
                how: "Apply to damp skin, massage gently, rinse with lukewarm water",
                timeOfDay: "both"
            )
        case "oil_cleanser":
            return ProductTypeInfo(
                name: "Oil Cleanser",
                description: "Gentle oil-based cleanser for effective makeup and sunscreen removal",
                why: "Oil dissolves oil, making it perfect for removing waterproof makeup and sunscreen",
                how: "Apply to dry skin, massage gently, add water to emulsify, rinse completely",
                timeOfDay: "evening"
            )
        case "hydrating_toner":
            return ProductTypeInfo(
                name: "Hydrating Toner",
                description: "Alcohol-free toner that balances pH and provides instant hydration",
                why: "Restores skin's natural pH balance and prepares skin for better product absorption",
                how: "Apply with cotton pad or hands, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "exfoliating_toner":
            return ProductTypeInfo(
                name: "Exfoliating Toner",
                description: "Gentle exfoliating toner with AHA/BHA for smoother skin texture",
                why: "Removes dead skin cells and unclogs pores for brighter, smoother skin",
                how: "Apply with cotton pad, avoid eye area, use 2-3 times per week",
                timeOfDay: "evening"
            )
        case "niacinamide_serum":
            return ProductTypeInfo(
                name: "Niacinamide Serum",
                description: "Vitamin B3 serum that minimizes pores and controls oil production",
                why: "Reduces pore size, controls sebum production, and improves skin texture",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "vitamin_c_serum":
            return ProductTypeInfo(
                name: "Vitamin C Serum",
                description: "Antioxidant serum that brightens skin and protects against environmental damage",
                why: "Neutralizes free radicals, brightens skin tone, and boosts collagen production",
                how: "Apply 2-3 drops in the morning, pat gently, follow with sunscreen",
                timeOfDay: "morning"
            )
        case "hyaluronic_acid_serum":
            return ProductTypeInfo(
                name: "Hyaluronic Acid Serum",
                description: "Intensive hydrating serum that plumps and smooths skin",
                why: "Attracts and retains moisture, plumping skin and reducing fine lines",
                how: "Apply to damp skin, pat gently until absorbed, follow with moisturizer",
                timeOfDay: "both"
            )
        case "retinol_serum":
            return ProductTypeInfo(
                name: "Retinol Serum",
                description: "Anti-aging serum that promotes cell turnover and reduces signs of aging",
                why: "Stimulates collagen production, reduces fine lines, and improves skin texture",
                how: "Start with 2-3 times per week, apply at night, avoid eye area",
                timeOfDay: "evening"
            )
        case "peptide_serum":
            return ProductTypeInfo(
                name: "Peptide Serum",
                description: "Anti-aging serum with peptides for firmer, more youthful skin",
                why: "Stimulates collagen production and improves skin firmness and elasticity",
                how: "Apply 2-3 drops to clean skin, pat gently until absorbed",
                timeOfDay: "both"
            )
        case "lightweight_moisturizer":
            return ProductTypeInfo(
                name: "Lightweight Moisturizer",
                description: "Oil-free gel moisturizer that hydrates without clogging pores",
                why: "Provides essential hydration while maintaining a matte finish",
                how: "Apply a pea-sized amount, massage in upward circular motions",
                timeOfDay: "both"
            )
        case "rich_moisturizer":
            return ProductTypeInfo(
                name: "Rich Moisturizer",
                description: "Nourishing cream moisturizer for deep hydration and skin repair",
                why: "Provides intensive hydration and supports overnight skin repair",
                how: "Apply generously to face and neck, massage gently until absorbed",
                timeOfDay: "evening"
            )
        case "night_cream":
            return ProductTypeInfo(
                name: "Night Cream",
                description: "Intensive night cream that repairs and rejuvenates while you sleep",
                why: "Works with your skin's natural repair cycle to restore and rejuvenate",
                how: "Apply generously before bed, massage in upward motions",
                timeOfDay: "evening"
            )
        case "daily_sunscreen":
            return ProductTypeInfo(
                name: "Daily Sunscreen",
                description: "Broad spectrum SPF 30+ sunscreen for daily protection",
                why: "Protects against UVA/UVB rays, prevents premature aging and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours",
                timeOfDay: "morning"
            )
        case "mineral_sunscreen":
            return ProductTypeInfo(
                name: "Mineral Sunscreen",
                description: "Physical sunscreen with zinc oxide for sensitive skin protection",
                why: "Provides immediate protection and is gentle on sensitive skin",
                how: "Apply generously, blend well to avoid white cast",
                timeOfDay: "morning"
            )
        case "spot_treatment":
            return ProductTypeInfo(
                name: "Spot Treatment",
                description: "Targeted treatment for blemishes and acne spots",
                why: "Reduces inflammation and speeds up healing of individual blemishes",
                how: "Apply a small amount directly to blemishes, avoid surrounding skin",
                timeOfDay: "evening"
            )
        case "exfoliating_mask":
            return ProductTypeInfo(
                name: "Exfoliating Mask",
                description: "Weekly mask that removes dead skin cells and improves texture",
                why: "Deep cleanses pores and reveals smoother, brighter skin",
                how: "Apply to clean skin, leave on for recommended time, rinse thoroughly",
                timeOfDay: "weekly"
            )
        case "hydrating_mask":
            return ProductTypeInfo(
                name: "Hydrating Mask",
                description: "Intensive hydrating mask for plump, dewy skin",
                why: "Provides deep hydration and improves skin's moisture retention",
                how: "Apply to clean skin, leave on for 15-20 minutes, rinse or remove",
                timeOfDay: "weekly"
            )
        case "clay_mask":
            return ProductTypeInfo(
                name: "Clay Mask",
                description: "Purifying clay mask that draws out impurities and tightens pores",
                why: "Absorbs excess oil and unclogs pores for clearer, tighter skin",
                how: "Apply to clean skin, leave on until dry, rinse with warm water",
                timeOfDay: "weekly"
            )
        default:
            return ProductTypeInfo(
                name: "Skincare Step",
                description: "Important step in your skincare routine",
                why: "Part of your personalized skincare routine",
                how: "Follow the routine as recommended",
                timeOfDay: "both"
            )
        }
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
