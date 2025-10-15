//
//  EntryCard.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct EntryCard: View {
    let entry: SkinJournalEntryModel
    let store: SkinJournalStore
    @StateObject private var moodStore = DailyMoodStore()

    private var moodForEntry: String? {
        moodStore.getMoodEntry(for: entry.date)?.moodEmoji
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo thumbnail
            ZStack(alignment: .topTrailing) {
                if let image = store.loadPhoto(for: entry) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(ThemeManager.shared.theme.palette.surface)
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        )
                }
                
                // Date badge
                Text(formatDate(entry.date))
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(8)
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 8) {
                // Mood emoji (from DailyMoodStore)
                if let mood = moodForEntry {
                    HStack(spacing: 6) {
                        Text(mood)
                            .font(.system(size: 24))
                        
                        Text("Mood")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                }
                
                // Skin feel tags
                if !entry.skinFeelTags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(entry.skinFeelTags.prefix(2), id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag.emoji)
                                    .font(.system(size: 10))
                                Text(tag.rawValue)
                                    .font(ThemeManager.shared.theme.typo.caption)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(tag.color.opacity(0.15))
                            .foregroundColor(tag.color)
                            .cornerRadius(6)
                        }
                        
                        if entry.skinFeelTags.count > 2 {
                            Text("+\(entry.skinFeelTags.count - 2)")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(ThemeManager.shared.theme.palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
        )
        .shadow(
            color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}


