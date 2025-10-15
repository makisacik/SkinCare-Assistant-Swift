//
//  SkinJournalModels.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Journal Entry Source

enum JournalEntrySource: String, Codable {
    case skinJournal = "skin_journal"
    case moodTrackingCard = "mood_tracking_card"
}

// MARK: - Skin Journal Entry

struct SkinJournalEntryModel: Identifiable, Codable {
    let id: UUID
    let date: Date
    var photoFileName: String
    var notes: String
    var moodTags: [String] // Emoji tags
    var skinFeelTags: [SkinFeelTag]
    var imageAnalysis: ImageAnalysisResult
    let createdAt: Date
    var reminderEnabled: Bool
    var source: JournalEntrySource // Track where entry was created from
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        photoFileName: String,
        notes: String = "",
        moodTags: [String] = [],
        skinFeelTags: [SkinFeelTag] = [],
        imageAnalysis: ImageAnalysisResult = ImageAnalysisResult(),
        createdAt: Date = Date(),
        reminderEnabled: Bool = false,
        source: JournalEntrySource = .skinJournal
    ) {
        self.id = id
        self.date = date
        self.photoFileName = photoFileName
        self.notes = notes
        self.moodTags = moodTags
        self.skinFeelTags = skinFeelTags
        self.imageAnalysis = imageAnalysis
        self.createdAt = createdAt
        self.reminderEnabled = reminderEnabled
        self.source = source
    }
}

// MARK: - Skin Feel Tag

enum SkinFeelTag: String, CaseIterable, Codable {
    case oily = "Oily"
    case dry = "Dry"
    case smooth = "Smooth"
    case rough = "Rough"
    case irritated = "Irritated"
    case calm = "Calm"
    case glowing = "Glowing"
    case dull = "Dull"
    case sensitive = "Sensitive"
    case wrinkles = "Wrinkles"
    case dryness = "Dryness"
    
    var emoji: String {
        switch self {
        case .oily: return "💧"
        case .dry: return "🏜️"
        case .smooth: return "✨"
        case .rough: return "🌵"
        case .irritated: return "🔴"
        case .calm: return "😌"
        case .glowing: return "✨"
        case .dull: return "😑"
        case .sensitive: return "😣"
        case .wrinkles: return "👴"
        case .dryness: return "🥵"
        }
    }
    
    var color: Color {
        switch self {
        case .oily: return .blue
        case .dry: return .orange
        case .smooth: return .green
        case .rough: return .brown
        case .irritated: return .red
        case .calm: return .mint
        case .glowing: return .yellow
        case .dull: return .gray
        case .sensitive: return .pink
        case .wrinkles: return .purple
        case .dryness: return .orange
        }
    }
}

// MARK: - Mood Tag

struct MoodTag {
    let emoji: String
    let label: String
    
    static let allTags: [MoodTag] = [
        MoodTag(emoji: "💤", label: "Sleep"),
        MoodTag(emoji: "☀️", label: "Sun"),
        MoodTag(emoji: "🍫", label: "Diet"),
        MoodTag(emoji: "💧", label: "Hydration"),
        MoodTag(emoji: "😰", label: "Stress"),
        MoodTag(emoji: "🏋️", label: "Exercise"),
        MoodTag(emoji: "🧴", label: "New Product"),
        MoodTag(emoji: "🌙", label: "Sleep Quality")
    ]
}

// MARK: - Image Analysis Result

struct ImageAnalysisResult: Codable {
    let brightness: Double // 0.0 to 1.0
    let overallTone: String // "even", "redness detected", etc.
    let analyzedAt: Date
    
    init(
        brightness: Double = 0.5,
        overallTone: String = "Not analyzed",
        analyzedAt: Date = Date()
    ) {
        self.brightness = brightness
        self.overallTone = overallTone
        self.analyzedAt = analyzedAt
    }
    
    var brightnessDescription: String {
        switch brightness {
        case 0.0..<0.3:
            return "Darker appearance"
        case 0.3..<0.5:
            return "Moderate tone"
        case 0.5..<0.7:
            return "Bright appearance"
        case 0.7...1.0:
            return "Very bright"
        default:
            return "Normal"
        }
    }
    
    var brightnessChange: Double {
        // This will be calculated when comparing two entries
        return 0.0
    }
}

// MARK: - Helper Extensions

extension SkinJournalEntryModel {
    /// Convert Core Data entity to model
    static func from(entity: SkinJournalEntry) -> SkinJournalEntryModel? {
        guard let id = entity.id,
              let date = entity.date,
              let photoFileName = entity.photoFileName,
              let createdAt = entity.createdAt else {
            return nil
        }
        
        let notes = entity.notes ?? ""
        let moodTags = (entity.moodTags ?? "").split(separator: ",").map(String.init)
        let skinFeelTagStrings = (entity.skinFeelTags ?? "").split(separator: ",").map(String.init)
        let skinFeelTags = skinFeelTagStrings.compactMap { SkinFeelTag(rawValue: $0) }
        
        let imageAnalysis = ImageAnalysisResult(
            brightness: entity.brightness,
            overallTone: entity.overallTone ?? "Not analyzed",
            analyzedAt: createdAt
        )

        // Parse source, defaulting to skinJournal for backward compatibility
        let sourceString = entity.value(forKey: "source") as? String ?? "skin_journal"
        let source = JournalEntrySource(rawValue: sourceString) ?? .skinJournal

        return SkinJournalEntryModel(
            id: id,
            date: date,
            photoFileName: photoFileName,
            notes: notes,
            moodTags: moodTags,
            skinFeelTags: skinFeelTags,
            imageAnalysis: imageAnalysis,
            createdAt: createdAt,
            reminderEnabled: entity.reminderEnabled,
            source: source
        )
    }

    /// Convert model to Core Data entity
    func toEntity(context: NSManagedObjectContext) -> SkinJournalEntry {
        let entity = SkinJournalEntry(context: context)
        entity.id = self.id
        entity.date = self.date
        entity.photoFileName = self.photoFileName
        entity.notes = self.notes
        entity.moodTags = self.moodTags.joined(separator: ",")
        entity.skinFeelTags = self.skinFeelTags.map { $0.rawValue }.joined(separator: ",")
        entity.brightness = self.imageAnalysis.brightness
        entity.overallTone = self.imageAnalysis.overallTone
        entity.createdAt = self.createdAt
        entity.reminderEnabled = self.reminderEnabled

        // Save source if the entity supports it (backward compatible)
        entity.setValue(self.source.rawValue, forKey: "source")

        return entity
    }
}

import CoreData
