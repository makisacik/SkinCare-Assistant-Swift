//
//  PremiumJourneyPreview.swift
//  ManCare
//
//  Preview of journal entries for premium users with journal button
//

import SwiftUI

struct PremiumJourneyPreview: View {
    let onJournalRequest: () -> Void
    
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
            // Two latest entries in vertical list
            let sortedEntries = store.entries.sorted { $0.date > $1.date }
            let entriesToShow = Array(sortedEntries.prefix(2))

            ForEach(entriesToShow, id: \.id) { entry in
                entryPreviewRow(entry)
            }

            // "More on journal" text if more than 3 entries
            if store.totalEntries > 3 {
                Text(L10n.SkinJournal.Journey.moreOnJournal)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    .padding(.top, 4)
            }

            // View Journal button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onJournalRequest()
            } label: {
                HStack(spacing: 8) {
                    Text(L10n.SkinJournal.Journey.viewJournal)
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
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
                .cornerRadius(12)
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
        }
    }
    
    // MARK: - Entry Preview Row
    
    private func entryPreviewRow(_ entry: SkinJournalEntryModel) -> some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let image = store.loadPhoto(for: entry) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(formatDate(entry.date))
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                // Mood emoji (from DailyMoodStore)
                if let mood = moodStore.getMoodEntry(for: entry.date)?.moodEmoji {
                    HStack(spacing: 6) {
                        Text(mood)
                            .font(.system(size: 20))

                        Text(L10n.SkinJournal.Journey.mood)
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.background.opacity(0.5))
        )
    }
    
    // MARK: - No Entries Section
    
    private var noEntriesSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted.opacity(0.6))
            
            VStack(spacing: 4) {
                Text(L10n.SkinJournal.Journey.addMoreEntries)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text(L10n.SkinJournal.Journey.addAtLeastTwoPhotos)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

