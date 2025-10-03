//
//  ProductLookupService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Product Lookup Service

/// Service for finding and ranking product candidates using Open Beauty Facts API
final class ProductLookupService {
    let client = OpenBeautyFactsClient()

    /// Find and rank product candidates for a given product guess
    /// - Parameter guess: Normalized product information from OCR/GPT processing
    /// - Returns: Array of ranked OBF products sorted by score (highest first)
    func findCandidates(for guess: ProductGuess) async throws -> [RankedOBF] {
        // primary query: brand + full name
        var products = try await client.search(brand: guess.brand, name: guess.name)
        
        // fallback if few/weak hits: refined name only
        if products.isEmpty {
            let refined = QueryRefiner.stripNoise(guess.name)
            products = try await client.search(brand: nil, name: refined)
        }
        
        // Score and rank all candidates
        let ranked = products.map { 
            RankedOBF(product: $0, score: ProductScorer.score(guess: guess, candidate: $0)) 
        }
        .sorted { $0.score > $1.score }
        
        return ranked
    }
}
