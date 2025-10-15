//
//  SkinJournalComparisonView.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct SkinJournalComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = SkinJournalStore.shared
    
    @State private var beforeEntry: SkinJournalEntryModel?
    @State private var afterEntry: SkinJournalEntryModel?
    @State private var sliderPosition: CGFloat = 0.5
    @State private var viewMode: ComparisonMode = .slider
    
    enum ComparisonMode {
        case slider
        case sideBySide
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Entry selectors
                entrySelectorsSection
                
                // Comparison view
                if let before = beforeEntry, let after = afterEntry {
                    comparisonSection(before: before, after: after)
                } else {
                    emptySelectionView
                }
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("Compare Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if beforeEntry != nil && afterEntry != nil {
                        Picker("View", selection: $viewMode) {
                            Image(systemName: "slider.horizontal.3")
                                .tag(ComparisonMode.slider)
                            Image(systemName: "square.split.2x1")
                                .tag(ComparisonMode.sideBySide)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                }
            }
        }
        .onAppear {
            setupDefaultComparison()
        }
    }
    
    // MARK: - Entry Selectors
    
    private var entrySelectorsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Before selector
                entrySelector(
                    label: "Before",
                    entry: beforeEntry,
                    color: .red
                ) {
                    beforeEntry = $0
                }
                
                // After selector
                entrySelector(
                    label: "After",
                    entry: afterEntry,
                    color: .green
                ) {
                    afterEntry = $0
                }
            }
            
            if let before = beforeEntry, let after = afterEntry {
                timeDifferenceView(before: before, after: after)
            }
        }
        .padding()
        .background(ThemeManager.shared.theme.palette.surface)
    }
    
    private func entrySelector(
        label: String,
        entry: SkinJournalEntryModel?,
        color: Color,
        onSelect: @escaping (SkinJournalEntryModel) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                .foregroundColor(color)
            
            Menu {
                ForEach(store.entries) { e in
                    Button {
                        onSelect(e)
                    } label: {
                        Text(formatDate(e.date))
                    }
                }
            } label: {
                HStack {
                    if let entry = entry {
                        if let image = store.loadPhoto(for: entry) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDate(entry.date))
                                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            Text(formatTime(entry.date))
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    } else {
                        Text("Select Entry")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.3), lineWidth: 2)
                        )
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func timeDifferenceView(before: SkinJournalEntryModel, after: SkinJournalEntryModel) -> some View {
        let days = Calendar.current.dateComponents([.day], from: before.date, to: after.date).day ?? 0
        
        return HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 14))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text("\(abs(days)) day\(abs(days) == 1 ? "" : "s") apart")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(ThemeManager.shared.theme.palette.background)
        )
    }
    
    // MARK: - Comparison Section
    
    private func comparisonSection(before: SkinJournalEntryModel, after: SkinJournalEntryModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo comparison
                if viewMode == .slider {
                    sliderComparisonView(before: before, after: after)
                } else {
                    sideBySideComparisonView(before: before, after: after)
                }
                
                // Tags comparison
                tagsComparisonView(before: before, after: after)
            }
            .padding()
        }
    }
    
    private func sliderComparisonView(before: SkinJournalEntryModel, after: SkinJournalEntryModel) -> some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // After image (background)
                    if let afterImage = store.loadPhoto(for: after) {
                        Image(uiImage: afterImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    
                    // Before image (sliding overlay)
                    if let beforeImage = store.loadPhoto(for: before) {
                        Image(uiImage: beforeImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .mask(
                                Rectangle()
                                    .frame(width: geometry.size.width * sliderPosition)
                            )
                    }
                    
                    // Slider line
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 3)
                        .offset(x: geometry.size.width * sliderPosition - 1.5)
                    
                    // Slider handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(radius: 4)
                        .overlay(
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 10, weight: .bold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.black)
                        )
                        .offset(x: geometry.size.width * sliderPosition - 20)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    sliderPosition = min(max(0, value.location.x / geometry.size.width), 1)
                                }
                        )
                }
            }
            .frame(height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
            )
            
            // Labels
            HStack {
                Label("Before", systemImage: "arrow.left")
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(.red)
                
                Spacer()
                
                Label("After", systemImage: "arrow.right")
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(.green)
                    .labelStyle(.trailingIcon)
            }
            .padding(.horizontal, 8)
        }
    }
    
    private func sideBySideComparisonView(before: SkinJournalEntryModel, after: SkinJournalEntryModel) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                if let beforeImage = store.loadPhoto(for: before) {
                    Image(uiImage: beforeImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text("Before")
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                if let afterImage = store.loadPhoto(for: after) {
                    Image(uiImage: afterImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text("After")
                    .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                    .foregroundColor(.green)
            }
        }
    }
    
    private func tagsComparisonView(before: SkinJournalEntryModel, after: SkinJournalEntryModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skin Feel")
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            HStack(alignment: .top, spacing: 12) {
                // Before tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("Before")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                        .foregroundColor(.red)
                    
                    if !before.skinFeelTags.isEmpty {
                        ForEach(before.skinFeelTags, id: \.self) { tag in
                            Text("• \(tag.rawValue)")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    } else {
                        Text("No tags")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // After tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("After")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                        .foregroundColor(.green)
                    
                    if !after.skinFeelTags.isEmpty {
                        ForEach(after.skinFeelTags, id: \.self) { tag in
                            Text("• \(tag.rawValue)")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    } else {
                        Text("No tags")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
    }
    
    // MARK: - Empty State
    
    private var emptySelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.and.right.square")
                .font(.system(size: 60))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text("Select entries to compare")
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func setupDefaultComparison() {
        if store.entries.count >= 2 {
            // Set most recent as "after" and second most recent as "before"
            afterEntry = store.entries[0]
            beforeEntry = store.entries[1]
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Trailing Icon Label Style

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}


