//
//  ProductNormalizationExample.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Example Usage

/// Example usage of ProductNormalizationService
class ProductNormalizationExample {
    
    private let normalizationService: ProductNormalizationService
    private var outputResults: [String] = []
    
    init() {
        self.normalizationService = ProductNormalizationService()
    }
    
    /// Get the output results
    var results: [String] {
        return outputResults
    }
    
    /// Clear results
    func clearResults() {
        outputResults.removeAll()
    }
    
    /// Add a result line
    private func addResult(_ message: String) {
        outputResults.append(message)
    }
    
    // MARK: - Example Methods
    
    /// Example: Normalize a single product from OCR text
    func exampleSingleProductNormalization() async {
        addResult("🔍 ProductNormalizationExample: Starting single product normalization example")
        
        let ocrText = "CeraVe Foaming Facial Cleanser 16 fl oz"
        
        do {
            let response = try await normalizationService.normalizeProduct(ocrText: ocrText)
            
            addResult("✅ Normalization successful:")
            addResult("   Brand: \(response.brand ?? "Unknown")")
            addResult("   Product Name: \(response.productName)")
            addResult("   Product Type: \(response.productType)")
            addResult("   Confidence: \(response.confidence)")
            
            // Convert to Product
            let product = response.toProduct()
            addResult("   Created Product: \(product.displayName)")
            addResult("   Product Type: \(product.tagging.productType.displayName)")
            
        } catch {
            addResult("❌ Normalization failed: \(error)")
        }
    }
    
    /// Example: Normalize multiple products in batch
    func exampleBatchNormalization() async {
        addResult("🔍 ProductNormalizationExample: Starting batch normalization example")
        
        let ocrTexts = [
            "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
            "The Ordinary Niacinamide 10% + Zinc 1%",
            "CeraVe Daily Moisturizing Lotion",
            "Paula's Choice 2% BHA Liquid Exfoliant"
        ]
        
        do {
            let responses = try await normalizationService.normalizeProducts(ocrTexts: ocrTexts)
            
            addResult("✅ Batch normalization successful:")
            for (index, response) in responses.enumerated() {
                addResult("   Product \(index + 1):")
                addResult("     Brand: \(response.brand ?? "Unknown")")
                addResult("     Name: \(response.productName)")
                addResult("     Type: \(response.productType)")
                addResult("     Confidence: \(response.confidence)")
                addResult("")
            }
            
        } catch {
            addResult("❌ Batch normalization failed: \(error)")
        }
    }
    
    /// Example: Quick normalization with convenience method
    func exampleQuickNormalization() async {
        addResult("🔍 ProductNormalizationExample: Starting quick normalization example")
        
        let ocrText = "La Roche-Posay Toleriane Double Repair Face Moisturizer"
        
        do {
            let response = try await ProductNormalizationService.quickNormalize(ocrText: ocrText)
            
            addResult("✅ Quick normalization successful:")
            addResult("   Brand: \(response.brand ?? "Unknown")")
            addResult("   Product Name: \(response.productName)")
            addResult("   Product Type: \(response.productType)")
            addResult("   Confidence: \(response.confidence)")
            
        } catch {
            addResult("❌ Quick normalization failed: \(error)")
        }
    }
    
    /// Example: Normalize and create Product directly
    func exampleNormalizeToProduct() async {
        addResult("🔍 ProductNormalizationExample: Starting normalize to product example")
        
        let ocrText = "Kiehl's Ultra Facial Cream"
        
        do {
            let product = try await normalizationService.normalizeToProduct(ocrText: ocrText)
            
            addResult("✅ Direct product creation successful:")
            addResult("   Product ID: \(product.id)")
            addResult("   Display Name: \(product.displayName)")
            addResult("   Brand: \(product.brand ?? "Unknown")")
            addResult("   Product Type: \(product.tagging.productType.displayName)")
            
        } catch {
            addResult("❌ Direct product creation failed: \(error)")
        }
    }
    
    /// Example: Handle various OCR text formats
    func exampleVariousOCRFormats() async {
        addResult("🔍 ProductNormalizationExample: Testing various OCR text formats")
        
        let testCases = [
            "CeraVe Foaming Facial Cleanser 16 fl oz",
            "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
            "The Ordinary Niacinamide 10% + Zinc 1%",
            "Paula's Choice 2% BHA Liquid Exfoliant",
            "La Roche-Posay Toleriane Double Repair Face Moisturizer",
            "Kiehl's Ultra Facial Cream",
            "Drunk Elephant C-Firma Vitamin C Day Serum",
            "Olay Regenerist Micro-Sculpting Cream",
            "Aveeno Positively Radiant Daily Moisturizer SPF 30",
            "Cetaphil Gentle Skin Cleanser"
        ]
        
        for (index, ocrText) in testCases.enumerated() {
            addResult("\n--- Test Case \(index + 1) ---")
            addResult("OCR Text: \(ocrText)")
            
            do {
                let response = try await normalizationService.normalizeProduct(ocrText: ocrText)
                addResult("✅ Result:")
                addResult("   Brand: \(response.brand ?? "Unknown")")
                addResult("   Name: \(response.productName)")
                addResult("   Type: \(response.productType)")
                addResult("   Confidence: \(response.confidence)")
            } catch {
                addResult("❌ Failed: \(error)")
            }
        }
    }
    
    /// Run all examples
    func runAllExamples() async {
        clearResults()
        addResult("🚀 ProductNormalizationExample: Running all examples")
        addResult("=" * 60)
        
        await exampleSingleProductNormalization()
        addResult("\n" + "=" * 60)
        
        await exampleBatchNormalization()
        addResult("\n" + "=" * 60)
        
        await exampleQuickNormalization()
        addResult("\n" + "=" * 60)
        
        await exampleNormalizeToProduct()
        addResult("\n" + "=" * 60)
        
        await exampleVariousOCRFormats()
        
        addResult("\n🎉 ProductNormalizationExample: All examples completed!")
    }
}

// MARK: - SwiftUI Preview

struct ProductNormalizationExampleView: View {
    
    @State private var isRunning = false
    @State private var results: [String] = []
    
    private let example = ProductNormalizationExample()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Product Normalization Examples")
                    .font(.title.weight(.bold))
                
                Text("Test the GPT-powered product normalization system")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if isRunning {
                    VStack {
                        ProgressView()
                        Text("Running examples...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(results, id: \.self) { result in
                            Text(result)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Button(action: runExamples) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Run Examples")
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    .padding()
                    .background(ThemeManager.shared.theme.palette.info)
                    .cornerRadius(8)
                }
                .disabled(isRunning)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Normalization Examples")
        }
    }
    
    private func runExamples() {
        isRunning = true
        results = []
        
        Task<Void, Never> {
            // Run examples and capture output
            await example.runAllExamples()
            
            DispatchQueue.main.async {
                self.results = self.example.results
                self.isRunning = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProductNormalizationExampleView()
}
