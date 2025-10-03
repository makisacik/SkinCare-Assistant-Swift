//
//  LLMClient.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - LLM Client Protocol

/// Protocol for LLM operations in the product agent
protocol LLMClient {
    func refineQuery(brand: String?, name: String, ocr: String) async throws -> [(brand: String?, name: String)]
    func enrichIngredients(from ingredientsText: String) async throws -> [INCIEntry]
}

// MARK: - Query Refinement Response

struct QueryRefinementResponse: Codable {
    let brand: String?
    let name: String
}

// MARK: - OpenAI LLM Client Implementation

/// OpenAI-based LLM client for product agent operations
final class OpenAILLMClient: LLMClient {
    private let gptService: GPTService
    
    init(gptService: GPTService = GPTService.shared) {
        self.gptService = gptService
    }
    
    /// Refine search query by generating alternate brand/name combinations
    func refineQuery(brand: String?, name: String, ocr: String) async throws -> [(brand: String?, name: String)] {
        let system = """
        You are a query refiner for a cosmetics search engine. Generate 2-3 alternate search queries.
        Rules: remove marketing fluff, fix OCR errors, use brand aliases, simplify product names.
        
        IMPORTANT: Respond with ONLY a JSON array, no other text:
        [
          {"brand": "corrected_brand", "name": "simplified_name"},
          {"brand": "brand_alias", "name": "alternative_name"},
          {"brand": null, "name": "generic_search"}
        ]
        """
        
        let user = """
        OCR Text: \(ocr)
        Current Brand: \(brand ?? "unknown")
        Current Name: \(name)
        
        Generate 2-3 refined search queries to find this product in a cosmetics database.
        """
        
        let json = try await callJSON(system: system, user: user)
        print("🔍 LLM Query Refinement Response: \(json)")
        
        do {
            let data = Data(json.utf8)
            
            // Try to decode as direct array first
            if let responses = try? JSONDecoder().decode([QueryRefinementResponse].self, from: data) {
                return responses.map { (brand: $0.brand, name: $0.name) }
            }
            
            // Try to decode as wrapped object with "results" key
            struct WrappedResponse: Codable {
                let results: [QueryRefinementResponse]
            }
            
            if let wrapped = try? JSONDecoder().decode(WrappedResponse.self, from: data) {
                return wrapped.results.map { (brand: $0.brand, name: $0.name) }
            }
            
            throw NSError(domain: "LLMClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode JSON response"])
            
        } catch {
            print("❌ Failed to decode query refinement response: \(error)")
            print("   Raw JSON: \(json)")
            // Fallback: return simplified versions
            return [
                (brand: brand, name: QueryRefiner.stripNoise(name)),
                (brand: nil, name: name.components(separatedBy: " ").prefix(3).joined(separator: " "))
            ]
        }
    }
    
    /// Enrich ingredients by mapping to structured INCI entries
    func enrichIngredients(from ingredientsText: String) async throws -> [INCIEntry] {
        guard !ingredientsText.isEmpty else { return [] }
        
        let system = """
        You map raw ingredient strings to structured INCI records.
        For each ingredient, output: {"name": "INCI_name", "function": "role", "concerns": ["notes"]}.
        Keep original order. Respond with ONLY a JSON array, no other text:
        [
          {"name": "Aqua", "function": "solvent", "concerns": null},
          {"name": "Niacinamide", "function": "skin conditioning", "concerns": ["may irritate sensitive skin"]}
        ]
        """
        
        let user = "Ingredients: \(ingredientsText)"
        
        do {
            let json = try await callJSON(system: system, user: user)
            print("🔍 LLM Ingredient Enrichment Response: \(json.prefix(200))...")
            
            let data = Data(json.utf8)
            return try JSONDecoder().decode([INCIEntry].self, from: data)
        } catch {
            print("❌ Failed to enrich ingredients: \(error)")
            print("   Ingredients text: \(ingredientsText)")
            // Fallback: return basic INCI entries
            return ingredientsText
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { INCIEntry(name: $0, function: nil, concerns: nil) }
        }
    }
    
    /// Call LLM with JSON response format
    private func callJSON(system: String, user: String) async throws -> String {
        return try await gptService.completeJSON(
            systemPrompt: system,
            userPrompt: user,
            timeout: 15
        )
    }
}
