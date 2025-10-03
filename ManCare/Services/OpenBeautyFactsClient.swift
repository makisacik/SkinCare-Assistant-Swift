//
//  OpenBeautyFactsClient.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Open Beauty Facts Client

/// Client for interacting with Open Beauty Facts API
final class OpenBeautyFactsClient {
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 12
        return URLSession(configuration: config)
    }()

    /// Search for products using brand and product name
    /// - Parameters:
    ///   - brand: Optional brand name
    ///   - name: Product name
    ///   - pageSize: Number of results to return (default: 10)
    /// - Returns: Array of OBFProduct results
    func search(brand: String?, name: String, pageSize: Int = 10) async throws -> [OBFProduct] {
        let q = [brand, name]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        guard var comps = URLComponents(string: "https://world.openbeautyfacts.org/api/v2/search") else {
            return []
        }
        
        comps.queryItems = [
            .init(name: "search_terms", value: q),
            .init(name: "page_size", value: String(pageSize)),
            .init(name: "fields",
                  value: "code,brands,product_name,quantity,ingredients_text,image_url,image_front_small_url"),
            .init(name: "sort_by", value: "last_modified_t")
        ]
        
        guard let url = comps.url else {
            return []
        }
        
        let (data, resp) = try await session.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { 
            return [] 
        }
        
        return try JSONDecoder().decode(OBFSearchResponse.self, from: data).products
    }
}
