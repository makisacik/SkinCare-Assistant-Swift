//
//  OpenBeautyFactsModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Open Beauty Facts Models

/// Response from Open Beauty Facts search API
struct OBFSearchResponse: Decodable {
    let products: [OBFProduct]
}

/// Product model from Open Beauty Facts API
struct OBFProduct: Decodable, Identifiable {
    var id: String { code ?? UUID().uuidString }
    let code: String?
    let brands: String?
    let product_name: String?
    let quantity: String?
    let ingredients_text: String?
    // handy when present (not always):
    let image_url: String?
    let image_front_small_url: String?
}

// MARK: - Product Scoring Models

/// Normalized product information from OCR/GPT processing
struct ProductGuess {
    let brand: String?
    let name: String
    let sizeHint: String?        // e.g., "150 ml"
    let keyINCI: [String]        // from your GPT normalization
}

/// OBF product with scoring information
struct RankedOBF {
    let product: OBFProduct
    let score: Double
}

/// UI-friendly product candidate for confirmation sheet
struct ProductCandidate: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageURL: URL?
    let score: Double
    let raw: OBFProduct
}

// MARK: - AI Agent Models

/// Structured INCI ingredient entry
struct INCIEntry: Codable, Equatable {
    let name: String              // canonical INCI
    let function: String?         // e.g., humectant, emollient
    let concerns: [String]?       // optional notes
}

/// Context for AI agent processing
struct AgentContext {
    let ocrText: String
    let normalized: ProductGuess
}

/// Enriched product with INCI data
struct EnrichedProduct {
    let obf: OBFProduct
    let inci: [INCIEntry]    // from Tool C
    let confidence: Double
}
