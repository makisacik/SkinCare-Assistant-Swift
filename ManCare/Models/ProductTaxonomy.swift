//
//  ProductTaxonomy.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Core Taxonomy

/// Comprehensive product types ordered from most used to least used
enum ProductType: String, Codable, CaseIterable, Identifiable {
    // Most commonly used (daily essentials)
    case cleanser
    case moisturizer
    case sunscreen
    case toner

    // Treatment products
    case faceSerum
    case essence
    case exfoliator
    case faceMask
    case facialOil

    // Specialized products
    case facialMist
    case eyeCream
    case spotTreatment
    case retinol
    case vitaminC
    case niacinamide
    case hyaluronicAcid
    case peptide

    // Sun protection variations
    case faceSunscreen
    case bodySunscreen
    case lipBalm

    // Shaving products
    case shaveCream
    case aftershave
    case shaveGel

    // Body care
    case bodyLotion
    case bodyWash
    case handCream

    // Hair care
    case shampoo
    case conditioner
    case hairOil
    case hairMask

    // Specialized treatments
    case chemicalPeel
    case micellarWater
    case makeupRemover
    case faceWash
    case cleansingOil
    case cleansingBalm

    var id: String { rawValue }
    
    // Custom decoder to handle variations in product type names
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        // First, try exact match with raw value
        if let productType = ProductType(rawValue: value) {
            self = productType
            return
        }

        // Log that we need to normalize
        print("⚠️ [ProductType] No exact match for '\(value)', trying normalization...")

        // Normalize the input: remove spaces, convert to lowercase, convert underscores to nothing
        let normalized = value.replacingOccurrences(of: " ", with: "")
                             .replacingOccurrences(of: "_", with: "")
                             .lowercased()
        
        // Try to find a matching case by comparing normalized versions
        for productType in ProductType.allCases {
            let caseNormalized = productType.rawValue.lowercased()
            if normalized == caseNormalized {
                print("✅ [ProductType] Normalized '\(value)' -> '\(productType.rawValue)'")
                self = productType
                return
            }
        }
        
