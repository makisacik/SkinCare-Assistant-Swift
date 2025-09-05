//
//  ProductTaxonomy.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Core Taxonomy

/// Canonical slot types that define where products live in a routine (UI-facing, small enum)
enum SlotType: String, Codable, CaseIterable, Identifiable {
    case cleanser
    case toner
    case treatment
    case moisturizer
    case sunscreen
    case shave
    case aftershave
    case mask
    case faceOil
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .cleanser: return "Cleanser"
        case .toner: return "Toner"
        case .treatment: return "Treatment"
        case .moisturizer: return "Moisturizer"
        case .sunscreen: return "Sunscreen"
        case .shave: return "Shave"
        case .aftershave: return "Aftershave"
        case .mask: return "Mask"
        case .faceOil: return "Face Oil"
        }
    }
    
    /// Icon name for UI
    var iconName: String {
        switch self {
        case .cleanser: return "drop.fill"
        case .toner: return "sparkles"
        case .treatment: return "star.fill"
        case .moisturizer: return "drop.circle.fill"
        case .sunscreen: return "sun.max.fill"
        case .shave: return "scissors"
        case .aftershave: return "wind"
        case .mask: return "face.smiling"
        case .faceOil: return "drop.triangle.fill"
        }
    }
    
    /// Color for UI
    var color: String {
        switch self {
        case .cleanser: return "blue"
        case .toner: return "purple"
        case .treatment: return "indigo"
        case .moisturizer: return "green"
        case .sunscreen: return "yellow"
        case .shave: return "gray"
        case .aftershave: return "orange"
        case .mask: return "pink"
        case .faceOil: return "brown"
        }
    }
    
    /// Whether this slot is optional in a routine
    var isOptional: Bool {
        switch self {
        case .toner, .shave, .aftershave, .mask, .faceOil:
            return true
        case .cleanser, .treatment, .moisturizer, .sunscreen:
            return false
        }
    }
    
    /// Default frequency for this slot type
    var defaultFrequency: Frequency {
        switch self {
        case .cleanser, .moisturizer, .sunscreen:
            return .both
        case .treatment, .toner:
            return .dailyPM
        case .shave, .aftershave:
            return .dailyAM
        case .mask, .faceOil:
            return .weekly(times: 1)
        }
    }
}

/// More granular product subtypes for filtering and search
enum ProductSubtype: String, Codable, CaseIterable, Identifiable {
    // Treatments
    case serum
    case exfoliant
    case spotTreatment
    case retinoid
    case vitaminC
    case niacinamide
    case aha
    case bha
    case pha
    
    // Shave products
    case shaveCream
    case shaveGel
    case aftershaveLotion
    case aftershaveBalm
    
    // Masks
    case clayMask
    case sheetMask
    case sleepingMask
    
    // Base product types
    case gelCleanser
    case creamCleanser
    case lotionMoisturizer
    case gelMoisturizer
    case mineralSPF
    case chemicalSPF
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .serum: return "Serum"
        case .exfoliant: return "Exfoliant"
        case .spotTreatment: return "Spot Treatment"
        case .retinoid: return "Retinoid"
        case .vitaminC: return "Vitamin C"
        case .niacinamide: return "Niacinamide"
        case .aha: return "AHA"
        case .bha: return "BHA"
        case .pha: return "PHA"
        case .shaveCream: return "Shave Cream"
        case .shaveGel: return "Shave Gel"
        case .aftershaveLotion: return "Aftershave Lotion"
        case .aftershaveBalm: return "Aftershave Balm"
        case .clayMask: return "Clay Mask"
        case .sheetMask: return "Sheet Mask"
        case .sleepingMask: return "Sleeping Mask"
        case .gelCleanser: return "Gel Cleanser"
        case .creamCleanser: return "Cream Cleanser"
        case .lotionMoisturizer: return "Lotion Moisturizer"
        case .gelMoisturizer: return "Gel Moisturizer"
        case .mineralSPF: return "Mineral SPF"
        case .chemicalSPF: return "Chemical SPF"
        }
    }
    
    /// Which slot type this subtype belongs to
    var primarySlot: SlotType {
        switch self {
        case .serum, .exfoliant, .spotTreatment, .retinoid, .vitaminC, .niacinamide, .aha, .bha, .pha:
            return .treatment
        case .shaveCream, .shaveGel:
            return .shave
        case .aftershaveLotion, .aftershaveBalm:
            return .aftershave
        case .clayMask, .sheetMask, .sleepingMask:
            return .mask
        case .gelCleanser, .creamCleanser:
            return .cleanser
        case .lotionMoisturizer, .gelMoisturizer:
            return .moisturizer
        case .mineralSPF, .chemicalSPF:
            return .sunscreen
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
        case .dailyAM: return "Daily (AM)"
        case .dailyPM: return "Daily (PM)"
        case .both: return "Daily (AM & PM)"
        case .weekly(let times): return "\(times)x per week"
        case .custom(let days): return "Custom (\(days.joined(separator: ", ")))"
        }
    }
    
    var description: String {
        switch self {
        case .dailyAM: return "Use every morning"
        case .dailyPM: return "Use every evening"
        case .both: return "Use morning and evening"
        case .weekly(let times): return "Use \(times) times per week"
        case .custom(let days): return "Use on \(days.joined(separator: ", "))"
        }
    }
}

