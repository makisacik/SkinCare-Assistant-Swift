//
//  MiniGuideCard.swift
//  ManCare
//
//  Compact article-style card for Mini Guides
//

import SwiftUI

struct MiniGuideCard: View {
    let guide: MiniGuide
    let onTap: () -> Void

    // Rotating imagery for guide cards
    @State private var activeImageIndex: Int = 0
    private let imageTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    private var guideImages: [String] {
        switch guide.title {
        case "How your cycle affects skin":
            return ["guide-cycle-1", "guide-cycle-2", "guide-cycle-3", "guide-cycle-4"]
        case "AM vs PM Routine":
            return ["guide-ampm-1", "guide-ampm-2", "guide-ampm-3", "guide-ampm-4"]
        case "Acids, Explained":
            return ["guide-acids-1", "guide-acids-2", "guide-acids-3", "guide-acids-4"]
        case "Retinoids":
            return ["guide-retinol-1", "guide-retinol-2", "guide-retinol-3", "guide-retinol-4"]
        case "Skinimalism & Minimal Routines":
            return ["guide-minimalist-1", "guide-minimalist-2", "guide-minimalist-3", "guide-minimalist-4"]
        default:
            return []
        }
    }

    private var hasRotatingImages: Bool {
        !guideImages.isEmpty
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with read time badge
                ZStack {
                    Group {
                        if hasRotatingImages {
                            ZStack {
                                ForEach(0..<guideImages.count, id: \.self) { idx in
                                    Image(guideImages[idx])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 280, height: 180)
                                        .clipped()
                                        .opacity(idx == activeImageIndex ? 1 : 0)
                                }
                            }
                            .animation(.easeInOut(duration: 0.45), value: activeImageIndex)
                        } else {
                            Image(guide.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 280, height: 180)
                                .clipped()
                        }
                    }
                    // Image already framed and clipped, no wrapper clipping
                    
                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Read time badge overlay
                    VStack {
                        HStack {
                            // Read time badge
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("\(guide.minutes) MIN")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(Color.black.opacity(0.55))
                            )
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(16)
                    
                    // Bottom content
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(guide.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Text(guide.category)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                    }
                }
                .frame(width: 280, height: 180)
                .cornerRadius(16)
                .onReceive(imageTimer) { _ in
                    guard hasRotatingImages else { return }
                    activeImageIndex = (activeImageIndex + 1) % guideImages.count
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MiniGuideCard(
        guide: MiniGuide(
            id: UUID(),
            title: "Skincare 101: Build a basic routine",
            subtitle: "Cleanse, treat, moisturize, protect",
            minutes: 5,
            imageName: "skincare-products/basic-kit",
            category: "Basics"
        ),
        onTap: {}
    )
    .padding()
}
