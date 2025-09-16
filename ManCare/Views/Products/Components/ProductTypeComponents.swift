//
//  ProductTypeComponents.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Product Type Selector Button

struct ProductTypeSelectorButton: View {
    
    @Binding var selectedProductType: ProductType
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Type")
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Product Type Icon
                    Image(selectedProductType.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .background(ThemeManager.shared.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)

                    // Product Type Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedProductType.displayName)
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(1)

                        Text("Tap to change product type")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }

                    Spacer()

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(ThemeManager.shared.theme.palette.accentBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Product Type Card

struct ProductTypeCard: View {
    
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(productType.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)

            Text(productType.displayName)
                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.accentBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Product Type Row

struct ProductTypeRow: View {
    
    let productType: ProductType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(productType.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.secondary.opacity(0.1))
                    .cornerRadius(6)

                // Name
                Text(productType.displayName)
                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textPrimary)

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.cardBackground)
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
}
