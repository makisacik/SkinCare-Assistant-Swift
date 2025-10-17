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
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text(L10n.Routines.Edit.addNewStep)
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(L10n.Routines.Edit.addStepDescription(timeOfDay.displayName.lowercased()))
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
                        Text(L10n.Routines.Edit.stepName)
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        TextField(L10n.Routines.Edit.enterStepName, text: $customTitle)
                            .font(ThemeManager.shared.theme.typo.body)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                    )
                            )
                            .colorScheme(.light)
                    }

                    // Description - multiline
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Routines.Edit.description)
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $customDescription)
                                .frame(minHeight: 120)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                        )
                                )
                                .font(ThemeManager.shared.theme.typo.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .colorScheme(.light)

                            if customDescription.isEmpty {
                                Text(L10n.Routines.Edit.enterDescription)
                                    .font(ThemeManager.shared.theme.typo.body)
                                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.Common.add) {
                    addStep()
                }
                .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                .font(.system(size: 16, weight: .semibold))
            }
        }
        .sheet(isPresented: $showingProductTypeSelector) {
            ProductTypeSelectorSheet(selectedProductType: $selectedStepType)
        }
        .onAppear {
            // Initialize with default values on first load
            if customTitle.isEmpty {
                customTitle = getDefaultTitle(for: selectedStepType)
            }
            if customDescription.isEmpty {
                customDescription = getDefaultDescription(for: selectedStepType)
            }
        }
        .onChange(of: selectedStepType) { newType in
            // Always update title and description when product type changes
            customTitle = getDefaultTitle(for: newType)
            customDescription = getDefaultDescription(for: newType)
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

        editingService.addCustomStep(newStep)
        dismiss()
    }

    // MARK: - Helper Functions

    private func getDefaultTitle(for stepType: ProductType) -> String {
        // Return the display name for all types
        return stepType.displayName
    }

    private func getDefaultDescription(for stepType: ProductType) -> String {
        return L10n.Routines.ProductType.description(stepType.rawValue)
    }

    private func getDefaultWhy(for stepType: ProductType) -> String {
        return L10n.Routines.ProductType.defaultWhy
    }

    private func getDefaultHow(for stepType: ProductType) -> String {
        return L10n.Routines.ProductType.defaultHow
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
