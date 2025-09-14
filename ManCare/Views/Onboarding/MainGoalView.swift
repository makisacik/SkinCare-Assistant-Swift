//
//  MainGoalView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

enum MainGoal: String, CaseIterable, Identifiable, Codable {
    case healthierOverall, reduceBreakouts, sootheIrritation, preventAging, ageSlower, shinySkin
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .healthierOverall: return "Healthier skin overall"
        case .reduceBreakouts: return "Reduce breakouts"
        case .sootheIrritation: return "Soothe irritation"
        case .preventAging: return "Prevent aging / sun damage"
        case .ageSlower: return "Age slower"
        case .shinySkin: return "Shiny, glowing skin"
        }
    }
    
    var subtitle: String {
        switch self {
        case .healthierOverall: return "Build a solid foundation for better skin"
        case .reduceBreakouts: return "Clear acne and prevent future breakouts"
        case .sootheIrritation: return "Calm redness and sensitivity"
        case .preventAging: return "Protect against sun damage and aging"
        case .ageSlower: return "Slow down the aging process with targeted care"
        case .shinySkin: return "Achieve a radiant, healthy glow"
        }
    }
    
    var iconName: String {
        switch self {
        case .healthierOverall: return "heart.fill"
        case .reduceBreakouts: return "circle.grid.cross.left.fill"
        case .sootheIrritation: return "thermometer.snowflake"
        case .preventAging: return "sun.max.fill"
        case .ageSlower: return "clock.arrow.circlepath"
        case .shinySkin: return "sparkles"
        }
    }
}

struct MainGoalView: View {
    
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
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)
            
            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your main goal?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("Choose the primary focus for your skincare routine.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Card

private struct MainGoalCard: View {
    
    let goal: MainGoal
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 20, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(goal.title)
                .font(ThemeManager.shared.theme.typo.title)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(2)
            
            Text(goal.subtitle)
                .font(ThemeManager.shared.theme.typo.caption)
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(3)
        }
        .padding(ThemeManager.shared.theme.padding)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(selected ? ThemeManager.shared.theme.palette.cardBackground.opacity(0.98) : ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(1.0)
                                        : ThemeManager.shared.theme.palette.shadow,
                        radius: selected ? 14 : 10, x: 0, y: selected ? 8 : 6)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(selected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.18), value: selected)
    }
}

#Preview("MainGoalView - Light") {
    MainGoalView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.light)
}

#Preview("MainGoalView - Dark") {
    MainGoalView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.dark)
}
