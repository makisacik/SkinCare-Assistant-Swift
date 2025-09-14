//
//  EmptyProductsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct EmptyProductsView: View {
    

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bag")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)

                VStack(spacing: 8) {
                    Text("No Products Yet")
                        .font(ThemeManager.shared.theme.typo.h2)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text("Add your first product to get started")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview("EmptyProductsView") {
    EmptyProductsView()
}
