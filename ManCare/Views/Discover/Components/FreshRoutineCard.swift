//
//  FreshRoutineCard.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct FreshRoutineCard: View {
    let routine: RoutineTemplate
    let badge: RoutineBadge
    let onTap: () -> Void
    let onSave: () -> Void
    
    @State private var isSaved: Bool = false
    @State private var badgeScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with badge
                ZStack {
                    Image(routine.imageName)
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
                    
                    // Badge overlay
                    VStack {
                        HStack {
                            BadgeView(badge: badge, scale: badgeScale)
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
                                Text(routine.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(routine.stepCount) steps • \(routine.duration)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            // Save button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isSaved.toggle()
                                }
                                onSave()
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(16)
                    }
                }
                .frame(width: 280, height: 180)
                .cornerRadius(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if badge == .new {
                startBadgePulse()
            }
        }
    }
    
    private func startBadgePulse() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                badgeScale = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    badgeScale = 1.0
                }
            }
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let badge: RoutineBadge
    let scale: CGFloat
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: badge.icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
            
            Text(badge.displayText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(badge.color)
        )
        .scaleEffect(scale)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            FreshRoutineCard(
                routine: RoutineTemplate.featuredRoutines[0],
                badge: .new,
                onTap: {},
                onSave: {}
            )
            
            FreshRoutineCard(
                routine: RoutineTemplate.featuredRoutines[1],
                badge: .trending,
                onTap: {},
                onSave: {}
            )
            
            FreshRoutineCard(
                routine: RoutineTemplate.featuredRoutines[2],
                badge: .updated,
                onTap: {},
                onSave: {}
            )
        }
        .padding()
    }
}

