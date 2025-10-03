//
//  ProductInfoAgent.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Product Info Agent

/// AI Agent for orchestrating product lookup with query refinement and ingredient enrichment
final class ProductInfoAgent {
    let lookup = ProductLookupService()
    let llm: LLMClient
    
    init(llm: LLMClient = OpenAILLMClient()) {
        self.llm = llm
    }
    
    /// Main entry point for agent processing
    func run(context: AgentContext) async throws -> EnrichedProduct? {
        print("🤖 ProductInfoAgent: Starting agent processing")
        print("   OCR: \(context.ocrText)")
        print("   Normalized: \(context.normalized.brand ?? "nil") | \(context.normalized.name)")
        
        // 1) First pass with normalized query
        var ranked = try await lookup.findCandidates(for: context.normalized)
        print("   First pass: \(ranked.count) candidates, top score: \(ranked.first?.score ?? 0)")
        
        if let top = ranked.first, top.score >= 0.82 {
            print("   ✅ High confidence match found, finalizing...")
            return try await finalize(obf: top.product, score: top.score)
        }
        
        // 2) Ask LLM to refine query (Tool B)
        print("   🔄 Low confidence, refining query with LLM...")
        let alternates: [(brand: String?, name: String)]
        do {
            alternates = try await llm.refineQuery(
                brand: context.normalized.brand,
                name: context.normalized.name,
                ocr: context.ocrText
            )
        } catch {
            print("   ❌ Query refinement failed: \(error)")
            // Fallback: use simple refinements
            alternates = [
                (brand: context.normalized.brand, name: QueryRefiner.stripNoise(context.normalized.name)),
                (brand: nil, name: context.normalized.name.components(separatedBy: " ").prefix(2).joined(separator: " "))
            ]
        }
        
        print("   Generated \(alternates.count) alternate queries:")
        alternates.forEach { print("     - \($0.brand ?? "nil") | \($0.name)") }
        
        // Try alternates until confident enough
        for (index, alt) in alternates.enumerated() {
            let g = ProductGuess(
                brand: alt.brand,
                name: alt.name,
                sizeHint: context.normalized.sizeHint,
                keyINCI: context.normalized.keyINCI
            )
            
            ranked = try await lookup.findCandidates(for: g)
            print("   Alternate \(index + 1): \(ranked.count) candidates, top score: \(ranked.first?.score ?? 0)")
            
            if let top = ranked.first, top.score >= 0.82 {
                print("   ✅ High confidence match found with alternate query, finalizing...")
                return try await finalize(obf: top.product, score: top.score)
            }
        }
        
        // 3) If still low confidence, return nil so UI can show sheet (Step 3)
        print("   ⚠️ No high confidence matches found, returning nil for UI confirmation")
        return nil
    }
    
    /// Finalize product with ingredient enrichment
    private func finalize(obf: OBFProduct, score: Double) async throws -> EnrichedProduct {
        print("   🧪 Enriching ingredients for: \(obf.product_name ?? "Unknown")")
        
        let inci: [INCIEntry]
        do {
            inci = try await llm.enrichIngredients(from: obf.ingredients_text ?? "")
            print("   ✅ Enriched \(inci.count) INCI entries")
        } catch {
            print("   ❌ Ingredient enrichment failed: \(error)")
            // Fallback: create basic entries from raw text
            inci = (obf.ingredients_text ?? "")
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { INCIEntry(name: $0, function: nil, concerns: nil) }
            print("   🔄 Created \(inci.count) basic INCI entries as fallback")
        }
        
        return EnrichedProduct(obf: obf, inci: inci, confidence: score)
    }
}
