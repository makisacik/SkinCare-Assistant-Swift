//
//  EditRoutineView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct EditRoutineView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var editingService: RoutineEditingService
    @State private var selectedTimeOfDay: TimeOfDay = .morning
    @State private var showingAddStep = false
    @State private var showingStepDetail: EditableRoutineStep?
    @State private var showingAdvancedOptions = false
    
    init(originalRoutine: RoutineResponse?, routineTrackingService: RoutineTrackingService) {
        self._editingService = StateObject(wrappedValue: RoutineEditingService(originalRoutine: originalRoutine, routineTrackingService: routineTrackingService))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                EditRoutineHeader(
                    editingState: editingService.editingState,
                    isCustomized: editingService.editableRoutine.isCustomized,
                    onCancel: {
                        editingService.cancelEditing()
                        dismiss()
                    },
                    onSave: {
                        Task {
                            await editingService.saveRoutine()
                            dismiss()
                        }
                    },
                    onPreview: {
                        editingService.showPreview()
                    }
                )
                
                // Coach Messages
                if !editingService.coachMessages.isEmpty {
                    CoachMessagesView(
                        messages: editingService.coachMessages,
                        onDismiss: {
                            editingService.clearCoachMessages()
                        }
                    )
                }
                
                // Time of Day Selector
                TimeOfDaySelector(
                    selectedTimeOfDay: $selectedTimeOfDay,
                    editingState: editingService.editingState
                )
                
                // Content
                TabView(selection: $selectedTimeOfDay) {
                    // Morning Routine
                    EditableRoutineSection(
                        timeOfDay: .morning,
                        steps: editingService.editableRoutine.morningSteps,
                        editingService: editingService,
                        onStepTap: { step in
                            showingStepDetail = step
                        },
                        onAddStep: {
                            showingAddStep = true
                        }
                    )
                    .tag(TimeOfDay.morning)
                    
                    // Evening Routine
                    EditableRoutineSection(
                        timeOfDay: .evening,
                        steps: editingService.editableRoutine.eveningSteps,
                        editingService: editingService,
                        onStepTap: { step in
                            showingStepDetail = step
                        },
                        onAddStep: {
                            showingAddStep = true
                        }
                    )
                    .tag(TimeOfDay.evening)
                    
                    // Weekly Routine
                    EditableRoutineSection(
                        timeOfDay: .weekly,
                        steps: editingService.editableRoutine.weeklySteps,
                        editingService: editingService,
                        onStepTap: { step in
                            showingStepDetail = step
                        },
                        onAddStep: {
                            showingAddStep = true
                        }
                    )
                    .tag(TimeOfDay.weekly)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(tm.theme.palette.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddStep) {
            AddStepView(
                timeOfDay: selectedTimeOfDay,
                editingService: editingService
            )
        }
        .sheet(item: $showingStepDetail) { step in
            StepDetailEditView(
                step: step,
                editingService: editingService
            )
        }
        .sheet(isPresented: $editingService.showingPreview) {
            RoutinePreviewView(
                originalRoutine: editingService.editableRoutine.originalRoutine,
                editedRoutine: editingService.editableRoutine,
                onConfirm: {
                    Task {
                        await editingService.saveRoutine()
                        dismiss()
                    }
                },
                onCancel: {
                    editingService.showingPreview = false
                }
            )
        }
        .onAppear {
            editingService.startEditing()
        }
    }
}

// MARK: - Edit Routine Header

