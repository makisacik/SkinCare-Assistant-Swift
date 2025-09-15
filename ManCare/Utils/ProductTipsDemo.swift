//
//  ProductTipsDemo.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductTipsDemo: View {
    @State private var selectedProductType: ProductType = .cleanser
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Product Type Selector
                VStack(spacing: 16) {
                    Text("Select Product Type")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Picker("Product Type", selection: $selectedProductType) {
                        ForEach(ProductType.allCases, id: \.self) { productType in
                            Text(productType.displayName).tag(productType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 20)
                
                // Tips Count
                HStack {
                    Text("Available Tips:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    
                    Text("\(ProductTipsData.getTips(for: selectedProductType).count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Full Tips View
                VStack(spacing: 16) {
                    Text("Full Tips View")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    ProductTipsView(productType: selectedProductType)
                        .frame(height: 200)
                }
                .padding(.horizontal, 20)
                
                // Compact Tips View
                VStack(spacing: 16) {
                    Text("Compact Tips View (Timer)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    CompactProductTipsView(productType: selectedProductType)
                        .frame(height: 80)
                }
                .padding(.horizontal, 20)
                
                // Tips by Category
                VStack(spacing: 16) {
                    Text("Tips by Category")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TipCategory.allCases, id: \.self) { category in
                                let tips = ProductTipsData.getTipsByCategory(for: selectedProductType, category: category)
                                if !tips.isEmpty {
                                    CategoryTipCard(category: category, tipCount: tips.count)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Product Tips Demo")
            .background(ThemeManager.shared.theme.palette.background)
        }
    }
}

struct CategoryTipCard: View {
    let category: TipCategory
    let tipCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.systemIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(categoryColor)
            
            Text(category.displayName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("\(tipCount) tips")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var categoryColor: Color {
        switch category.colorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return ThemeManager.shared.theme.palette.primary
        }
    }
}

#Preview("ProductTipsDemo") {
    ProductTipsDemo()
}
