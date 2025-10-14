//
//  SkinJournalCard.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct SkinJournalCard: View {
    @ObservedObject private var store = SkinJournalStore.shared
    @State private var showingTimeline = false
    @State private var showingAddEntry = false
    
    var body: some View {
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
                showingAddEntry = true
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
            showingTimeline = true
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
                showingAddEntry = true
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
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}


