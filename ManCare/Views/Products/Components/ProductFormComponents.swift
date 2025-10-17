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

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextField("", text: $text)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .accentColor(ThemeManager.shared.theme.palette.secondary)
            }
            .background(ThemeManager.shared.theme.palette.accentBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
            )
        }
    }
}

// MARK: - Size Field with Unit Toggle

struct SizeField: View {

    let title: String
    @Binding var sizeValue: String
    @Binding var selectedUnit: SizeUnit
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            HStack(spacing: 0) {
                // Size input field
                ZStack(alignment: .leading) {
                    if sizeValue.isEmpty {
                        Text(placeholder)
                            .font(ThemeManager.shared.theme.typo.body)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }

                    TextField("", text: $sizeValue)
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .accentColor(ThemeManager.shared.theme.palette.secondary)
                }
                .background(ThemeManager.shared.theme.palette.accentBackground)

                // Unit toggle
                HStack(spacing: 8) {
                    Button(action: {
                        selectedUnit = .mL
                    }) {
                        Text(L10n.Products.Form.unitMilliliters)
                            .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                            .foregroundColor(selectedUnit == .mL ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedUnit == .mL ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.accentBackground)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        selectedUnit = .oz
                    }) {
                        Text(L10n.Products.Form.unitOunces)
                            .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                            .foregroundColor(selectedUnit == .oz ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedUnit == .oz ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.accentBackground)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(ThemeManager.shared.theme.palette.accentBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
            )
        }
    }
}

// MARK: - Size Unit Enum

enum SizeUnit: String, CaseIterable {
    case mL = "mL"
    case oz = "oz"

    var displayName: String {
        return rawValue
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
