//
//  PhotoStorageService.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import UIKit

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
        
        // Generate unique filename
        let filename = "\(id.uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(filename)
        
        // Compress image to JPEG (quality 0.8 for good balance)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Could not convert image to JPEG data")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Saved photo: \(filename), size: \(imageData.count / 1024)KB")
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
}


