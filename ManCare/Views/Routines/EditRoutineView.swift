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
    
    init(originalRoutine: RoutineResponse?, routineTrackingService: RoutineTrackingService) {
        self._editingService = StateObject(wrappedValue: RoutineEditingService(originalRoutine: originalRoutine, routineTrackingService: routineTrackingService))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Simple header
                HStack {
                    Button("Cancel") {
                        editingService.cancelEditing()
                        dismiss()
                    }
                    .foregroundColor(tm.theme.palette.textSecondary)
                    
                    Spacer()
                    
                    Text("Edit Routine")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        Task {
                            await editingService.saveRoutine()
                            dismiss()
                        }
                    }
                    .foregroundColor(tm.theme.palette.secondary)
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Time of Day Selector
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
                            .foregroundColor(selectedTimeOfDay == timeOfDay ? tm.theme.palette.textInverse : tm.theme.palette.textSecondary)
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
                .padding(.bottom, 16)
                
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
            .background(tm.theme.palette.cardBackground.ignoresSafeArea())
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
        .onAppear {
            editingService.startEditing()
        }
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
                // Section header with add button
                HStack {
                    Text("\(timeOfDay.displayName) Routine")
                        .font(tm.theme.typo.h2)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    
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
                .foregroundColor(tm.theme.palette.onPrimary)
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
                .fill(tm.theme.palette.cardBackground)
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

// MARK: - Preview

#Preview("EditRoutineView") {
    EditRoutineView(
        originalRoutine: nil,
        routineTrackingService: RoutineTrackingService()
    )
}