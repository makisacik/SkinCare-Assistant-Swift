//
//  SkinJournalStore.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import CoreData
import UIKit
import Combine

/// Store for managing skin journal entries in Core Data
class SkinJournalStore: ObservableObject {
    static let shared = SkinJournalStore()
    
    @Published var entries: [SkinJournalEntryModel] = []
    @Published var isLoading = false
    
    private let photoStorage = PhotoStorageService.shared
    private let imageAnalysis = ImageAnalysisService.shared
    private let context: NSManagedObjectContext
    
    private init() {
        self.context = PersistenceController.shared.container.viewContext
        fetchAllEntries()
    }
    
    // MARK: - Fetch Operations
    
    /// Fetch all journal entries from Core Data
    func fetchAllEntries() {
        isLoading = true
        
        let request: NSFetchRequest<SkinJournalEntry> = SkinJournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SkinJournalEntry.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            entries = entities.compactMap { SkinJournalEntryModel.from(entity: $0) }
            print("✅ Fetched \(entries.count) journal entries")
        } catch {
            print("❌ Failed to fetch entries: \(error)")
            entries = []
        }
        
        isLoading = false
    }
    
    /// Get a single entry by ID
    func getEntry(id: UUID) -> SkinJournalEntryModel? {
        return entries.first { $0.id == id }
    }
    
    /// Get the most recent entry
    func getMostRecentEntry() -> SkinJournalEntryModel? {
        return entries.first
    }
    
    /// Get entries for a specific date range
    func getEntries(from startDate: Date, to endDate: Date) -> [SkinJournalEntryModel] {
        return entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
    
    // MARK: - Create Operation
    
    /// Save a new journal entry
    func saveEntry(
        photo: UIImage,
        notes: String,
        skinFeelTags: [SkinFeelTag],
        date: Date = Date()
    ) async throws -> SkinJournalEntryModel {

        let id = UUID()
        print("🔵 Starting to save journal entry with ID: \(id)")

        // Save photo to disk
        guard let photoFileName = photoStorage.savePhoto(photo, withID: id) else {
            print("❌ Failed to save photo to disk")
            throw SkinJournalError.photoSaveFailed
        }
        print("✅ Photo saved to disk: \(photoFileName)")

        // Analyze image
        print("🔍 Starting image analysis...")
        let analysis = await imageAnalysis.analyzeImage(photo)
        print("✅ Image analysis complete: brightness=\(analysis.brightness), tone=\(analysis.overallTone)")

        // Create entry model
        let entry = SkinJournalEntryModel(
            id: id,
            date: date,
            photoFileName: photoFileName,
            notes: notes,
            skinFeelTags: skinFeelTags,
            imageAnalysis: analysis,
            createdAt: Date(),
            reminderEnabled: false
        )
        print("✅ Created entry model")
        
        // Save to Core Data
        return try await MainActor.run {
            print("💾 Saving to Core Data...")
            let entity = entry.toEntity(context: context)
            
            do {
                try context.save()
                print("✅ Saved journal entry to Core Data: \(id)")
                
                // Update published entries
                print("🔄 Refreshing entries list...")
                fetchAllEntries()
                print("✅ Entries refreshed. Total entries: \(entries.count)")
                
                return entry
            } catch {
                // If Core Data save fails, clean up the photo
                _ = photoStorage.deletePhoto(filename: photoFileName)
                print("❌ Failed to save entry to Core Data: \(error)")
                throw SkinJournalError.saveFailed
            }
        }
    }
    
    // MARK: - Update Operation
    
    /// Update an existing entry
    func updateEntry(
        id: UUID,
        notes: String? = nil,
        skinFeelTags: [SkinFeelTag]? = nil,
        reminderEnabled: Bool? = nil
    ) throws {
        let request: NSFetchRequest<SkinJournalEntry> = SkinJournalEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(request)
            guard let entity = results.first else {
                throw SkinJournalError.entryNotFound
            }

            // Update fields
            if let notes = notes {
                entity.notes = notes
            }
            if let skinFeelTags = skinFeelTags {
                entity.skinFeelTags = skinFeelTags.map { $0.rawValue }.joined(separator: ",")
            }
            if let reminderEnabled = reminderEnabled {
                entity.reminderEnabled = reminderEnabled
            }

            try context.save()
            print("✅ Updated journal entry: \(id)")

            // Refresh entries
            fetchAllEntries()
        } catch {
            print("❌ Failed to update entry: \(error)")
            throw SkinJournalError.updateFailed
        }
    }
    
    // MARK: - Delete Operation
    
    /// Delete an entry
    func deleteEntry(id: UUID) throws {
        let request: NSFetchRequest<SkinJournalEntry> = SkinJournalEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first else {
                throw SkinJournalError.entryNotFound
            }
            
            // Delete photo from disk
            if let photoFileName = entity.photoFileName {
                _ = photoStorage.deletePhoto(filename: photoFileName)
            }
            
            // Delete from Core Data
            context.delete(entity)
            try context.save()
            
            print("✅ Deleted journal entry: \(id)")
            
            // Refresh entries
            fetchAllEntries()
        } catch {
            print("❌ Failed to delete entry: \(error)")
            throw SkinJournalError.deleteFailed
        }
    }
    
    /// Delete all entries (use with caution!)
    func deleteAllEntries() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = SkinJournalEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            // Delete all photos
            _ = photoStorage.deleteAllPhotos()
            
            print("✅ Deleted all journal entries")
            
            // Refresh entries
            fetchAllEntries()
        } catch {
            print("❌ Failed to delete all entries: \(error)")
            throw SkinJournalError.deleteFailed
        }
    }
    
    // MARK: - Photo Loading
    
    /// Load photo for an entry
    func loadPhoto(for entry: SkinJournalEntryModel) -> UIImage? {
        return photoStorage.loadPhoto(filename: entry.photoFileName)
    }
    
    /// Load photo by filename
    func loadPhoto(filename: String) -> UIImage? {
        return photoStorage.loadPhoto(filename: filename)
    }
    
    // MARK: - Statistics
    
    /// Get total number of entries
    var totalEntries: Int {
        return entries.count
    }
    
    /// Get current streak (consecutive days with entries)
    func getCurrentStreak() -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            if entryDate == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if entryDate < currentDate {
                break
            }
        }
        
        return streak
    }
    
    /// Get storage used by photos
    func getTotalStorageUsed() -> String {
        let bytes = photoStorage.getTotalStorageUsed()
        let megabytes = Double(bytes) / 1_048_576.0
        return String(format: "%.1f MB", megabytes)
    }
}

// MARK: - Error Types

enum SkinJournalError: LocalizedError {
    case photoSaveFailed
    case saveFailed
    case updateFailed
    case deleteFailed
    case entryNotFound
    
    var errorDescription: String? {
        switch self {
        case .photoSaveFailed:
            return L10n.SkinJournal.Error.photoSaveFailed
        case .saveFailed:
            return L10n.SkinJournal.Error.saveFailed
        case .updateFailed:
            return L10n.SkinJournal.Error.updateFailed
        case .deleteFailed:
            return L10n.SkinJournal.Error.deleteFailed
        case .entryNotFound:
            return L10n.SkinJournal.Error.entryNotFound
        }
    }
}


