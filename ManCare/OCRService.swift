//
//  OCRService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Vision
import UIKit

class OCRService {
    
    /// Extract text from an image using iOS Vision OCR
    /// - Parameters:
    ///   - image: The image to process
    ///   - completion: Completion handler with the extracted text or error
    static func extractText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        print("🔍 OCRService: Starting text extraction for image: \(image.size)")
        
        guard let cgImage = image.cgImage else {
            print("❌ OCRService: Invalid image - no CGImage")
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        print("🔍 OCRService: Creating Vision request...")
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ OCRService: Vision request error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("❌ OCRService: No text observations found")
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            print("🔍 OCRService: Found \(observations.count) text observations")
            let extractedText = processTextObservations(observations)
            print("🔍 OCRService: Processed text: '\(extractedText)'")
            completion(.success(extractedText))
        }
        
        // Configure the request for better accuracy
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en"] // Add more languages as needed
        request.usesLanguageCorrection = true
        
        print("🔍 OCRService: Creating image request handler...")
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("🔍 OCRService: Performing Vision request...")
                try handler.perform([request])
            } catch {
                print("❌ OCRService: Handler perform error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Process the text observations and clean the extracted text
    /// - Parameter observations: Array of recognized text observations
    /// - Returns: Cleaned and formatted text string
    private static func processTextObservations(_ observations: [VNRecognizedTextObservation]) -> String {
        print("🔍 OCRService: Processing \(observations.count) text observations")
        var allText: [String] = []
        
        for (index, observation) in observations.enumerated() {
            guard let topCandidate = observation.topCandidates(1).first else {
                print("🔍 OCRService: No top candidate for observation \(index)")
                continue
            }
            
            let text = topCandidate.string
            let confidence = topCandidate.confidence
            print("🔍 OCRService: Observation \(index): '\(text)' (confidence: \(confidence))")
            allText.append(text)
        }
        
        // Join all text and clean it
        let rawText = allText.joined(separator: " ")
        print("🔍 OCRService: Raw text before cleaning: '\(rawText)'")
        let cleanedText = cleanText(rawText)
        print("🔍 OCRService: Cleaned text: '\(cleanedText)'")
        return cleanedText
    }
    
    /// Clean the extracted text by removing unwanted characters and formatting
    /// - Parameter text: Raw text from OCR
    /// - Returns: Cleaned text
    private static func cleanText(_ text: String) -> String {
        var cleanedText = text
        
        // Remove excessive whitespace and newlines
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Remove leading and trailing whitespace
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove common OCR artifacts
        cleanedText = cleanedText.replacingOccurrences(of: "|", with: "I") // Common OCR mistake
        cleanedText = cleanedText.replacingOccurrences(of: "0", with: "O", options: .regularExpression, range: nil) // In certain contexts
        
        // Collapse multiple spaces into single spaces
        cleanedText = cleanedText.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        
        return cleanedText
    }
    
    /// Extract text with confidence scores for debugging
    /// - Parameters:
    ///   - image: The image to process
    ///   - completion: Completion handler with detailed results
    static func extractTextWithConfidence(from image: UIImage, completion: @escaping (Result<[TextResult], Error>) -> Void) {
        
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            var textResults: [TextResult] = []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    continue
                }
                
                let textResult = TextResult(
                    text: topCandidate.string,
                    confidence: topCandidate.confidence,
                    boundingBox: observation.boundingBox
                )
                textResults.append(textResult)
            }
            
            completion(.success(textResults))
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct TextResult {
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}

enum OCRError: Error, LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for OCR processing"
        case .noTextFound:
            return "No text found in the image"
        case .processingFailed:
            return "Failed to process the image for text recognition"
        }
    }
}

// MARK: - OCR Utilities

extension OCRService {
    
    /// Check if the device supports text recognition
    static var isTextRecognitionSupported: Bool {
        let request = VNRecognizeTextRequest()
        do {
            let languages = try request.supportedRecognitionLanguages()
            return languages.contains("en")
        } catch {
            return false
        }
    }
    
    /// Get supported recognition languages
    static var supportedLanguages: [String] {
        let request = VNRecognizeTextRequest()
        do {
            return try request.supportedRecognitionLanguages()
        } catch {
            return []
        }
    }
    
    /// Preprocess image for better OCR results
    /// - Parameter image: Original image
    /// - Returns: Preprocessed image
    static func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply contrast enhancement
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(1.2, forKey: kCIInputContrastKey) // Increase contrast
        filter?.setValue(0.1, forKey: kCIInputBrightnessKey) // Slight brightness increase
        
        guard let outputImage = filter?.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgOutput)
    }
}
