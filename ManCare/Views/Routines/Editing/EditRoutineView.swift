//
//  EditRoutineView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// Helper struct for navigation
struct AddStepDestination: Hashable {
    let timeOfDay: TimeOfDay
}

struct EditRoutineView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var editingService: RoutineEditingService
    @State private var selectedTimeOfDay: TimeOfDay
    @State private var navigationPath = NavigationPath()
    
    let onRoutineUpdated: ((RoutineResponse) -> Void)?

    init(savedRoutine: SavedRoutineModel, completionViewModel: RoutineCompletionViewModel, initialTimeOfDay: TimeOfDay = .morning, onRoutineUpdated: ((RoutineResponse) -> Void)? = nil) {
        self._editingService = StateObject(wrappedValue: RoutineEditingService(savedRoutine: savedRoutine, completionViewModel: completionViewModel))
        self._selectedTimeOfDay = State(initialValue: initialTimeOfDay)
        self.onRoutineUpdated = onRoutineUpdated
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Modern header
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            editingService.cancelEditing()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

                        Spacer()

                        Text(L10n.Routines.Editing.title)
                            .font(ThemeManager.shared.theme.typo.h2)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Spacer()

                        Button(L10n.Routines.Editing.save) {
                            Task {
                                if let updatedRoutine = await editingService.saveRoutine() {
                                    onRoutineUpdated?(updatedRoutine)
                                }
                                dismiss()
                            }
                        }
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(ThemeManager.shared.theme.palette.cardBackground)
                
                // Time of Day Selector (only Morning and Evening)
                HStack(spacing: 12) {
                    ForEach([TimeOfDay.morning, TimeOfDay.evening], id: \.self) { timeOfDay in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTimeOfDay = timeOfDay
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: iconNameForTimeOfDay(timeOfDay))
                                    .font(.system(size: 18, weight: .semibold))
                                Text(timeOfDay.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(selectedTimeOfDay == timeOfDay ? ThemeManager.shared.theme.palette.onPrimary : ThemeManager.shared.theme.palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedTimeOfDay == timeOfDay ?
                                        ThemeManager.shared.theme.palette.secondary :
                                        ThemeManager.shared.theme.palette.accentBackground
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedTimeOfDay == timeOfDay ?
                                        ThemeManager.shared.theme.palette.secondary :
                                        ThemeManager.shared.theme.palette.separator,
                                        lineWidth: selectedTimeOfDay == timeOfDay ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Content
                TabView(selection: $selectedTimeOfDay) {
                    // Morning Routine
                    EditableRoutineSection(
                        timeOfDay: .morning,
                        steps: editingService.editableRoutine.morningSteps,
                        editingService: editingService,
                        navigationPath: $navigationPath
                    )
                    .tag(TimeOfDay.morning)
                    
                    // Evening Routine
                    EditableRoutineSection(
                        timeOfDay: .evening,
                        steps: editingService.editableRoutine.eveningSteps,
                        editingService: editingService,
                        navigationPath: $navigationPath
                    )
                    .tag(TimeOfDay.evening)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(ThemeManager.shared.theme.palette.cardBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: EditableRoutineStep.self) { step in
                StepDetailEditView(
                    step: step,
                    editingService: editingService
                )
            }
            .navigationDestination(for: AddStepDestination.self) { destination in
                AddStepView(
                    timeOfDay: destination.timeOfDay,
                    editingService: editingService
                )
            }
            .onAppear {
                editingService.startEditing()
            }
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
    
    let timeOfDay: TimeOfDay
    let steps: [EditableRoutineStep]
    let editingService: RoutineEditingService
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                // Section header with add button
                HStack {
                    Text(L10n.Routines.Editing.routineTitle(timeOfDay.displayName))
                        .font(ThemeManager.shared.theme.typo.h2)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        navigationPath.append(AddStepDestination(timeOfDay: timeOfDay))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(L10n.Routines.Editing.add)
                                .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                        }
                        .foregroundColor(ThemeManager.shared.theme.palette.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.12))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // Steps
                ForEach(steps.sorted { $0.order < $1.order }) { step in
                    EditableStepCard(
                        step: step,
                        editingService: editingService,
                        onTap: {
                            navigationPath.append(step)
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: steps.map { $0.order })
                
                // Empty state
                if steps.isEmpty {
                    EmptyRoutineState(
                        timeOfDay: timeOfDay,
                        navigationPath: $navigationPath
                    )
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Empty Routine State

private struct EmptyRoutineState: View {
    
    let timeOfDay: TimeOfDay
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconNameForTimeOfDay(timeOfDay))
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(L10n.Routines.Editing.noStepsYet)
                    .font(ThemeManager.shared.theme.typo.h2)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                Text(L10n.Routines.Editing.addFirstStepDescription(timeOfDay.displayName.lowercased()))
                    .font(ThemeManager.shared.theme.typo.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                navigationPath.append(AddStepDestination(timeOfDay: timeOfDay))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text(L10n.Routines.Editing.addFirstStep)
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                }
                .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.secondary)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeManager.shared.theme.palette.accentBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(ThemeManager.shared.theme.palette.separator, lineWidth: 1, antialiased: true)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 40)
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

#if DEBUG
#Preview("EditRoutineView") {
    EditRoutineView(
        savedRoutine: SavedRoutineModel.preview,
        completionViewModel: RoutineCompletionViewModel.preview,
        onRoutineUpdated: nil
    )
}
#endif