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
        switch stepType {
        case .cleanser:
            return "Removes dirt, oil, and makeup without stripping skin"
        case .faceSerum:
            return "Targeted treatment for your specific skin concerns"
        case .essence:
            return "Lightweight hydrating treatment that boosts absorption"
        case .moisturizer:
            return "Provides essential hydration and skin barrier support"
        case .sunscreen:
            return "Protects against UV damage and premature aging"
        case .toner:
            return "Balances skin pH and preps for next steps"
        case .exfoliator:
            return "Gently removes dead skin cells for smoother texture"
        case .faceMask:
            return "Intensive treatment for deep nourishment"
        case .eyeCream:
            return "Targets fine lines and dark circles around eyes"
        case .facialOil:
            return "Nourishes and seals in moisture"
        case .spotTreatment:
            return "Targets blemishes and problem areas"
        case .retinol:
            return "Anti-aging treatment that promotes cell turnover"
        case .vitaminC:
            return "Brightens and evens skin tone"
        case .niacinamide:
            return "Minimizes pores and improves skin texture"
        case .cleansingOil:
            return "Dissolves makeup and sunscreen effectively"
        case .cleansingBalm:
            return "Melts away makeup and impurities"
        case .micellarWater:
            return "Gentle no-rinse cleanser for sensitive skin"
        case .makeupRemover:
            return "Removes makeup quickly and effectively"
        case .faceWash:
            return "Daily facial cleanser for fresh clean skin"
        case .faceSunscreen:
            return "Lightweight sun protection for face"
        case .lipBalm:
            return "Keeps lips moisturized and protected"
        case .shaveCream:
            return "Provides smooth glide for comfortable shaving"
        case .aftershave:
            return "Soothes skin after shaving"
        case .shaveGel:
            return "Cushions skin during shaving"
        case .bodyLotion:
            return "Hydrates and softens body skin"
        case .bodyWash:
            return "Cleanses and refreshes body"
        case .bodySunscreen:
            return "Full body sun protection"
        case .handCream:
            return "Moisturizes and protects hands"
        case .facialMist:
            return "Refreshes and hydrates throughout the day"
        case .chemicalPeel:
            return "Deep exfoliation for skin renewal"
        case .shampoo:
            return "Cleanses hair and scalp"
        case .conditioner:
            return "Softens and detangles hair"
        case .hairOil:
            return "Nourishes and adds shine to hair"
        case .hairMask:
            return "Deep conditioning treatment for hair"
        }
    }

    private func getDefaultWhy(for stepType: ProductType) -> String {
        // Return a generic why for all product types
        return "Essential step in your skincare routine"
    }

    private func getDefaultHow(for stepType: ProductType) -> String {
        // Return a generic how for all product types
        return "Apply as directed on product packaging"
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
