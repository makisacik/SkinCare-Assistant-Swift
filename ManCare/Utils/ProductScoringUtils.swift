//
//  ProductScoringUtils.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Query Refiner

/// Utilities for refining search queries by removing marketing noise
enum QueryRefiner {
    /// Remove marketing fluff and noise from product names
    static func stripNoise(_ s: String) -> String {
        let lowered = s.lowercased()
        // kill common noisy tokens; expand as you observe data
        let noise = ["for men", "for women", "new", "pro", "advanced", "spf", "broad spectrum",
                     "with", "fragrance free", "fragrance-free", "normal", "oily", "dry", "ml", "oz"]
        var out = lowered
        noise.forEach { out = out.replacingOccurrences(of: $0, with: " ") }
        // remove sizes like "150 ml", "6.7 oz"
        out = out.replacingOccurrences(of: #"\b\d+(\.\d+)?\s?(ml|oz|g)\b"#, with: " ", options: .regularExpression)
        return out.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression).trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Product Scorer

/// Utilities for scoring product matches using deterministic algorithms
enum ProductScorer {
    /// Calculate Jaccard similarity between two strings based on token overlap
    static func jaccardTokens(_ a: String, _ b: String) -> Double {
        let A = Set(a.lowercased().split(separator: " ").map(String.init))
        let B = Set(b.lowercased().split(separator: " ").map(String.init))
        guard !A.isEmpty && !B.isEmpty else { return 0 }
        return Double(A.intersection(B).count) / Double(A.union(B).count)
    }

    /// Score a candidate OBF product against a normalized product guess
    static func score(guess: ProductGuess, candidate: OBFProduct) -> Double {
        let brandScore: Double = {
            guard let gb = guess.brand?.lowercased(), let cb = candidate.brands?.lowercased(), !gb.isEmpty, !cb.isEmpty else { return 0.0 }
            // exact or token overlap
            return gb == cb ? 1.0 : jaccardTokens(gb, cb) * 0.8
        }()

        let nameScore: Double = {
            let g = QueryRefiner.stripNoise(guess.name)
            let c = QueryRefiner.stripNoise(candidate.product_name ?? "")
            return jaccardTokens(g, c)
        }()

        let sizeScore: Double = {
            guard let size = guess.sizeHint?.lowercased(), let q = candidate.quantity?.lowercased(), !size.isEmpty, !q.isEmpty else { return 0.0 }
            return q.contains(size) ? 0.2 : 0.0   // tiny bonus only
        }()

        let inciScore: Double = {
            guard !guess.keyINCI.isEmpty, let txt = candidate.ingredients_text?.lowercased() else { return 0.0 }
            let hits = guess.keyINCI.map { txt.contains($0.lowercased()) ? 1 : 0 }.reduce(0,+)
            return Double(hits) / Double(max(3, guess.keyINCI.count)) * 0.4 // cap influence
        }()

        // weighted blend
        return min(1.0, brandScore * 0.35 + nameScore * 0.45 + sizeScore + inciScore)
    }
}
