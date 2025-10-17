//
//  AddSkinJournalEntryView.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

struct AddSkinJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = SkinJournalStore.shared
    @StateObject private var moodStore = DailyMoodStore()
    
    @State private var currentStep: AddEntryStep = .camera
    @State private var capturedPhoto: UIImage?
    @State private var isPhotoMirrored = false
    @State private var selectedMood: String? // Changed from selectedMoodTags to single mood
    @State private var selectedSkinFeelTags: Set<SkinFeelTag> = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var hasMoodForToday = false
    
    enum AddEntryStep {
        case camera
        case details
    }
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .camera:
                cameraView
            case .details:
                detailsView
            }
            
            if isSaving {
                savingOverlay
            }
        }
        .alert(L10n.Common.error, isPresented: $showError) {
            Button(L10n.Common.ok, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Camera View
    
    private var cameraView: some View {
        SkinJournalCameraView(
            lastSelfieImage: nil,
            onPhotoCapture: { photo in
                print("📸 Photo received in AddSkinJournalEntryView")
                print("📸 Photo size: \(photo.size)")
                capturedPhoto = photo
                print("📸 Transitioning to details step...")
                withAnimation {
                    currentStep = .details
                }
                print("📸 Now on step: \(currentStep)")
            }
        )
    }
    
    // MARK: - Details View
    
    private var detailsView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo preview
                    if let photo = capturedPhoto {
                        photoPreview(photo)
                    }
                    
                    // Mood tags section (only if no mood exists for today)
                    if !hasMoodForToday {
                        moodTagsSection
                    }
                    
                    // Skin feel tags section
                    skinFeelTagsSection
                }
                .padding()
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle(L10n.SkinJournal.AddEntry.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(ThemeManager.shared.theme.palette.surface, for: .navigationBar)
            .onAppear {
                // Set navigation title color to app's text color
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(ThemeManager.shared.theme.palette.surface)
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor(ThemeManager.shared.theme.palette.textPrimary)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance

                // Check if mood already exists for today
                hasMoodForToday = moodStore.getMoodEntry(for: Date()) != nil

                print("📝 Details view appeared")
                print("📝 Captured photo exists: \(capturedPhoto != nil)")
                print("📝 Has mood for today: \(hasMoodForToday)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.SkinJournal.AddEntry.back) {
                        print("🔙 Back button tapped, returning to camera")
                        withAnimation {
                            currentStep = .camera
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.SkinJournal.AddEntry.save) {
                        print("💾 Save button tapped!")
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func photoPreview(_ photo: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.SkinJournal.AddEntry.yourPhoto)
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
                
                Button {
                    print("🔄 Mirror tapped! Current: \(isPhotoMirrored)")
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPhotoMirrored.toggle()
                    }
                    print("🔄 New state: \(isPhotoMirrored)")
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            ThemeManager.shared.theme.palette.primary.opacity(isPhotoMirrored ? 0.3 : 0.1)
                        )
                        .clipShape(Circle())
                        .contentShape(Circle())  // full circle is hittable
                }
                .buttonStyle(.plain)
                .background(Color.black.opacity(0.001))  // guarantees a hittable surface
                .allowsHitTesting(true)  // belt-and-suspenders
            }
            .zIndex(10)  // lift the header above anything below
            .onTapGesture { 
                print("📍 Header row tapped (sanity check)")
            }
            .onAppear {
                print("📸 Photo preview appeared with flip button")
            }
            
            ZStack {
                if isPhotoMirrored {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(x: -1, y: 1)
                } else {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
            )
            .zIndex(0)  // explicitly under the header
        }
    }
    
    private var moodTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.SkinJournal.AddEntry.howAreYouFeeling)
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text(L10n.SkinJournal.AddEntry.selectMood)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            // Mood grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(MoodOption.allMoods) { mood in
                    moodButton(mood: mood)
                }
            }
        }
    }
    
    private func moodButton(mood: MoodOption) -> some View {
        let isSelected = selectedMood == mood.emoji
        
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if isSelected {
                selectedMood = nil
            } else {
                selectedMood = mood.emoji
            }
        } label: {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 32))

                Text(mood.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.primary.opacity(0.15) : ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var skinFeelTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.SkinJournal.AddEntry.skinFeel)
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text(L10n.SkinJournal.AddEntry.describeSkinFeel)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            SkinJournalFlowLayout(spacing: 8) {
                ForEach(SkinFeelTag.allCases, id: \.self) { tag in
                    skinFeelTagChip(tag)
                }
            }
        }
    }
    
    private func skinFeelTagChip(_ tag: SkinFeelTag) -> some View {
        let isSelected = selectedSkinFeelTags.contains(tag)
        
        return Button {
            if isSelected {
                selectedSkinFeelTags.remove(tag)
            } else {
                selectedSkinFeelTags.insert(tag)
            }
        } label: {
            HStack(spacing: 6) {
                Text(tag.emoji)
                    .font(.system(size: 16))
                Text(tag.displayName)
                    .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                    tag.color.opacity(0.15) :
                    ThemeManager.shared.theme.palette.surface
            )
            .foregroundColor(
                isSelected ?
                    tag.color :
                    ThemeManager.shared.theme.palette.textPrimary
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                            tag.color :
                            ThemeManager.shared.theme.palette.border,
                        lineWidth: 1.5
                    )
            )
        }
    }
    
    // MARK: - Saving Overlay
    
    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(L10n.SkinJournal.AddEntry.analyzingPhoto)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(.white)
                
                Text(L10n.SkinJournal.AddEntry.takingAMoment)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func saveEntry() {
        guard var photo = capturedPhoto else {
            print("❌ No photo captured")
            errorMessage = L10n.SkinJournal.AddEntry.noPhotoCaptured
            showError = true
            return
        }
        
        // Apply mirroring if user flipped the image
        if isPhotoMirrored {
            photo = mirrorImage(photo)
            print("🔄 Photo mirrored before saving")
        }
        
        print("📝 Starting to save entry...")
        print("   Selected mood: \(selectedMood ?? "none")")
        print("   Skin feel tags: \(selectedSkinFeelTags)")
        print("   Photo mirrored: \(isPhotoMirrored)")
        
        isSaving = true
        
        Task {
            do {
                let skinFeelTagsArray = Array(selectedSkinFeelTags)

                // Save mood separately to DailyMoodStore if selected (only if no mood exists yet)
                if let moodEmoji = selectedMood, !hasMoodForToday {
                    moodStore.saveMood(emoji: moodEmoji, for: Date())
                    print("💚 Saved mood: \(moodEmoji)")
                }

                let savedEntry = try await store.saveEntry(
                    photo: photo,
                    notes: "",
                    skinFeelTags: skinFeelTagsArray
                )
                
                print("✅ Entry saved successfully! ID: \(savedEntry.id)")
                
                await MainActor.run {
                    isSaving = false
                    print("✅ Dismissing add entry view")
                    dismiss()
                }
            } catch {
                print("❌ Error saving entry: \(error)")
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func mirrorImage(_ image: UIImage) -> UIImage {
        // Use UIImage's draw method to preserve orientation
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        // Flip the context horizontally
        context.translateBy(x: image.size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        
        // Draw using UIImage's draw method which respects orientation
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        // Get the flipped image
        guard let flippedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return image
        }
        
        return flippedImage
    }
}

// MARK: - Flow Layout

struct SkinJournalFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}


