//
//  ProductScanManager.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

/// Manages the state of product scanning and navigation between scan and products tab
class ProductScanManager: ObservableObject {
    static let shared = ProductScanManager()

    @Published var scannedProductData: ScannedProductData?
    @Published var shouldNavigateToProducts = false
    @Published var showProductConfirmation = false
    @Published var productCandidates: [ProductCandidate] = []

    private let lookupService = ProductLookupService()
    private let productService = ProductService.shared
    private let agent = ProductInfoAgent()

    private init() {}

    /// Set the scanned product data and trigger navigation to products tab
    func setScannedProduct(extractedText: String, normalizedProduct: ProductNormalizationResponse) {
        scannedProductData = ScannedProductData(
            extractedText: extractedText,
            normalizedProduct: normalizedProduct
        )
        shouldNavigateToProducts = true
    }

    /// Clear the scanned product data
    func clearScannedProduct() {
        scannedProductData = nil
        shouldNavigateToProducts = false
        showProductConfirmation = false
        productCandidates = []
    }

    /// Resolve product using AI agent with query refinement and ingredient enrichment
    @MainActor
    func resolveProductWithAgent(ocrText: String, guess: ProductGuess) async {
        do {
            let context = AgentContext(ocrText: ocrText, normalized: guess)
            if let enriched = try await agent.run(context: context) {
                acceptEnrichedProduct(enriched)
                return
            }

            // Agent couldn't find high-confidence match, fall back to manual confirmation
            print("🤖 Agent: Falling back to manual confirmation")
            await resolveProduct(from: guess)
            
            // Let the user decide - don't auto-create fallback products
            print("📋 Letting user choose from candidates or select 'None'")

        } catch {
            print("❌ ProductScanManager: Agent failed - \(error)")
            // Fallback to direct resolution
            await resolveProduct(from: guess)
        }
    }

    /// Resolve product from normalized guess with confirmation flow (original method)
    @MainActor
    func resolveProduct(from guess: ProductGuess) async {
        do {
            let ranked = try await lookupService.findCandidates(for: guess)

            // Auto-accept if top score is high enough (lowered threshold for testing)
            if let top = ranked.first, top.score >= 0.6 { // Changed from 0.82 to 0.6 for testing
                acceptOBFProduct(top.product)
                return
            }

            // Show confirmation sheet for top 3 candidates
            print("🔍 Creating confirmation sheet with \(ranked.count) total candidates")
            let choices = ranked.prefix(3).map { rankedProduct in
                let candidate = ProductCandidate(
                    title: rankedProduct.product.product_name ?? "Unknown Product",
                    subtitle: [rankedProduct.product.brands, rankedProduct.product.quantity].compactMap{$0}.joined(separator: " • "),
                    imageURL: URL(string: rankedProduct.product.image_front_small_url ?? rankedProduct.product.image_url ?? ""),
                    score: rankedProduct.score,
                    raw: rankedProduct.product
                )
                print("   Candidate: \(candidate.title) | \(candidate.subtitle) | Score: \(candidate.score)")
                return candidate
            }
            
            productCandidates = Array(choices)
            print("📋 Setting \(productCandidates.count) candidates for confirmation sheet")
            showProductConfirmation = true
            print("✅ Confirmation sheet should now be visible")

        } catch {
            print("❌ ProductScanManager: Failed to resolve product - \(error)")
            // Fallback: create product from guess
            let fallbackProduct = ProductGuess(
                brand: guess.brand,
                name: guess.name,
                sizeHint: guess.sizeHint,
                keyINCI: guess.keyINCI
            )
            createFallbackProduct(from: fallbackProduct)
        }
    }

    /// Handle product selection from confirmation sheet
    func handleProductSelection(_ candidate: ProductCandidate?) {
        print("🎯 ProductScanManager: User made selection")
        if let candidate = candidate {
            print("   ✅ User selected: \(candidate.title) (Score: \(candidate.score))")
            acceptOBFProduct(candidate.raw)
        } else {
            print("   ❌ User selected 'None' - showing retry UI")
            // User selected "None" - show retry UI or fallback
            showRetryUI()
        }
        print("🔄 Closing confirmation sheet")
        showProductConfirmation = false
        productCandidates = []
    }

    /// Accept an enriched product with INCI data
    private func acceptEnrichedProduct(_ enriched: EnrichedProduct) {
        print("✅ ProductScanManager: Accepting enriched product - \(enriched.obf.product_name ?? "Unknown")")
        print("   Confidence: \(enriched.confidence)")
        print("   INCI entries: \(enriched.inci.count)")

        // Create Product from OBF data with enriched INCI data
        let product = productService.create(from: enriched.obf, enrichedINCI: enriched.inci)

        // Add to user's collection
        productService.addUserProduct(product)

        // Navigate to products tab
        shouldNavigateToProducts = true

        print("🎉 ProductScanManager: Enriched product added successfully")
    }

    /// Accept an OBF product and add it to the user's collection
    private func acceptOBFProduct(_ obf: OBFProduct) {
        print("✅ ProductScanManager: Accepting OBF product - \(obf.product_name ?? "Unknown")")

        // Create Product from OBF data
        let product = productService.create(from: obf, enrichedINCI: nil)

        // Add to user's collection
        productService.addUserProduct(product)

        // Navigate to products tab
        shouldNavigateToProducts = true

        print("🎉 ProductScanManager: Product added successfully")
    }

    /// Create a fallback product when lookup fails
    private func createFallbackProduct(from guess: ProductGuess) {
        print("⚠️ ProductScanManager: Creating fallback product")

        let product = productService.createProductFromName(
            guess.name,
            brand: guess.brand,
            additionalInfo: [
                "size": guess.sizeHint ?? "",
                "ingredients": guess.keyINCI,
                "description": "Scanned product"
            ]
        )

        productService.addUserProduct(product)
        shouldNavigateToProducts = true
    }

    /// Show retry UI when user selects "None"
    private func showRetryUI() {
        print("🔄 ProductScanManager: User selected 'None' - creating fallback product")
        
        // Create a fallback product from the last normalized data
        if let scannedData = scannedProductData {
            let product = productService.createProductFromName(
                scannedData.normalizedProduct.productName,
                brand: scannedData.normalizedProduct.brand,
                additionalInfo: [
                    "size": scannedData.normalizedProduct.size ?? "",
                    "ingredients": scannedData.normalizedProduct.ingredients,
                    "description": "Scanned product (no Open Beauty Facts match)"
                ]
            )
            
            productService.addUserProduct(product)
            shouldNavigateToProducts = true
            
            print("✅ Fallback product created from normalized data")
        } else {
            // No scanned data available, just clear
            clearScannedProduct()
        }
    }
}

/// Data structure for scanned product information
struct ScannedProductData {
    let extractedText: String
    let normalizedProduct: ProductNormalizationResponse
}