        // If still no match, use the alias mapping system
        print("⚠️ [ProductType] Using alias mapping for '\(value)'")
        let mappedType = ProductAliasMapping.normalize(value)
        print("✅ [ProductType] Mapped '\(value)' -> '\(mappedType.rawValue)'")
        self = mappedType
    }

    /// Display name for UI
    var displayName: String {
        switch self {
        // Most commonly used
        case .cleanser: return L10n.Products.TypeName.cleanser
        case .moisturizer: return L10n.Products.TypeName.moisturizer
        case .sunscreen: return L10n.Products.TypeName.sunscreen
        case .toner: return L10n.Products.TypeName.toner

        // Treatment products
        case .faceSerum: return L10n.Products.TypeName.faceSerum
        case .essence: return L10n.Products.TypeName.essence
        case .exfoliator: return L10n.Products.TypeName.exfoliator
        case .faceMask: return L10n.Products.TypeName.faceMask
        case .facialOil: return L10n.Products.TypeName.facialOil

        // Specialized products
        case .facialMist: return L10n.Products.TypeName.facialMist
        case .eyeCream: return L10n.Products.TypeName.eyeCream
        case .spotTreatment: return L10n.Products.TypeName.spotTreatment
        case .retinol: return L10n.Products.TypeName.retinol
        case .vitaminC: return L10n.Products.TypeName.vitaminC
        case .niacinamide: return L10n.Products.TypeName.niacinamide
        case .hyaluronicAcid: return L10n.Products.TypeName.hyaluronicAcid
        case .peptide: return L10n.Products.TypeName.peptide

        // Sun protection variations
        case .faceSunscreen: return L10n.Products.TypeName.faceSunscreen
        case .bodySunscreen: return L10n.Products.TypeName.bodySunscreen
        case .lipBalm: return L10n.Products.TypeName.lipBalm

        // Shaving products
        case .shaveCream: return L10n.Products.TypeName.shaveCream
        case .aftershave: return L10n.Products.TypeName.aftershave
        case .shaveGel: return L10n.Products.TypeName.shaveGel

        // Body care
        case .bodyLotion: return L10n.Products.TypeName.bodyLotion
        case .bodyWash: return L10n.Products.TypeName.bodyWash
        case .handCream: return L10n.Products.TypeName.handCream

        // Hair care
        case .shampoo: return L10n.Products.TypeName.shampoo
        case .conditioner: return L10n.Products.TypeName.conditioner
        case .hairOil: return L10n.Products.TypeName.hairOil
        case .hairMask: return L10n.Products.TypeName.hairMask

        // Specialized treatments
        case .chemicalPeel: return L10n.Products.TypeName.chemicalPeel
        case .micellarWater: return L10n.Products.TypeName.micellarWater
        case .makeupRemover: return L10n.Products.TypeName.makeupRemover
        case .faceWash: return L10n.Products.TypeName.faceWash
        case .cleansingOil: return L10n.Products.TypeName.cleansingOil
        case .cleansingBalm: return L10n.Products.TypeName.cleansingBalm
        }
    }

    /// Icon name for UI - uses custom asset images for all product types
    var iconName: String {
        return ProductIconManager.getIconName(for: self)
    }

    /// Color for UI
    var color: String {
        switch self {
        // Most commonly used
        case .cleanser: return "blue"
        case .moisturizer: return "green"
        case .sunscreen: return "yellow"
        case .toner: return "purple"

        // Treatment products
        case .faceSerum: return "indigo"
        case .essence: return "indigo"
        case .exfoliator: return "orange"
        case .faceMask: return "pink"
        case .facialOil: return "brown"

        // Specialized products
        case .facialMist: return "cyan"
        case .eyeCream: return "mint"
        case .spotTreatment: return "red"
        case .retinol: return "green"
        case .vitaminC: return "yellow"
        case .niacinamide: return "blue"
        case .hyaluronicAcid: return "cyan"
        case .peptide: return "purple"

        // Sun protection variations
        case .faceSunscreen: return "yellow"
        case .bodySunscreen: return "orange"
        case .lipBalm: return "pink"

        // Shaving products
        case .shaveCream: return "gray"
        case .aftershave: return "blue"
        case .shaveGel: return "cyan"

        // Body care
        case .bodyLotion: return "green"
        case .bodyWash: return "blue"
        case .handCream: return "mint"

        // Hair care
        case .shampoo: return "brown"
        case .conditioner: return "brown"
        case .hairOil: return "yellow"
        case .hairMask: return "brown"

        // Specialized treatments
        case .chemicalPeel: return "red"
        case .micellarWater: return "blue"
        case .makeupRemover: return "pink"
        case .faceWash: return "blue"
        case .cleansingOil: return "yellow"
        case .cleansingBalm: return "gray"
        }
    }

    /// Whether this product type is optional in a routine
    var isOptional: Bool {
        switch self {
        case .cleanser, .moisturizer, .sunscreen:
            return false
        default:
            return true
        }
    }

    /// Default frequency for this product type
    var defaultFrequency: Frequency {
        switch self {
        case .cleanser, .moisturizer, .sunscreen:
            return .both
        case .toner, .faceSerum, .essence, .exfoliator, .retinol, .vitaminC, .niacinamide, .hyaluronicAcid, .peptide:
            return .dailyPM
        case .shaveCream, .aftershave, .shaveGel:
            return .dailyAM
        case .faceMask, .facialOil, .chemicalPeel, .hairMask:
            return .weekly(times: 1)
        default:
            return .both
        }
    }

    /// Category for grouping in UI
    var category: ProductCategory {
        switch self {
        case .cleanser, .faceWash, .cleansingOil, .cleansingBalm, .micellarWater, .makeupRemover:
            return .cleansing
        case .toner, .facialMist:
            return .toning
        case .faceSerum, .essence, .exfoliator, .spotTreatment, .retinol, .vitaminC, .niacinamide, .hyaluronicAcid, .peptide, .chemicalPeel:
            return .treatment
        case .moisturizer, .eyeCream, .facialOil:
            return .moisturizing
        case .sunscreen, .faceSunscreen, .bodySunscreen, .lipBalm:
            return .sunProtection
        case .faceMask, .hairMask:
            return .masks
        case .shaveCream, .aftershave, .shaveGel:
            return .shaving
        case .bodyLotion, .bodyWash, .handCream:
            return .bodyCare
        case .shampoo, .conditioner, .hairOil:
            return .hairCare
        }
    }
}

