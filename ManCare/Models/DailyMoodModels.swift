//
//  DailyMoodModels.swift
//  ManCare
//
//  Created by AI Assistant on 15.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Daily Mood Entry

struct DailyMoodEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let moodEmoji: String
    var hasPhoto: Bool
    var skinJournalEntryId: UUID?
    
    init(
        id: UUID = UUID(),
        date: Date,
        moodEmoji: String,
        hasPhoto: Bool = false,
        skinJournalEntryId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.moodEmoji = moodEmoji
        self.hasPhoto = hasPhoto
        self.skinJournalEntryId = skinJournalEntryId
    }
}

// MARK: - Mood Option

struct MoodOption: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
    
    static let allMoods: [MoodOption] = [
        MoodOption(emoji: "😊", label: "Happy"),
        MoodOption(emoji: "😐", label: "Neutral"),
        MoodOption(emoji: "😔", label: "Sad"),
        MoodOption(emoji: "😴", label: "Tired"),
        MoodOption(emoji: "😰", label: "Stressed"),
        MoodOption(emoji: "😤", label: "Frustrated"),
        MoodOption(emoji: "🤩", label: "Excited"),
        MoodOption(emoji: "😌", label: "Calm")
    ]
}

// MARK: - Daily Mood Store

class DailyMoodStore: ObservableObject {
    @Published var entries: [DailyMoodEntry] = []
    
    private let userDefaultsKey = "dailyMoodEntries"
    private let calendar = Calendar.current
    
    init() {
        loadEntries()
    }
    
    // MARK: - Public Methods
    
    /// Get mood entry for a specific date
    func getMoodEntry(for date: Date) -> DailyMoodEntry? {
        let normalizedDate = calendar.startOfDay(for: date)
        return entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: normalizedDate)
        }
    }
    
    /// Save a new mood selection
    func saveMood(emoji: String, for date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Remove existing entry for this date if any
        entries.removeAll { entry in
            calendar.isDate(entry.date, inSameDayAs: normalizedDate)
        }
        
        // Create new entry
        let newEntry = DailyMoodEntry(
            date: normalizedDate,
            moodEmoji: emoji,
            hasPhoto: false
        )
        
        entries.append(newEntry)
        saveEntries()
        
        print("💚 Saved mood \(emoji) for \(normalizedDate)")
    }
    
    /// Update mood entry to mark photo as taken
    func markPhotoTaken(for date: Date, journalEntryId: UUID) {
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let index = entries.firstIndex(where: { entry in
            calendar.isDate(entry.date, inSameDayAs: normalizedDate)
        }) {
            entries[index].hasPhoto = true
            entries[index].skinJournalEntryId = journalEntryId
            saveEntries()
            
            print("📸 Marked photo taken for mood entry on \(normalizedDate)")
        }
    }
    
    /// Check if mood and photo are completed for date
    func isCompleted(for date: Date) -> Bool {
        guard let entry = getMoodEntry(for: date) else {
            return false
        }
        return entry.hasPhoto
    }
    
    /// Check if mood is selected (but photo not taken yet)
    func hasMoodOnly(for date: Date) -> Bool {
        guard let entry = getMoodEntry(for: date) else {
            return false
        }
        return !entry.hasPhoto
    }
    
    // MARK: - Persistence
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            entries = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            entries = try decoder.decode([DailyMoodEntry].self, from: data)
            print("✅ Loaded \(entries.count) mood entries")
        } catch {
            print("❌ Error loading mood entries: \(error)")
            entries = []
        }
    }
    
    private func saveEntries() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entries)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            print("💾 Saved \(entries.count) mood entries")
        } catch {
            print("❌ Error saving mood entries: \(error)")
        }
    }
    
    /// Clean up old entries (optional - keep last 90 days)
    func cleanupOldEntries() {
        let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        entries.removeAll { entry in
            entry.date < ninetyDaysAgo
        }
        saveEntries()
    }
}

