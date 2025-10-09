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
    var onSubscribe: () -> Void  // Called when user "purchases" (testing mode - no actual payment)
    var onClose: () -> Void      // Called when user closes without purchasing
    
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
                            Text("PREMIUM")
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
                        Text("Try for free")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .padding(.top, 4)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(text: "Enjoy your first week for free!")
                            FeatureRow(text: "Cancel anytime with ease")
                            FeatureRow(text: "Create and track skincare routines")
                            FeatureRow(text: "Sync routines with your cycle")
                            FeatureRow(text: "All content, no limits, no ads")
                        }
                        .padding(.horizontal, 24)
                        
                        // Pricing
                        VStack(spacing: 4) {
                            Text("Try 7 days free, then just ₺199,99 / year")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Only ₺16,66/month, billed annually.")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // CTA Button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onSubscribe()
                        } label: {
                            Text("Start my free week")
                                .font(.system(size: 17, weight: .semibold))
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
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Footer
                        HStack(spacing: 4) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            
                            Text("Secured by the App Store. Cancel at any time.")
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
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onClose()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    }
                }
            }
            .modifier(ClearNavigationBarModifier())
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
