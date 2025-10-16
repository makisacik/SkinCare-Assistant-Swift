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
    @State private var showBubble = false
    @State private var interactionCount = 0
    @State private var isDragging = false
    @State private var showUpgradePrompt = false
    @State private var shouldRunAnimation = false
    
    private let upgradePromptShownKey = "skinJourneyUpgradePromptShown"
    private let demoVisitCountKey = "skinJourneyDemoVisitCount"
    private let bubbleShownKey = "skinJourneyBubbleShown"
    
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
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
                .background(ThemeManager.shared.theme.palette.border)
            
            // Comparison demo
            VStack(spacing: 8) {
                comparisonSliderView
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // Upgrade prompt (shows after interaction or if previously shown)
                if showUpgradePrompt {
                    upgradePromptView
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Check if upgrade prompt has been shown before
            if UserDefaults.standard.bool(forKey: upgradePromptShownKey) {
                showUpgradePrompt = true
            }
            
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Skin Journey")
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text("See your glow evolve over time")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(ThemeManager.shared.theme.palette.primary.opacity(0.6))
        }
        .padding(20)
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
                                
                                // Hide bubble after first interaction
                                if showBubble {
                                    showBubble = false
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                                interactionCount += 1
                                
                                // Haptic feedback
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                
                                // Show upgrade prompt after first interaction
                                if interactionCount == 1 && !showUpgradePrompt {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        showUpgradePrompt = true
                                        UserDefaults.standard.set(true, forKey: upgradePromptShownKey)
                                    }
                                }
                            }
                    )
                
                // Floating bubble
                if showBubble && !showUpgradePrompt {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            DemoBubble(text: "Try moving the slider!", isVisible: $showBubble)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Upgrade Prompt View
    
    private var upgradePromptView: some View {
        VStack(spacing: 12) {
            Text("Unlock to compare your own photos")
                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onUpgradeRequest()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                    Text("Upgrade to Premium")
                        .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.theme.palette.primary,
                            ThemeManager.shared.theme.palette.secondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ThemeManager.shared.theme.palette.primary.opacity(0.3),
                                    ThemeManager.shared.theme.palette.secondary.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
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
                
                // Show bubble after animation completes (only if never shown before)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    demoPhase = .interactive
                    
                    // Only show bubble if it has never been shown before
                    if !UserDefaults.standard.bool(forKey: bubbleShownKey) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showBubble = true
                            UserDefaults.standard.set(true, forKey: bubbleShownKey)
                        }
                    }
                }
            }
        }
    }
}

