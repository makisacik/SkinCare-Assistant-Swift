//
//  RoutinePreviewView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutinePreviewView: View {
    
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
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Review your customized routine before saving")
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                                .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ThemeManager.shared.theme.palette.secondary)
                        .cornerRadius(ThemeManager.shared.theme.cardRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        onCancel()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Cancel")
                                .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ThemeManager.shared.theme.palette.accentBackground)
                        .cornerRadius(ThemeManager.shared.theme.cardRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Routine Comparison Section

private struct RoutineComparisonSection: View {
    
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
                        .font(ThemeManager.shared.theme.typo.h2)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("Compare your changes")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .padding(.top, 20)
                
                // Original routine
                if !originalSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Original Routine")
                                .font(ThemeManager.shared.theme.typo.h3)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            Spacer()
                            
                            Text("\(originalSteps.count) steps")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                        
                        ForEach(Array(originalSteps.enumerated()), id: \.offset) { index, step in
                            OriginalStepCard(step: step, stepNumber: index + 1)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.theme.palette.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                            )
                    )
                }
                
                // Edited routine
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Customized Routine")
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Spacer()
                        
                        Text("\(editedSteps.filter { $0.isEnabled }.count) active steps")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    ForEach(editedSteps.sorted { $0.order < $1.order }) { step in
                        EditedStepCard(step: step)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.secondary.opacity(0.3), lineWidth: 2)
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
    
    let step: APIRoutineStep
    let stepNumber: Int
    
    private var stepTypeColor: Color {
        Color(step.step.color)
    }
    
    private var iconName: String { step.step.iconName }
    
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
                    .font(ThemeManager.shared.theme.typo.title)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text(step.why)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
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
                .fill(ThemeManager.shared.theme.palette.accentBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Edited Step Card

private struct EditedStepCard: View {
    
    let step: EditableRoutineStep
    
    private var stepTypeColor: Color { Color(step.stepType.color) }
    
    var body: some View {
        HStack(spacing: 12) {
            // Step icon with status
            ZStack {
                Circle()
                    .fill(step.isEnabled ? stepTypeColor.opacity(0.2) : ThemeManager.shared.theme.palette.textMuted.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                if step.isEnabled {
                    Image(systemName: step.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(stepTypeColor)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(step.title)
                        .font(ThemeManager.shared.theme.typo.title)
                        .foregroundColor(step.isEnabled ? ThemeManager.shared.theme.palette.textPrimary : ThemeManager.shared.theme.palette.textMuted)
                        .strikethrough(!step.isEnabled)
                    
                    // Indicators
                    HStack(spacing: 4) {
                        if step.originalStep {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.info)
                        }
                        
                        if !step.originalStep {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.success)
                        }
                        
                        if step.frequency != .daily {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.warning)
                        }
                    }
                }
                
                Text(step.description)
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(step.isEnabled ? ThemeManager.shared.theme.palette.textSecondary : ThemeManager.shared.theme.palette.textMuted)
                    .lineLimit(nil)
                
                // Frequency and timing info
                if step.isEnabled {
                    HStack(spacing: 8) {
                        if step.frequency != .daily {
                            Text(step.frequency.displayName)
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.warning)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ThemeManager.shared.theme.palette.warning.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        if step.morningEnabled && step.eveningEnabled {
                            Text("AM & PM")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.info)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ThemeManager.shared.theme.palette.info.opacity(0.1))
                                .cornerRadius(4)
                        } else if step.morningEnabled {
                            Text("AM")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.warning)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ThemeManager.shared.theme.palette.warning.opacity(0.1))
                                .cornerRadius(4)
                        } else if step.eveningEnabled {
                            Text("PM")
                                .font(ThemeManager.shared.theme.typo.caption)
                                .foregroundColor(ThemeManager.shared.theme.palette.info)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ThemeManager.shared.theme.palette.info.opacity(0.1))
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
                .fill(step.isEnabled ? ThemeManager.shared.theme.palette.accentBackground : ThemeManager.shared.theme.palette.accentBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(step.isEnabled ? ThemeManager.shared.theme.palette.separator : ThemeManager.shared.theme.palette.textMuted.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Routine Summary Card

private struct RoutineSummaryCard: View {
    
    let originalCount: Int
    let editedCount: Int
    let addedCount: Int
    let removedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary of Changes")
                .font(ThemeManager.shared.theme.typo.h3)
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            VStack(spacing: 12) {
                SummaryRow(
                    title: "Original steps",
                    value: "\(originalCount)",
                    iconName: "list.bullet",
                    color: ThemeManager.shared.theme.palette.info
                )
                
                SummaryRow(
                    title: "Active steps",
                    value: "\(editedCount)",
                    iconName: "checkmark.circle",
                    color: ThemeManager.shared.theme.palette.success
                )
                
                if addedCount > 0 {
                    SummaryRow(
                        title: "Added steps",
                        value: "\(addedCount)",
                        iconName: "plus.circle",
                        color: ThemeManager.shared.theme.palette.success
                    )
                }
                
                if removedCount > 0 {
                    SummaryRow(
                        title: "Removed steps",
                        value: "\(removedCount)",
                        iconName: "minus.circle",
                        color: ThemeManager.shared.theme.palette.error
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Summary Row

private struct SummaryRow: View {
    
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
                .font(ThemeManager.shared.theme.typo.body)
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
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
}