private struct EditRoutineHeader: View {
    @Environment(\.themeManager) private var tm
    let editingState: RoutineEditingState
    let isCustomized: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                Button {
                    onCancel()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Cancel")
                            .font(tm.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Customization indicator
                if isCustomized {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)
                        Text("Customized")
                            .font(tm.theme.typo.caption.weight(.medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button {
                    onSave()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Save")
                            .font(tm.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(tm.theme.palette.secondary)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(editingState == .saving)
            }
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text("Edit Your Routine")
                    .font(tm.theme.typo.h1)
                    .foregroundColor(tm.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Customize your skincare routine to fit your lifestyle")
                    .font(tm.theme.typo.sub)
                    .foregroundColor(tm.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Action buttons
            if editingState == .editing {
                HStack(spacing: 12) {
                    Button {
                        onPreview()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Preview Changes")
                                .font(tm.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(tm.theme.palette.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(tm.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

// MARK: - Coach Messages View

private struct CoachMessagesView: View {
    @Environment(\.themeManager) private var tm
    let messages: [CoachMessage]
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(messages) { message in
                    CoachMessageCard(
                        message: message,
                        onDismiss: onDismiss
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Coach Message Card

private struct CoachMessageCard: View {
    @Environment(\.themeManager) private var tm
    let message: CoachMessage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: message.type.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(message.type.color)
                
                Text(message.title)
                    .font(tm.theme.typo.body.weight(.semibold))
                    .foregroundColor(tm.theme.palette.textPrimary)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Message
            Text(message.message)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
                .multilineTextAlignment(.leading)
            
            // Action button
            if let actionTitle = message.actionTitle, let action = message.action {
                Button {
                    action()
                } label: {
                    Text(actionTitle)
                        .font(tm.theme.typo.body.weight(.medium))
                        .foregroundColor(message.type.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(message.type.color.opacity(0.1))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(message.type.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(message.type.color.opacity(0.2), lineWidth: 1)
                )
        )
        .frame(maxWidth: 300)
    }
}

// MARK: - Time of Day Selector

private struct TimeOfDaySelector: View {
    @Environment(\.themeManager) private var tm
    @Binding var selectedTimeOfDay: TimeOfDay
    let editingState: RoutineEditingState
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimeOfDay.allCases, id: \.self) { timeOfDay in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTimeOfDay = timeOfDay
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: iconNameForTimeOfDay(timeOfDay))
                            .font(.system(size: 16, weight: .semibold))
                        Text(timeOfDay.displayName)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(selectedTimeOfDay == timeOfDay ? .white : tm.theme.palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        selectedTimeOfDay == timeOfDay ?
                        tm.theme.palette.secondary :
                        Color.clear
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tm.theme.palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private func iconNameForTimeOfDay(_ timeOfDay: TimeOfDay) -> String {
        switch timeOfDay {
        case .morning:
            return "sun.max.fill"
        case .evening:
            return "moon.fill"
        case .weekly:
            return "calendar"
        }
    }
}

// MARK: - Editable Routine Section

private struct EditableRoutineSection: View {
    @Environment(\.themeManager) private var tm
    let timeOfDay: TimeOfDay
    let steps: [EditableRoutineStep]
    let editingService: RoutineEditingService
    let onStepTap: (EditableRoutineStep) -> Void
    let onAddStep: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Section header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(timeOfDay.displayName) Routine")
                            .font(tm.theme.typo.h2)
                            .foregroundColor(tm.theme.palette.textPrimary)
                        
                        Text("\(steps.count) steps")
                            .font(tm.theme.typo.caption)
                            .foregroundColor(tm.theme.palette.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        onAddStep()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add Step")
                                .font(tm.theme.typo.body.weight(.medium))
                        }
                        .foregroundColor(tm.theme.palette.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(tm.theme.palette.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Steps
                ForEach(steps.sorted { $0.order < $1.order }) { step in
                    EditableStepCard(
                        step: step,
                        editingService: editingService,
                        onTap: {
                            onStepTap(step)
                        }
                    )
                }
                
                // Empty state
                if steps.isEmpty {
                    EmptyRoutineState(
                        timeOfDay: timeOfDay,
                        onAddStep: onAddStep
                    )
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Empty Routine State

private struct EmptyRoutineState: View {
    @Environment(\.themeManager) private var tm
    let timeOfDay: TimeOfDay
    let onAddStep: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconNameForTimeOfDay(timeOfDay))
                .font(.system(size: 48, weight: .light))
                .foregroundColor(tm.theme.palette.textMuted)
            
            Text("No steps yet")
                .font(tm.theme.typo.h3)
                .foregroundColor(tm.theme.palette.textPrimary)
            
            Text("Add your first step to build your \(timeOfDay.displayName.lowercased()) routine")
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                onAddStep()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add First Step")
                        .font(tm.theme.typo.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(tm.theme.palette.secondary)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tm.theme.palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tm.theme.palette.separator, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private func iconNameForTimeOfDay(_ timeOfDay: TimeOfDay) -> String {
        switch timeOfDay {
        case .morning:
            return "sun.max"
        case .evening:
            return "moon"
        case .weekly:
            return "calendar"
        }
    }
}

// MARK: - Extensions

// MARK: - Preview

#Preview("EditRoutineView") {
    EditRoutineView(
        originalRoutine: nil,
        routineTrackingService: RoutineTrackingService()
    )
    .themed(ThemeManager())
}

