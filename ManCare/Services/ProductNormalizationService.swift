//
//  ProductNormalizationService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Product Normalization Models

/// Request model for product normalization
struct ProductNormalizationRequest: Codable {
    let ocrText: String
    let locale: String
    
    init(ocrText: String, locale: String = "en-US") {
        self.ocrText = ocrText
        self.locale = locale
    }
}

/// Response model for product normalization
struct ProductNormalizationResponse: Codable {
    let brand: String?
    let productName: String
    let productType: String
    let confidence: Double
    let size: String?
    let ingredients: [String]
    
    enum CodingKeys: String, CodingKey {
        case brand
        case productName = "product_name"
        case productType = "product_type"
        case confidence
        case size
        case ingredients
    }

    /// Convert to ProductType enum
    func toProductType() -> ProductType {
        return ProductAliasMapping.normalize(productType)
    }
    
    /// Create a Product from the normalized data
    func toProduct() -> Product {
        let productType = toProductType()
        let tagging = ProductTagging(
            productType: productType,
            ingredients: ingredients
        )
        
        return Product(
            id: UUID().uuidString,
            displayName: productName,
            tagging: tagging,
            brand: brand,
            size: size
        )
    }
}

// MARK: - Product Normalization Service

/// Service for normalizing OCR text into structured product data using GPT
class ProductNormalizationService {
    
    // MARK: - Properties
    
