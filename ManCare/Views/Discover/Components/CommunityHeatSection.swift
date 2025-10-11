//
//  CommunityHeatSection.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct CommunityHeatSection: View {
    let trendingRoutines: [(routine: RoutineTemplate, increase: Int)]
    let selectedPeriod: TrendingPeriod
    let onPeriodChange: (TrendingPeriod) -> Void
    let onRoutineTap: (RoutineTemplate) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Community Heat")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.orange)
                    }
                    
                    Text("What people save most")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Period filter chips
            HStack(spacing: 8) {
                ForEach(TrendingPeriod.allCases, id: \.self) { period in
                    PeriodChip(
                        period: period,
                        isSelected: selectedPeriod == period,
                        onTap: {
                            onPeriodChange(period)
                        }
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Trending routines list
            if trendingRoutines.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(trendingRoutines.enumerated()), id: \.element.routine.id) { index, item in
                        TrendingRoutineRow(
                            routine: item.routine,
                            increase: item.increase,
                            onTap: {
                                onRoutineTap(item.routine)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Update timestamp
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    
                    Text("Updated \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text("No trending data yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Period Chip

struct PeriodChip: View {
    let period: TrendingPeriod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(period.displayText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.onPrimary : ThemeManager.shared.theme.palette.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surface)
                )
                .overlay(
                    Capsule()
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CommunityHeatSection(
        trendingRoutines: [
            (routine: RoutineTemplate.featuredRoutines[0], increase: 42),
            (routine: RoutineTemplate.featuredRoutines[1], increase: 31),
            (routine: RoutineTemplate.featuredRoutines[2], increase: 24)
        ],
        selectedPeriod: .thisWeek,
        onPeriodChange: { _ in },
        onRoutineTap: { _ in }
    )
}

