//
//  InsightStatCard.swift
//  ManCare
//
//  Created for Insights Tab Feature
//

import SwiftUI

struct InsightStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let iconColor: Color
    let showGradient: Bool
    
    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String,
        iconColor: Color,
        showGradient: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.showGradient = showGradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and title
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )
                
                Text(title)
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
            }
            
            // Value
            Text(value)
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            // Subtitle
            Text(subtitle)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    showGradient ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            iconColor.opacity(0.1),
                            iconColor.opacity(0.05),
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
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
}

#Preview {
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
    .background(ThemeManager.shared.theme.palette.background)
}