/// Product categories for UI grouping
enum ProductCategory: String, CaseIterable {
    case cleansing = "Cleansing"
    case toning = "Toning"
    case treatment = "Treatment"
    case moisturizing = "Moisturizing"
    case sunProtection = "Sun Protection"
    case masks = "Masks"
    case shaving = "Shaving"
    case bodyCare = "Body Care"
    case hairCare = "Hair Care"

    var displayName: String {
        switch self {
        case .cleansing: return L10n.Products.Category.cleansing
        case .toning: return L10n.Products.Category.toning
        case .treatment: return L10n.Products.Category.treatment
        case .moisturizing: return L10n.Products.Category.moisturizing
        case .sunProtection: return L10n.Products.Category.sunProtection
        case .masks: return L10n.Products.Category.masks
        case .shaving: return L10n.Products.Category.shaving
        case .bodyCare: return L10n.Products.Category.bodyCare
        case .hairCare: return L10n.Products.Category.hairCare
        }
    }

    var iconName: String {
        switch self {
        case .cleansing: return ProductIconManager.getIconName(for: .cleanser)
        case .toning: return ProductIconManager.getIconName(for: .toner)
        case .treatment: return ProductIconManager.getIconName(for: .faceSerum)
        case .moisturizing: return ProductIconManager.getIconName(for: .moisturizer)
        case .sunProtection: return ProductIconManager.getIconName(for: .sunscreen)
        case .masks: return ProductIconManager.getIconName(for: .faceMask)
        case .shaving: return ProductIconManager.getIconName(for: .shaveCream)
        case .bodyCare: return ProductIconManager.getIconName(for: .bodyLotion)
        case .hairCare: return ProductIconManager.getIconName(for: .shampoo)
        }
    }
}


// MARK: - Frequency System

/// Frequency options for routine steps
enum Frequency: Codable, Equatable {
    case dailyAM
    case dailyPM
    case both
    case weekly(times: Int)
    case custom([String]) // e.g., ["Mon","Wed","Fri"]

    var displayName: String {
        switch self {
        case .dailyAM: return L10n.Routines.Frequency.dailyAM
        case .dailyPM: return L10n.Routines.Frequency.dailyPM
        case .both: return L10n.Routines.Frequency.both
        case .weekly(let times): return L10n.Routines.Frequency.weekly(times)
        case .custom(let days): return L10n.Routines.Frequency.custom(days.joined(separator: ", "))
        }
    }

    var description: String {
        switch self {
        case .dailyAM: return L10n.Routines.Frequency.Description.dailyAM
        case .dailyPM: return L10n.Routines.Frequency.Description.dailyPM
        case .both: return L10n.Routines.Frequency.Description.both
        case .weekly(let times): return L10n.Routines.Frequency.Description.weekly(times)
        case .custom(let days): return L10n.Routines.Frequency.Description.custom(days.joined(separator: ", "))
        }
    }
}

// MARK: - Product Tagging System

/// Comprehensive tagging system for products
struct ProductTagging: Codable, Equatable {
    let productType: ProductType       // primary product type
    let ingredients: [String]          // INCI hints (niacinamide, zinc PCA, AHA, BHA, PHA…)
    let claims: [String]               // "fragranceFree", "vegan", "sensitiveSafe"

