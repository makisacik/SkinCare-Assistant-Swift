//
//  TagTrendsCard.swift
//  ManCare
//
//  Created for Insights Tab Feature
//

import SwiftUI

struct TagTrendsCard: View {
    let tagFrequencies: [(tag: SkinFeelTag, percentage: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                    )
                
                Text(L10n.Myself.SkinFeel.title)
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
            }
            
            if tagFrequencies.isEmpty {
                emptyStateView
            } else {
                // Grid of circular progress rings
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(tagFrequencies, id: \.tag) { item in
                        tagItem(tag: item.tag, percentage: item.percentage)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }
    
    @ViewBuilder
    private func tagItem(tag: SkinFeelTag, percentage: Double) -> some View {
        VStack(spacing: 8) {
            CircularProgressRing(
                percentage: percentage,
                color: tag.color,
                lineWidth: 6,
                size: 70
            )
            
            VStack(spacing: 2) {
                Text(tag.emoji)
                    .font(.system(size: 20))
                
                Text(tag.displayName)
                    .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "face.smiling")
                .font(.system(size: 32))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text(L10n.Myself.SkinFeel.empty)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Text(L10n.Myself.SkinFeel.emptySubtitle)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    VStack(spacing: 16) {
        TagTrendsCard(tagFrequencies: [
            (.glowing, 45),
            (.smooth, 35),
            (.calm, 25),
            (.oily, 20),
            (.dry, 15)
        ])
        
        TagTrendsCard(tagFrequencies: [])
    }
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}