// MARK: - Product Tagging System

/// Comprehensive tagging system for products
struct ProductTagging: Codable, Equatable {
    let slot: SlotType                 // primary slot
    let subtypes: [ProductSubtype]     // granular hints (filtering/search)
    let ingredients: [String]          // INCI hints (niacinamide, zinc PCA…)
    let claims: [String]               // "fragranceFree", "vegan", "sensitiveSafe"
    let budget: Budget                 // low|mid|high
    
    init(slot: SlotType, subtypes: [ProductSubtype] = [], ingredients: [String] = [], claims: [String] = [], budget: Budget = .mid) {
        self.slot = slot
        self.subtypes = subtypes
        self.ingredients = ingredients
        self.claims = claims
        self.budget = budget
    }
}

// MARK: - Product Alias System

/// Maps flexible product names to canonical slots
struct ProductAliasMapping {
    static let aliases: [String: (slot: SlotType, subtype: ProductSubtype?)] = [
        // Treatment aliases
        "essence": (.treatment, .serum),
        "ampoule": (.treatment, .serum),
        "peel": (.treatment, .exfoliant),
        "chemical peel": (.treatment, .exfoliant),
        "acne treatment": (.treatment, .spotTreatment),
        "spot treatment": (.treatment, .spotTreatment),
        "retinol": (.treatment, .retinoid),
        "vitamin c": (.treatment, .vitaminC),
        "ascorbic acid": (.treatment, .vitaminC),
        "niacinamide": (.treatment, .niacinamide),
        "glycolic acid": (.treatment, .aha),
        "salicylic acid": (.treatment, .bha),
        "lactic acid": (.treatment, .aha),
        
        // Cleanser aliases
        "face wash": (.cleanser, .gelCleanser),
        "facial cleanser": (.cleanser, .gelCleanser),
        "cleansing gel": (.cleanser, .gelCleanser),
        "cleansing cream": (.cleanser, .creamCleanser),
        "milk cleanser": (.cleanser, .creamCleanser),
        
        // Moisturizer aliases
        "face cream": (.moisturizer, .lotionMoisturizer),
        "face lotion": (.moisturizer, .lotionMoisturizer),
        "moisturizing cream": (.moisturizer, .lotionMoisturizer),
        "moisturizing gel": (.moisturizer, .gelMoisturizer),
        "gel moisturizer": (.moisturizer, .gelMoisturizer),
        
        // Sunscreen aliases
        "sunscreen": (.sunscreen, .chemicalSPF),
        "spf": (.sunscreen, .chemicalSPF),
        "sun protection": (.sunscreen, .chemicalSPF),
        "mineral sunscreen": (.sunscreen, .mineralSPF),
        "zinc oxide": (.sunscreen, .mineralSPF),
        "titanium dioxide": (.sunscreen, .mineralSPF),
        
        // Shave aliases
        "shaving cream": (.shave, .shaveCream),
        "shaving gel": (.shave, .shaveGel),
        "shave foam": (.shave, .shaveCream),
        
        // Aftershave aliases
        "after shave": (.aftershave, .aftershaveLotion),
        "aftershave": (.aftershave, .aftershaveLotion),
        "post shave": (.aftershave, .aftershaveLotion),
        "aftershave balm": (.aftershave, .aftershaveBalm),
        "soothing balm": (.aftershave, .aftershaveBalm),
        
        // Face oil aliases
        "face oil": (.faceOil, nil),
        "facial oil": (.faceOil, nil),
        "oil": (.faceOil, nil),
        
        // Mask aliases
        "face mask": (.mask, .clayMask),
        "clay mask": (.mask, .clayMask),
        "sheet mask": (.mask, .sheetMask),
        "sleeping mask": (.mask, .sleepingMask),
        "overnight mask": (.mask, .sleepingMask)
    ]
    
