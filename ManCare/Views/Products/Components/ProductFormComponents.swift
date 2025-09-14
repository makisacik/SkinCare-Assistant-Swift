//
//  ProductFormComponents.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Product Form Section

struct ProductFormSection<Content: View>: View {
    
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            content
        }
        .padding(20)
        .background(ThemeManager.shared.theme.palette.cardBackground)
        .cornerRadius(ThemeManager.shared.theme.cardRadius)
        .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Form Field

struct FormField: View {
    
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            TextField(placeholder, text: $text)
                .font(ThemeManager.shared.theme.typo.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(ThemeManager.shared.theme.palette.accentBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                )
        }
    }
}

#Preview("ProductFormComponents") {
    VStack(spacing: 20) {
        ProductFormSection(title: "Basic Information") {
            FormField(title: "Product Name", text: .constant("Sample Product"), placeholder: "Enter product name")
        }
    }
    .padding()
}
