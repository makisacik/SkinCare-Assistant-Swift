//
//  SkinJournalEntryDetailView.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct SkinJournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = SkinJournalStore.shared
    
    let entry: SkinJournalEntryModel
    
    @State private var showingDeleteConfirm = false
    @State private var showingShareSheet = false
    @State private var isEditing = false
    @State private var editedNotes: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo
                    photoSection
                    
                    // Analysis insights
                    analysisSection
                    
                    // Notes
                    notesSection
                    
                    // Tags
                    if !entry.moodTags.isEmpty || !entry.skinFeelTags.isEmpty {
                        tagsSection
                    }
                    
                    // Metadata
                    metadataSection
                }
                .padding()
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            if let image = store.loadPhoto(for: entry) {
                                shareImage(image)
                            }
                        } label: {
                            Label("Share Photo", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Label("Delete Entry", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                }
            }
            .confirmationDialog("Delete Entry", isPresented: $showingDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    deleteEntry()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
        }
        .onAppear {
            editedNotes = entry.notes
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = store.loadPhoto(for: entry) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            } else {
                // Placeholder if photo not found
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeManager.shared.theme.palette.surface)
                    .frame(height: 400)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            Text("Photo not available")
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                    )
            }
        }
    }
    
    // MARK: - Analysis Section
    
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis")
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            VStack(spacing: 12) {
                analysisCard(
                    icon: "sun.max.fill",
                    title: "Brightness",
                    value: entry.imageAnalysis.brightnessDescription,
                    color: .orange
                )
                
                analysisCard(
                    icon: "face.smiling",
                    title: "Skin Tone",
                    value: entry.imageAnalysis.overallTone,
                    color: .blue
                )
            }
        }
    }
    
    private func analysisCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                
                Text(value)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes")
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
                
                if !entry.notes.isEmpty {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveNotes()
                        }
                        isEditing.toggle()
                    }
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
            }
            
            if isEditing {
                TextEditor(text: $editedNotes)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(ThemeManager.shared.theme.palette.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            } else if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeManager.shared.theme.palette.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                            )
                    )
            } else {
                Text("No notes added")
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    .italic()
            }
        }
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !entry.moodTags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lifestyle Factors")
                        .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    SkinJournalFlowLayout(spacing: 8) {
                        ForEach(entry.moodTags, id: \.self) { emoji in
                            tagChip(emoji: emoji, label: getMoodTagLabel(emoji: emoji))
                        }
                    }
                }
            }
            
            if !entry.skinFeelTags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Skin Feel")
                        .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    SkinJournalFlowLayout(spacing: 8) {
                        ForEach(entry.skinFeelTags, id: \.self) { tag in
                            skinFeelChip(tag: tag)
                        }
                    }
                }
            }
        }
    }
    
    private func tagChip(emoji: String, label: String) -> some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 16))
            Text(label)
                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(ThemeManager.shared.theme.palette.surface)
        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
        )
    }
    
    private func skinFeelChip(tag: SkinFeelTag) -> some View {
        HStack(spacing: 6) {
            Text(tag.emoji)
                .font(.system(size: 16))
            Text(tag.rawValue)
                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tag.color.opacity(0.15))
        .foregroundColor(tag.color)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tag.color, lineWidth: 1)
        )
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        VStack(spacing: 8) {
            metadataRow(icon: "calendar", label: "Date", value: formatDate(entry.date))
            metadataRow(icon: "clock", label: "Created", value: formatDateTime(entry.createdAt))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.5))
        )
    }
    
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .frame(width: 20)
            
            Text(label)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMoodTagLabel(emoji: String) -> String {
        MoodTag.allTags.first { $0.emoji == emoji }?.label ?? emoji
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveNotes() {
        do {
            try store.updateEntry(id: entry.id, notes: editedNotes)
        } catch {
            print("❌ Failed to update notes: \(error)")
        }
    }
    
    private func deleteEntry() {
        do {
            try store.deleteEntry(id: entry.id)
            dismiss()
        } catch {
            print("❌ Failed to delete entry: \(error)")
        }
    }
    
    private func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}


