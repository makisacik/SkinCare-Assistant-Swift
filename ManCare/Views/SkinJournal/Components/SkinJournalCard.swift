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
    @State private var showingTimeline = false
    @State private var showingAddEntry = false
    @State private var showingPremiumAlert = false

    var body: some View {
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

            // Premium overlay
            if !premiumManager.isPremium {
                premiumOverlay
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
        .onAppear {
            print("🔄 SkinJournalCard appeared, refreshing entries...")
            store.fetchAllEntries()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Latest entry preview
            if let latestEntry = store.getMostRecentEntry() {
                latestEntryPreview(latestEntry)
            }

            // Stats and actions
            HStack(spacing: 16) {
                // Streak stat
                statPill(
                    icon: "flame.fill",
                    value: "\(store.getCurrentStreak())",
                    label: "Day Streak",
                    color: .orange
                )

                // View button
                viewJournalButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func latestEntryPreview(_ entry: SkinJournalEntryModel) -> some View {
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
                Text("Latest Entry")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                Text(formatDate(entry.date))
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                // Mood tags
                if !entry.moodTags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.moodTags.prefix(4), id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 14))
                        }
                    }
                }
            }

            Spacer()

            // Add button
            Button {
                if premiumManager.canUseSkinJournal() {
                    showingAddEntry = true
                } else {
                    showingPremiumAlert = true
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.background.opacity(0.5))
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func statPill(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(ThemeManager.shared.theme.typo.body.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text(label)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }

    private var viewJournalButton: some View {
        Button {
            if premiumManager.canUseSkinJournal() {
                showingTimeline = true
            } else {
                showingPremiumAlert = true
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
                    showingPremiumAlert = true
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
                showingPremiumAlert = true
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
        .alert("Premium Required", isPresented: $showingPremiumAlert) {
            if !premiumManager.isPremium {
                Button("Upgrade", role: nil) {
                    // For now, just grant premium in test mode
                    Task {
                        try? await premiumManager.purchasePremium()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Skin Journey requires a premium subscription. Upgrade now to unlock this feature!")
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}


