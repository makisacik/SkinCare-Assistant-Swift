//
//  SkinJournalCard.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct SkinJournalCard: View {
    @ObservedObject private var store = SkinJournalStore.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @StateObject private var moodStore = DailyMoodStore()
    @State private var showingTimeline = false
    @State private var showingAddEntry = false
    @State private var showPremiumSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Content based on premium status
            if !premiumManager.isPremium {
                // Non-premium users - always show interactive demo
                InteractiveComparisonDemo(onUpgradeRequest: {
                    showPremiumSheet = true
                })
            } else {
                // Premium users
                if store.totalEntries >= 2 {
                    // Show premium preview with journal button
                    VStack(spacing: 0) {
                        premiumHeaderSection
                        Divider()
                            .background(ThemeManager.shared.theme.palette.border)
                        PremiumJourneyPreview(onJournalRequest: {
                            showingTimeline = true
                        })
                    }
                } else {
                    // Show regular content view
                    standardContentView
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingTimeline) {
            SkinJournalTimelineView()
        }
        .sheet(isPresented: $showingAddEntry) {
            AddSkinJournalEntryView()
        }
        .sheet(isPresented: $showPremiumSheet) {
            SkinJournalPremiumSheet()
        }
        .onAppear {
            print("🔄 SkinJournalCard appeared, refreshing entries...")
            store.fetchAllEntries()
        }
    }

    // MARK: - Premium Header Section

    private var premiumHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Skin Journey")
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text("\(store.totalEntries) entr\(store.totalEntries == 1 ? "y" : "ies")")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            Spacer()

            Image(systemName: "camera.on.rectangle.fill")
                .font(.system(size: 24))
                .foregroundColor(ThemeManager.shared.theme.palette.primary.opacity(0.6))
        }
        .padding(20)
    }

    // MARK: - Standard Content View

    private var standardContentView: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skin Journey")
                            .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        if store.totalEntries > 0 {
                            Text("\(store.totalEntries) entr\(store.totalEntries == 1 ? "y" : "ies")")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        } else {
                            Text("Track your skin progress")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "camera.on.rectangle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary.opacity(0.6))
                }
                .padding(20)

                Divider()
                    .background(ThemeManager.shared.theme.palette.border)

                if store.totalEntries > 0 {
                    // Content when entries exist
                    contentView
                } else {
                    // Empty state
                    emptyStateView
                }
            }
            .blur(radius: premiumManager.isPremium ? 0 : 5)

            // Premium overlay for non-premium users
            if !premiumManager.isPremium {
                premiumOverlay
            }
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Latest two entries preview
            latestEntriesPreview()

            // "More on journal" text if more than 3 entries
            if store.totalEntries > 3 {
                Text("More on journal")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    .padding(.top, 4)
            }

            // View Journal button
            viewJournalButton
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }

    private func latestEntriesPreview() -> some View {
        VStack(spacing: 12) {
            let sortedEntries = store.entries.sorted { $0.date > $1.date }
            let entriesToShow = Array(sortedEntries.prefix(2))

            ForEach(entriesToShow, id: \.id) { entry in
                entryPreviewRow(entry)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

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

                        Text("Mood")
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

    private var viewJournalButton: some View {
        Button {
            if premiumManager.canUseSkinJournal() {
                showingTimeline = true
            } else {
                showPremiumSheet = true
            }
        } label: {
            HStack(spacing: 8) {
                Text("View Journal")
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primary,
                        ThemeManager.shared.theme.palette.secondary
                    ]),
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

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.circle")
                .font(.system(size: 48))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted.opacity(0.6))

            VStack(spacing: 6) {
                Text("Start tracking your skin")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text("Take progress selfies and journal entries")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                if premiumManager.canUseSkinJournal() {
                    showingAddEntry = true
                } else {
                    showPremiumSheet = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Add First Entry")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.primary,
                            ThemeManager.shared.theme.palette.secondary
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
    }

    // MARK: - Premium Overlay

    private var premiumOverlay: some View {
        VStack(spacing: 16) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.84, blue: 0.0),
                                Color(red: 1.0, green: 0.65, blue: 0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.4), radius: 12, x: 0, y: 6)

                Image(systemName: "crown.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Premium Feature")
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text("Track your skin journey with progress photos and detailed entries")
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Button {
                showPremiumSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Upgrade to Premium")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.65, blue: 0.0),
                            Color(red: 1.0, green: 0.45, blue: 0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(24)
                .shadow(
                    color: Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.98))
        )
        .padding(.horizontal, 40)
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}