    /// Normalize a product name to canonical slot and subtype
    static func normalize(_ productName: String) -> (slot: SlotType, subtype: ProductSubtype?) {
        let normalized = productName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct match
        if let mapping = aliases[normalized] {
            return mapping
        }
        
        // Partial match - find the best match
        for (alias, mapping) in aliases {
            if normalized.contains(alias) || alias.contains(normalized) {
                return mapping
            }
        }
        
        // Default fallback - try to infer from keywords
        if normalized.contains("cleanser") || normalized.contains("wash") {
            return (.cleanser, .gelCleanser)
        } else if normalized.contains("moisturizer") || normalized.contains("cream") || normalized.contains("lotion") {
            return (.moisturizer, .lotionMoisturizer)
        } else if normalized.contains("serum") || normalized.contains("treatment") {
            return (.treatment, .serum)
        } else if normalized.contains("sunscreen") || normalized.contains("spf") {
            return (.sunscreen, .chemicalSPF)
        } else {
            // Ultimate fallback
            return (.treatment, .serum)
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
    var price: Double?
    var size: String?
    var description: String?
    
    init(id: String, displayName: String, tagging: ProductTagging, brand: String? = nil, link: URL? = nil, imageURL: URL? = nil, price: Double? = nil, size: String? = nil, description: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.tagging = tagging
        self.brand = brand
        self.link = link
        self.imageURL = imageURL
        self.price = price
        self.size = size
        self.description = description
    }
    
    /// Create a product from a product name with automatic tagging
    static func fromName(_ name: String, brand: String? = nil, budget: Budget = .mid) -> Product {
        let (slot, subtype) = ProductAliasMapping.normalize(name)
        let subtypes = subtype.map { [$0] } ?? []
        let tagging = ProductTagging(slot: slot, subtypes: subtypes, budget: budget)
        
        return Product(
            id: UUID().uuidString,
            displayName: name,
            tagging: tagging,
            brand: brand
        )
    }
}

// MARK: - Updated Routine Step Model

/// Updated routine step using SlotType
struct RoutineStep: Codable, Identifiable, Equatable {
    let id: String
    let slot: SlotType
    let subtypes: [ProductSubtype]?
    let title: String           // UI: "Gentle Cleanser", "Niacinamide Serum"
    let instructions: String    // how/why
    let frequency: Frequency
    let constraints: Constraints
    
    init(slot: SlotType, subtypes: [ProductSubtype]? = nil, title: String, instructions: String, frequency: Frequency? = nil, constraints: Constraints = Constraints()) {
        self.id = UUID().uuidString
        self.slot = slot
        self.subtypes = subtypes
        self.title = title
        self.instructions = instructions
        self.frequency = frequency ?? slot.defaultFrequency
        self.constraints = constraints
    }
}

// MARK: - Product Slot Recommendation

/// Recommendation for a product slot
struct ProductSlotRecommendation: Codable, Identifiable, Equatable {
    let id: String
    let slot: SlotType
    let subtypes: [ProductSubtype]?
    let notes: String?
    let constraints: Constraints
    let budget: Budget?
    
    init(slot: SlotType, subtypes: [ProductSubtype]? = nil, notes: String? = nil, constraints: Constraints = Constraints(), budget: Budget? = nil) {
        self.id = UUID().uuidString
        self.slot = slot
        self.subtypes = subtypes
        self.notes = notes
        self.constraints = constraints
        self.budget = budget
    }
}

// MARK: - Migration Helpers

/// Helper for migrating from old StepType to new SlotType
extension SlotType {
    /// Convert from old StepType
    static func fromOldStepType(_ oldType: StepType) -> SlotType {
        switch oldType {
        case .cleanser: return .cleanser
        case .treatment: return .treatment
        case .moisturizer: return .moisturizer
        case .sunscreen: return .sunscreen
        case .optional: return .treatment // Map optional to treatment as default
        }
    }
}

/// Helper for migrating from old StepType
extension StepType {
    /// Convert to new SlotType
    func toSlotType() -> SlotType {
        return SlotType.fromOldStepType(self)
    }
}

// MARK: - Taxonomy Versioning

/// Version tracking for taxonomy updates
struct TaxonomyVersion: Codable {
    let version: String
    let updatedAt: Date
    
    static let current = TaxonomyVersion(version: "1.0.0", updatedAt: Date())
}
