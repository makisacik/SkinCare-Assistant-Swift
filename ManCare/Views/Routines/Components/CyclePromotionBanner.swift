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
    @State private var showPaywall = false
    @ObservedObject private var premiumManager = PremiumManager.shared

    var body: some View {
        // Don't show promotion banner to premium users
        if premiumManager.isPremium {
            EmptyView()
        } else {
            bannerContent
                .sheet(isPresented: $showPaywall) {
                    PaywallView(
                        onSubscribe: {
                            showPaywall = false
                            // After successful subscription, enable cycle tracking
                            onEnable()
                        },
                        onClose: {
                            showPaywall = false
                        }
                    )
                }
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
                    Text(L10n.Routines.CyclePromotion.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }

                Text(premiumManager.isPremium ? L10n.Routines.CyclePromotion.subtitlePremium : L10n.Routines.CyclePromotion.subtitleNonPremium)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Phase icons with descriptions
            HStack(spacing: 12) {
                phaseIcon(icon: "drop.fill", color: ThemeManager.shared.theme.palette.error, text: L10n.Routines.CyclePromotion.phaseGentle)
                phaseIcon(icon: "sparkles", color: ThemeManager.shared.theme.palette.success, text: L10n.Routines.CyclePromotion.phaseActive)
                phaseIcon(icon: "sun.max.fill", color: ThemeManager.shared.theme.palette.warning, text: L10n.Routines.CyclePromotion.phaseBalanced)
                phaseIcon(icon: "moon.fill", color: ThemeManager.shared.theme.palette.primary, text: L10n.Routines.CyclePromotion.phaseControl)
            }

            // Enable button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if premiumManager.isPremium {
                    // Premium users can enable directly
                    onEnable()
                } else {
                    // Non-premium users see paywall
                    showPaywall = true
                }
            } label: {
                HStack(spacing: 8) {
                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(premiumManager.isPremium ? L10n.Routines.CyclePromotion.enableCycleTracking : L10n.Routines.CyclePromotion.upgradeToPremium)
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


