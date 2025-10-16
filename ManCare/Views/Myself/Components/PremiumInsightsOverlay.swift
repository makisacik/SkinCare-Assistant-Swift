//
//  PremiumInsightsOverlay.swift
//  ManCare
//
//  Premium overlay for Insights tab
//

import SwiftUI

struct PremiumInsightsOverlay: View {
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            // Solid background to prevent any content from showing through
            ThemeManager.shared.theme.palette.background
                .ignoresSafeArea()

            // ScrollView structure matching Journal tab
            ScrollView {
                VStack(spacing: 20) {
                    // Premium content card
                    premiumContentCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onSubscribe: {
                    // Premium granted
                },
                onClose: {
                    // User dismissed
                }
            )
        }
    }
    
    @ViewBuilder
    private var premiumContentCard: some View {
        VStack(spacing: 24) {
            // Premium badge
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 13, weight: .bold))
                Text("AI-POWERED")
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
                Text("Get AI-powered insights")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("on your routines and skin progress")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)
            
            // Feature highlights
            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Smart routine analysis"
                )
                
                featureRow(
                    icon: "chart.bar.fill",
                    text: "Most used product trends"
                )
                
                featureRow(
                    icon: "drop.fill",
                    text: "Mood & skin pattern correlation"
                )
            }
            .padding(.top, 8)
            
            // CTA Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showPaywall = true
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
            .padding(.top, 8)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.15),
                    radius: 30,
                    x: 0,
                    y: 15
                )
        )
    }
    
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
}

#Preview {
    ZStack {
        // Background content (simulated insights)
        ScrollView {
            VStack(spacing: 16) {
                InsightStatCard(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "7",
                    subtitle: "Days in a row",
                    iconColor: ThemeManager.shared.theme.palette.success,
                    showGradient: true
                )
                
                InsightStatCard(
                    icon: "chart.bar.fill",
                    title: "Weekly Rate",
                    value: "85%",
                    subtitle: "12 of 14 routines completed",
                    iconColor: ThemeManager.shared.theme.palette.primary
                )
            }
            .padding()
        }
        .background(ThemeManager.shared.theme.palette.background)
        
        // Overlay
        PremiumInsightsOverlay()
    }
}

