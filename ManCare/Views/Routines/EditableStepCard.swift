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
    
    @State private var showingProductSelection = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 16) {
                // Reorder handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(tm.theme.palette.textMuted)
                    .frame(width: 20)
                
                // Step icon
                ZStack {
                    Circle()
                        .fill(step.stepTypeColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: step.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(step.stepTypeColor)
                }
                
                // Step info
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(tm.theme.typo.title)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Text(step.description)
                        .font(tm.theme.typo.body)
                        .foregroundColor(tm.theme.palette.textSecondary)
                        .lineLimit(2)
                    
                    // Attached product info
                    if let attachedProduct = editingService.getAttachedProduct(for: step) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.green)
                            
                            Text(attachedProduct.displayName)
                                .font(tm.theme.typo.caption.weight(.medium))
                                .foregroundColor(Color.green)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 8) {
                    // Attach/Detach product button
                    Button {
                        if step.hasAttachedProduct {
                            editingService.detachProduct(from: step)
                        } else {
                            showingProductSelection = true
                        }
                    } label: {
                        Image(systemName: step.hasAttachedProduct ? "link.badge.minus" : "link.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(step.hasAttachedProduct ? Color.red : tm.theme.palette.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Remove button (only for non-locked steps)
                    if !step.isLocked {
                        Button {
                            editingService.removeStep(step)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(tm.theme.palette.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tm.theme.palette.separator, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onDrag {
            return NSItemProvider(object: step.id as NSString)
        }
        .onDrop(of: [.text], delegate: StepDropDelegate(
            step: step,
            editingService: editingService
        ))
        .sheet(isPresented: $showingProductSelection) {
            ProductSelectionView(
                step: step,
                editingService: editingService
            )
        }
    }
}

// MARK: - Step Drop Delegate

struct StepDropDelegate: DropDelegate {
    let step: EditableRoutineStep
    let editingService: RoutineEditingService
    
    func dropEntered(info: DropInfo) {
        // Visual feedback when dragging over
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, error) in
            if let data = item as? Data,
               let draggedStepId = String(data: data, encoding: .utf8),
               draggedStepId != step.id {
                
                DispatchQueue.main.async {
                    editingService.reorderSteps(draggedStepId: draggedStepId, targetStepId: step.id)
                }
            }
        }
        
        return true
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
        eveningEnabled: false,
        attachedProductId: nil,
        productConstraints: nil
    )
    
    EditableStepCard(
        step: mockStep,
        editingService: RoutineEditingService(
            originalRoutine: nil,
            routineTrackingService: RoutineTrackingService()
        ),
        onTap: {}
    )
}