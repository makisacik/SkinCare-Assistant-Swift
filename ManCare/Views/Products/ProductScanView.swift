//
//  ProductScanView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI
import Vision
import AVFoundation
import UIKit

struct ProductScanView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var cameraManager = CameraManager()
    private let productService = ProductService.shared

    @State private var extractedText = ""
    @State private var isProcessing = false
    @State private var showingTextResult = false
    @State private var capturedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isCapturing = false
    
    // Auto-flow states
    @State private var currentStep = ""
    @State private var normalizedProduct: ProductNormalizationResponse?
    @State private var createdProduct: Product?
    @State private var processingError: String?
    @State private var showingSuccess = false

    let onTextExtracted: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera Preview
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                // Overlay UI
                VStack {
                    // Top Controls
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Scan Product")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        // Flashlight toggle
                        Button {
                            cameraManager.toggleFlashlight()
                        } label: {
                            Image(systemName: cameraManager.isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Debug: Test OCR button
                        Button {
                            testOCR()
                        } label: {
                            Image(systemName: "text.badge.checkmark")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .background(Color.blue.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        // Debug: Test Camera button
                        Button {
                            testCameraCapture()
                        } label: {
                            Image(systemName: "camera.badge.ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .background(Color.orange.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        // Debug: Force OCR button
                        Button {
                            if capturedImage != nil {
                                print("🔍 Manually triggering OCR...")
                                processImage()
                            } else {
                                print("❌ No captured image to process")
                            }
                        } label: {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .background(Color.purple.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Scanning Frame
                    VStack(spacing: 20) {
                        Text("Position the product label within the frame")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Scanning frame overlay
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 280, height: 200)
                            
                            // Corner indicators
                            ForEach(0..<4) { index in
                                CornerIndicator(corner: index)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom Controls
                    HStack(spacing: 40) {
                        // Gallery button
                        Button {
                            showingImagePicker = true
                        } label: {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(Color.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Capture button
                        Button {
                            capturePhoto()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .disabled(isProcessing || isCapturing)
                        
                        // Process button (appears after capture)
                        if capturedImage != nil {
                            Button {
                                print("🔘 Process button tapped!")
                                processImage()
                            } label: {
                                Image(systemName: "text.viewfinder")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.white)
                                    .frame(width: 50, height: 50)
                                    .background(tm.theme.palette.secondary)
                                    .clipShape(Circle())
                            }
                            .disabled(isProcessing)
                        } else {
                            // Placeholder to maintain layout
                            Color.clear
                                .frame(width: 50, height: 50)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                // Captured image preview
                if let image = capturedImage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                
                                Text("Photo captured!")
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .background(Color.black.opacity(0.3))
                }
                
                // Processing overlay
                if isProcessing {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.3), value: isProcessing)
                    
                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))

                            VStack(spacing: 12) {
                                Text(currentStep.isEmpty ? "Processing..." : currentStep)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)

                                if !extractedText.isEmpty {
                                    Text("Extracted: \(extractedText)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                        .lineLimit(3)
                                }
                            }
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.6))
                                .blur(radius: 1)
                        )
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }

                // Success overlay
                if showingSuccess {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.3), value: showingSuccess)

                    VStack(spacing: 24) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color.green)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingSuccess)

                            Text("Product Added Successfully!")
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color.white)

                            if let product = createdProduct {
                                VStack(spacing: 12) {
                                    Text(product.displayName)
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.center)

                                    Text(product.tagging.productType.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))

                                    if let brand = product.brand {
                                        Text("by \(brand)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }

                            Button("Done") {
                                dismiss()
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.green)
                            )
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.6))
                                .blur(radius: 1)
                        )
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTextResult) {
            TextResultView(
                extractedText: extractedText,
                onContinue: { text in
                    onTextExtracted(text)
                    dismiss()
                },
                onRetake: {
                    showingTextResult = false
                    capturedImage = nil
                    extractedText = ""
                    resetAutoFlow()
                }
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                if let image = image {
                    print("✅ Image selected from gallery: \(image.size)")
                    capturedImage = image
                    resetAutoFlow()
                    print("🚀 Starting automatic processing flow from gallery...")
                    startAutomaticFlow()
                } else {
                    print("❌ No image selected from gallery")
                }
            }
        }
        .onAppear {
            cameraManager.requestCameraPermission()
        }
        .onChange(of: cameraManager.permissionGranted) { granted in
            if granted {
                print("✅ Camera permission granted")
            } else {
                print("❌ Camera permission denied")
            }
        }
    }
    
    private func capturePhoto() {
        guard !isCapturing else {
            print("⏳ Already capturing, ignoring duplicate tap")
            return
        }
        
        print("📸 Capturing photo...")
        isCapturing = true
        resetAutoFlow()
        
        cameraManager.capturePhoto { image in
            DispatchQueue.main.async {
                self.isCapturing = false
                if let image = image {
                    print("✅ Photo captured successfully")
                    self.capturedImage = image
                    print("🖼️ capturedImage set to: \(image.size)")
                    print("🚀 Starting automatic processing flow...")
                    // Start the automatic flow: OCR → GPT → Product Creation
                    self.startAutomaticFlow()
                } else {
                    print("❌ Failed to capture photo")
                }
            }
        }
    }
    
    private func processImage() {
        guard let image = capturedImage else { 
            print("❌ No captured image to process")
            return 
        }
        
        print("🔍 Starting OCR processing for image: \(image.size)")
        isProcessing = true
        
        // Use Vision OCR to extract text
        OCRService.extractText(from: image) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success(let text):
                    print("✅ OCR Success! Extracted text: '\(text)'")
                    self.extractedText = text
                    self.showingTextResult = true
                case .failure(let error):
                    print("❌ OCR Error: \(error.localizedDescription)")
                    // Show error alert
                }
            }
        }
    }
    
    private func testOCR() {
        print("🧪 Testing automatic flow with sample text image...")
        
        // Create a simple test image with text
        let testImage = createTestImage()
        capturedImage = testImage
        resetAutoFlow()
        
        // Start automatic flow
        startAutomaticFlow()
    }
    
    private func testCameraCapture() {
        print("🧪 Testing camera capture with automatic flow...")
        cameraManager.capturePhoto { image in
            if let image = image {
                print("✅ Direct camera test successful: \(image.size)")
                self.capturedImage = image
                self.resetAutoFlow()
                print("🚀 Starting automatic processing flow...")
                self.startAutomaticFlow()
            } else {
                print("❌ Direct camera test failed")
            }
        }
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Black text
            UIColor.black.setFill()
            let text = "CeraVe\nFoaming Facial Cleanser\n150ml"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            attributedString.draw(in: textRect)
        }
    }

    // MARK: - Automatic Flow Functions

    private func resetAutoFlow() {
        currentStep = ""
        normalizedProduct = nil
        createdProduct = nil
        processingError = nil
        showingSuccess = false
        extractedText = ""
    }

    private func startAutomaticFlow() {
        guard let image = capturedImage else {
            print("❌ No captured image to process")
            return
        }

        print("🚀 Starting automatic processing flow...")
        isProcessing = true
        currentStep = "Step 1: Extracting text from image..."

        // Step 1: OCR Text Extraction
        OCRService.extractText(from: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    print("✅ Step 1 Complete - OCR Success!")
                    print("   Extracted text: '\(text)'")
                    self.extractedText = text
                    self.currentStep = "Step 2: Normalizing with GPT..."

                    // Step 2: GPT Normalization
                    self.normalizeWithGPT()

                case .failure(let error):
                    print("❌ Step 1 Failed - OCR Error: \(error.localizedDescription)")
                    self.processingError = "OCR failed: \(error.localizedDescription)"
                    self.isProcessing = false
                    self.currentStep = "OCR failed"
                }
            }
        }
    }

    private func normalizeWithGPT() {
        print("🔹 Step 2 — GPT normalization (cheap text call)")
        print("Sending OCR text to GPT: '\(extractedText)'")

        Task {
            do {
                let service = ProductNormalizationService()
                let response = try await service.normalizeProduct(ocrText: extractedText)

                await MainActor.run {
                    print("✅ Step 2 Complete - GPT Normalization successful!")
                    print("   Brand: \(response.brand ?? "Unknown")")
                    print("   Product Name: \(response.productName)")
                    print("   Product Type: \(response.productType)")
                    print("   Confidence: \(response.confidence)")

                    self.normalizedProduct = response
                    self.currentStep = "Step 3: Creating and adding product..."

                    // Step 3: Create and Add Product
                    self.createAndAddProduct()
                }

            } catch {
                await MainActor.run {
                    print("❌ Step 2 Failed - GPT Normalization failed: \(error)")
                    self.processingError = "GPT normalization failed: \(error.localizedDescription)"
                    self.isProcessing = false
                    self.currentStep = "GPT normalization failed"
                }
            }
        }
    }

    private func createAndAddProduct() {
        guard let normalized = normalizedProduct else {
            print("❌ No normalized product data available")
            processingError = "No normalized product data"
            isProcessing = false
            return
        }

        print("🔹 Step 3 — Creating and adding product")

        // Create Product from normalized data
        let product = normalized.toProduct()

        // Add to ProductService
        productService.addUserProduct(product)

        print("✅ Step 3 Complete - Product created and added!")
        print("   Product ID: \(product.id)")
        print("   Display Name: \(product.displayName)")
        print("   Product Type: \(product.tagging.productType.displayName)")
        print("   Brand: \(product.brand ?? "Unknown")")

        // Show success
        createdProduct = product
        isProcessing = false
        currentStep = "Product added successfully!"
        showingSuccess = true

        print("🎉 Automatic flow completed successfully!")
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraManager.setupPreview(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Corner Indicator

struct CornerIndicator: View {
    let corner: Int
    
    var body: some View {
        let size: CGFloat = 20
        let lineWidth: CGFloat = 3
        
        switch corner {
        case 0: // Top-left
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size, height: lineWidth)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: size)
                    Spacer()
                }
            }
            .frame(width: size, height: size)
            .offset(x: -size/2, y: -size/2)
            
        case 1: // Top-right
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size, height: lineWidth)
                }
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: size)
                }
            }
            .frame(width: size, height: size)
            .offset(x: size/2, y: -size/2)
            
        case 2: // Bottom-left
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: size)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size, height: lineWidth)
                    Spacer()
                }
            }
            .frame(width: size, height: size)
            .offset(x: -size/2, y: size/2)
            
        case 3: // Bottom-right
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: lineWidth, height: size)
                }
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size, height: lineWidth)
                }
            }
            .frame(width: size, height: size)
            .offset(x: size/2, y: size/2)
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Text Result View