    private let gptService: GPTService
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(apiKey: String? = nil, session: URLSession = .shared) {
        let key = apiKey ?? Config.openAIAPIKey
        self.gptService = GPTService(apiKey: key, model: Config.chatGPTModel, session: session)
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Normalize OCR text into structured product data
    /// - Parameters:
    ///   - ocrText: Raw text extracted from product image
    ///   - locale: Locale for the request (default: "en-US")
    ///   - timeout: Request timeout in seconds (default: 30)
    /// - Returns: Normalized product data
    func normalizeProduct(ocrText: String, locale: String = "en-US", timeout: TimeInterval = 30) async throws -> ProductNormalizationResponse {
        print("🔍 ProductNormalizationService: Starting normalization for OCR text: '\(ocrText)'")
        
        let request = ProductNormalizationRequest(ocrText: ocrText, locale: locale)
        
        do {
            let response = try await performNormalization(request: request, timeout: timeout)
            print("✅ ProductNormalizationService: Successfully normalized product")
            print("   - Brand: \(response.brand ?? "Unknown")")
            print("   - Product Name: \(response.productName)")
            print("   - Product Type: \(response.productType)")
            print("   - Confidence: \(response.confidence)")
            
            return response
        } catch {
            print("❌ ProductNormalizationService: Normalization failed: \(error)")
            throw error
        }
    }
    
    /// Normalize multiple products in batch
    /// - Parameters:
    ///   - ocrTexts: Array of OCR text strings
    ///   - locale: Locale for the request (default: "en-US")
    ///   - timeout: Request timeout in seconds (default: 30)
    /// - Returns: Array of normalized product data
    func normalizeProducts(ocrTexts: [String], locale: String = "en-US", timeout: TimeInterval = 30) async throws -> [ProductNormalizationResponse] {
        print("🔍 ProductNormalizationService: Starting batch normalization for \(ocrTexts.count) products")
        
        var results: [ProductNormalizationResponse] = []
        
        // Process in parallel with concurrency limit
        await withTaskGroup(of: (Int, Result<ProductNormalizationResponse, Error>).self) { group in
            for (index, ocrText) in ocrTexts.enumerated() {
                group.addTask {
                    do {
                        let response = try await self.normalizeProduct(ocrText: ocrText, locale: locale, timeout: timeout)
                        return (index, .success(response))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }
            
            for await (index, result) in group {
                switch result {
                case .success(let response):
                    results.append(response)
                case .failure(let error):
                    print("❌ ProductNormalizationService: Failed to normalize product at index \(index): \(error)")
                    // Continue with other products even if one fails
                }
            }
        }
        
        // Sort results by original order
        results.sort { first, second in
            let firstIndex = ocrTexts.firstIndex(of: first.productName) ?? Int.max
            let secondIndex = ocrTexts.firstIndex(of: second.productName) ?? Int.max
            return firstIndex < secondIndex
        }
        
        print("✅ ProductNormalizationService: Batch normalization completed. \(results.count)/\(ocrTexts.count) successful")
        return results
    }
    
    // MARK: - Private Methods
    
    /// Perform the actual normalization using GPT
    private func performNormalization(request: ProductNormalizationRequest, timeout: TimeInterval) async throws -> ProductNormalizationResponse {
        let systemPrompt = buildSystemPrompt()
        let userPrompt = buildUserPrompt(from: request)
        
        do {
            let jsonResponse = try await gptService.completeJSON(
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                timeout: timeout
            )
            
            return try parseNormalizationResponse(jsonResponse)
        } catch {
            throw ProductNormalizationError.gptRequestFailed(error)
        }
    }
    
    /// Build the system prompt for product normalization
    private func buildSystemPrompt() -> String {
        let productTypes = ProductType.allCases.map { $0.rawValue }.joined(separator: ", ")
        
        return """
        You are a skincare product normalization expert for ManCare, a men's skincare app.
        
        Your task is to analyze OCR text from product images and extract structured product information.
        
        Return ONLY valid JSON matching this exact schema:
        {
          "brand": "string or null",
          "product_name": "string",
          "product_type": "string",
          "confidence": 0.0-1.0,
          "size": "string or null",
          "ingredients": ["string"]
        }
        
        Rules:
        1. Extract the brand name if clearly identifiable, otherwise use null
        2. Clean the product name - remove size info, marketing fluff, but keep the core product name
        3. Map product_type to one of these exact values: \(productTypes)
        4. Set confidence between 0.0-1.0 based on how certain you are about the classification
        5. If the product type is unclear, choose the most likely category
        6. Remove common OCR artifacts and normalize text
        7. Extract size information (e.g., "150ml", "30ml", "1.7 fl oz") - return null if not found
        8. Extract key active ingredients from the text (e.g., "Niacinamide", "Hyaluronic Acid", "Retinol") - return empty array if none found
        
        Examples:
        - "CeraVe Foaming Facial Cleanser 16 fl oz" → {"brand": "CeraVe", "product_name": "Foaming Facial Cleanser", "product_type": "cleanser", "confidence": 0.95, "size": "16 fl oz", "ingredients": []}
        - "Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55" → {"brand": "Neutrogena", "product_name": "Ultra Sheer Dry-Touch Sunscreen", "product_type": "sunscreen", "confidence": 0.9, "size": null, "ingredients": []}
        - "The Ordinary Niacinamide 10% + Zinc 1% 30ml" → {"brand": "The Ordinary", "product_name": "Niacinamide 10% + Zinc 1%", "product_type": "niacinamide", "confidence": 0.95, "size": "30ml", "ingredients": ["Niacinamide", "Zinc"]}
        - "MIA KLINIKA RELAIC ACID SERUM NIACINAMIDE ZINC TEA TREE GLYCINE 30ML" → {"brand": "MIA KLINIKA", "product_name": "RELAIC ACID SERUM", "product_type": "faceSerum", "confidence": 0.85, "size": "30ML", "ingredients": ["Niacinamide", "Zinc", "Tea Tree", "Glycine"]}
        """
    }
    
    /// Build the user prompt from the request
    private func buildUserPrompt(from request: ProductNormalizationRequest) -> String {
        return """
        Normalize this OCR text from a skincare product image:
        
        OCR Text: "\(request.ocrText)"
        Locale: \(request.locale)
        
        Return JSON only.
        """
    }
    
    /// Parse the GPT response into ProductNormalizationResponse
    private func parseNormalizationResponse(_ jsonString: String) throws -> ProductNormalizationResponse {
        guard let data = jsonString.data(using: .utf8) else {
            throw ProductNormalizationError.invalidJSON("Could not convert string to data")
        }
        
        do {
            let response = try JSONDecoder().decode(ProductNormalizationResponse.self, from: data)
            
            // Validate the response
            try validateNormalizationResponse(response)
            
            return response
        } catch {
            print("❌ ProductNormalizationService: Failed to decode response: \(error)")
            print("📄 Raw JSON that failed to decode:")
            print(jsonString)
            throw ProductNormalizationError.decodingFailed(String(describing: error))
        }
    }
    
    /// Validate the normalization response
    private func validateNormalizationResponse(_ response: ProductNormalizationResponse) throws {
        // Check required fields
        guard !response.productName.isEmpty else {
            throw ProductNormalizationError.invalidResponse("Product name cannot be empty")
        }
        
        guard !response.productType.isEmpty else {
            throw ProductNormalizationError.invalidResponse("Product type cannot be empty")
        }
        
        // Check confidence range
        guard response.confidence >= 0.0 && response.confidence <= 1.0 else {
            throw ProductNormalizationError.invalidResponse("Confidence must be between 0.0 and 1.0")
        }
        
        // Check if product type is valid
        let validProductTypes = ProductType.allCases.map { $0.rawValue }
        guard validProductTypes.contains(response.productType) else {
            throw ProductNormalizationError.invalidResponse("Invalid product type: \(response.productType)")
        }
    }
}

// MARK: - Error Types

enum ProductNormalizationError: Error, LocalizedError {
    case gptRequestFailed(Error)
    case invalidJSON(String)
    case decodingFailed(String)
    case invalidResponse(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .gptRequestFailed(let error):
            return "GPT request failed: \(error.localizedDescription)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}


// MARK: - Convenience Methods

extension ProductNormalizationService {
    /// Quick normalization with default settings
    static func quickNormalize(ocrText: String) async throws -> ProductNormalizationResponse {
        let service = ProductNormalizationService()
        return try await service.normalizeProduct(ocrText: ocrText)
    }
    
    /// Normalize and create a Product directly
    func normalizeToProduct(ocrText: String) async throws -> Product {
        let response = try await normalizeProduct(ocrText: ocrText)
        return response.toProduct()
    }
}
