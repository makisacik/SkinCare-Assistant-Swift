//
//  CategoryChip.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct CategoryChip: View {
    let category: RoutineCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .medium))

                Text(category.title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        CategoryChip(
            category: .antiAging,
            isSelected: false,
            onTap: {}
        )
        CategoryChip(
            category: .antiAging,
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}
