//
//  SkinJournalPremiumSheet.swift
//  ManCare
//
//  Premium upgrade sheet for Skin Journey feature
//

import SwiftUI

struct SkinJournalPremiumSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero icon
                    heroSection
                    
                    // Title and subtitle
                    titleSection
                    
                    // Features list
                    featuresSection
                    
                    // CTA Button
                    ctaButton
                    
                    // Footer
                    footerSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.theme.palette.primary.opacity(0.2),
                            ThemeManager.shared.theme.palette.secondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "camera.aperture")
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Unlock Your Skin Journey")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Track your skin's transformation with powerful visual comparisons")
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(
                icon: "photo.on.rectangle.angled",
                title: "Compare unlimited photos",
                description: "Side-by-side and slider comparisons"
            )
            
            FeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Track your progress over time",
                description: "See improvements day by day"
            )
            
            FeatureRow(
                icon: "sparkles.rectangle.stack",
                title: "Get detailed skin analysis",
                description: "Brightness, tone, and more insights"
            )
            
            FeatureRow(
                icon: "book.closed.fill",
                title: "Journal with notes & mood tags",
                description: "Remember what worked for you"
            )
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task {
                isPurchasing = true
                do {
                    try await premiumManager.purchasePremium()
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
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                
                Text(isPurchasing ? "Processing..." : "Upgrade to Premium")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
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
            .cornerRadius(27)
            .shadow(
                color: ThemeManager.shared.theme.palette.primary.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Try 7 days free, then ₺199,99/year")
                .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 11))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                
                Text("Secured by App Store • Cancel anytime")
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.theme.palette.primary.opacity(0.15),
                                ThemeManager.shared.theme.palette.secondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text(description)
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

