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
        case .preventAging: return "Prevent sun damage"
        case .ageSlower: return "Age slower"
        case .shinySkin: return "Shiny, glowing skin"
        }
    }
    
    var subtitle: String {
        switch self {
        case .healthierOverall: return "Build a solid foundation for better skin"
        case .reduceBreakouts: return "Clear acne and prevent future breakouts"
        case .sootheIrritation: return "Calm redness and sensitivity"
        case .preventAging: return "Protect against UV damage and aging"
        case .ageSlower: return "Slow down aging with targeted care"
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
    @State private var customGoal: String = ""
    @State private var isEditingCustomGoal: Bool = false
    var onContinue: (MainGoal?, String) -> Void
    
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]
    
    /// Continue button is enabled when either a selection exists or custom text is not empty
    private var isContinueEnabled: Bool {
        selection != nil || !customGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's your main goal?")
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        Text("Choose the primary focus for your skincare routine.")
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .onTapGesture {
                        dismissKeyboard()
                    }
            
                    // Grid of goals
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(MainGoal.allCases) { goal in
                            MainGoalCard(goal: goal, selected: selection == goal)
                                .onTapGesture {
                                    dismissKeyboard()
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
            
                    // Custom goal input
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isEditingCustomGoal || !customGoal.isEmpty ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.secondary)
                        
                    TextField("Type your own goal...", text: $customGoal, onEditingChanged: { editing in
                        isEditingCustomGoal = editing
                        // Clear card selection when text field is tapped
                        if editing {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                selection = nil
                            }
                        }
                    })
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .tint(ThemeManager.shared.theme.palette.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                        .colorScheme(.light)
                        .submitLabel(.done)
                        .onChange(of: customGoal) { newValue in
                            if newValue.count > 60 {
                                customGoal = String(newValue.prefix(60))
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                            .fill(ThemeManager.shared.theme.palette.cardBackground)
                            .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(isEditingCustomGoal ? 0.2 : 0.1), radius: isEditingCustomGoal ? 6 : 3, x: 0, y: isEditingCustomGoal ? 3 : 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                                    .stroke(isEditingCustomGoal || !customGoal.isEmpty ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.separator, lineWidth: isEditingCustomGoal || !customGoal.isEmpty ? 2 : 1)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isEditingCustomGoal)
                    .animation(.easeInOut(duration: 0.2), value: customGoal.isEmpty)
                    
                    Spacer(minLength: 8)
                    
                // Continue button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    // If a card is selected, it overrides the custom text
                    onContinue(selection, customGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                } label: {
                    Text("Continue")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isContinueEnabled)
                .opacity(isContinueEnabled ? 1.0 : 0.7)
                }
                .padding(20)
            }
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Card

private struct MainGoalCard: View {
    
    let goal: MainGoal
    let selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        .font(.system(size: 18, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Text(goal.title)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.9)
            
            Text(goal.subtitle)
                .font(.system(size: 12))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: 110)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(selected ? ThemeManager.shared.theme.palette.cardBackground.opacity(0.98) : ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: selected ? ThemeManager.shared.theme.palette.shadow.opacity(0.3)
                                        : ThemeManager.shared.theme.palette.shadow.opacity(0.15),
                        radius: selected ? 8 : 4, x: 0, y: selected ? 4 : 2)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(selected ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator,
                                lineWidth: selected ? 2 : 1)
                )
        )
        .scaleEffect(selected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
    }
}

#Preview("MainGoalView - Light") {
    MainGoalView(onContinue: { _, _ in })
        .preferredColorScheme(.light)
}

#Preview("MainGoalView - Dark") {
    MainGoalView(onContinue: { _, _ in })
        .preferredColorScheme(.dark)
}
