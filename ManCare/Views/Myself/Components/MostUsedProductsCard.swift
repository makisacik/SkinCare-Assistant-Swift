//
//  MostUsedProductsCard.swift
//  ManCare
//
//  Created for Insights Tab Feature
//

import SwiftUI

struct MostUsedProductsCard: View {
    let products: [(product: String, productType: ProductType, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(ThemeManager.shared.theme.palette.primary.opacity(0.15))
                    )
                
                Text(L10n.Myself.MostUsedProducts.title)
                    .font(ThemeManager.shared.theme.typo.h3.weight(.bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
            }
            
            if products.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                        productRow(
                            rank: index + 1,
                            name: product.product,
                            productType: product.productType,
                            count: product.count
                        )
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }
    
    @ViewBuilder
    private func productRow(rank: Int, name: String, productType: ProductType, count: Int) -> some View {
        HStack(spacing: 12) {
            // Rank badge
            Text(L10n.Myself.MostUsedProducts.rank(rank))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(
                            rank == 1 ? ThemeManager.shared.theme.palette.warning :
                            rank == 2 ? ThemeManager.shared.theme.palette.textSecondary :
                            ThemeManager.shared.theme.palette.textMuted
                        )
                )
            
            // Product icon
            Image(productType: productType)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product info
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text(L10n.Myself.MostUsedProducts.usedCount(count))
                    .font(ThemeManager.shared.theme.typo.caption)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.background.opacity(0.5))
        )
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text(L10n.Myself.MostUsedProducts.empty)
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Text(L10n.Myself.MostUsedProducts.emptySubtitle)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

