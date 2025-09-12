//
//  BudgetComponents.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Budget Selector

struct BudgetSelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedBudget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Range")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            HStack(spacing: 12) {
                ForEach(Budget.allCases, id: \.self) { budget in
                    BudgetCard(budget: budget, isSelected: selectedBudget == budget) {
                        selectedBudget = budget
                    }
                }
            }
        }
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    @Environment(\.themeManager) private var tm
    let budget: Budget
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text(budgetTitle(budget))
                .font(tm.theme.typo.caption.weight(.semibold))
                .foregroundColor(isSelected ? .white : budgetColor(budget))

            Text(budgetDescription(budget))
                .font(.system(size: 10))
                .foregroundColor(isSelected ? .white.opacity(0.8) : tm.theme.palette.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? budgetColor(budget) : tm.theme.palette.bg)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? budgetColor(budget) : tm.theme.palette.separator, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }

    private func budgetTitle(_ budget: Budget) -> String {
        switch budget {
        case .low: return "Budget"
        case .mid: return "Mid"
        case .high: return "Premium"
        }
    }

    private func budgetDescription(_ budget: Budget) -> String {
        switch budget {
        case .low: return "$5-15"
        case .mid: return "$15-40"
        case .high: return "$40+"
        }
    }

    private func budgetColor(_ budget: Budget) -> Color {
        switch budget {
        case .low: return .green
        case .mid: return .orange
        case .high: return .red
        }
    }
}

#Preview("BudgetComponents") {
    VStack(spacing: 20) {
        BudgetSelector(selectedBudget: .constant(.mid))
    }
    .padding()
    .themed(ThemeManager())
}
