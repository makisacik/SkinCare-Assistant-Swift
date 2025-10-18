//
//  ReviewPromptView.swift
//  ManCare
//
//  Custom review prompt that matches app theme
//

import SwiftUI
import StoreKit

struct ReviewPromptView: View {
    let onRateNow: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Main prompt card
            VStack(spacing: 0) {
                // Icon section with gradient background
                ZStack {
                    // Gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.primary.opacity(0.15),
                            ThemeManager.shared.theme.palette.primary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 120)
                    
                    // Heart icon with glow effect
                    ZStack {
                        // Glow layers
                        Circle()
                            .fill(ThemeManager.shared.theme.palette.primary.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)
                        
                        Circle()
                            .fill(ThemeManager.shared.theme.palette.primary.opacity(0.15))
                            .frame(width: 70, height: 70)
                        
                        // Main icon
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    }
                }
                
                // Content section
                VStack(spacing: 16) {
                    // Title
                    Text(L10n.Routines.Review.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    // Message
                    Text(L10n.Routines.Review.message)
                        .font(.system(size: 15))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                    
                    // Star rating display (visual only)
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ThemeManager.shared.theme.palette.warning)
                        }
                    }
                    .padding(.top, 4)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        // Rate Now button
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            print("📊 Rate button tapped")
                            onDismiss()
                            // Small delay to allow dismiss animation before showing system review
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("📊 Calling onRateNow callback")
                                onRateNow()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(L10n.Routines.Review.rateNow)
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        ThemeManager.shared.theme.palette.primary,
                                        ThemeManager.shared.theme.palette.primary.opacity(0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(
                                color: ThemeManager.shared.theme.palette.primary.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Not Now button
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onDismiss()
                        }) {
                            Text(L10n.Routines.Review.notNow)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(ThemeManager.shared.theme.palette.background)
            .cornerRadius(20)
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 20,
                x: 0,
                y: 10
            )
            .padding(.horizontal, 32)
            .scaleEffect(1.0)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// Custom button style for scale effect
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Manager to handle review prompt logic
class ReviewPromptManager: ObservableObject {
    private let visitCountKey = "routineHomeVisitCount"
    private let promptCountKey = "reviewPromptCount"
    private let userRatedKey = "userRatedApp"
    
    // Show at visits 5, 20, and 30
    private let promptMilestones = [5, 20, 30]
    private let maxPromptCount = 3 // Show maximum 3 times
    
    @Published var shouldShowPrompt = false
    
    func recordVisit() {
        // Don't do anything if user already rated
        if UserDefaults.standard.bool(forKey: userRatedKey) {
            print("📊 User already rated app, not showing prompt")
            return
        }
        
        let currentCount = UserDefaults.standard.integer(forKey: visitCountKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: visitCountKey)
        
        print("📊 Routine home visit count: \(newCount)")
        
        checkShouldShowPrompt()
    }
    
    private func checkShouldShowPrompt() {
        // Don't show if user already rated
        if UserDefaults.standard.bool(forKey: userRatedKey) {
            print("📊 User already rated app")
            return
        }
        
        let visitCount = UserDefaults.standard.integer(forKey: visitCountKey)
        let promptCount = UserDefaults.standard.integer(forKey: promptCountKey)
        
        // Check if we've shown the prompt 3 times already
        if promptCount >= maxPromptCount {
            print("📊 Already shown prompt \(promptCount) times, not showing again")
            return
        }
        
        // Check if current visit count matches a milestone
        if promptMilestones.contains(visitCount) {
            print("📊 Reached milestone visit \(visitCount), showing prompt (attempt \(promptCount + 1)/\(maxPromptCount))")
            shouldShowPrompt = true
        } else {
            print("📊 Visit \(visitCount) - Next milestone: \(promptMilestones.first(where: { $0 > visitCount }) ?? 0)")
        }
    }
    
    func markReviewPromptShown() {
        // Increment prompt count
        let currentPromptCount = UserDefaults.standard.integer(forKey: promptCountKey)
        UserDefaults.standard.set(currentPromptCount + 1, forKey: promptCountKey)
        print("📊 Review prompt dismissed (shown \(currentPromptCount + 1) times)")
    }
    
    func requestReview() {
        // Mark that user tapped rate - never show again
        UserDefaults.standard.set(true, forKey: userRatedKey)
        print("📊 User tapped rate button - will never show prompt again")
        
        // Also increment prompt count to keep tracking consistent
        markReviewPromptShown()
        
        print("📊 Requesting app review...")
        
        // Request the system review on main thread
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    print("📊 Found active window scene, requesting review")
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    print("📊 No active window scene found")
                }
            } else {
                print("📊 Using legacy review request")
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    // For testing: reset all review data
    func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: visitCountKey)
        UserDefaults.standard.removeObject(forKey: promptCountKey)
        UserDefaults.standard.removeObject(forKey: userRatedKey)
        print("📊 Review prompt data reset - next prompt will show at visit 5")
    }
}

#Preview {
    ReviewPromptView(
        onRateNow: {
            print("Rate now tapped")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
}

