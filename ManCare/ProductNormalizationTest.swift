//
//  ProductNormalizationTest.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Test Cases

/// Test cases for ProductNormalizationService
struct ProductNormalizationTest {
    
    static let testCases = [
        // Cleansers
        "CeraVe Foaming Facial Cleanser 16 fl oz",
        "Neutrogena Ultra Gentle Daily Cleanser",
        "La Roche-Posay Toleriane Hydrating Gentle Cleanser",
        
        // Moisturizers
        "CeraVe Daily Moisturizing Lotion",
        "Neutrogena Hydro Boost Water Gel",
        "Kiehl's Ultra Facial Cream",
        
        // Sunscreens
        "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
        "EltaMD UV Clear Broad-Spectrum SPF 46",
        "La Roche-Posay Anthelios Ultra Light Sunscreen Fluid SPF 60",
        
        // Serums
        "The Ordinary Niacinamide 10% + Zinc 1%",
        "Drunk Elephant C-Firma Vitamin C Day Serum",
        "Paula's Choice 2% BHA Liquid Exfoliant",
        
        // Toners
        "Thayers Witch Hazel Toner",
        "The Ordinary Glycolic Acid 7% Toning Solution",
        
        // Face Oils
        "The Ordinary 100% Organic Cold-Pressed Rose Hip Seed Oil",
        "Drunk Elephant Virgin Marula Luxury Facial Oil",
        
        // Masks
        "The Ordinary AHA 30% + BHA 2% Peeling Solution",
        "Kiehl's Rare Earth Deep Pore Cleansing Masque",
        
        // Eye Creams
        "Kiehl's Creamy Eye Treatment with Avocado",
        "The Ordinary Caffeine Solution 5% + EGCG",
        
        // Shaving
        "Cremo Original Shave Cream",
        "Jack Black Supreme Cream Triple Cushion Shave Lather",
        
        // Body Care
        "CeraVe Daily Moisturizing Lotion for Normal to Dry Skin",
        "Neutrogena Body Clear Body Wash",
        
        // Hair Care
        "Head & Shoulders Classic Clean Shampoo",
        "The Ordinary Multi-Peptide Serum for Hair Density"
    ]
    
    /// Run all test cases
    static func runAllTests() async {
        print("🧪 ProductNormalizationTest: Starting comprehensive test suite")
        print("=" * 80)
        
        let service = ProductNormalizationService()
        var successCount = 0
        var totalCount = testCases.count
        
        for (index, ocrText) in testCases.enumerated() {
            print("\n--- Test \(index + 1)/\(totalCount) ---")
            print("OCR Text: \(ocrText)")
            
            do {
                let response = try await service.normalizeProduct(ocrText: ocrText)
                print("✅ SUCCESS:")
                print("   Brand: \(response.brand ?? "Unknown")")
                print("   Name: \(response.productName)")
                print("   Type: \(response.productType)")
                print("   Confidence: \(String(format: "%.2f", response.confidence))")
                
                // Validate the response
                let productType = response.toProductType()
                print("   Mapped to: \(productType.displayName)")
                
                successCount += 1
                
            } catch {
                print("❌ FAILED: \(error)")
            }
        }
        
        print("\n" + "=" * 80)
        print("🧪 Test Results:")
        print("   Total Tests: \(totalCount)")
        print("   Successful: \(successCount)")
        print("   Failed: \(totalCount - successCount)")
        print("   Success Rate: \(String(format: "%.1f", Double(successCount) / Double(totalCount) * 100))%")
        print("=" * 80)
    }
    
    /// Test specific product categories
    static func testProductCategories() async {
        print("🧪 ProductNormalizationTest: Testing product categories")
        print("=" * 60)
        
        let service = ProductNormalizationService()
        
        let categoryTests = [
            "Cleansers": [
                "CeraVe Foaming Facial Cleanser",
                "Neutrogena Ultra Gentle Daily Cleanser",
                "La Roche-Posay Toleriane Hydrating Gentle Cleanser"
            ],
            "Moisturizers": [
                "CeraVe Daily Moisturizing Lotion",
                "Neutrogena Hydro Boost Water Gel",
                "Kiehl's Ultra Facial Cream"
            ],
            "Sunscreens": [
                "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
                "EltaMD UV Clear Broad-Spectrum SPF 46",
                "La Roche-Posay Anthelios Ultra Light Sunscreen Fluid SPF 60"
            ],
            "Serums": [
                "The Ordinary Niacinamide 10% + Zinc 1%",
                "Drunk Elephant C-Firma Vitamin C Day Serum",
                "Paula's Choice 2% BHA Liquid Exfoliant"
            ]
        ]
        
        for (category, products) in categoryTests {
            print("\n--- Testing \(category) ---")
            
            for product in products {
                do {
                    let response = try await service.normalizeProduct(ocrText: product)
                    let productType = response.toProductType()
                    let isCorrect = productType.category.rawValue.lowercased().contains(category.lowercased()) ||
                                   category.lowercased().contains(productType.category.rawValue.lowercased())
                    
                    print("   \(product)")
                    print("   → \(response.productType) (\(productType.displayName))")
                    print("   → Category: \(productType.category.rawValue)")
                    print("   → Correct: \(isCorrect ? "✅" : "❌")")
                    print("   → Confidence: \(String(format: "%.2f", response.confidence))")
                    print("")
                    
                } catch {
                    print("   ❌ Failed: \(error)")
                }
            }
        }
    }
    
