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

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with read time badge
                ZStack {
                    Image("placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 180)
                        .clipped()
                    
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
