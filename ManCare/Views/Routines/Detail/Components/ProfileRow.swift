//
//  ProfileRow.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProfileRow: View {
    
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Text(title)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
}

#Preview("ProfileRow") {
    ProfileRow(
        title: "Skin Type",
        value: "Combination",
        iconName: "face.smiling"
    )
    .padding()
    .background(ThemeManager.shared.theme.palette.cardBackground)
}

