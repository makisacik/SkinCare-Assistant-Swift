//
//  SkinJournalTimelineView.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct SkinJournalTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = SkinJournalStore.shared
    @State private var showingAddEntry = false
    @State private var searchText = ""
    @State private var showingComparison = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredEntries: [SkinJournalEntryModel] {
        if searchText.isEmpty {
            return store.entries
        } else {
            return store.entries.filter { entry in
                entry.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                if store.entries.isEmpty {
                    emptyState
                } else {
                    contentView
                }
                
                // Floating action button
                addButton
                    .padding(24)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("Skin Journey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                }
                
                if !store.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingComparison = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left.and.right")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Compare")
                                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                            }
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(ThemeManager.shared.theme.palette.primary.opacity(0.12))
                            .cornerRadius(16)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search notes...")
            .sheet(isPresented: $showingAddEntry) {
                AddSkinJournalEntryView()
            }
            .sheet(isPresented: $showingComparison) {
                if store.entries.count >= 2 {
                    SkinJournalComparisonView()
                }
            }
        }
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats header
                statsHeader
                
                // Timeline grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredEntries) { entry in
                        EntryCard(entry: entry, store: store)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for FAB
            }
            .padding(.top)
        }
    }
    
    private var statsHeader: some View {
        HStack(spacing: 16) {
            statBox(
                icon: "photo.on.rectangle.angled",
                value: "\(store.totalEntries)",
                label: "Entries"
            )
            
            statBox(
                icon: "flame.fill",
                value: "\(store.getCurrentStreak())",
                label: "Day Streak"
            )
            
            statBox(
                icon: "internaldrive.fill",
                value: store.getTotalStorageUsed(),
                label: "Storage"
            )
        }
        .padding(.horizontal)
    }
    
    private func statBox(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
            
            Text(value)
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text(label)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.on.rectangle.fill")
                .font(.system(size: 80))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            VStack(spacing: 8) {
                Text("Start Your Skin Journey")
                    .font(ThemeManager.shared.theme.typo.h2.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text("Track your skin progress with selfies and notes")
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showingAddEntry = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Add Your First Entry")
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
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
                .cornerRadius(25)
                .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button {
            showingAddEntry = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.primary,
                            ThemeManager.shared.theme.palette.secondary
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
}


