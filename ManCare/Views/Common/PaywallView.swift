//
//  PaywallView.swift
//  ManCare
//
//  Premium feature paywall view
//
//  TESTING MODE: Currently simulates successful purchases without payment processing
//  For production: Integrate StoreKit/RevenueCat for actual subscription handling
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var premiumManager = PremiumManager.shared
    var onSubscribe: () -> Void  // Called when user "purchases" (testing mode - no actual payment)
    var onClose: () -> Void      // Called when user closes without purchasing

    @State private var showCloseButton = false
    @State private var isPurchasing = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Hero Image - extends behind toolbar
                    Image("paywall-background-1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.35)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    
                    // Content below image
                    VStack(spacing: 16) {
                        // Premium Badge
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text(L10n.Paywall.premium)
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.2)
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ThemeManager.shared.theme.palette.primary,
                                            ThemeManager.shared.theme.palette.primaryLight
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 6, x: 0, y: 3)
                        .padding(.top, 12)
                        
                        // Title
                        Text(L10n.Paywall.title)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .padding(.top, 4)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(text: L10n.Paywall.Features.freeWeek)
                            FeatureRow(text: L10n.Paywall.Features.cancelAnytime)
                            FeatureRow(text: L10n.Paywall.Features.createRoutines)
                            FeatureRow(text: L10n.Paywall.Features.syncCycle)
                            FeatureRow(text: L10n.Paywall.Features.noLimits)
                        }
                        .padding(.horizontal, 24)
                        
                        // Pricing
                        VStack(spacing: 4) {
                            Text(L10n.Paywall.Pricing.trial)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(L10n.Paywall.Pricing.monthly)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // CTA Button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            Task {
                                isPurchasing = true
                                do {
                                    try await premiumManager.purchasePremium()
                                    onSubscribe()
                                    dismiss()
                                } catch {
                                    print("❌ Purchase failed: \(error)")
                                }
                                isPurchasing = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                }
                                Text(isPurchasing ? L10n.Paywall.Action.processing : L10n.Paywall.Action.startFreeTrial)
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
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
                            .cornerRadius(26)
                            .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Footer
                        HStack(spacing: 4) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            
                            Text(L10n.Paywall.Footer.secure)
                                .font(.system(size: 12))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .background(ThemeManager.shared.theme.palette.background)
                }
            }
            .background(ThemeManager.shared.theme.palette.background)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showCloseButton {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onClose()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .modifier(ClearNavigationBarModifier())
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showCloseButton = true
                    }
                }
            }
        }
    }
}

// MARK: - Clear Navigation Bar Modifier

private struct ClearNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.clear, for: .navigationBar)
        } else {
            content
                .onAppear {
                    // For iOS 15 and earlier, use UIKit appearance
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.success)
                )
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Spacer()
        }
    }
}


// MARK: - Preview

#Preview("PaywallView") {
    PaywallView(
        onSubscribe: {
            print("Subscribe tapped")
        },
        onClose: {
            print("Close tapped")
        }
    )
}
