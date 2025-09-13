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
    
    init(step: EditableRoutineStep, editingService: RoutineEditingService) {
        self.step = step
        self.editingService = editingService
        self._title = State(initialValue: step.title)
        self._description = State(initialValue: step.description)
        self._customInstructions = State(initialValue: step.customInstructions ?? "")
        self._frequency = State(initialValue: step.frequency)
        self._morningEnabled = State(initialValue: step.morningEnabled)
        self._eveningEnabled = State(initialValue: step.eveningEnabled)
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
                            
                            Text("Customize this step")
                                .font(tm.theme.typo.body)
                                .foregroundColor(tm.theme.palette.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        VStack(spacing: 16) {
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(tm.theme.typo.body.weight(.medium))
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                
                                TextField("Step title", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(tm.theme.typo.body.weight(.medium))
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                
                                TextField("Step description", text: $description)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Time of Day Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When to use")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        VStack(spacing: 12) {
                            // Morning toggle
                            HStack {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.orange)
                                
                                Text("Morning")
                                    .font(tm.theme.typo.body)
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $morningEnabled)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(tm.theme.palette.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                                    )
                            )
                            
                            // Evening toggle
                            HStack {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.blue)
                                
                                Text("Evening")
                                    .font(tm.theme.typo.body)
                                    .foregroundColor(tm.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $eveningEnabled)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
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
                    .padding(.horizontal, 20)
                    
                    // Frequency
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequency")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Picker("Frequency", selection: $frequency) {
                            ForEach(StepFrequency.allCases, id: \.self) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Custom Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Custom Instructions")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        TextEditor(text: $customInstructions)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(tm.theme.palette.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
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
                    dismiss()
                }
                .foregroundColor(tm.theme.palette.secondary)
                .font(.system(size: 16, weight: .semibold))
            )
        }
    }
    
    private func saveChanges() {
        let updatedStep = step.copy(
            title: title,
            description: description,
            frequency: frequency,
            customInstructions: customInstructions.isEmpty ? nil : customInstructions,
            morningEnabled: morningEnabled,
            eveningEnabled: eveningEnabled
        )
        editingService.editableRoutine.updateStep(updatedStep)
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
        why: "Essential for removing daily buildup",
        how: "Apply to damp skin, massage gently, rinse thoroughly",
        isEnabled: true,
        frequency: .daily,
        customInstructions: "Focus on T-zone area",
        isLocked: true,
        originalStep: true,
        order: 0,
        morningEnabled: true,
        eveningEnabled: false,
        attachedProductId: nil,
        productConstraints: nil
    )
    
    StepDetailEditView(
        step: mockStep,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            routineTrackingService: RoutineTrackingService()
        )
    )
}