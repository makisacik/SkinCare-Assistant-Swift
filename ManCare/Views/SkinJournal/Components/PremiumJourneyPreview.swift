//
//  PremiumJourneyPreview.swift
//  ManCare
//
//  Preview of journal entries for premium users with compare button
//

import SwiftUI

struct PremiumJourneyPreview: View {
    let onCompareRequest: () -> Void
    
    @ObservedObject private var store = SkinJournalStore.shared
    @StateObject private var moodStore = DailyMoodStore()
    
    var body: some View {
        VStack(spacing: 16) {
            if store.totalEntries >= 2 {
                // Show latest 2 entries preview
                entriesPreviewSection
            } else {
                // Not enough entries yet
                noEntriesSection
            }
        }
        .padding(20)
    }
    
    // MARK: - Entries Preview Section
    
    private var entriesPreviewSection: some View {
        VStack(spacing: 16) {
            // Two entry thumbnails side by side
            HStack(spacing: 12) {
                if let entries = getLatestTwoEntries() {
                    // Before entry
                    entryThumbnail(entry: entries.before, label: "Before", color: Color(red: 0.9, green: 0.6, blue: 0.6))
                    
                    // After entry
                    entryThumbnail(entry: entries.after, label: "After", color: Color(red: 0.71, green: 0.88, blue: 0.78))
                }
            }
            
            // Compare button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onCompareRequest()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.2.gobackward")
                        .font(.system(size: 16))
                    Text("Compare Progress")
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.theme.palette.primary,
                            ThemeManager.shared.theme.palette.secondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
        }
    }
    
    // MARK: - Entry Thumbnail
    
    private func entryThumbnail(entry: SkinJournalEntryModel, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            // Photo
            if let image = store.loadPhoto(for: entry) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.4), lineWidth: 2)
                    )
            }
            
            // Info
            VStack(spacing: 4) {
                Text(label)
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(color)
                
                Text(formatDate(entry.date))
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                
                // Mood emoji (from DailyMoodStore)
                if let mood = moodStore.getMoodEntry(for: entry.date)?.moodEmoji {
                    Text(mood)
                        .font(.system(size: 20))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - No Entries Section
    
    private var noEntriesSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted.opacity(0.6))
            
            VStack(spacing: 4) {
                Text("Add More Entries")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text("Add at least 2 photos to start comparing")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    private func getLatestTwoEntries() -> (before: SkinJournalEntryModel, after: SkinJournalEntryModel)? {
        let sortedEntries = store.entries.sorted { $0.date > $1.date }
        guard sortedEntries.count >= 2 else { return nil }
        
        return (before: sortedEntries[1], after: sortedEntries[0])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

