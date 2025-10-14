//
//  PhotoStorageService.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

/// Service for managing local photo storage in the app's Documents directory
class PhotoStorageService {
    static let shared = PhotoStorageService()
    
    private let fileManager = FileManager.default
    private let skinJournalDirectory = "SkinJournal"
    
    private init() {
        createDirectoryIfNeeded()
    }
    
    // MARK: - Directory Management
    
    private func createDirectoryIfNeeded() {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access Documents directory")
            return
        }
        
        let directoryURL = documentsURL.appendingPathComponent(skinJournalDirectory)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                print("✅ Created SkinJournal directory at: \(directoryURL.path)")
            } catch {
                print("❌ Failed to create SkinJournal directory: \(error)")
            }
        }
    }
    
    private func getDirectoryURL() -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(skinJournalDirectory)
    }
    
    // MARK: - Save Photo
    
    /// Save a photo to disk and return the filename
    func savePhoto(_ image: UIImage, withID id: UUID) -> String? {
        guard let directoryURL = getDirectoryURL() else {
            print("❌ Could not get directory URL")
            return nil
        }
        
        // Generate unique filename with HEIC extension
        let filename = "\(id.uuidString).heic"
        let fileURL = directoryURL.appendingPathComponent(filename)
        
        // Step 1: Resize to reasonable dimensions (1200px max)
        let resizedImage = resizeImage(image, maxDimension: 1200)
        print("📐 Resized image from \(image.size) to \(resizedImage.size)")

        // Step 2: Convert to HEIC with quality 0.85 (high quality, still efficient)
        guard let imageData = resizedImage.heicData(compressionQuality: 0.85) else {
            print("⚠️ HEIC conversion failed, falling back to JPEG")
            // Fallback to JPEG if HEIC fails
            guard let jpegData = resizedImage.jpegData(compressionQuality: 0.85) else {
                print("❌ Could not convert image to any format")
                return nil
            }
            let jpegFilename = "\(id.uuidString).jpg"
            let jpegURL = directoryURL.appendingPathComponent(jpegFilename)
            do {
                try jpegData.write(to: jpegURL)
                print("✅ Saved JPEG photo: \(jpegFilename), size: \(jpegData.count / 1024)KB")
                return jpegFilename
            } catch {
                print("❌ Failed to save photo: \(error)")
                return nil
            }
        }
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Saved HEIC photo: \(filename), size: \(imageData.count / 1024)KB")
            return filename
        } catch {
            print("❌ Failed to save photo: \(error)")
            return nil
        }
    }
    
    // MARK: - Load Photo
    
    /// Load a photo from disk by filename
    func loadPhoto(filename: String) -> UIImage? {
        guard let directoryURL = getDirectoryURL() else {
            print("❌ Could not get directory URL")
            return nil
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("⚠️ Photo file does not exist: \(filename)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            print("❌ Could not load image from: \(filename)")
            return nil
        }
        
        return image
    }
    
    // MARK: - Delete Photo
    
    /// Delete a photo from disk by filename
    func deletePhoto(filename: String) -> Bool {
        guard let directoryURL = getDirectoryURL() else {
            print("❌ Could not get directory URL")
            return false
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("⚠️ Photo file does not exist, nothing to delete: \(filename)")
            return true // Consider it successful if already gone
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("✅ Deleted photo: \(filename)")
            return true
        } catch {
            print("❌ Failed to delete photo: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get the file URL for a photo filename
    func getPhotoURL(filename: String) -> URL? {
        guard let directoryURL = getDirectoryURL() else {
            return nil
        }
        return directoryURL.appendingPathComponent(filename)
    }
    
    /// Check if a photo exists
    func photoExists(filename: String) -> Bool {
        guard let directoryURL = getDirectoryURL() else {
            return false
        }
        let fileURL = directoryURL.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Get total storage used by skin journal photos (in bytes)
    func getTotalStorageUsed() -> Int64 {
        guard let directoryURL = getDirectoryURL() else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.fileSizeKey])
            for fileURL in files {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        } catch {
            print("❌ Failed to calculate storage: \(error)")
        }
        
        return totalSize
    }
    
    /// Delete all photos (use with caution!)
    func deleteAllPhotos() -> Bool {
        guard let directoryURL = getDirectoryURL() else {
            return false
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in files {
                try fileManager.removeItem(at: fileURL)
            }
            print("✅ Deleted all skin journal photos")
            return true
        } catch {
            print("❌ Failed to delete all photos: \(error)")
            return false
        }
    }

    // MARK: - Image Optimization

    /// Resize image to a maximum dimension while preserving aspect ratio
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1200) -> UIImage {
        let size = image.size

        // Check if resize is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            print("📐 Image already smaller than \(maxDimension)px, skipping resize")
            return image
        }

        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Create graphics context and resize
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: newSize))

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("⚠️ Failed to resize image, using original")
            return image
        }

        print("📐 Resized from \(Int(size.width))×\(Int(size.height)) to \(Int(newSize.width))×\(Int(newSize.height))")
        return resizedImage
    }
}

// MARK: - UIImage HEIC Extension

extension UIImage {
    /// Convert UIImage to HEIC data with specified compression quality
    func heicData(compressionQuality: CGFloat) -> Data? {
        guard let cgImage = self.cgImage else {
            print("⚠️ Could not get CGImage for HEIC conversion")
            return nil
        }

        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.heic.identifier as CFString,
            1,
            nil
        ) else {
            print("⚠️ Could not create HEIC destination")
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            print("⚠️ Could not finalize HEIC image")
            return nil
        }

        print("✅ Converted to HEIC format")
        return data as Data
    }
}
