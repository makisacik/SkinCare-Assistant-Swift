//
//  HeroBannerCard.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct HeroBannerCard: View {
    let banner: HeroBanner
    let onTap: () -> Void
    
    @State private var tickerOffset: CGFloat = 0
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Main content
                VStack(alignment: .leading, spacing: 12) {
                    // Title with shimmer
                    Text(banner.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(shimmerOverlay)
                    
                    // Subtitle
                    Text(banner.subtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // CTA Button
                    HStack {
                        Text(banner.ctaText)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(ThemeManager.shared.theme.palette.primary)
                    )
                    .padding(.top, 4)
                }
                .padding(20)
                
                // Ticker section
                TickerView(tickerText: banner.ticker.displayText, offset: $tickerOffset)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Color.black.opacity(0.03)
                    )
            }
            .background(
                LinearGradient(
                    colors: banner.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.1), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            startTickerAnimation()
            startShimmerAnimation()
        }
    }
    
    private var shimmerOverlay: some View {
        LinearGradient(
            colors: [
                .white.opacity(0),
                .white.opacity(0.3),
                .white.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 100)
        .offset(x: shimmerPhase * 400 - 200)
        .mask(
            Text(banner.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
        )
    }
    
    private func startTickerAnimation() {
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            tickerOffset = -500
        }
    }
    
    private func startShimmerAnimation() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5s before first shimmer
            withAnimation(.linear(duration: 2)) {
                shimmerPhase = 1
            }
        }
    }
}

// MARK: - Ticker View

struct TickerView: View {
    let tickerText: String
    @Binding var offset: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundColor(ThemeManager.shared.theme.palette.primary.opacity(0.7))
            
            Text(tickerText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        HeroBannerCard(
            banner: HeroBanner(
                title: "Barrier Reset Week",
                subtitle: "Soothe redness + rebuild your moisture shield",
                ctaText: "Explore routines",
                themeColor: "#FFE6D1",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7 * 24 * 3600),
                ticker: TickerStats(routines: 5, guides: 2)
            ),
            onTap: {
                print("Banner tapped")
            }
        )
        .padding()
    }
}

