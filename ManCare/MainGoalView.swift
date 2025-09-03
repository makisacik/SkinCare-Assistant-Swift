//
//  MainGoalView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

enum MainGoal: String, CaseIterable, Identifiable, Codable {
    case healthierOverall, reduceBreakouts, sootheIrritation, preventAging
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .healthierOverall: return "Healthier skin overall"
        case .reduceBreakouts: return "Reduce breakouts"
        case .sootheIrritation: return "Soothe irritation"
        case .preventAging: return "Prevent aging / sun damage"
        }
    }
    
    var subtitle: String {
        switch self {
        case .healthierOverall: return "Build a solid foundation for better skin"
        case .reduceBreakouts: return "Clear acne and prevent future breakouts"
        case .sootheIrritation: return "Calm redness and sensitivity"
        case .preventAging: return "Protect against sun damage and aging"
        }
    }
    
    var iconName: String {
        switch self {
        case .healthierOverall: return "heart.fill"
        case .reduceBreakouts: return "circle.grid.cross.left.fill"
        case .sootheIrritation: return "thermometer.snowflake"
        case .preventAging: return "sun.max.fill"
        }
    }
}

struct MainGoalView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme) private var cs
    
    @State private var selection: MainGoal? = nil
    var onContinue: (MainGoal) -> Void
    var onBack: () -> Void
    
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with back button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)
            
            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your main goal?")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text("Choose the primary focus for your skincare routine.")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
            }
            
            // Grid of goals
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(MainGoal.allCases) { goal in
                    MainGoalCard(goal: goal, selected: selection == goal)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                selection = goal
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(goal.title))
                        .accessibilityHint(Text("Tap to select"))
                        .accessibilityAddTraits(selection == goal ? .isSelected : [])
                }
            }
            
            Spacer(minLength: 8)
            
            // Continue button
            Button {
                guard let picked = selection else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue(picked)
            } label: {
                Text(selection == nil ? "Continue" : "Continue with \(selection!.title)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.7 : 1.0)
        }
        .padding(20)
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { tm.refreshForSystemChange($0) }
    }
}

// MARK: - Card

private struct MainGoalCard: View {
    @Environment(\.themeManager) private var tm
    let goal: MainGoal
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tm.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(tm.theme.palette.accent)
                        .font(.system(size: 20, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(goal.title)
                .font(tm.theme.typo.title)
                .foregroundColor(tm.theme.palette.textPrimary)
                .lineLimit(2)
            
            Text(goal.subtitle)
                .font(tm.theme.typo.caption)
                .foregroundColor(tm.theme.palette.textMuted)
                .lineLimit(3)
        }
        .padding(tm.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: tm.theme.cardRadius, style: .continuous)
                .fill(selected ? tm.theme.palette.card.opacity(0.98) : tm.theme.palette.card)
                .shadow(color: selected ? tm.theme.palette.shadow.opacity(1.0)
                                        : tm.theme.palette.shadow,
                        radius: selected ? 14 : 10, x: 0, y: selected ? 8 : 6)
                .overlay(
                    RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                        .stroke(selected ? tm.theme.palette.secondary : tm.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.18), value: selected)
    }
}

#Preview("MainGoalView - Light") {
    MainGoalView(onContinue: { _ in }, onBack: {})
        .themed(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("MainGoalView - Dark") {
    MainGoalView(onContinue: { _ in }, onBack: {})
        .themed(ThemeManager())
        .preferredColorScheme(.dark)
}
