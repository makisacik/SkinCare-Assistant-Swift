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
    
    @State private var currentStep: AddEntryStep = .camera
    @State private var capturedPhoto: UIImage?
    @State private var isPhotoMirrored = false
    @State private var notes: String = ""
    @State private var selectedMoodTags: Set<String> = []
    @State private var selectedSkinFeelTags: Set<SkinFeelTag> = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
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
                    
                    // Notes section
                    notesSection
                    
                    // Mood tags section
                    moodTagsSection
                    
                    // Skin feel tags section
                    skinFeelTagsSection
                }
                .padding()
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(ThemeManager.shared.theme.palette.surface, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        print("🔙 Back button tapped, returning to camera")
                        withAnimation {
                            currentStep = .camera
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("💾 Save button tapped!")
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving)
                }
            }
            .onAppear {
                print("📝 Details view appeared")
                print("📝 Captured photo exists: \(capturedPhoto != nil)")
            }
        }
    }
    
    private func photoPreview(_ photo: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Photo")
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
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text("How is your skin feeling today?")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            TextEditor(text: $notes)
                .frame(height: 120)
                .padding(12)
                .background(ThemeManager.shared.theme.palette.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        }
    }
    
    private var moodTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifestyle Factors")
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text("What might be affecting your skin?")
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            SkinJournalFlowLayout(spacing: 8) {
                ForEach(MoodTag.allTags, id: \.emoji) { tag in
                    moodTagChip(tag)
                }
            }
        }
    }
    
    private func moodTagChip(_ tag: MoodTag) -> some View {
        let isSelected = selectedMoodTags.contains(tag.emoji)
        
        return Button {
            if isSelected {
                selectedMoodTags.remove(tag.emoji)
            } else {
                selectedMoodTags.insert(tag.emoji)
            }
        } label: {
            HStack(spacing: 6) {
                Text(tag.emoji)
                    .font(.system(size: 16))
                Text(tag.label)
                    .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                    ThemeManager.shared.theme.palette.primary.opacity(0.15) :
                    ThemeManager.shared.theme.palette.surface
            )
            .foregroundColor(
                isSelected ?
                    ThemeManager.shared.theme.palette.primary :
                    ThemeManager.shared.theme.palette.textPrimary
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                            ThemeManager.shared.theme.palette.primary :
                            ThemeManager.shared.theme.palette.border,
                        lineWidth: 1.5
                    )
            )
        }
    }
    
    private var skinFeelTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skin Feel")
                .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text("Describe how your skin feels")
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
                Text(tag.rawValue)
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
                
                Text("Analyzing your photo...")
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(.white)
                
                Text("This may take a moment")
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
            errorMessage = "No photo captured"
            showError = true
            return
        }
        
        // Apply mirroring if user flipped the image
        if isPhotoMirrored {
            photo = mirrorImage(photo)
            print("🔄 Photo mirrored before saving")
        }
        
        print("📝 Starting to save entry...")
        print("   Notes: '\(notes)'")
        print("   Mood tags: \(selectedMoodTags)")
        print("   Skin feel tags: \(selectedSkinFeelTags)")
        print("   Photo mirrored: \(isPhotoMirrored)")
        
        isSaving = true
        
        Task {
            do {
                let moodTagsArray = Array(selectedMoodTags)
                let skinFeelTagsArray = Array(selectedSkinFeelTags)
                
                let savedEntry = try await store.saveEntry(
                    photo: photo,
                    notes: notes,
                    moodTags: moodTagsArray,
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


