//
//  RoutineResultStepRow.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineResultStepRow: View {
    
    let step: RoutineStep
    let stepNumber: Int
    
    private var stepColor: Color {
        switch step.productType.color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "orange": return ThemeManager.shared.theme.palette.warning
        case "purple": return ThemeManager.shared.theme.palette.primary
        case "red": return ThemeManager.shared.theme.palette.error
        case "pink": return ThemeManager.shared.theme.palette.primary
        case "teal": return ThemeManager.shared.theme.palette.info
        case "indigo": return ThemeManager.shared.theme.palette.info
        case "brown": return ThemeManager.shared.theme.palette.textMuted
        case "gray": return ThemeManager.shared.theme.palette.textMuted
        default: return ThemeManager.shared.theme.palette.primary
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left content area
            VStack(alignment: .leading, spacing: 16) {
                // Horizontal row with step number, icon, and name
                HStack(spacing: 12) {
                    // Step number
                    Text("\(stepNumber)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(stepColor)
                        .frame(width: 40)

                    // Product image
                    Image(step.productType.customIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .background(ThemeManager.shared.theme.palette.secondary.opacity(0.1))
                        .clipShape(Circle())

                    // Step title (smaller font) - allow it to expand and wrap
                    Text(step.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 8)
                }

                // Step description
                Text(step.instructions)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .lineLimit(nil)
                    .padding(.leading, 56) // Align with the content above
            }
            .padding(20)
            .contentShape(Rectangle())
        }
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

#Preview("RoutineResultStepRow") {
    RoutineResultStepRow(
        step: RoutineStep(
            productType: .cleanser,
            title: "Gentle Cleanser",
            instructions: "Oil-free gel cleanser – reduces shine, clears pores"
        ),
        stepNumber: 1
    )
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}