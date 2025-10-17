//
//  SkinJournalModels.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Skin Journal Entry

struct SkinJournalEntryModel: Identifiable, Codable {
    let id: UUID
    let date: Date
    var photoFileName: String
    var notes: String
    var skinFeelTags: [SkinFeelTag]
    var imageAnalysis: ImageAnalysisResult
    let createdAt: Date
    var reminderEnabled: Bool
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        photoFileName: String,
        notes: String = "",
        skinFeelTags: [SkinFeelTag] = [],
        imageAnalysis: ImageAnalysisResult = ImageAnalysisResult(),
        createdAt: Date = Date(),
        reminderEnabled: Bool = false
    ) {
        self.id = id
        self.date = date
        self.photoFileName = photoFileName
        self.notes = notes
        self.skinFeelTags = skinFeelTags
        self.imageAnalysis = imageAnalysis
        self.createdAt = createdAt
        self.reminderEnabled = reminderEnabled
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
    
    var displayName: String {
        switch self {
        case .oily: return L10n.SkinJournal.Tag.oily
        case .dry: return L10n.SkinJournal.Tag.dry
        case .smooth: return L10n.SkinJournal.Tag.smooth
        case .rough: return L10n.SkinJournal.Tag.rough
        case .irritated: return L10n.SkinJournal.Tag.irritated
        case .calm: return L10n.SkinJournal.Tag.calm
        case .glowing: return L10n.SkinJournal.Tag.glowing
        case .dull: return L10n.SkinJournal.Tag.dull
        case .sensitive: return L10n.SkinJournal.Tag.sensitive
        case .wrinkles: return L10n.SkinJournal.Tag.wrinkles
        case .dryness: return L10n.SkinJournal.Tag.dryness
        }
    }

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
    
    static var allTags: [MoodTag] {
        return [
            MoodTag(emoji: "💤", label: L10n.SkinJournal.Mood.sleep),
            MoodTag(emoji: "☀️", label: L10n.SkinJournal.Mood.sun),
            MoodTag(emoji: "🍫", label: L10n.SkinJournal.Mood.diet),
            MoodTag(emoji: "💧", label: L10n.SkinJournal.Mood.hydration),
            MoodTag(emoji: "😰", label: L10n.SkinJournal.Mood.stress),
            MoodTag(emoji: "🏋️", label: L10n.SkinJournal.Mood.exercise),
            MoodTag(emoji: "🧴", label: L10n.SkinJournal.Mood.newProduct),
            MoodTag(emoji: "🌙", label: L10n.SkinJournal.Mood.sleepQuality)
        ]
    }
}

// MARK: - Image Analysis Result

struct ImageAnalysisResult: Codable {
    let brightness: Double // 0.0 to 1.0
    let overallTone: String // "even", "redness detected", etc.
    let analyzedAt: Date
    
    init(
        brightness: Double = 0.5,
        overallTone: String? = nil,
        analyzedAt: Date = Date()
    ) {
        self.brightness = brightness
        self.overallTone = overallTone ?? L10n.SkinJournal.Analysis.notAnalyzed
        self.analyzedAt = analyzedAt
    }
    
    var brightnessDescription: String {
        switch brightness {
        case 0.0..<0.3:
            return L10n.SkinJournal.Analysis.darkerAppearance
        case 0.3..<0.5:
            return L10n.SkinJournal.Analysis.moderateTone
        case 0.5..<0.7:
            return L10n.SkinJournal.Analysis.brightAppearance
        case 0.7...1.0:
            return L10n.SkinJournal.Analysis.veryBright
        default:
            return L10n.SkinJournal.Analysis.normal
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
        let skinFeelTagStrings = (entity.skinFeelTags ?? "").split(separator: ",").map(String.init)
        let skinFeelTags = skinFeelTagStrings.compactMap { SkinFeelTag(rawValue: $0) }

        let imageAnalysis = ImageAnalysisResult(
            brightness: entity.brightness,
            overallTone: entity.overallTone,
            analyzedAt: createdAt
        )

        return SkinJournalEntryModel(
            id: id,
            date: date,
            photoFileName: photoFileName,
            notes: notes,
            skinFeelTags: skinFeelTags,
            imageAnalysis: imageAnalysis,
            createdAt: createdAt,
            reminderEnabled: entity.reminderEnabled
        )
    }

    /// Convert model to Core Data entity
    func toEntity(context: NSManagedObjectContext) -> SkinJournalEntry {
        let entity = SkinJournalEntry(context: context)
        entity.id = self.id
        entity.date = self.date
        entity.photoFileName = self.photoFileName
        entity.notes = self.notes
        entity.skinFeelTags = self.skinFeelTags.map { $0.rawValue }.joined(separator: ",")
        entity.brightness = self.imageAnalysis.brightness
        entity.overallTone = self.imageAnalysis.overallTone
        entity.createdAt = self.createdAt
        entity.reminderEnabled = self.reminderEnabled

        return entity
    }
}

import CoreData
