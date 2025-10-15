//
//  DailyMoodTrackingCard.swift
//  ManCare
//
//  Created by AI Assistant on 15.10.2025.
//

import SwiftUI

struct DailyMoodTrackingCard: View {
    let selectedDate: Date
    
    @StateObject private var moodStore = DailyMoodStore()
    @State private var showingCamera = false
    @State private var selectedMood: String?
    @State private var capturedImage: UIImage?
    @State private var shouldHideCard = false
    
    private var moodEntry: DailyMoodEntry? {
        moodStore.getMoodEntry(for: selectedDate)
    }
    
    private var cardState: CardState {
        if let entry = moodEntry {
            return entry.hasPhoto ? .completed : .photoCapture
        } else {
            return .moodSelection
        }
    }
    
    private var shouldShowCard: Bool {
        // Don't show if already completed for today
        if moodStore.isCompleted(for: selectedDate) {
            return false
        }
        // Don't show if manually hidden after completion
        if shouldHideCard {
            return false
        }
        return true
    }

    enum CardState {
        case moodSelection
        case photoCapture
        case completed
    }
    
    var body: some View {
        Group {
            if shouldShowCard {
                VStack(spacing: 0) {
                    switch cardState {
                    case .moodSelection:
                        moodSelectionView
                    case .photoCapture:
                        photoCaptureView
                    case .completed:
                        completedView
                    }
                }
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            SkinJournalCameraView(
                lastSelfieImage: nil,
                onPhotoCapture: { image in
                    handlePhotoCapture(image)
                }
            )
        }
        .onChange(of: selectedDate) { _ in
            // Reset hide state when date changes
            shouldHideCard = false
        }
    }
    
    // MARK: - State 1: Mood Selection
    
    private var moodSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("How are you feeling today?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text("Select your mood to track your skin journey")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            // Mood Grid
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.background.opacity(0.2),
                            ThemeManager.shared.theme.palette.background.opacity(0.2),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }
    
    private func moodButton(mood: MoodOption) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood.emoji
                moodStore.saveMood(emoji: mood.emoji, for: selectedDate)
            }
        } label: {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 40))
                
                Text(mood.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - State 2: Photo Capture
    
    private var photoCaptureView: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showingCamera = true
        } label: {
            HStack(spacing: 16) {
                // Mood indicator
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Text(moodEntry?.moodEmoji ?? "😊")
                        .font(.system(size: 32))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Skin Log")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("Capture your skin today")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                Spacer()
                
                // Camera icon
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.shared.theme.palette.background.opacity(0.2),
                                ThemeManager.shared.theme.palette.background.opacity(0.2),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeManager.shared.theme.palette.primary.opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - State 3: Completed
    
    private var completedView: some View {
        HStack(spacing: 16) {
            // Mood indicator with checkmark
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.theme.palette.success.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Text(moodEntry?.moodEmoji ?? "😊")
                    .font(.system(size: 28))
                
                // Checkmark badge
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.success)
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 20, y: 20)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Daily Skin Log")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.success)
                }
                
                Text("Completed for today")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            Spacer()
            
            // View in journal button
            Button {
                // TODO: Navigate to Skin Journal
                print("📖 Navigate to Skin Journal")
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.background.opacity(0.2),
                            ThemeManager.shared.theme.palette.background.opacity(0.2),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.success.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // MARK: - Photo Capture Handler
    
    private func handlePhotoCapture(_ image: UIImage) {
        print("📸 Photo captured in mood tracking card")
        
        // Create UUID for this entry
        let entryId = UUID()
        
        // Save image using PhotoStorageService
        guard let photoFileName = PhotoStorageService.shared.savePhoto(image, withID: entryId) else {
            print("❌ Failed to save image")
            showingCamera = false
            return
        }
        
        print("✅ Saved photo: \(photoFileName)")
        
        // Create Skin Journal entry (without mood - that's stored separately)
        let journalEntry = SkinJournalEntryModel(
            id: entryId,
            date: selectedDate,
            photoFileName: photoFileName,
            notes: "",
            skinFeelTags: [],
            imageAnalysis: analyzeImage(image),
            createdAt: Date(),
            reminderEnabled: false
        )
        
        // Save to Skin Journal (using Core Data)
        saveSkinJournalEntry(journalEntry)
        
        // Update mood store
        moodStore.markPhotoTaken(for: selectedDate, journalEntryId: journalEntry.id)
        
        // Provide haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Dismiss camera
        showingCamera = false
        
        print("✅ Skin Journal entry created with mood: \(moodEntry?.moodEmoji ?? "")")

        // Hide card after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                shouldHideCard = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func analyzeImage(_ image: UIImage) -> ImageAnalysisResult {
        // Simple brightness analysis
        let brightness = calculateAverageBrightness(image: image)
        
        return ImageAnalysisResult(
            brightness: brightness,
            overallTone: "Captured from mood tracking",
            analyzedAt: Date()
        )
    }
    
    private func calculateAverageBrightness(image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0.5 }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalBrightness: Double = 0
        let pixelCount = width * height
        
        for i in 0..<pixelCount {
            let offset = i * bytesPerPixel
            let r = Double(pixelData[offset])
            let g = Double(pixelData[offset + 1])
            let b = Double(pixelData[offset + 2])
            
            // Calculate perceived brightness
            let brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            totalBrightness += brightness
        }
        
        return totalBrightness / Double(pixelCount)
    }
    
    private func saveSkinJournalEntry(_ entry: SkinJournalEntryModel) {
        let context = PersistenceController.shared.container.viewContext
        let _ = entry.toEntity(context: context)
        
        do {
            try context.save()
            print("✅ Saved Skin Journal entry to Core Data")
        } catch {
            print("❌ Error saving Skin Journal entry: \(error)")
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Mood Selection") {
    DailyMoodTrackingCard(selectedDate: Date())
        .padding()
}
#endif