    /// Test edge cases and difficult OCR text
    static func testEdgeCases() async {
        print("🧪 ProductNormalizationTest: Testing edge cases")
        print("=" * 60)
        
        let service = ProductNormalizationService()
        
        let edgeCases = [
            // OCR artifacts
            "CeraVe Foaming Facial Cleanser 16 fl oz",
            "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
            
            // Partial text
            "CeraVe Foaming",
            "SPF 30",
            "Niacinamide 10%",
            
            // Mixed case
            "CERAVE FOAMING FACIAL CLEANSER",
            "neutrogena ultra gentle daily cleanser",
            "The Ordinary Niacinamide 10% + Zinc 1%",
            
            // Special characters
            "Drunk Elephant C-Firma Vitamin C Day Serum",
            "Paula's Choice 2% BHA Liquid Exfoliant",
            "Kiehl's Ultra Facial Cream",
            
            // Long names
            "La Roche-Posay Toleriane Double Repair Face Moisturizer with Ceramide and Niacinamide",
            "The Ordinary 100% Organic Cold-Pressed Rose Hip Seed Oil",
            
            // Ambiguous cases
            "Face Cream",
            "Serum",
            "Cleanser",
            "Sunscreen"
        ]
        
        for (index, ocrText) in edgeCases.enumerated() {
            print("\n--- Edge Case \(index + 1) ---")
            print("OCR Text: '\(ocrText)'")
            
            do {
                let response = try await service.normalizeProduct(ocrText: ocrText)
                print("✅ Result:")
                print("   Brand: \(response.brand ?? "Unknown")")
                print("   Name: \(response.productName)")
                print("   Type: \(response.productType)")
                print("   Confidence: \(String(format: "%.2f", response.confidence))")
                
            } catch {
                print("❌ Failed: \(error)")
            }
        }
    }
    
    /// Test confidence scores
    static func testConfidenceScores() async {
        print("🧪 ProductNormalizationTest: Testing confidence scores")
        print("=" * 60)
        
        let service = ProductNormalizationService()
        
        let confidenceTests = [
            // High confidence (clear product names)
            "CeraVe Foaming Facial Cleanser",
            "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55",
            "The Ordinary Niacinamide 10% + Zinc 1%",
            
            // Medium confidence (partial info)
            "CeraVe Foaming",
            "SPF 30 Sunscreen",
            "Niacinamide Serum",
            
            // Low confidence (ambiguous)
            "Face Cream",
            "Serum",
            "Cleanser"
        ]
        
        for (index, ocrText) in confidenceTests.enumerated() {
            print("\n--- Confidence Test \(index + 1) ---")
            print("OCR Text: '\(ocrText)'")
            
            do {
                let response = try await service.normalizeProduct(ocrText: ocrText)
                let confidenceLevel = response.confidence > 0.8 ? "High" : 
                                    response.confidence > 0.5 ? "Medium" : "Low"
                
                print("✅ Result:")
                print("   Brand: \(response.brand ?? "Unknown")")
                print("   Name: \(response.productName)")
                print("   Type: \(response.productType)")
                print("   Confidence: \(String(format: "%.2f", response.confidence)) (\(confidenceLevel))")
                
            } catch {
                print("❌ Failed: \(error)")
            }
        }
    }
    
    /// Run all test suites
    static func runAllTestSuites() async {
        print("🚀 ProductNormalizationTest: Running all test suites")
        print("=" * 80)
        
        await runAllTests()
        print("\n")
        
        await testProductCategories()
        print("\n")
        
        await testEdgeCases()
        print("\n")
        
        await testConfidenceScores()
        
        print("\n🎉 ProductNormalizationTest: All test suites completed!")
    }
}

// MARK: - Quick Test Runner

extension ProductNormalizationTest {
    /// Quick test with a single product
    static func quickTest(_ ocrText: String) async {
        print("🧪 Quick Test: '\(ocrText)'")
        print("-" * 40)
        
        let service = ProductNormalizationService()
        
        do {
            let response = try await service.normalizeProduct(ocrText: ocrText)
            print("✅ Success:")
            print("   Brand: \(response.brand ?? "Unknown")")
            print("   Name: \(response.productName)")
            print("   Type: \(response.productType)")
            print("   Confidence: \(String(format: "%.2f", response.confidence))")
            
            let product = response.toProduct()
            print("   Created Product: \(product.displayName)")
            print("   Product Type: \(product.tagging.productType.displayName)")
            
        } catch {
            print("❌ Failed: \(error)")
        }
    }
}
