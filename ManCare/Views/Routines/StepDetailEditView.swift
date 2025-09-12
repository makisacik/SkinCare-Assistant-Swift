//
//  StepDetailEditView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct StepDetailEditView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    @State private var title: String
    @State private var description: String
    @State private var customInstructions: String
    @State private var frequency: StepFrequency
    @State private var morningEnabled: Bool
    @State private var eveningEnabled: Bool
    @State private var isEnabled: Bool
    
    init(step: EditableRoutineStep, editingService: RoutineEditingService) {
        self.step = step
        self.editingService = editingService
        self._title = State(initialValue: step.title)
        self._description = State(initialValue: step.description)
        self._customInstructions = State(initialValue: step.customInstructions ?? "")
        self._frequency = State(initialValue: step.frequency)
        self._morningEnabled = State(initialValue: step.morningEnabled)
        self._eveningEnabled = State(initialValue: step.eveningEnabled)
        self._isEnabled = State(initialValue: step.isEnabled)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    // Header with step icon and type
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(step.stepTypeColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: step.iconName)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(step.stepTypeColor)
                        }
                        
                        VStack(spacing: 8) {
                            Text(step.stepTypeDisplayName)
                                .font(tm.theme.typo.h2)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            Text(step.timeOfDay.displayName)
                                .font(tm.theme.typo.body)
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Enable/disable toggle
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Step Status")
                                .font(tm.theme.typo.h3)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                        
                        Text(isEnabled ? "This step is active in your routine" : "This step is disabled and won't appear in your routine")
                            .font(tm.theme.typo.body)
                            .foregroundColor(tm.theme.palette.textSecondary)
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
                    
                    // Step details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step Details")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step Name")
                                .font(tm.theme.typo.body.weight(.semibold))
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            TextField("Enter step name", text: $title)
                                .font(tm.theme.typo.body)
                                .foregroundColor(tm.theme.palette.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tm.theme.palette.bg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(tm.theme.typo.body.weight(.semibold))
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            TextField("Enter description", text: $description)
                                .font(tm.theme.typo.body)
                                .foregroundColor(tm.theme.palette.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tm.theme.palette.bg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(tm.theme.palette.separator, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Custom instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Instructions")
                                .font(tm.theme.typo.body.weight(.semibold))
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            TextField("Add personal notes or instructions", text: $customInstructions)
                                .font(tm.theme.typo.body)
                                .foregroundColor(tm.theme.palette.textPrimary)
                                .padding(12)
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
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tm.theme.palette.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tm.theme.palette.separator, lineWidth: 1)
                            )
                    )
                    
                    // Frequency selection
                    FrequencySelectionView(
                        frequency: $frequency,
                        theme: tm.theme
                    )
                    
                    // Time of day selection (only for non-weekly steps)
                    if step.timeOfDay != .weekly {
                        TimeOfDaySelectionView(
                            morningEnabled: $morningEnabled,
                            eveningEnabled: $eveningEnabled,
                            theme: tm.theme
                        )
                    }
                    
                    // Step information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step Information")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(
                                title: "Why this step?",
                                content: step.why
                            )
                            
                            InfoRow(
                                title: "How to apply",
                                content: step.how
                            )
                            
                            if step.originalStep {
                                InfoRow(
                                    title: "Source",
                                    content: "Recommended by AI"
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
                .padding(20)
            }
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(tm.theme.palette.textSecondary),
                trailing: Button("Save") {
                    saveChanges()
                }
                .foregroundColor(tm.theme.palette.secondary)
                .font(.system(size: 16, weight: .semibold))
                .disabled(title.isEmpty || description.isEmpty)
            )
        }
    }
    
    private func saveChanges() {
        let updatedStep = step.copy(
            title: title,
            description: description,
            isEnabled: isEnabled,
            frequency: frequency,
            customInstructions: customInstructions.isEmpty ? nil : customInstructions,
            morningEnabled: morningEnabled,
            eveningEnabled: eveningEnabled
        )
        
        editingService.editableRoutine.updateStep(updatedStep)
        dismiss()
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            Text(content)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Frequency Selection View

private struct FrequencySelectionView: View {
    @Binding var frequency: StepFrequency
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Frequency")
                .font(theme.typo.h3)
                .foregroundColor(theme.palette.textPrimary)
            
            HStack(spacing: 8) {
                ForEach(StepFrequency.allCases, id: \.self) { freq in
                    Button {
                        frequency = freq
                    } label: {
                        Text(freq.displayName)
                            .font(theme.typo.caption.weight(.medium))
                            .foregroundColor(frequency == freq ? .white : theme.palette.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(frequency == freq ? theme.palette.secondary : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(frequency == freq ? theme.palette.secondary : theme.palette.separator, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Time of Day Selection View

private struct TimeOfDaySelectionView: View {
    @Binding var morningEnabled: Bool
    @Binding var eveningEnabled: Bool
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When to Use")
                .font(theme.typo.h3)
                .foregroundColor(theme.palette.textPrimary)
            
            HStack(spacing: 16) {
                // Morning toggle
                Button {
                    morningEnabled.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(morningEnabled ? .orange : .gray)
                        
                        Text("Morning")
                            .font(theme.typo.body.weight(.medium))
                            .foregroundColor(morningEnabled ? theme.palette.textPrimary : theme.palette.textMuted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(morningEnabled ? Color.orange.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(morningEnabled ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Evening toggle
                Button {
                    eveningEnabled.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(eveningEnabled ? .blue : .gray)
                        
                        Text("Evening")
                            .font(theme.typo.body.weight(.medium))
                            .foregroundColor(eveningEnabled ? theme.palette.textPrimary : theme.palette.textMuted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(eveningEnabled ? Color.blue.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(eveningEnabled ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.palette.separator, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview("StepDetailEditView") {
    let mockStep = EditableRoutineStep(
        id: "test_step",
        title: "Gentle Cleanser",
        description: "Removes dirt, oil, and makeup without stripping skin",
        iconName: "drop.fill",
        stepType: .cleanser,
        timeOfDay: .morning,
        why: "Essential for removing daily buildup and preparing skin for other products",
        how: "Apply to damp skin, massage gently for 30 seconds, rinse thoroughly",
        isEnabled: true,
        frequency: .daily,
        customInstructions: "Focus on T-zone area",
        isLocked: true,
        originalStep: true,
        order: 0,
        morningEnabled: true,
        eveningEnabled: false
    )
    
    StepDetailEditView(
        step: mockStep,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            routineTrackingService: RoutineTrackingService()
        )
    )
}
