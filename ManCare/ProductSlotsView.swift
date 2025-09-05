//
//  ProductSlotsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductSlotsView: View {
    @Environment(\.themeManager) private var tm
    let productSlots: [ProductSlot]
    
    @State private var showingEditRoutine = false
    @State private var selectedSlot: ProductSlot?
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Product Recommendations")
                            .font(tm.theme.typo.h1)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        Text("Based on your routine and preferences")
                            .font(tm.theme.typo.sub)
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }

                    Spacer()
                    Button {
                        showingEditRoutine = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Edit Routine")
                                .font(tm.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(tm.theme.palette.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(tm.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 20)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(productSlots, id: \.slotID) { slot in
                        ProductSlotCard(
                            slot: slot,
                            onEditStep: {
                                selectedSlot = slot
                            }
                        )
                    }
                }
                .padding(20)
            }
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
                            .sheet(isPresented: $showingEditRoutine) {
                        // This would need the original routine - for now we'll show a placeholder
                        Text("Edit Routine View")
                    }
        .sheet(item: $selectedSlot) { slot in
            ProductSlotEditView(slot: slot)
        }
    }
}

// MARK: - Product Slot Card

private struct ProductSlotCard: View {
    @Environment(\.themeManager) private var tm
    let slot: ProductSlot
    let onEditStep: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: iconNameForStepType(slot.step))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(stepTypeTitle(slot.step))
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
            
            // Product hints
            if let notes = slot.notes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Product Hints")
                        .font(tm.theme.typo.body.weight(.semibold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text(notes)
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
            }
            
            // Constraints
            if hasConstraints(slot.constraints) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Requirements")
                        .font(tm.theme.typo.body.weight(.semibold))
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(constraintItems(slot.constraints), id: \.title) { item in
                            ConstraintItem(item: item)
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    onEditStep()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Edit Step")
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
                Button {
                    // TODO: Implement product search/affiliate integration
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Find Products")
                            .font(tm.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(tm.theme.palette.secondary.opacity(0.1))
                    .cornerRadius(tm.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(tm.theme.palette.card)
        .cornerRadius(tm.theme.cardRadius)
        .shadow(color: tm.theme.palette.shadow.opacity(0.5), radius: 8, x: 0, y: 4)
    }
    
    private func iconNameForStepType(_ stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "drop.fill"
        case .treatment:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen:
            return "sun.max.fill"
        case .optional:
            return "plus.circle.fill"
        }
    }
    
    private func stepTypeTitle(_ stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Cleanser"
        case .treatment:
            return "Face Serum"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen"
        case .optional:
            return "Optional Treatment"
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
    
    private func hasConstraints(_ constraints: Constraints) -> Bool {
        return constraints.fragranceFree == true ||
               constraints.sensitiveSafe == true ||
               constraints.vegan == true ||
               constraints.crueltyFree == true ||
               !(constraints.avoidIngredients?.isEmpty ?? true) ||
               !(constraints.preferIngredients?.isEmpty ?? true)
    }
    
    private func constraintItems(_ constraints: Constraints) -> [ConstraintItemData] {
        var items: [ConstraintItemData] = []
        
        if constraints.fragranceFree == true {
            items.append(ConstraintItemData(
                title: "Fragrance Free",
                iconName: "leaf.fill",
                color: .green
            ))
        }
        
        if constraints.sensitiveSafe == true {
            items.append(ConstraintItemData(
                title: "Sensitive Safe",
                iconName: "heart.fill",
                color: .pink
            ))
        }
        
        if constraints.vegan == true {
            items.append(ConstraintItemData(
                title: "Vegan",
                iconName: "leaf.circle.fill",
                color: .green
            ))
        }
        
        if constraints.crueltyFree == true {
            items.append(ConstraintItemData(
                title: "Cruelty Free",
                iconName: "pawprint.fill",
                color: .orange
            ))
        }
        
        if let spf = constraints.spf, spf > 0 {
            items.append(ConstraintItemData(
                title: "SPF \(spf)+",
                iconName: "sun.max.fill",
                color: .yellow
            ))
        }
        
        return items
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

// MARK: - Constraint Item

private struct ConstraintItem: View {
    @Environment(\.themeManager) private var tm
    let item: ConstraintItemData
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: item.iconName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(item.color)
            
            Text(item.title)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tm.theme.palette.bg)
        .cornerRadius(6)
        .help(tooltipText(for: item.title))
    }
    private func tooltipText(for title: String) -> String {
        switch title {
        case "Fragrance Free":
            return "No artificial fragrances - minimal irritation risk"
        case "Sensitive Safe":
            return "Formulated for sensitive skin - minimal irritation risk"
        case "Vegan":
            return "No animal-derived ingredients"
        case "Cruelty Free":
            return "Not tested on animals"
        case let spf where spf.hasPrefix("SPF"):
            return "Sun Protection Factor - blocks UV rays"
        default:
            return title
        }
    }
}

// MARK: - Models

struct ConstraintItemData {
    let title: String
    let iconName: String
    let color: Color
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
                fragranceFree: true,
                sensitiveSafe: true,
                vegan: true,
                crueltyFree: true,
                avoidIngredients: [],
                preferIngredients: ["salicylic acid", "niacinamide"]
            ),
            budget: .mid,
            notes: "Choose a gentle formula that suits normal skin."
        ),
        ProductSlot(
            slotID: "2",
            step: .treatment,
            time: .AM,
            constraints: Constraints(
                spf: 0,
                fragranceFree: true,
                sensitiveSafe: true,
                vegan: true,
                crueltyFree: true,
                avoidIngredients: [],
                preferIngredients: ["niacinamide"]
            ),
            budget: .mid,
            notes: "Focus on pore-minimizing ingredients."
        )
    ])
    .themed(ThemeManager())
}
