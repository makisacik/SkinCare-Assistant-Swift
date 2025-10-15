//
//  StepDetailEditView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct StepDetailEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    @State private var title: String
    @State private var description: String
    
    init(step: EditableRoutineStep, editingService: RoutineEditingService) {
        self.step = step
        self.editingService = editingService
        self._title = State(initialValue: step.title)
        self._description = State(initialValue: step.description)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with step icon and type
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(step.stepTypeColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(step.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                        }
                        
                        VStack(spacing: 8) {
                            Text(step.stepTypeDisplayName)
                                .font(ThemeManager.shared.theme.typo.h2)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            Text("Edit step details")
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Step Information
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step Name")
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            TextField("Enter step name", text: $title)
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Description - multiline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $description)
                                    .font(ThemeManager.shared.theme.typo.body)
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(ThemeManager.shared.theme.palette.accentBackground)
                                    )
                                
                                if description.isEmpty {
                                    Text("Enter step description...")
                                        .font(ThemeManager.shared.theme.typo.body)
                                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationTitle("Edit Step")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedStep = step.copy(
            title: title,
            description: description
        )
        editingService.editableRoutine.updateStep(updatedStep)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("StepDetailEditView") {
    let mockStep = EditableRoutineStep(
        id: "test_step",
        title: "Gentle Cleanser",
        description: "Removes dirt, oil, and makeup without stripping skin",
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
            savedRoutine: SavedRoutineModel.preview,
            completionViewModel: RoutineCompletionViewModel.preview
        )
    )
}
#endif