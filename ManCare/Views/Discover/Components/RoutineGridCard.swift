//
//  RoutineGridCard.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineGridCard: View {
    let routine: RoutineTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Image("example-photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()

                    // Duration badge in bottom-left
                    VStack {
                        Spacer()
                        HStack {
                            Text(routine.duration)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.9))
                                )
                            Spacer()
                        }
                    }
                    .padding(12)
                }
                .frame(height: 180) // Fixed height for image
                .cornerRadius(16, corners: [.topLeft, .topRight])

                // Minimal content with fixed height
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.category.title.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .tracking(0.5)

                    Text(routine.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 50) // Fixed height for info section
                .padding(12)
                .background(
                    RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
                        .fill(ThemeManager.shared.theme.palette.surface)
                )
            }
            .frame(height: 230) // Total fixed height: 180 (image) + 50 (info)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RoutineGridCard(
        routine: RoutineTemplate.allRoutines.first!,
        onTap: {}
    )
    .padding()
}
