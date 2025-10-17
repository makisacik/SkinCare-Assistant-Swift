//
//  RoutineDepthView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 10.10.2025.
//

import SwiftUI

// MARK: - Routine Depth Model

enum RoutineDepth: String, CaseIterable, Identifiable, Codable {
    case simple
    case intermediate
    case advanced
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .simple: return L10n.Onboarding.RoutineDepthTypes.simple
        case .intermediate: return L10n.Onboarding.RoutineDepthTypes.intermediate
        case .advanced: return L10n.Onboarding.RoutineDepthTypes.advanced
        }
    }
    
    var subtitle: String {
        switch self {
        case .simple: return L10n.Onboarding.RoutineDepthTypes.simpleSubtitle
        case .intermediate: return L10n.Onboarding.RoutineDepthTypes.intermediateSubtitle
        case .advanced: return L10n.Onboarding.RoutineDepthTypes.advancedSubtitle
        }
    }
    
    var description: String {
        switch self {
        case .simple:
            return L10n.Onboarding.RoutineDepthTypes.simpleDescription
        case .intermediate:
            return L10n.Onboarding.RoutineDepthTypes.intermediateDescription
        case .advanced:
            return L10n.Onboarding.RoutineDepthTypes.advancedDescription
        }
    }
    
    var stepCountDescription: String {
        switch self {
        case .simple:
            return L10n.Onboarding.RoutineDepthTypes.simpleStepCount
        case .intermediate:
            return L10n.Onboarding.RoutineDepthTypes.intermediateStepCount
        case .advanced:
            return L10n.Onboarding.RoutineDepthTypes.advancedStepCount
        }
    }
    
    var timeEstimate: String {
        switch self {
        case .simple:
            return L10n.Onboarding.RoutineDepthTypes.simpleTimeEstimate
        case .intermediate:
            return L10n.Onboarding.RoutineDepthTypes.intermediateTimeEstimate
        case .advanced:
            return L10n.Onboarding.RoutineDepthTypes.advancedTimeEstimate
        }
    }
    
    var iconName: String {
        switch self {
        case .simple: return "bolt.fill"
        case .intermediate: return "star.fill"
        case .advanced: return "crown.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .simple: return Color(red: 0.2, green: 0.7, blue: 0.9) // Light blue
        case .intermediate: return Color(red: 0.4, green: 0.6, blue: 0.9) // Medium blue
        case .advanced: return Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
        }
    }
    
    // For GPT system prompt
    var stepGuidance: String {
        switch self {
        case .simple:
            return L10n.Onboarding.RoutineDepthTypes.simpleStepGuidance
        case .intermediate:
            return L10n.Onboarding.RoutineDepthTypes.intermediateStepGuidance
        case .advanced:
            return L10n.Onboarding.RoutineDepthTypes.advancedStepGuidance
        }
    }
}

// MARK: - View

struct RoutineDepthView: View {
    
    @Environment(\.colorScheme) private var cs
    @State private var selectedDepth: RoutineDepth?
    
    var onContinue: (RoutineDepth) -> Void
    
    var body: some View {
        ZStack {
            // Background that fills entire space
            ThemeManager.shared.theme.palette.accentBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Title section
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Onboarding.RoutineDepth.title)
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    Text(L10n.Onboarding.RoutineDepth.subtitle)
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Options
                        VStack(spacing: 10) {
                            ForEach(RoutineDepth.allCases) { depth in
                                RoutineDepthCard(
                                    depth: depth,
                                    isSelected: selectedDepth == depth
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDepth = depth
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                        }
                    }
                }
                
                // Buttons
                VStack(spacing: 12) {
                    // Continue Button
                    Button {
                        guard let depth = selectedDepth else { return }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onContinue(depth)
                    } label: {
                        Text(L10n.Onboarding.RoutineDepth.continue)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedDepth == nil)
                    .opacity(selectedDepth == nil ? 0.7 : 1.0)
                }
            }
            .padding(20)
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

// MARK: - Routine Depth Card

private struct RoutineDepthCard: View {
    
    let depth: RoutineDepth
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? depth.accentColor : depth.accentColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: depth.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : depth.accentColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(depth.title)
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(nil)
                        
                        Spacer()
                        
                        // Selection indicator
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(depth.accentColor)
                        } else {
                            Circle()
                                .strokeBorder(ThemeManager.shared.theme.palette.separator, lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    Text(depth.subtitle)
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(depth.description)
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                    
                    // Stats
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 12, weight: .medium))
                            Text(depth.stepCountDescription)
                                .font(ThemeManager.shared.theme.typo.caption)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .medium))
                            Text(depth.timeEstimate)
                                .font(ThemeManager.shared.theme.typo.caption)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    .padding(.top, 6)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                    .fill(ThemeManager.shared.theme.palette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                            .strokeBorder(
                                isSelected ? depth.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected 
                    ? depth.accentColor.opacity(0.3)
                    : ThemeManager.shared.theme.palette.shadow.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#Preview("Routine Depth - Light") {
    RoutineDepthView(onContinue: { _ in })
        .preferredColorScheme(.light)
}

#Preview("Routine Depth - Dark") {
    RoutineDepthView(onContinue: { _ in })
        .preferredColorScheme(.dark)
}

