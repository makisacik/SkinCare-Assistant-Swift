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
    }
}

/// Data structure for scanned product information
struct ScannedProductData {
    let extractedText: String
    let normalizedProduct: ProductNormalizationResponse
}