struct TextResultView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let extractedText: String
    let onContinue: (String) -> Void
    let onRetake: () -> Void
    
    @State private var isNormalizing = false
    @State private var normalizedProduct: ProductNormalizationResponse?
    @State private var normalizationError: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(tm.theme.palette.secondary)
                    
                    Text("Extracted Text")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("Review and edit the text before continuing")
                        .font(tm.theme.typo.sub)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Text Editor
                VStack(alignment: .leading, spacing: 12) {
                    Text("Product Information")
                        .font(tm.theme.typo.title.weight(.semibold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    TextEditor(text: .constant(extractedText))
                        .font(tm.theme.typo.body)
                        .frame(minHeight: 200)
                        .padding(16)
                        .background(tm.theme.palette.card)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Normalized Product Results
                if let normalized = normalizedProduct {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Normalized Product")
                            .font(tm.theme.typo.title.weight(.semibold))
                            .foregroundColor(tm.theme.palette.textPrimary)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Brand:")
                                    .font(tm.theme.typo.body.weight(.medium))
                                Text(normalized.brand ?? "Unknown")
                                    .font(tm.theme.typo.body)
                            }

                            HStack {
                                Text("Name:")
                                    .font(tm.theme.typo.body.weight(.medium))
                                Text(normalized.productName)
                                    .font(tm.theme.typo.body)
                            }

                            HStack {
                                Text("Type:")
                                    .font(tm.theme.typo.body.weight(.medium))
                                Text(normalized.productType)
                                    .font(tm.theme.typo.body)
                            }

                            HStack {
                                Text("Confidence:")
                                    .font(tm.theme.typo.body.weight(.medium))
                                Text(String(format: "%.1f%%", normalized.confidence * 100))
                                    .font(tm.theme.typo.body)
                                    .foregroundColor(normalized.confidence > 0.7 ? Color.green : Color.orange)
                            }
                        }
                        .padding(16)
                        .background(tm.theme.palette.card)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                }

                // Error Message
                if let error = normalizationError {
                    Text("Normalization Error: \(error)")
                        .font(tm.theme.typo.caption)
                        .foregroundColor(Color.red)
                        .padding(.horizontal, 20)
                }

                // Action Buttons
                VStack(spacing: 12) {
                    // GPT Normalization Button
                    if normalizedProduct == nil && !isNormalizing {
                        Button {
                            normalizeWithGPT()
                        } label: {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("Normalize with GPT")
                            }
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    }

                    // Processing indicator
                    if isNormalizing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Normalizing with GPT...")
                                .font(tm.theme.typo.body)
                        }
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }

                    // Continue with normalized or raw text
                    Button {
                        if let normalized = normalizedProduct {
                            // Use normalized product name
                            onContinue(normalized.productName)
                        } else {
                            // Use raw OCR text
                            onContinue(extractedText)
                        }
                    } label: {
                        Text(normalizedProduct != nil ? "Continue with Normalized Product" : "Continue with Raw Text")
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(tm.theme.palette.secondary)
                            .cornerRadius(12)
                    }
                    .disabled(isNormalizing)
                    
                    Button {
                        onRetake()
                    } label: {
                        Text("Retake Photo")
                            .font(tm.theme.typo.body.weight(.medium))
                            .foregroundColor(tm.theme.palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(tm.theme.palette.bg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tm.theme.palette.separator, lineWidth: 1)
                            )
                    }
                    .disabled(isNormalizing)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                }
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
            }
        }
    }

    private func normalizeWithGPT() {
        print("🔹 Step 2 — GPT normalization (cheap text call)")
        print("Sending OCR text to GPT: '\(extractedText)'")

        isNormalizing = true
        normalizationError = nil

        Task {
            do {
                let service = ProductNormalizationService()
                let response = try await service.normalizeProduct(ocrText: extractedText)

                await MainActor.run {
                    self.normalizedProduct = response
                    self.isNormalizing = false

                    print("✅ GPT Normalization successful:")
                    print("   Brand: \(response.brand ?? "Unknown")")
                    print("   Product Name: \(response.productName)")
                    print("   Product Type: \(response.productType)")
                    print("   Confidence: \(response.confidence)")
                }

            } catch {
                await MainActor.run {
                    self.normalizationError = error.localizedDescription
                    self.isNormalizing = false
                    print("❌ GPT Normalization failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            } else {
                parent.onImageSelected(nil)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageSelected(nil)
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview

#Preview("ProductScanView") {
    ProductScanView { text in
        print("Extracted text: \(text)")
    }
}
