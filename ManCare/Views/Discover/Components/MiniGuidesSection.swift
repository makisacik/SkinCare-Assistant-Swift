//
//  MiniGuidesSection.swift
//  ManCare
//
//  Horizontal grid of mini guide cards
//

import SwiftUI

struct MiniGuidesSection: View {
    let guides: [MiniGuide]
    let onTap: (MiniGuide) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mini Guides")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Quick reads on skincare fundamentals")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            // Cards grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(guides) { guide in
                        MiniGuideCard(guide: guide) {
                            onTap(guide)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    MiniGuidesSection(
        guides: [
            MiniGuide(
                id: UUID(),
                title: "Skincare 101: Build a basic routine",
                subtitle: "Cleanse, treat, moisturize, protect",
                minutes: 5,
                imageName: "skincare-products/basic-kit",
                category: "Basics"
            ),
            MiniGuide(
                id: UUID(),
                title: "How your cycle affects skin",
                subtitle: "Breakouts, sensitivity and glow across phases",
                minutes: 7,
                imageName: "skincare-products/cycle-care",
                category: "Menstrual Health"
            )
        ],
        onTap: { _ in }
    )
}
