//
//  EmptyProductsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct EmptyProductsView: View {
    @Environment(\.themeManager) private var tm

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bag")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(tm.theme.palette.textMuted)

                VStack(spacing: 8) {
                    Text("No Products Yet")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)

                    Text("Add your first product to get started")
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
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
        .themed(ThemeManager())
}
