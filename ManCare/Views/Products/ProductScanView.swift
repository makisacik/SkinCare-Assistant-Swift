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

    @Environment(\.dismiss) private var dismiss

    @StateObject private var cameraManager = CameraManager()
    @StateObject private var scanManager = ProductScanManager.shared
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
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .background(ThemeManager.shared.theme.palette.textPrimary.opacity(0.3))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text(L10n.Products.Scan.title)
                            .font(.headline)
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(ThemeManager.shared.theme.palette.textPrimary.opacity(0.3))
                            .cornerRadius(20)

                        Spacer()

                        // Flashlight toggle
                        Button {
                            cameraManager.toggleFlashlight()
                        } label: {
                            Image(systemName: cameraManager.isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .background(ThemeManager.shared.theme.palette.textPrimary.opacity(0.3))
                                .clipShape(Circle())
                        }

                        // Debug: Test OCR button with real scanned text
                        Button {
                            testRealOCR()
                        } label: {
                            Image(systemName: "text.badge.checkmark")
                                .font(.system(size: 20))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .background(ThemeManager.shared.theme.palette.info.opacity(0.7))
                                .clipShape(Circle())
                        }

                        // Debug: Test Camera button
                        Button {
                            testCameraCapture()
                        } label: {
                            Image(systemName: "camera.badge.ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .background(ThemeManager.shared.theme.palette.warning.opacity(0.7))
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
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .background(ThemeManager.shared.theme.palette.primary.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    // Scanning Frame
                    VStack(spacing: 20) {
                        Text(L10n.Products.Scan.instruction)
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        // Scanning frame overlay
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(ThemeManager.shared.theme.palette.textInverse, lineWidth: 2)
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
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                .frame(width: 50, height: 50)
                                .background(ThemeManager.shared.theme.palette.textPrimary.opacity(0.3))
                                .clipShape(Circle())
                        }

                        // Capture button
                        Button {
                            capturePhoto()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.shared.theme.palette.textInverse)
                                    .frame(width: 70, height: 70)

                                Circle()
                                    .stroke(ThemeManager.shared.theme.palette.textPrimary, lineWidth: 2)
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
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                    .frame(width: 50, height: 50)
                                    .background(ThemeManager.shared.theme.palette.secondary)
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
                                            .stroke(ThemeManager.shared.theme.palette.textInverse, lineWidth: 2)
                                    )

                                Text(L10n.Products.Scan.photoCapture)
                                    .font(.caption)
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ThemeManager.shared.theme.palette.success)
                                    .cornerRadius(8)
                            }

                            Spacer()
                        }

                        Spacer()
                    }
                    .background(ThemeManager.shared.theme.palette.textPrimary.opacity(0.3))
                }

                // Processing overlay
                if isProcessing {
                    ThemeManager.shared.theme.palette.textPrimary.opacity(0.8)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.3), value: isProcessing)

                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))

                            VStack(spacing: 12) {
                                Text(currentStep.isEmpty ? L10n.Products.Scan.processing : currentStep)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                    .multilineTextAlignment(.center)

                                if !extractedText.isEmpty {
                                    Text(L10n.Products.Scan.extracted(extractedText))
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                        .lineLimit(3)
                                }
                            }
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(ThemeManager.shared.theme.palette.textPrimary.opacity(0.6))
                                .blur(radius: 1)
                        )
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }

                // Success overlay
                if showingSuccess {
                    ThemeManager.shared.theme.palette.textPrimary.opacity(0.8)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.3), value: showingSuccess)

                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(ThemeManager.shared.theme.palette.success)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingSuccess)

                            Text(L10n.Products.Scan.success)
                                .font(.title2.weight(.bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                            if let product = createdProduct {
                                VStack(spacing: 12) {
                                    Text(product.displayName)
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                                        .multilineTextAlignment(.center)

                                    Text(product.tagging.productType.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))

                                    if let brand = product.brand {
                                        Text(L10n.Products.Scan.byBrand(brand))
                                            .font(.caption)
                                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.6))
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(ThemeManager.shared.theme.palette.textInverse.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(ThemeManager.shared.theme.palette.textInverse.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }

                            Button(L10n.Products.Scan.done) {
                                dismiss()
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(ThemeManager.shared.theme.palette.success)
                            )
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(ThemeManager.shared.theme.palette.textPrimary.opacity(0.6))
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
        .sheet(isPresented: $scanManager.showProductConfirmation) {
            ProductConfirmSheet(candidates: scanManager.productCandidates) { candidate in
                scanManager.handleProductSelection(candidate)
                // Only dismiss if a product was selected (not "None")
                if candidate != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
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
        .onChange(of: scanManager.shouldNavigateToProducts) { shouldNavigate in
            if shouldNavigate {
                print("📱 ProductScanManager triggered navigation - dismissing scan view")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
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
    
    private func testRealOCR() {
        print("🧪 Testing with real scanned OCR text...")
        
        // Use the actual OCR text you encountered
        let realOCRText = "mia klinika RELAIC ACID SERUN NIACINAMION ZING TEA TREE GLYCINE"
        extractedText = realOCRText
        resetAutoFlow()
        
        // Skip OCR step and go directly to GPT normalization
        isProcessing = true
        currentStep = L10n.Products.Scan.Step.step2
        normalizeWithGPT()
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
        currentStep = L10n.Products.Scan.Step.step1

        // Step 1: OCR Text Extraction
        OCRService.extractText(from: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    print("✅ Step 1 Complete - OCR Success!")
                    print("   Extracted text: '\(text)'")
                    self.extractedText = text
                    self.currentStep = L10n.Products.Scan.Step.step2

                    // Step 2: GPT Normalization
                    self.normalizeWithGPT()

                case .failure(let error):
                    print("❌ Step 1 Failed - OCR Error: \(error.localizedDescription)")
                    self.processingError = "OCR failed: \(error.localizedDescription)"
                    self.isProcessing = false
                    self.currentStep = L10n.Products.Scan.Status.ocrFailed
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
                    self.currentStep = L10n.Products.Scan.Step.step3

                    // Step 3: Create and Add Product
                    self.createAndAddProduct()
                }

            } catch {
                await MainActor.run {
                    print("❌ Step 2 Failed - GPT Normalization failed: \(error)")
                    self.processingError = "GPT normalization failed: \(error.localizedDescription)"
                    self.isProcessing = false
                    self.currentStep = L10n.Products.Scan.Status.normalizationFailed
                }
            }
        }
    }

    private func createAndAddProduct() {
        guard let normalized = normalizedProduct else {
            print("❌ No normalized product data available")
            processingError = L10n.Products.Scan.Status.noData
            isProcessing = false
            return
        }

        print("🔹 Step 3 — Looking up product in Open Beauty Facts...")
        currentStep = L10n.Products.Scan.Step.step3Database

        // Create ProductGuess from normalized data
        let guess = ProductGuess(
            brand: normalized.brand,
            name: normalized.productName,
            sizeHint: normalized.size,
            keyINCI: normalized.ingredients
        )

        // Store the scanned data for potential fallback use
        scanManager.setScannedProduct(extractedText: extractedText, normalizedProduct: normalized)
        
        // Use the AI Agent to find and enrich the product
        Task {
            await scanManager.resolveProductWithAgent(ocrText: extractedText, guess: guess)
            
            await MainActor.run {
                self.isProcessing = false
                self.currentStep = L10n.Products.Scan.Status.lookupCompleted
                
                // Don't dismiss immediately - let the confirmation sheet handle it
                // or wait for the scanManager to trigger navigation
                print("🎉 Open Beauty Facts lookup completed!")
            }
        }
    }

    private func createFallbackProduct(from normalized: ProductNormalizationResponse) {
        print("🔄 Creating fallback product from normalized data...")
        currentStep = L10n.Products.Scan.Step.step3

        // Create product using the existing ProductService method
        let product = productService.createProductFromName(
            normalized.productName,
            brand: normalized.brand,
            additionalInfo: [
                "size": normalized.size ?? "",
                "ingredients": normalized.ingredients,
                "description": "Scanned product"
            ]
        )

        // Add to user's collection
        productService.addUserProduct(product)

        isProcessing = false
        currentStep = L10n.Products.Scan.Status.productAdded

        // Show success and dismiss
        createdProduct = product
        showingSuccess = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss()
        }

        print("✅ Fallback product created and added successfully!")
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
                        .fill(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: size, height: lineWidth)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.textInverse)
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
                        .fill(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: size, height: lineWidth)
                }
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: lineWidth, height: size)
                }
            }
            .frame(width: size, height: size)
            .offset(x: size/2, y: -size/2)

        case 2: // Bottom-left
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: lineWidth, height: size)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.textInverse)
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
                        .fill(ThemeManager.shared.theme.palette.textInverse)
                        .frame(width: lineWidth, height: size)
                }
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.textInverse)
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
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)

                    Text(L10n.Products.Scan.Step.extractedText)
                        .font(ThemeManager.shared.theme.typo.h2)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Products.Scan.Step.reviewText)
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Text Editor
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.Products.Scan.Step.productInfo)
                        .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    TextEditor(text: .constant(extractedText))
                        .font(ThemeManager.shared.theme.typo.body)
                        .frame(minHeight: 200)
                        .padding(16)
                        .background(ThemeManager.shared.theme.palette.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Normalized Product Results
                if let normalized = normalizedProduct {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.Products.Scan.Step.normalizedProduct)
                            .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(L10n.Products.Scan.Step.brand)
                                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                Text(normalized.brand ?? L10n.Products.Scan.Step.unknown)
                                    .font(ThemeManager.shared.theme.typo.body)
                            }

                            HStack {
                                Text(L10n.Products.Scan.Step.name)
                                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                Text(normalized.productName)
                                    .font(ThemeManager.shared.theme.typo.body)
                            }

                            HStack {
                                Text(L10n.Products.Scan.Step.type)
                                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                Text(normalized.productType)
                                    .font(ThemeManager.shared.theme.typo.body)
                            }

                            HStack {
                                Text(L10n.Products.Scan.Step.confidence)
                                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                Text(String(format: "%.1f%%", normalized.confidence * 100))
                                    .font(ThemeManager.shared.theme.typo.body)
                                    .foregroundColor(normalized.confidence > 0.7 ? ThemeManager.shared.theme.palette.success : ThemeManager.shared.theme.palette.warning)
                            }
                        }
                        .padding(16)
                        .background(ThemeManager.shared.theme.palette.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                }

                // Error Message
                if let error = normalizationError {
                    Text(L10n.Products.Scan.Step.normalizationError(error))
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.error)
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
                                Text(L10n.Products.Scan.Step.normalizeWithGPT)
                            }
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.theme.palette.primary)
                            .cornerRadius(12)
                        }
                    }

                    // Processing indicator
                    if isNormalizing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(L10n.Products.Scan.Step.normalizing)
                                .font(ThemeManager.shared.theme.typo.body)
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                        Text(normalizedProduct != nil ? L10n.Products.Scan.Step.continueNormalized : L10n.Products.Scan.Step.continueRaw)
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.theme.palette.secondary)
                            .cornerRadius(12)
                    }
                    .disabled(isNormalizing)

                    Button {
                        onRetake()
                    } label: {
                        Text(L10n.Products.Scan.retakePhoto)
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.theme.palette.accentBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                            )
                    }
                    .disabled(isNormalizing)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                }
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Products.Scan.Step.cancel) {
                        dismiss()
                    }
                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
