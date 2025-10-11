//
//  ArticleCard.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct ArticleCard: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.theme.palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeManager.shared.theme.palette.border.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        ArticleCard(title: "Barrier First: why it matters") {}
        ArticleCard(title: "Humectants vs Emollients vs Occlusives") {}
        ArticleCard(title: "Wind-Proof Night Routine") {}
    }
    .padding()
}

