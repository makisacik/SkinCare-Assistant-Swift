//
//  CyclePromotionBanner.swift
//  ManCare
//
//  Promotional banner for cycle tracking feature
//

import SwiftUI

struct CyclePromotionBanner: View {
    let onEnable: () -> Void
    let onDismiss: () -> Void

    @State private var isVisible = false
    @ObservedObject private var premiumManager = PremiumManager.shared

    var body: some View {
        // Don't show promotion banner to premium users
        if premiumManager.isPremium {
            EmptyView()
        } else {
            bannerContent
        }
    }

    private var bannerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with dismiss button
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("Adapt Your Routine to Your Cycle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }

                Text(premiumManager.isPremium ? "Get personalized skincare for each phase" : "Premium feature - Upgrade to unlock")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Phase icons with descriptions
            HStack(spacing: 12) {
                phaseIcon(icon: "drop.fill", color: ThemeManager.shared.theme.palette.error, text: "Gentle")
                phaseIcon(icon: "sparkles", color: ThemeManager.shared.theme.palette.success, text: "Active")
                phaseIcon(icon: "sun.max.fill", color: ThemeManager.shared.theme.palette.warning, text: "Balanced")
                phaseIcon(icon: "moon.fill", color: ThemeManager.shared.theme.palette.primary, text: "Control")
            }

            // Enable button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if premiumManager.canUseCycleAdaptation() {
                    onEnable()
                }
            } label: {
                HStack(spacing: 8) {
                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(premiumManager.isPremium ? "Enable Cycle Tracking" : "Upgrade to Premium")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.shared.theme.palette.primary,
                    ThemeManager.shared.theme.palette.primaryLight
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 12, x: 0, y: 4)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }

    private func phaseIcon(icon: String, color: Color, text: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CyclePromotionBanner(
            onEnable: { print("Enable tapped") },
            onDismiss: { print("Dismiss tapped") }
        )
        .padding()

        Spacer()
    }
    .background(ThemeManager.shared.theme.palette.background)
}


