//
//  AddStepView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AddStepView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    let timeOfDay: TimeOfDay
    let editingService: RoutineEditingService
    
    @State private var selectedStepType: StepType = .treatment
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
                            .font(tm.theme.typo.h1)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Text("Add a new step to your \(timeOfDay.displayName.lowercased()) routine")
                            .font(tm.theme.typo.sub)
                            .foregroundColor(tm.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Step type selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step Type")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(StepType.allCases, id: \.self) { stepType in
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
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step Name")
                                .font(tm.theme.typo.body.weight(.semibold))
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
                            TextField("Enter step name", text: $customTitle)
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
                            
                            TextField("Enter description", text: $customDescription)
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
                            Text("Custom Instructions (Optional)")
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
                    
                    // Frequency selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequency")
                            .font(tm.theme.typo.h3)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(StepFrequency.allCases, id: \.self) { freq in
                                Button {
                                    frequency = freq
                                } label: {
                                    Text(freq.displayName)
                                        .font(tm.theme.typo.caption.weight(.medium))
                                        .foregroundColor(frequency == freq ? .white : tm.theme.palette.textSecondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(frequency == freq ? tm.theme.palette.secondary : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(frequency == freq ? tm.theme.palette.secondary : tm.theme.palette.separator, lineWidth: 1)
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
                                .font(tm.theme.typo.h3)
                                .foregroundColor(tm.theme.palette.textPrimary)
                            
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
                                            .font(tm.theme.typo.body.weight(.medium))
                                            .foregroundColor(morningEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
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
                                            .font(tm.theme.typo.body.weight(.medium))
                                            .foregroundColor(eveningEnabled ? tm.theme.palette.textPrimary : tm.theme.palette.textMuted)
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
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addStep()
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(customTitle.isEmpty || customDescription.isEmpty)
                }
            }
        }
        .onAppear {
            updateDefaultsForStepType(selectedStepType)
        }
    }
    
    private func updateDefaultsForStepType(_ stepType: StepType) {
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
            iconName: iconNameForStepType(selectedStepType),
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
            eveningEnabled: eveningEnabled
        )
        
        editingService.addNewStep(type: selectedStepType, timeOfDay: timeOfDay)
        dismiss()
    }
    
    // MARK: - Helper Functions
    
    private func getDefaultTitle(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Gentle Cleanser"
        case .treatment:
            return "Face Serum"
        case .moisturizer:
            return "Moisturizer"
        case .sunscreen:
            return "Sunscreen SPF 30+"
        case .optional:
            return "Optional Treatment"
        }
    }
    
    private func getDefaultDescription(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Removes dirt, oil, and makeup without stripping skin"
        case .treatment:
            return "Targeted treatment for your specific skin concerns"
        case .moisturizer:
            return "Provides essential hydration and skin barrier support"
        case .sunscreen:
            return "Protects against UV damage and premature aging"
        case .optional:
            return "Additional treatment for enhanced results"
        }
    }
    
    private func getDefaultWhy(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Essential for removing daily buildup and preparing skin for other products"
        case .treatment:
            return "Provides targeted benefits for your specific skin concerns"
        case .moisturizer:
            return "Maintains skin hydration and supports the skin barrier"
        case .sunscreen:
            return "Prevents UV damage, premature aging, and skin cancer"
        case .optional:
            return "Provides additional benefits beyond your core routine"
        }
    }
    
    private func getDefaultHow(for stepType: StepType) -> String {
        switch stepType {
        case .cleanser:
            return "Apply to damp skin, massage gently for 30 seconds, rinse thoroughly"
        case .treatment:
            return "Apply 2-3 drops to clean skin, pat gently until absorbed"
        case .moisturizer:
            return "Apply a pea-sized amount, massage in upward circular motions"
        case .sunscreen:
            return "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
        case .optional:
            return "Follow product instructions for best results"
        }
    }
    
    private func iconNameForStepType(_ stepType: StepType) -> String {
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
    
    private func isStepTypeLocked(_ stepType: StepType) -> Bool {
        switch stepType {
        case .cleanser, .sunscreen:
            return true
        case .treatment, .moisturizer, .optional:
            return false
        }
    }
}

// MARK: - Step Type Card

private struct StepTypeCard: View {
    @Environment(\.themeManager) private var tm
    let stepType: StepType
    let isSelected: Bool
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
                    .foregroundColor(isSelected ? .white : stepTypeColor)
                
                Text(displayName)
                    .font(tm.theme.typo.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)
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
            routineTrackingService: RoutineTrackingService()
        )
    )
    .themed(ThemeManager())
}
