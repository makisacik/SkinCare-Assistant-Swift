//
//  AddStepView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AddStepView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let timeOfDay: TimeOfDay
    let editingService: RoutineEditingService
    
    @State private var selectedStepType: ProductType = .faceSerum
    @State private var customTitle = ""
    @State private var customDescription = ""
    @State private var customInstructions = ""
    @State private var frequency: StepFrequency = .daily
    @State private var morningEnabled = true
    @State private var eveningEnabled = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Add New Step")
                            .font(ThemeManager.shared.theme.typo.h1)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Text("Add a new step to your \(timeOfDay.displayName.lowercased()) routine")
                            .font(ThemeManager.shared.theme.typo.sub)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Step type selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step Type")
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(ProductType.allCases, id: \.self) { stepType in
                                StepTypeCard(
                                    stepType: stepType,
                                    isSelected: selectedStepType == stepType,
                                    onSelect: {
                                        selectedStepType = stepType
                                        updateDefaultsForStepType(stepType)
                                    }
                                )
                            }
                        }
                    }
                    
                    // Custom details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Customize Details")
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step Name")
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            TextField("Enter step name", text: $customTitle)
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            TextField("Enter description", text: $customDescription)
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Custom instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Instructions (Optional)")
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            TextField("Add personal notes or instructions", text: $customInstructions)
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .padding(12)
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
                    
                    // Frequency selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequency")
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(StepFrequency.allCases, id: \.self) { freq in
                                Button {
                                    frequency = freq
                                } label: {
                                    Text(freq.displayName)
                                        .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                                        .foregroundColor(frequency == freq ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textSecondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(frequency == freq ? ThemeManager.shared.theme.palette.secondary : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(frequency == freq ? ThemeManager.shared.theme.palette.secondary : ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Time of day selection (only for non-weekly steps)
                    if timeOfDay != .weekly {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("When to Use")
                                .font(ThemeManager.shared.theme.typo.h3)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            HStack(spacing: 16) {
                                // Morning toggle
                                Button {
                                    morningEnabled.toggle()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sun.max.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(morningEnabled ? ThemeManager.shared.theme.palette.warning : ThemeManager.shared.theme.palette.textMuted)
                                        
                                        Text("Morning")
                                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                            .foregroundColor(morningEnabled ? ThemeManager.shared.theme.palette.textPrimary : ThemeManager.shared.theme.palette.textMuted)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(morningEnabled ? ThemeManager.shared.theme.palette.warning.opacity(0.1) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(morningEnabled ? ThemeManager.shared.theme.palette.warning : ThemeManager.shared.theme.palette.textMuted.opacity(0.3), lineWidth: 1)
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
                                            .foregroundColor(eveningEnabled ? ThemeManager.shared.theme.palette.info : ThemeManager.shared.theme.palette.textMuted)
                                        
                                        Text("Evening")
                                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                                            .foregroundColor(eveningEnabled ? ThemeManager.shared.theme.palette.textPrimary : ThemeManager.shared.theme.palette.textMuted)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(eveningEnabled ? ThemeManager.shared.theme.palette.info.opacity(0.1) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(eveningEnabled ? ThemeManager.shared.theme.palette.info : ThemeManager.shared.theme.palette.textMuted.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Add Step")
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
                    Button("Add") {
                        addStep()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(customTitle.isEmpty || customDescription.isEmpty)
                }
            }
        }
        .onAppear {
            updateDefaultsForStepType(selectedStepType)
        }
    }
    
    private func updateDefaultsForStepType(_ stepType: ProductType) {
        if customTitle.isEmpty {
            customTitle = getDefaultTitle(for: stepType)
        }
        if customDescription.isEmpty {
            customDescription = getDefaultDescription(for: stepType)
        }
    }
    
    private func addStep() {
        let newStep = EditableRoutineStep(
            id: "\(timeOfDay.rawValue)_\(selectedStepType.rawValue)_\(UUID().uuidString.prefix(8))",
            title: customTitle,
            description: customDescription,
            stepType: selectedStepType,
            timeOfDay: timeOfDay,
            why: getDefaultWhy(for: selectedStepType),
            how: getDefaultHow(for: selectedStepType),
            isEnabled: true,
            frequency: frequency,
            customInstructions: customInstructions.isEmpty ? nil : customInstructions,
            isLocked: isStepTypeLocked(selectedStepType),
            originalStep: false,
            order: editingService.editableRoutine.steps(for: timeOfDay).count,
            morningEnabled: morningEnabled,
            eveningEnabled: eveningEnabled,
            attachedProductId: nil,
            productConstraints: nil
        )
        
        editingService.addNewStep(type: selectedStepType, timeOfDay: timeOfDay)
        dismiss()
    }
    
    // MARK: - Helper Functions
    
    private func getDefaultTitle(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Gentle Cleanser"
        case .faceSerum:
            return "Face Serum"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen SPF 30+"
        default:
            return stepType.displayName
        }
    }
    
    private func getDefaultDescription(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Removes dirt, oil, and makeup without stripping skin"
        case .faceSerum:
            return "Targeted treatment for your specific skin concerns"
        case .moisturizer:
            return "Provides essential hydration and skin barrier support"
        case .sunscreen:
            return "Protects against UV damage and premature aging"
        default:
            return ""
        }
    }
    
    private func getDefaultWhy(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Essential for removing daily buildup and preparing skin for other products"
        case .faceSerum:
            return "Provides targeted benefits for your specific skin concerns"
        case .moisturizer:
            return "Maintains skin hydration and supports the skin barrier"
        case .sunscreen:
            return "Prevents UV damage, premature aging, and skin cancer"
        default:
            return ""
        }
    }
    
    private func getDefaultHow(for stepType: ProductType) -> String {
        switch stepType {
        case .cleanser:
            return "Apply to damp skin, massage gently for 30 seconds, rinse thoroughly"
        case .faceSerum:
            return "Apply 2-3 drops to clean skin, pat gently until absorbed"
        case .moisturizer:
            return "Apply a pea-sized amount, massage in upward circular motions"
        case .sunscreen:
            return "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
        default:
            return ""
        }
    }
    
    // iconName is computed from stepType in the model, not in helper functions
    
    private func isStepTypeLocked(_ stepType: ProductType) -> Bool {
        switch stepType {
        case .cleanser, .sunscreen, .faceSunscreen:
            return true
        default:
            return false
        }
    }
}

// MARK: - Step Type Card

private struct StepTypeCard: View {
    
    let stepType: ProductType
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var stepTypeColor: Color { Color(stepType.color) }
    
    private var iconName: String { ProductIconManager.getIconName(for: stepType) }
    
    private var displayName: String { stepType.displayName }
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : stepTypeColor)
                
                Text(displayName)
                    .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    .foregroundColor(isSelected ? ThemeManager.shared.theme.palette.textInverse : ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? stepTypeColor : stepTypeColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? stepTypeColor : stepTypeColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview("AddStepView") {
    AddStepView(
        timeOfDay: .morning,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            completionViewModel: RoutineCompletionViewModel.preview
        )
    )
}
