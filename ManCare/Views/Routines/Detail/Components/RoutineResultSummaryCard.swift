//
//  RoutineResultSummaryCard.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineResultSummaryCard: View {
    
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Routines.ResultSummary.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            VStack(spacing: 12) {
                ProfileRow(title: L10n.Routines.ResultSummary.skinType, value: skinType.title, iconName: skinType.iconName)
                ProfileRow(title: L10n.Routines.ResultSummary.mainGoal, value: mainGoal.title, iconName: mainGoal.iconName)
                
                if !concerns.isEmpty {
                    ProfileRow(
                        title: L10n.Routines.ResultSummary.focusAreas,
                        value: L10n.Routines.ResultSummary.selectedCount(concerns.count),
                        iconName: "target"
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }
}

#Preview("RoutineResultSummaryCard") {
    RoutineResultSummaryCard(
        skinType: .combination,
        concerns: [.acne, .redness],
        mainGoal: .reduceBreakouts
    )
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}