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
    @State private var showingProductTypeSelector = false
    
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
                    
                    // Product Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        ProductTypeSelectorButton(selectedProductType: $selectedStepType) {
                            showingProductTypeSelector = true
                        }
                    }
                    
                    // Step Details
                    VStack(alignment: .leading, spacing: 20) {
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
                                TextEditor(text: $customDescription)
                                    .font(ThemeManager.shared.theme.typo.body)
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(ThemeManager.shared.theme.palette.accentBackground)
                                    )
                                
                                if customDescription.isEmpty {
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
                }
                .padding(20)
            }
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
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
        .sheet(isPresented: $showingProductTypeSelector) {
            ProductTypeSelectorSheet(selectedProductType: $selectedStepType)
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
            frequency: .daily,
            customInstructions: nil,
            isLocked: isStepTypeLocked(selectedStepType),
            originalStep: false,
            order: editingService.editableRoutine.steps(for: timeOfDay).count,
            morningEnabled: timeOfDay == .morning || timeOfDay == .weekly,
            eveningEnabled: timeOfDay == .evening || timeOfDay == .weekly,
            attachedProductId: nil,
            productConstraints: nil
        )
        
        editingService.editableRoutine.addStep(newStep)
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


// MARK: - Preview

#if DEBUG
#Preview("AddStepView") {
    AddStepView(
        timeOfDay: .morning,
        editingService: RoutineEditingService(
            savedRoutine: SavedRoutineModel.preview,
            completionViewModel: RoutineCompletionViewModel.preview
        )
    )
}
#endif
