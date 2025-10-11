//
//  RoutineResponse.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Main Response Structure

struct RoutineResponse: Codable {
    let version: String
    let locale: String
    let summary: Summary
    let routine: Routine
    let guardrails: Guardrails
    let adaptation: Adaptation
    let productSlots: [ProductSlot]

    enum CodingKeys: String, CodingKey {
        case version, locale, summary, routine, guardrails, adaptation
        case productSlots = "product_slots"
    }
}

// MARK: - Summary

struct Summary: Codable {
    let title: String
    let oneLiner: String

    enum CodingKeys: String, CodingKey {
        case title
        case oneLiner = "one_liner"
    }
}

// MARK: - Routine

struct Routine: Codable {
    let depth: Depth
    let morning: [APIRoutineStep]
    let evening: [APIRoutineStep]
    let weekly: [APIRoutineStep]?
}

enum Depth: String, Codable { 
    case simple, intermediate, advanced 
}

// MARK: - Routine Step

struct APIRoutineStep: Codable {
    let step: ProductType
    let name: String
    let why: String
    let how: String
    let constraints: Constraints
}

// Removed StepType. Use ProductType everywhere.

// MARK: - Constraints

struct Constraints: Codable, Equatable {
    let spf: Int?
    let fragranceFree: Bool?
    let sensitiveSafe: Bool?
    let vegan: Bool?
    let crueltyFree: Bool?
    let avoidIngredients: [String]?
    let preferIngredients: [String]?

    init(spf: Int? = nil, fragranceFree: Bool? = nil, sensitiveSafe: Bool? = nil, vegan: Bool? = nil, crueltyFree: Bool? = nil, avoidIngredients: [String]? = nil, preferIngredients: [String]? = nil) {
        self.spf = spf
        self.fragranceFree = fragranceFree
        self.sensitiveSafe = sensitiveSafe
        self.vegan = vegan
        self.crueltyFree = crueltyFree
        self.avoidIngredients = avoidIngredients
        self.preferIngredients = preferIngredients
    }

    enum CodingKeys: String, CodingKey {
        case spf
        case fragranceFree = "fragrance_free"
        case sensitiveSafe = "sensitive_safe"
        case vegan
        case crueltyFree = "cruelty_free"
        case avoidIngredients = "avoid_ingredients"
        case preferIngredients = "prefer_ingredients"
    }
}

// MARK: - Guardrails

struct Guardrails: Codable {
    let cautions: [String]
    let whenToStop: [String]
    let sunNotes: String

    enum CodingKeys: String, CodingKey {
        case cautions
        case whenToStop = "when_to_stop"
        case sunNotes = "sun_notes"
    }
}

// MARK: - Adaptation

struct Adaptation: Codable {
    let forSkinType: String
    let forConcerns: [String]
    let forPreferences: [String]

    enum CodingKeys: String, CodingKey {
        case forSkinType = "for_skin_type"
        case forConcerns = "for_concerns"
        case forPreferences = "for_preferences"
    }
}

// MARK: - Product Slot

struct ProductSlot: Codable, Identifiable {
    let slotID: String
    let step: ProductType
    let time: SlotTime
    let constraints: Constraints
    let notes: String?

    var id: String { slotID }

    enum CodingKeys: String, CodingKey {
        case slotID = "slot_id"
        case step
        case time
        case constraints
        case notes
    }
}

enum SlotTime: String, Codable { 
    case AM, PM, Weekly 
}
