//
//  EditableStepCard.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct EditableStepCard: View {
    @Environment(\.themeManager) private var tm
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    let onTap: () -> Void
    
    @State private var isExpanded = false
    @State private var showingSwapOptions = false
    @State private var showingFrequencyOptions = false
    @State private var showingCustomInstructions = false
    @State private var customInstructionsText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(spacing: 16) {
                // Header with step info and controls
                HStack(spacing: 16) {
                    // Step icon and info
                    HStack(spacing: 12) {
                        // Icon with status indicator
                        ZStack {
                            Circle()
                                .fill(step.stepTypeColor.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            if !step.isEnabled {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            
                            Image(systemName: step.iconName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(step.isEnabled ? step.stepTypeColor : .gray)
                        }
                        
                        // Step details
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(step.title)
                                    .font(tm.theme.typo.title)
                                    .foregroundColor(step.isEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
                                    .strikethrough(!step.isEnabled)
                                
                                // Original step indicator
                                if step.originalStep {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                
                                // Locked step indicator
                                if step.isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Text(step.description)
                                .font(tm.theme.typo.body)
                                .foregroundColor(step.isEnabled ? tm.theme.palette.textSecondary : tm.theme.palette.textMuted)
                                .lineLimit(nil)
                        }
                    }
                    
                    Spacer()
                    
                    // Quick actions
                    VStack(spacing: 8) {
                        // Enable/disable toggle
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            editingService.toggleStep(step)
                        } label: {
                            Image(systemName: step.isEnabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(step.isEnabled ? .green : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Expand/collapse button
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Expanded content
                if isExpanded {
                    VStack(spacing: 16) {
                        // Time of day toggles
                        TimeOfDayToggles(
                            step: step,
                            editingService: editingService
                        )
                        
                        // Frequency selector
                        FrequencySelector(
                            step: step,
                            editingService: editingService
                        )
                        
                        // Custom instructions
                        if let instructions = step.customInstructions {
                            CustomInstructionsView(
                                instructions: instructions,
                                onEdit: {
                                    customInstructionsText = instructions
                                    showingCustomInstructions = true
                                }
                            )
                        }
                        
                        // Action buttons
                        ActionButtons(
                            step: step,
                            editingService: editingService,
                            onSwap: {
                                showingSwapOptions = true
                            },
                            onEditInstructions: {
                                customInstructionsText = step.customInstructions ?? ""
                                showingCustomInstructions = true
                            }
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(step.isEnabled ? tm.theme.palette.card : tm.theme.palette.card.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(step.isEnabled ? tm.theme.palette.separator : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .sheet(isPresented: $showingSwapOptions) {
            SwapStepView(
                currentStep: step,
                editingService: editingService
            )
        }
        .sheet(isPresented: $showingCustomInstructions) {
            CustomInstructionsEditView(
                step: step,
                instructions: $customInstructionsText,
                editingService: editingService
            )
        }
    }
}

// MARK: - Time of Day Toggles

private struct TimeOfDayToggles: View {
    @Environment(\.themeManager) private var tm
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to use")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            HStack(spacing: 16) {
                // Morning toggle
                Button {
                    editingService.toggleTimeOfDay(step, timeOfDay: .morning)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(step.morningEnabled ? .orange : .gray)
                        
                        Text("Morning")
                            .font(tm.theme.typo.body.weight(.medium))
                            .foregroundColor(step.morningEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(step.morningEnabled ? Color.orange.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(step.morningEnabled ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(step.timeOfDay == .weekly)
                
                // Evening toggle
                Button {
                    editingService.toggleTimeOfDay(step, timeOfDay: .evening)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(step.eveningEnabled ? .blue : .gray)
                        
                        Text("Evening")
                            .font(tm.theme.typo.body.weight(.medium))
                            .foregroundColor(step.eveningEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(step.eveningEnabled ? Color.blue.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(step.eveningEnabled ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(step.timeOfDay == .weekly)
                
                Spacer()
            }
        }
    }
}

// MARK: - Frequency Selector

private struct FrequencySelector: View {
    @Environment(\.themeManager) private var tm
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frequency")
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)
            
            HStack(spacing: 8) {
                ForEach(StepFrequency.allCases, id: \.self) { frequency in
                    Button {
                        editingService.updateStepFrequency(step, frequency: frequency)
                    } label: {
                        Text(frequency.displayName)
                            .font(tm.theme.typo.caption.weight(.medium))
                            .foregroundColor(step.frequency == frequency ? .white : tm.theme.palette.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(step.frequency == frequency ? tm.theme.palette.secondary : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(step.frequency == frequency ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Custom Instructions View

private struct CustomInstructionsView: View {
    @Environment(\.themeManager) private var tm
    let instructions: String
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Custom Instructions")
                    .font(tm.theme.typo.body.weight(.semibold))
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Spacer()
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(tm.theme.palette.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(instructions)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
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
}

// MARK: - Action Buttons

private struct ActionButtons: View {
    @Environment(\.themeManager) private var tm
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    let onSwap: () -> Void
    let onEditInstructions: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Swap button
            Button {
                onSwap()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Swap")
                        .font(tm.theme.typo.body.weight(.medium))
                }
                .foregroundColor(tm.theme.palette.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(tm.theme.palette.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Edit instructions button
            Button {
                onEditInstructions()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Edit Notes")
                        .font(tm.theme.typo.body.weight(.medium))
                }
                .foregroundColor(tm.theme.palette.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(tm.theme.palette.bg)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Remove button (only for non-locked steps)
            if !step.isLocked {
                Button {
                    editingService.removeStep(step)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Remove")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Swap Step View

struct SwapStepView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let currentStep: EditableRoutineStep
    let editingService: RoutineEditingService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current step info
                VStack(spacing: 12) {
                    Text("Current Step")
                        .font(tm.theme.typo.h3)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: currentStep.iconName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(currentStep.stepTypeColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentStep.title)
                                .font(tm.theme.typo.title)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            Text(currentStep.stepTypeDisplayName)
                                .font(tm.theme.typo.caption)
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                        
                        Spacer()
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
                
                // Available step types
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose New Step Type")
                        .font(tm.theme.typo.h3)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(editingService.getAvailableStepTypes(excluding: currentStep.stepType), id: \.self) { stepType in
                            SwapOptionCard(
                                stepType: stepType,
                                onSelect: {
                                    editingService.swapStepType(currentStep, newType: stepType)
                                    dismiss()
                                }
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Swap Step")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                }
            }
        }
    }
}

// MARK: - Swap Option Card

private struct SwapOptionCard: View {
    @Environment(\.themeManager) private var tm
    let stepType: StepType
    let onSelect: () -> Void
    
    private var stepTypeColor: Color {
        switch stepType {
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
    
    private var displayName: String {
        switch stepType {
        case .cleanser:
            return "Cleanser"
        case .treatment:
            return "Treatment"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen"
        case .optional:
            return "Optional"
        }
    }
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(stepTypeColor)
                
                Text(displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(stepTypeColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(stepTypeColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Instructions Edit View

struct CustomInstructionsEditView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let step: EditableRoutineStep
    @Binding var instructions: String
    let editingService: RoutineEditingService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Instructions")
                        .font(tm.theme.typo.h3)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text("Add personal notes or specific instructions for this step")
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
                
                TextEditor(text: $instructions)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tm.theme.palette.bg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tm.theme.palette.separator, lineWidth: 1)
                            )
                    )
                    .frame(minHeight: 200)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editingService.addCustomInstructions(step, instructions: instructions)
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("EditableStepCard") {
    let mockStep = EditableRoutineStep(
        id: "test_step",
        title: "Gentle Cleanser",
        description: "Removes dirt, oil, and makeup without stripping skin",
        iconName: "drop.fill",
        stepType: .cleanser,
        timeOfDay: .morning,
        why: "Essential for removing daily buildup",
        how: "Apply to damp skin, massage gently, rinse thoroughly",
        isEnabled: true,
        frequency: .daily,
        customInstructions: "Focus on T-zone area",
        isLocked: true,
        originalStep: true,
        order: 0,
        morningEnabled: true,
        eveningEnabled: false
    )
    
    EditableStepCard(
        step: mockStep,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            routineTrackingService: RoutineTrackingService()
        ),
        onTap: {}
    )
    .themed(ThemeManager())
}
