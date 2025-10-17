//
//  AdaptationBriefingCard.swift
//  ManCare
//
//  Briefing card showing phase-specific information
//

import SwiftUI

struct AdaptationBriefingCard: View {
    let briefing: PhaseBriefing
    let contextKey: String
    let date: Date

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(briefing.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.theme.palette.textPrimary)

                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(theme.theme.palette.textSecondary)
                }

                Spacer()

                // Phase icon
                phaseIcon
                    .font(.title2)
                    .foregroundColor(phaseColor)
            }

            // Summary
            Text(briefing.summary)
                .font(.body)
                .foregroundColor(theme.theme.palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Tips
            if !briefing.tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Routines.AdaptationBriefing.tips)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.theme.palette.textPrimary)

                    ForEach(briefing.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)

                            Text(tip)
                                .font(.caption)
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }
                    }
                }
            }

            // Warnings
            if !briefing.generalWarnings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(briefing.generalWarnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)

                            Text(warning)
                                .font(.caption)
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(phaseColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(phaseColor.opacity(0.3), lineWidth: 1)
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var phaseIcon: Image {
        switch contextKey.lowercased() {
        case "menstrual":
            return Image(systemName: "drop.fill")
        case "follicular":
            return Image(systemName: "sparkles")
        case "ovulation":
            return Image(systemName: "sun.max.fill")
        case "luteal":
            return Image(systemName: "moon.fill")
        default:
            return Image(systemName: "circle.fill")
        }
    }

    private var phaseColor: Color {
        switch contextKey.lowercased() {
        case "menstrual":
            return theme.theme.palette.error
        case "follicular":
            return theme.theme.palette.success
        case "ovulation":
            return theme.theme.palette.warning
        case "luteal":
            return theme.theme.palette.primary
        default:
            return theme.theme.palette.primary
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleBriefing = PhaseBriefing(
        contextKey: "follicular",
        title: "Follicular Phase (Days 6-13)",
        summary: "Your skin is resilient and glowing! This is the perfect time for intensive treatments and trying new products.",
        tips: [
            "Perfect time for intensive treatments and peels",
            "Try new products or increase active concentration",
            "Maximize use of exfoliants and retinoids"
        ],
        generalWarnings: []
    )

    return AdaptationBriefingCard(
        briefing: sampleBriefing,
        contextKey: "follicular",
        date: Date()
    )
    .environmentObject(ThemeManager.shared)
    .padding()
}

