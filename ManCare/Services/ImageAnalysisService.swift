//
//  ImageAnalysisService.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import UIKit
import Vision
import CoreImage

/// Service for analyzing skin photos using iOS Vision framework
class ImageAnalysisService {
    static let shared = ImageAnalysisService()
    
    private init() {}
    
    // MARK: - Main Analysis Method
    
    /// Analyze a photo and return analysis results
    func analyzeImage(_ image: UIImage) async -> ImageAnalysisResult {
        // Run analysis on background thread
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let brightness = self.calculateBrightness(image)
                let tone = self.analyzeSkinTone(image)
                
                let result = ImageAnalysisResult(
                    brightness: brightness,
                    overallTone: tone,
                    analyzedAt: Date()
                )
                
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - Brightness Analysis
    
    private func calculateBrightness(_ image: UIImage) -> Double {
        guard let cgImage = image.cgImage else {
            print("⚠️ Could not get CGImage for brightness analysis")
            return 0.5
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let extentVector = CIVector(
            x: ciImage.extent.origin.x,
            y: ciImage.extent.origin.y,
            z: ciImage.extent.size.width,
            w: ciImage.extent.size.height
        )
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: extentVector
        ]),
        let outputImage = filter.outputImage else {
            print("⚠️ Could not create brightness filter")
            return 0.5
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        // Calculate perceived brightness using standard luminance formula
        let r = Double(bitmap[0]) / 255.0
        let g = Double(bitmap[1]) / 255.0
        let b = Double(bitmap[2]) / 255.0
        
        // Perceived brightness formula
        let brightness = 0.299 * r + 0.587 * g + 0.114 * b
        
        print("✅ Brightness calculated: \(String(format: "%.2f", brightness))")
        return brightness
    }
    
    // MARK: - Skin Tone Analysis
    
    private func analyzeSkinTone(_ image: UIImage) -> String {
        guard let cgImage = image.cgImage else {
            return L10n.SkinJournal.Analysis.unableToAnalyze
        }
        
        // Use Vision to detect face
        let faceDetected = detectFace(in: cgImage)
        
        if !faceDetected {
            return L10n.SkinJournal.Analysis.noFaceDetected
        }
        
        // Analyze color variance for evenness
        let variance = calculateColorVariance(image)
        
        if variance < 0.02 {
            return L10n.SkinJournal.Analysis.evenSkinTone
        } else if variance < 0.05 {
            return L10n.SkinJournal.Analysis.mostlyEvenSkinTone
        } else if variance < 0.08 {
            return L10n.SkinJournal.Analysis.someUnevenness
        } else {
            return L10n.SkinJournal.Analysis.significantVariation
        }
    }
    
    private func detectFace(in cgImage: CGImage) -> Bool {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            if let results = request.results, !results.isEmpty {
                print("✅ Face detected in image")
                return true
            }
        } catch {
            print("⚠️ Face detection failed: \(error)")
        }
        
        return false
    }
    
    private func calculateColorVariance(_ image: UIImage) -> Double {
        guard let cgImage = image.cgImage else {
            return 0.0
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Sample multiple regions to calculate variance
        let sampleRegions = [
            CGRect(x: 0.3, y: 0.3, width: 0.1, height: 0.1),
            CGRect(x: 0.5, y: 0.3, width: 0.1, height: 0.1),
            CGRect(x: 0.7, y: 0.3, width: 0.1, height: 0.1),
            CGRect(x: 0.4, y: 0.5, width: 0.1, height: 0.1),
            CGRect(x: 0.6, y: 0.5, width: 0.1, height: 0.1)
        ]
        
        var colors: [(r: Double, g: Double, b: Double)] = []
        
        for region in sampleRegions {
            let actualRegion = CGRect(
                x: region.origin.x * ciImage.extent.width,
                y: region.origin.y * ciImage.extent.height,
                width: region.width * ciImage.extent.width,
                height: region.height * ciImage.extent.height
            )
            
            if let color = getAverageColor(in: ciImage, region: actualRegion) {
                colors.append(color)
            }
        }
        
        guard !colors.isEmpty else {
            return 0.0
        }
        
        // Calculate variance
        let avgR = colors.map { $0.r }.reduce(0, +) / Double(colors.count)
        let avgG = colors.map { $0.g }.reduce(0, +) / Double(colors.count)
        let avgB = colors.map { $0.b }.reduce(0, +) / Double(colors.count)
        
        let variance = colors.map { color in
            let dr = color.r - avgR
            let dg = color.g - avgG
            let db = color.b - avgB
            return dr * dr + dg * dg + db * db
        }.reduce(0, +) / Double(colors.count)
        
        print("✅ Color variance calculated: \(String(format: "%.4f", variance))")
        return variance
    }
    
    private func getAverageColor(in image: CIImage, region: CGRect) -> (r: Double, g: Double, b: Double)? {
        let extentVector = CIVector(
            x: region.origin.x,
            y: region.origin.y,
            z: region.size.width,
            w: region.size.height
        )
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: image,
            kCIInputExtentKey: extentVector
        ]),
        let outputImage = filter.outputImage else {
            return nil
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return (
            r: Double(bitmap[0]) / 255.0,
            g: Double(bitmap[1]) / 255.0,
            b: Double(bitmap[2]) / 255.0
        )
    }
    
    // MARK: - Comparison Methods
    
    /// Compare two images and return brightness difference
    func compareBrightness(image1: UIImage, image2: UIImage) -> Double {
        let brightness1 = calculateBrightness(image1)
        let brightness2 = calculateBrightness(image2)
        return brightness2 - brightness1
    }
    
    /// Get a human-readable comparison description
    func getComparisonDescription(brightnessDiff: Double) -> String {
        let absDiff = abs(brightnessDiff)
        
        if absDiff < 0.05 {
            return L10n.SkinJournal.Analysis.similarBrightness
        } else if brightnessDiff > 0 {
            if absDiff < 0.15 {
                return L10n.SkinJournal.Analysis.slightlyBrighter
            } else if absDiff < 0.3 {
                return L10n.SkinJournal.Analysis.noticeablyBrighter
            } else {
                return L10n.SkinJournal.Analysis.muchBrighter
            }
        } else {
            if absDiff < 0.15 {
                return L10n.SkinJournal.Analysis.slightlyDarker
            } else if absDiff < 0.3 {
                return L10n.SkinJournal.Analysis.noticeablyDarker
            } else {
                return L10n.SkinJournal.Analysis.muchDarker
            }
        }
    }
}



