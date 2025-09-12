//
//  ProductTypeComponents.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Product Type Selector Button

struct ProductTypeSelectorButton: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedProductType: ProductType
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Type")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Product Type Icon
                    Image(systemName: selectedProductType.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(tm.theme.palette.secondary)
                        .frame(width: 32, height: 32)
                        .background(tm.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)

                    // Product Type Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedProductType.displayName)
                            .font(tm.theme.typo.body.weight(.semibold))
                            .foregroundColor(tm.theme.palette.textPrimary)
                            .lineLimit(1)

                        Text("Tap to change product type")
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textMuted)
                    }

                    Spacer()

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(tm.theme.palette.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(tm.theme.palette.bg)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Product Type Card

struct ProductTypeCard: View {
    @Environment(\.themeManager) private var tm
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: productType.iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.secondary)

            Text(productType.displayName)
                .font(tm.theme.typo.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.bg)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Product Type Row

struct ProductTypeRow: View {
    @Environment(\.themeManager) private var tm
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: productType.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : tm.theme.palette.secondary)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.secondary.opacity(0.1))
                    .cornerRadius(6)

                // Name
                Text(productType.displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.card)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("ProductTypeComponents") {
    VStack(spacing: 20) {
        ProductTypeSelectorButton(selectedProductType: .constant(.cleanser)) {
            print("Tapped")
        }
        
        ProductTypeCard(productType: .cleanser, isSelected: true) {
            print("Card tapped")
        }
    }
    .padding()
    .themed(ThemeManager())
}
