//
//  ProductScanIntegrationExample.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Complete Product Scanning Flow

/// Example of how to integrate OCR + GPT normalization + Product creation
class ProductScanIntegrationExample: ObservableObject {
    
    @Published var isProcessing = false
    @Published var currentStep = ""
    @Published var extractedText = ""
    @Published var normalizedProduct: ProductNormalizationResponse?
    @Published var createdProduct: Product?
    @Published var errorMessage: String?
    
    private let ocrService = OCRService.self
    private let normalizationService = ProductNormalizationService()
    private let productService = ProductService()
    
    // MARK: - Complete Flow
    
    /// Complete product scanning flow: Image → OCR → GPT Normalization → Product Creation
    func scanProduct(from image: UIImage) async {
        await MainActor.run {
            isProcessing = true
            currentStep = "Extracting text from image..."
            errorMessage = nil
        }
        
        do {
            // Step 1: Extract text using OCR
            let ocrText = try await extractTextFromImage(image)
            
            await MainActor.run {
                extractedText = ocrText
                currentStep = "Normalizing product data with GPT..."
            }
            
            // Step 2: Normalize with GPT
            let normalized = try await normalizationService.normalizeProduct(ocrText: ocrText)
            
            await MainActor.run {
                normalizedProduct = normalized
                currentStep = "Creating product..."
            }
            
            // Step 3: Create Product and add to service
            let product = normalized.toProduct()
            productService.addUserProduct(product)
            
            await MainActor.run {
                createdProduct = product
                currentStep = "Product added successfully!"
                isProcessing = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                currentStep = "Error occurred"
                isProcessing = false
            }
        }
    }
    
    /// Extract text from image using OCR
    private func extractTextFromImage(_ image: UIImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            ocrService.extractText(from: image) { result in
                switch result {
                case .success(let text):
                    continuation.resume(returning: text)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Individual Step Examples
    
    /// Example: Just OCR extraction
    func extractTextOnly(from image: UIImage) async {
        await MainActor.run {
            isProcessing = true
            currentStep = "Extracting text..."
        }
        
        do {
            let text = try await extractTextFromImage(image)
            await MainActor.run {
                extractedText = text
                currentStep = "Text extracted successfully"
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                currentStep = "OCR failed"
                isProcessing = false
            }
        }
    }
    
    /// Example: Just GPT normalization
    func normalizeTextOnly(_ text: String) async {
        await MainActor.run {
            isProcessing = true
            currentStep = "Normalizing with GPT..."
            extractedText = text
        }
        
        do {
            let normalized = try await normalizationService.normalizeProduct(ocrText: text)
            await MainActor.run {
                normalizedProduct = normalized
                currentStep = "Normalization complete"
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                currentStep = "Normalization failed"
                isProcessing = false
            }
        }
    }
    
    /// Example: Create product from normalized data
    func createProductFromNormalized() async {
        guard let normalized = normalizedProduct else { return }
        
        await MainActor.run {
            isProcessing = true
            currentStep = "Creating product..."
        }
        
        let product = normalized.toProduct()
        productService.addUserProduct(product)
        
        await MainActor.run {
            createdProduct = product
            currentStep = "Product created and added"
            isProcessing = false
        }
    }
    
    // MARK: - Utility Methods
    
    /// Reset the state
    func reset() {
        extractedText = ""
        normalizedProduct = nil
        createdProduct = nil
        errorMessage = nil
        currentStep = ""
        isProcessing = false
    }
    
    /// Get user products from the service
    var userProducts: [Product] {
        return productService.userProducts
    }
}

// MARK: - SwiftUI Integration View

struct ProductScanIntegrationView: View {
    @StateObject private var scanner = ProductScanIntegrationExample()
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Product Scanner")
                        .font(.title.weight(.bold))
                    
                    Text("Scan product images to extract and normalize product data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Image Selection
                Button(action: { showingImagePicker = true }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Select Product Image")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .disabled(scanner.isProcessing)
                
                // Processing Status
                if scanner.isProcessing {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text(scanner.currentStep)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Results
                if !scanner.extractedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Extracted Text:")
                            .font(.headline)
                        Text(scanner.extractedText)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                if let normalized = scanner.normalizedProduct {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Normalized Product:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Brand: \(normalized.brand ?? "Unknown")")
                            Text("Name: \(normalized.productName)")
                            Text("Type: \(normalized.productType)")
                            Text("Confidence: \(String(format: "%.2f", normalized.confidence))")
                        }
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                if let product = scanner.createdProduct {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Created Product:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ID: \(product.id)")
                            Text("Display Name: \(product.displayName)")
                            Text("Brand: \(product.brand ?? "Unknown")")
                            Text("Type: \(product.tagging.productType.displayName)")
                        }
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Error Message
                if let error = scanner.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button("Reset") {
                        scanner.reset()
                    }
                    .disabled(scanner.isProcessing)
                    
                    if scanner.normalizedProduct != nil && scanner.createdProduct == nil {
                        Button("Create Product") {
                            Task {
                                await scanner.createProductFromNormalized()
                            }
                        }
                        .disabled(scanner.isProcessing)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Product Scanner")
                    .sheet(isPresented: $showingImagePicker) {
            GalleryImagePicker(selectedImage: $selectedImage)
        }
            .onChange(of: selectedImage) { image in
                if let image = image {
                    Task {
                        await scanner.scanProduct(from: image)
                    }
                }
            }
        }
    }
}

// MARK: - Gallery Image Picker

struct GalleryImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: GalleryImagePicker
        
        init(_ parent: GalleryImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    ProductScanIntegrationView()
}
