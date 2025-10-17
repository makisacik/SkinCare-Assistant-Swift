//
//  PersonalizedRoutineCard.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct PersonalizedRoutineCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Discover.Personalized.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(L10n.Discover.Personalized.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Icon with decorative circles
                ZStack {
                    // Outer circle
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    // Inner circle
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 45, height: 45)
                    
                    // Main icon
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.shared.theme.palette.primary.opacity(0.8),
                                ThemeManager.shared.theme.palette.primary.opacity(0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PersonalizedRoutineCard(onTap: {})
        .padding()
}
