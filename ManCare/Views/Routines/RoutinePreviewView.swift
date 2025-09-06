//
//  RoutinePreviewView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutinePreviewView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let originalRoutine: RoutineResponse?
    let editedRoutine: EditableRoutine
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @State private var selectedTimeOfDay: TimeOfDay = .morning
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Preview Your Changes")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Review your customized routine before saving")
                        .font(tm.theme.typo.sub)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Time of day selector
                Picker("Time of Day", selection: $selectedTimeOfDay) {
                    ForEach(TimeOfDay.allCases, id: \.self) { timeOfDay in
                        Text(timeOfDay.displayName).tag(timeOfDay)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Content
                TabView(selection: $selectedTimeOfDay) {
                    // Morning Routine
                    RoutineComparisonSection(
                        timeOfDay: .morning,
                        originalSteps: originalRoutine?.routine.morning ?? [],
                        editedSteps: editedRoutine.morningSteps,
                        title: "Morning Routine"
                    )
                    .tag(TimeOfDay.morning)
                    
                    // Evening Routine
                    RoutineComparisonSection(
                        timeOfDay: .evening,
                        originalSteps: originalRoutine?.routine.evening ?? [],
                        editedSteps: editedRoutine.eveningSteps,
                        title: "Evening Routine"
                    )
                    .tag(TimeOfDay.evening)
                    
                    // Weekly Routine
                    RoutineComparisonSection(
                        timeOfDay: .weekly,
                        originalSteps: originalRoutine?.routine.weekly ?? [],
                        editedSteps: editedRoutine.weeklySteps,
                        title: "Weekly Routine"
                    )
                    .tag(TimeOfDay.weekly)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        onConfirm()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Save Changes")
                                .font(tm.theme.typo.title.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(tm.theme.palette.secondary)
                        .cornerRadius(tm.theme.cardRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        onCancel()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Cancel")
                                .font(tm.theme.typo.title.weight(.semibold))
                        }
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(tm.theme.palette.bg)
                        .cornerRadius(tm.theme.cardRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: tm.theme.cardRadius)
                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Routine Comparison Section

private struct RoutineComparisonSection: View {
    @Environment(\.themeManager) private var tm
    let timeOfDay: TimeOfDay
    let originalSteps: [APIRoutineStep]
    let editedSteps: [EditableRoutineStep]
    let title: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Section header
                VStack(spacing: 8) {
                    Text(title)
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("Compare your changes")
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
                .padding(.top, 20)
                
                // Original routine
                if !originalSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Original Routine")
                                .font(tm.theme.typo.h3)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            Spacer()
                            
                            Text("\(originalSteps.count) steps")
                                .font(tm.theme.typo.caption)
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                        
                        ForEach(Array(originalSteps.enumerated()), id: \.offset) { index, step in
                            OriginalStepCard(step: step, stepNumber: index + 1)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tm.theme.palette.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tm.theme.palette.separator, lineWidth: 1)
                            )
                    )
                }
                
                // Edited routine
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Customized Routine")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Spacer()
                        
                        Text("\(editedSteps.filter { $0.isEnabled }.count) active steps")
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }
                    
                    ForEach(editedSteps.sorted { $0.order < $1.order }) { step in
                        EditedStepCard(step: step)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tm.theme.palette.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(tm.theme.palette.secondary.opacity(0.3), lineWidth: 2)
                        )
                )
                
                // Summary
                RoutineSummaryCard(
                    originalCount: originalSteps.count,
                    editedCount: editedSteps.filter { $0.isEnabled }.count,
                    addedCount: editedSteps.filter { !$0.originalStep && $0.isEnabled }.count,
                    removedCount: originalSteps.count - editedSteps.filter { $0.originalStep && $0.isEnabled }.count
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Original Step Card

private struct OriginalStepCard: View {
    @Environment(\.themeManager) private var tm
    let step: APIRoutineStep
    let stepNumber: Int
    
    private var stepTypeColor: Color {
        switch step.step {
        case .cleanser:
            return .blue
        case .treatment:
            return .purple
        case .moisturizer:
            return .green
        case .sunscreen:
            return .yellow
        case .optional:
            return .orange
        }
    }
    
    private var iconName: String {
        switch step.step {
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
    
    var body: some View {
        HStack(spacing: 12) {
            // Step number
            ZStack {
                Circle()
                    .fill(stepTypeColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("\(stepNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(stepTypeColor)
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.name)
                    .font(tm.theme.typo.title)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Text(step.why)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .lineLimit(nil)
            }
            
            Spacer()
            
            // Step icon
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(stepTypeColor.opacity(0.7))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(tm.theme.palette.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Edited Step Card

private struct EditedStepCard: View {
    @Environment(\.themeManager) private var tm
    let step: EditableRoutineStep
    
    private var stepTypeColor: Color {
        switch step.stepType {
        case .cleanser:
            return .blue
        case .treatment:
            return .purple
        case .moisturizer:
            return .green
        case .sunscreen:
            return .yellow
        case .optional:
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Step icon with status
            ZStack {
                Circle()
                    .fill(step.isEnabled ? stepTypeColor.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                if step.isEnabled {
                    Image(systemName: step.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(stepTypeColor)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(step.title)
                        .font(tm.theme.typo.title)
                        .foregroundColor(step.isEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
                        .strikethrough(!step.isEnabled)
                    
                    // Indicators
                    HStack(spacing: 4) {
                        if step.originalStep {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        if !step.originalStep {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        
                        if step.frequency != .daily {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Text(step.description)
                    .font(tm.theme.typo.body)
                    .foregroundColor(step.isEnabled ? tm.theme.palette.textSecondary : tm.theme.palette.textMuted)
                    .lineLimit(nil)
                
                // Frequency and timing info
                if step.isEnabled {
                    HStack(spacing: 8) {
                        if step.frequency != .daily {
                            Text(step.frequency.displayName)
                                .font(tm.theme.typo.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        if step.morningEnabled && step.eveningEnabled {
                            Text("AM & PM")
                                .font(tm.theme.typo.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        } else if step.morningEnabled {
                            Text("AM")
                                .font(tm.theme.typo.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        } else if step.eveningEnabled {
                            Text("PM")
                                .font(tm.theme.typo.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(step.isEnabled ? tm.theme.palette.bg : tm.theme.palette.bg.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(step.isEnabled ? tm.theme.palette.separator : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Routine Summary Card

private struct RoutineSummaryCard: View {
    @Environment(\.themeManager) private var tm
    let originalCount: Int
    let editedCount: Int
    let addedCount: Int
    let removedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary of Changes")
                .font(tm.theme.typo.h3)
                .foregroundColor(tm.theme.palette.textPrimary)
            
            VStack(spacing: 12) {
                SummaryRow(
                    title: "Original steps",
                    value: "\(originalCount)",
                    iconName: "list.bullet",
                    color: .blue
                )
                
                SummaryRow(
                    title: "Active steps",
                    value: "\(editedCount)",
                    iconName: "checkmark.circle",
                    color: .green
                )
                
                if addedCount > 0 {
                    SummaryRow(
                        title: "Added steps",
                        value: "\(addedCount)",
                        iconName: "plus.circle",
                        color: .green
                    )
                }
                
                if removedCount > 0 {
                    SummaryRow(
                        title: "Removed steps",
                        value: "\(removedCount)",
                        iconName: "minus.circle",
                        color: .red
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tm.theme.palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Summary Row

private struct SummaryRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview("RoutinePreviewView") {
    let mockEditableRoutine = EditableRoutine(
        morningSteps: [
            EditableRoutineStep(
                id: "morning_cleanser",
                title: "Gentle Cleanser",
                description: "Removes dirt and oil",
                iconName: "drop.fill",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Essential for cleaning",
                how: "Apply and rinse",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: true,
                originalStep: true,
                order: 0,
                morningEnabled: true,
                eveningEnabled: false
            )
        ],
        eveningSteps: [],
        weeklySteps: [],
        originalRoutine: nil,
        lastModified: Date(),
        isCustomized: true
    )
    
    RoutinePreviewView(
        originalRoutine: nil,
        editedRoutine: mockEditableRoutine,
        onConfirm: {},
        onCancel: {}
    )
    .themed(ThemeManager())
}