    init(productType: ProductType, ingredients: [String] = [], claims: [String] = []) {
        self.productType = productType
        self.ingredients = ingredients
        self.claims = claims
    }
}

// MARK: - Product Alias System

/// Maps flexible product names to canonical product types
struct ProductAliasMapping {
    static let aliases: [String: ProductType] = [
        // Cleanser aliases
        "cleanser": .cleanser,
        "face wash": .faceWash,
        "facial cleanser": .cleanser,
        "cleansing gel": .cleanser,
        "cleansing cream": .cleanser,
        "milk cleanser": .cleanser,
        "cleansing oil": .cleansingOil,
        "oil cleanser": .cleansingOil,
        "cleansing balm": .cleansingBalm,
        "micellar water": .micellarWater,
        "makeup remover": .makeupRemover,

        // Moisturizer aliases
        "moisturizer": .moisturizer,
        "face cream": .moisturizer,
        "face lotion": .moisturizer,
        "moisturizing cream": .moisturizer,
        "moisturizing gel": .moisturizer,
        "gel moisturizer": .moisturizer,
        "eye cream": .eyeCream,

        // Sunscreen aliases
        "sunscreen": .sunscreen,
        "spf": .sunscreen,
        "sun protection": .sunscreen,
        "face sunscreen": .faceSunscreen,
        "body sunscreen": .bodySunscreen,
        "lip balm": .lipBalm,

        // Treatment aliases
        "serum": .faceSerum,
        "face serum": .faceSerum,
        "essence": .essence,
        "ampoule": .faceSerum,
        "exfoliator": .exfoliator,
        "peel": .exfoliator,
        "chemical peel": .chemicalPeel,
        "spot treatment": .spotTreatment,
        "acne treatment": .spotTreatment,
        "retinol": .retinol,
        "vitamin c": .vitaminC,
        "ascorbic acid": .vitaminC,
        "niacinamide": .niacinamide,
        "hyaluronic acid": .hyaluronicAcid,
        "ha serum": .hyaluronicAcid,
        "peptide": .peptide,
        "peptide complex": .peptide,
        "peptide serum": .peptide,

        // Toner aliases
        "toner": .toner,
        "facial mist": .facialMist,
        "face mist": .facialMist,
        "facial spray": .facialMist,

        // Face oil aliases
        "face oil": .facialOil,
        "facial oil": .facialOil,
        "oil": .facialOil,

        // Mask aliases
        "face mask": .faceMask,
        "clay mask": .faceMask,
        "sheet mask": .faceMask,
        "sleeping mask": .faceMask,
        "overnight mask": .faceMask,

        // Shave aliases
        "shave cream": .shaveCream,
        "shaving cream": .shaveCream,
        "shave gel": .shaveGel,
        "shaving gel": .shaveGel,
        "shave foam": .shaveCream,

        // Aftershave aliases
        "aftershave": .aftershave,
        "after shave": .aftershave,
        "post shave": .aftershave,
        "aftershave balm": .aftershave,
        "soothing balm": .aftershave,

        // Body care aliases
        "body lotion": .bodyLotion,
        "body wash": .bodyWash,
        "hand cream": .handCream,

        // Hair care aliases
        "shampoo": .shampoo,
        "conditioner": .conditioner,
        "hair oil": .hairOil,
        "hair mask": .hairMask
    ]

