//
//  SeasonalPlaybookSection.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct SeasonalPlaybookSection: View {
    let playbook: SeasonalPlaybook
    let onArticleTap: (String) -> Void
    let onCTATap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text(playbook.displayTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Articles stack
            VStack(spacing: 12) {
                ForEach(playbook.articles, id: \.self) { article in
                    ArticleCard(title: article) {
                        onArticleTap(article)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // CTA Button
            Button(action: onCTATap) {
                HStack {
                    Text(playbook.ctaText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: playbook.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(ThemeManager.shared.theme.palette.primary.opacity(0.5))
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SeasonalPlaybookSection(
        playbook: SeasonalPlaybook(
            season: .autumn,
            articles: [
                "Barrier First: why it matters",
                "Humectants vs Emollients vs Occlusives",
                "Wind-Proof Night Routine"
            ],
            ctaText: "Build my seasonal plan"
        ),
        onArticleTap: { _ in },
        onCTATap: {}
    )
}

