//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @Environment(\.themeManager) private var tm
    @StateObject private var productService = ProductService()
    @State private var showingAddProduct = false
    let productSlots: [ProductSlot]
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text("My Products")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)

                    Spacer()
                }

                Text("Store and manage your own products")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(productSlots, id: \.slotID) { slot in
                        ProductSlotCard(slot: slot)
                    }
                }
                .padding(20)
            }
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .sheet(isPresented: $showingAddProduct) {
            AddProductView { product in
                // Product added successfully
                print("Added product: \(product.displayName)")
            }
        }
    }
}

// MARK: - Product Slot Card

private struct ProductSlotCard: View {
    @Environment(\.themeManager) private var tm
    @StateObject private var productService = ProductService()
    @State private var showingAddProduct = false
    let slot: ProductSlot

    private var userProducts: [Product] {
        productService.getUserProducts(for: slot.slotType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: slot.slotType.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.slotType.displayName)
                        .font(tm.theme.typo.title)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text(timeOfDayTitle(slot.time))
                        .font(tm.theme.typo.caption)
                        .foregroundColor(tm.theme.palette.textMuted)
                }
                
                Spacer()
                
                if let budget = slot.budget {
                    BudgetBadge(budget: budget)
                }
            }
            
            // Product category description
            if let notes = slot.notes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Product Category")
                        .font(tm.theme.typo.body.weight(.semibold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text(notes)
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
            }
            
            // User products for this slot
            if !userProducts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Products (\(userProducts.count))")
                        .font(tm.theme.typo.body.weight(.semibold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(userProducts.prefix(3)) { product in
                            UserProductCard(product: product)
                        }

                        if userProducts.count > 3 {
                            Text("+\(userProducts.count - 3) more")
                                .font(tm.theme.typo.caption)
                                .foregroundColor(tm.theme.palette.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tm.theme.palette.bg)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    showingAddProduct = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Add Product")
                            .font(tm.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(tm.theme.palette.secondary)
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())

                Button {
                    // TODO: Implement view products functionality
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 16, weight: .semibold))
                        Text("View Products")
                            .font(tm.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(tm.theme.palette.bg)
                    .cornerRadius(tm.theme.cardRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingAddProduct) {
            AddProductView { product in
                productService.addUserProduct(product)
            }
        }
    }
    
    
    private func timeOfDayTitle(_ time: SlotTime) -> String {
        switch time {
        case .AM:
            return "Morning"
        case .PM:
            return "Evening"
        case .Weekly:
            return "Weekly"
        }
    }
    
}

// MARK: - User Product Card

private struct UserProductCard: View {
    @Environment(\.themeManager) private var tm
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.displayName)
                .font(tm.theme.typo.caption.weight(.medium))
                .foregroundColor(tm.theme.palette.textPrimary)
                .lineLimit(2)

            if let brand = product.brand {
                Text(brand)
                    .font(.system(size: 10))
                    .foregroundColor(tm.theme.palette.textMuted)
                    .lineLimit(1)
            }

            if let price = product.price {
                Text("$\(String(format: "%.2f", price))")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(tm.theme.palette.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tm.theme.palette.bg)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tm.theme.palette.separator, lineWidth: 1)
        )
    }
}

// MARK: - Budget Badge

private struct BudgetBadge: View {
    @Environment(\.themeManager) private var tm
    let budget: Budget
    
    var body: some View {
        Text(budgetTitle(budget))
            .font(tm.theme.typo.caption.weight(.semibold))
            .foregroundColor(budgetColor(budget))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(budgetColor(budget).opacity(0.1))
            .cornerRadius(8)
    }
    
    private func budgetTitle(_ budget: Budget) -> String {
        switch budget {
        case .low:
            return "Budget"
        case .mid:
            return "Mid"
        case .high:
            return "Premium"
        }
    }
    
    private func budgetColor(_ budget: Budget) -> Color {
        switch budget {
        case .low:
            return .green
        case .mid:
            return .orange
        case .high:
            return .red
        }
    }
}


// MARK: - Preview

#Preview("ProductSlotsView") {
    ProductSlotsView(productSlots: [
        ProductSlot(
            slotID: "1",
            step: .cleanser,
            time: .AM,
            constraints: Constraints(
                spf: 0,
                fragranceFree: nil,
                sensitiveSafe: nil,
                vegan: nil,
                crueltyFree: nil,
                avoidIngredients: nil,
                preferIngredients: nil
            ),
            budget: .mid,
            notes: "Store your cleanser products here"
        ),
        ProductSlot(
            slotID: "2",
            step: .treatment,
            time: .AM,
            constraints: Constraints(
                spf: 0,
                fragranceFree: nil,
                sensitiveSafe: nil,
                vegan: nil,
                crueltyFree: nil,
                avoidIngredients: nil,
                preferIngredients: nil
            ),
            budget: .mid,
            notes: "Store your treatment products here"
        )
    ])
    .themed(ThemeManager())
}
