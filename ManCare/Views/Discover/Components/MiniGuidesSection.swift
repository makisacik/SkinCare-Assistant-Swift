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
                    Text(L10n.Discover.Guides.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Discover.Guides.subtitle)
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
                guideKey: "cycleSkin",
                minutes: 2,
                imageName: "placeholder",
                title: nil,
                subtitle: nil,
                category: nil
            ),
            MiniGuide(
                id: UUID(),
                guideKey: "ampmRoutine",
                minutes: 4,
                imageName: "placeholder",
                title: nil,
                subtitle: nil,
                category: nil
            )
        ],
        onTap: { _ in }
    )
}