    /// Normalize a product name to canonical product type
    static func normalize(_ productName: String) -> ProductType {
        let normalized = productName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Try direct match first
        if let productType = aliases[normalized] {
            return productType
        }

        // CRITICAL FIX: Try removing spaces/underscores for camelCase handling
        // e.g., "hyaluronicAcid" -> "hyaluronicacid" matches "hyaluronic acid" -> "hyaluronicacid"
        let normalizedNoSpaces = normalized.replacingOccurrences(of: " ", with: "")
                                          .replacingOccurrences(of: "_", with: "")
        
        // Check if any alias (with spaces removed) matches
        for (alias, productType) in aliases {
            let aliasNoSpaces = alias.replacingOccurrences(of: " ", with: "")
                                    .replacingOccurrences(of: "_", with: "")
            if normalizedNoSpaces == aliasNoSpaces {
                return productType
            }
        }

        // Partial match - find the best match (only as fallback)
        for (alias, productType) in aliases {
            if normalized.contains(alias) || alias.contains(normalized) {
                return productType
            }
        }

        // Default fallback - try to infer from keywords
        if normalized.contains("cleanser") || normalized.contains("wash") {
            return .cleanser
        } else if normalized.contains("moisturizer") || normalized.contains("cream") || normalized.contains("lotion") {
            return .moisturizer
        } else if normalized.contains("essence") {
            return .essence
        } else if normalized.contains("serum") || normalized.contains("treatment") {
            return .faceSerum
        } else if normalized.contains("sunscreen") || normalized.contains("spf") {
            return .sunscreen
        } else if normalized.contains("toner") {
            return .toner
        } else if normalized.contains("oil") {
            return .facialOil
        } else if normalized.contains("mask") {
            return .faceMask
        } else {
            // Ultimate fallback
            return .faceSerum
        }
    }
}

// MARK: - Updated Product Model

/// Updated Product model using the new tagging system
struct Product: Codable, Identifiable, Equatable {
    var id: String
    var displayName: String
    var tagging: ProductTagging
    var brand: String?
    var link: URL?
    var imageURL: URL?
    var size: String?
    var description: String?
    var enrichedINCI: [INCIEntry]?

    init(id: String, displayName: String, tagging: ProductTagging, brand: String? = nil, link: URL? = nil, imageURL: URL? = nil, size: String? = nil, description: String? = nil, enrichedINCI: [INCIEntry]? = nil) {
        self.id = id
        self.displayName = displayName
        self.tagging = tagging
        self.brand = brand
        self.link = link
        self.imageURL = imageURL
        self.size = size
        self.description = description
        self.enrichedINCI = enrichedINCI
    }

    /// Create a product from a product name with automatic tagging
    static func fromName(_ name: String, brand: String? = nil) -> Product {
        let productType = ProductAliasMapping.normalize(name)
        let tagging = ProductTagging(productType: productType)

        return Product(
            id: UUID().uuidString,
            displayName: name,
            tagging: tagging,
            brand: brand
        )
    }
}

// MARK: - Updated Routine Step Model

/// Updated routine step using ProductType
struct RoutineStep: Codable, Identifiable, Equatable {
    let id: String
    let productType: ProductType
    let title: String           // UI: "Gentle Cleanser", "Niacinamide Serum"
    let instructions: String    // how/why
    let frequency: Frequency
    let constraints: Constraints

    init(productType: ProductType, title: String, instructions: String, frequency: Frequency? = nil, constraints: Constraints = Constraints()) {
        self.id = UUID().uuidString
        self.productType = productType
        self.title = title
        self.instructions = instructions
        self.frequency = frequency ?? productType.defaultFrequency
        self.constraints = constraints
    }
}

// MARK: - Product Slot Recommendation

/// Recommendation for a product type
struct ProductTypeRecommendation: Codable, Identifiable, Equatable {
    let id: String
    let productType: ProductType
    let notes: String?
    let constraints: Constraints

    init(productType: ProductType, notes: String? = nil, constraints: Constraints = Constraints()) {
        self.id = UUID().uuidString
        self.productType = productType
        self.notes = notes
        self.constraints = constraints
    }
}

// MARK: - Migration Helpers
// Removed per request: no migration helpers are needed.

// MARK: - Taxonomy Versioning

/// Version tracking for taxonomy updates
struct TaxonomyVersion: Codable {
    let version: String
    let updatedAt: Date

    static let current = TaxonomyVersion(version: "1.0.0", updatedAt: Date())
}
