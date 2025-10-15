//
//  EditableStepCard.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct EditableStepCard: View {
    
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    let onTap: () -> Void
    
    @State private var showingProductSelection = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 14) {
                // Step icon - bigger with rounded corners
                Image(step.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Step info - tappable area to edit
                VStack(alignment: .leading, spacing: 6) {
                    Text(step.title)
                        .font(ThemeManager.shared.theme.typo.title)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text(step.description)
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .lineLimit(2)
                    
                    // Attached product info
                    if let attachedProduct = editingService.getAttachedProduct(for: step) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.success)
                            
                            Text(attachedProduct.displayName)
                                .font(ThemeManager.shared.theme.typo.caption.weight(.medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.success)
                        }
                        .padding(.top, 2)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
                
                Spacer()
                
                // Action buttons - larger touch targets
                HStack(spacing: 8) {
                    // Move up/down buttons - bigger and easier to tap
                    VStack(spacing: 2) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                editingService.moveStepUp(step)
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .frame(width: 44, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                editingService.moveStepDown(step)
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .frame(width: 44, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // Delete button - always show in edit mode
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            editingService.removeStep(step)
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.error)
                            .frame(width: 44, height: 68)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ThemeManager.shared.theme.palette.error.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.shared.theme.palette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingProductSelection) {
            ProductSelectionView(
                step: step,
                editingService: editingService
            )
        }
    }
}


// MARK: - Preview

#if DEBUG
#Preview("EditableStepCard") {
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
    
    EditableStepCard(
        step: mockStep,
        editingService: RoutineEditingService(
            savedRoutine: SavedRoutineModel.preview,
            completionViewModel: RoutineCompletionViewModel.preview
        ),
        onTap: {}
    )
}
#endif