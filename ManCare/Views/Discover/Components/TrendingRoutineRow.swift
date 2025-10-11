//
//  TrendingRoutineRow.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct TrendingRoutineRow: View {
    let routine: RoutineTemplate
    let increase: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Trend indicator
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.success)
                    
                    Text("\(increase)%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.success)
                }
                .frame(width: 40)
                
                // Routine info
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: routine.category.iconName)
                            .font(.system(size: 11))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        
                        Text(routine.category.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
                
                Spacer()
                
                // Sparkline
                SparklineView(percentage: increase)
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.surface)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        TrendingRoutineRow(
            routine: RoutineTemplate.featuredRoutines[0],
            increase: 42,
            onTap: {}
        )
        
        TrendingRoutineRow(
            routine: RoutineTemplate.featuredRoutines[1],
            increase: 31,
            onTap: {}
        )
        
        TrendingRoutineRow(
            routine: RoutineTemplate.featuredRoutines[2],
            increase: 24,
            onTap: {}
        )
    }
    .padding()
}

