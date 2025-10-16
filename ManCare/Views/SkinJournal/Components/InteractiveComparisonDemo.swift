//
//  InteractiveComparisonDemo.swift
//  ManCare
//
//  Interactive before/after comparison demo for non-premium users
//

import SwiftUI

struct InteractiveComparisonDemo: View {
    let onUpgradeRequest: () -> Void
    
    @State private var sliderPosition: CGFloat = 1.0
    @State private var demoPhase: DemoPhase = .idle
    @State private var isDragging = false
    @State private var shouldRunAnimation = false
    
    private let demoVisitCountKey = "skinJourneyDemoVisitCount"
    
    enum DemoPhase {
        case idle
        case autoPlaying
        case interactive
        case completed
    }
    
    // Demo images
    private let beforeImage = "before-3"
    private let afterImage = "after-3"
    
    var body: some View {
        VStack(spacing: 24) {
            // Premium badge
            HStack(spacing: 6) {
                Image(systemName: "camera.on.rectangle.fill")
                    .font(.system(size: 13, weight: .bold))
                Text("SKIN JOURNEY")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1.2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.theme.palette.primary,
                                ThemeManager.shared.theme.palette.secondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.4), radius: 8, x: 0, y: 4)
            
            // Tagline
            VStack(spacing: 8) {
                Text("See your glow evolve")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Track progress with before & after photos")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            // Comparison demo
            comparisonSliderView

            // Feature highlights
            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "camera.fill",
                    text: "Weekly progress selfies"
                )

                featureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Visual timeline of changes"
                )

                featureRow(
                    icon: "face.smiling.fill",
                    text: "Mood & skin correlation"
                )
            }
            .padding(.top, 8)

            // CTA Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onUpgradeRequest()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Try Premium Free for 7 Days")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.theme.palette.primary,
                            ThemeManager.shared.theme.palette.secondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(28)
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.5),
                    radius: 16,
                    x: 0,
                    y: 8
                )
            }
        }
        .padding(28)
        .onAppear {
            // Increment visit count
            let currentCount = UserDefaults.standard.integer(forKey: demoVisitCountKey)
            let newCount = currentCount + 1
            UserDefaults.standard.set(newCount, forKey: demoVisitCountKey)
            
            // Run animation only on odd visits (1, 3, 5, 7, etc.)
            if newCount % 2 == 1 {
                shouldRunAnimation = true
                startAutoPlaySequence()
            } else {
                // Even visits - just set to middle position without animation
                sliderPosition = 0.5
                demoPhase = .interactive
            }
        }
    }
    
    // MARK: - Feature Row
    
    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary.opacity(0.12))
                )
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Spacer()
        }
    }
    
    // MARK: - Comparison Slider View
    
    private var comparisonSliderView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // After image (background)
                Image(afterImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Before image (sliding overlay)
                Image(beforeImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .mask(
                        Rectangle()
                            .frame(width: geometry.size.width * sliderPosition)
                    )
                
                // Slider line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
                    .offset(x: geometry.size.width * sliderPosition - 1.5)
                
                // Slider handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.gray)
                    )
                    .offset(x: geometry.size.width * sliderPosition - 22)
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if demoPhase == .autoPlaying { return }
                                
                                isDragging = true
                                demoPhase = .interactive
                                
                                let newPosition = min(max(0, value.location.x / geometry.size.width), 1)
                                sliderPosition = newPosition
                            }
                            .onEnded { _ in
                                isDragging = false
                                
                                // Haptic feedback
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    )
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Auto-Play Sequence
    
    private func startAutoPlaySequence() {
        demoPhase = .idle
        
        // Wait 1 second before starting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            demoPhase = .autoPlaying
            
            // Animate slider from right (1.0) to left (0.0)
            withAnimation(.easeInOut(duration: 2.0)) {
                sliderPosition = 0.0
            }
            
            // Pause for 0.5s, then animate to middle
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 2.0)) {
                    sliderPosition = 0.5
                }
                
                // Complete animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    demoPhase = .interactive
                }
            }
        }
    }
}

