//
//  AdaptationSettingsView.swift
//  ManCare
//
//  Settings view for managing routine adaptation
//

import SwiftUI

struct AdaptationSettingsView: View {
    let routine: SavedRoutineModel
    let routineService: RoutineServiceProtocol
    @Environment(\.dismiss) var dismiss

    @State private var adaptationEnabled: Bool
    @State private var selectedAdaptationType: AdaptationType
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    @EnvironmentObject var theme: ThemeManager
    @ObservedObject private var premiumManager = PremiumManager.shared

    init(routine: SavedRoutineModel, routineService: RoutineServiceProtocol) {
        self.routine = routine
        self.routineService = routineService
        _adaptationEnabled = State(initialValue: routine.adaptationEnabled)
        _selectedAdaptationType = State(initialValue: routine.adaptationType ?? .cycle)
    }

    var body: some View {
        NavigationView {
            Form {
                // Adaptation Toggle Section
                Section {
                    Toggle(isOn: $adaptationEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Routines.Adaptation.adaptiveMode)
                                .font(.headline)

                            Text(L10n.Routines.Adaptation.autoAdjust)
                                .font(.caption)
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }
                    }
                    .tint(theme.theme.palette.primary)
                } header: {
                    Text(L10n.Routines.Adaptation.adaptation)
                } footer: {
                    Text(L10n.Routines.Adaptation.whenEnabled)
                }

                // Adaptation Type Selection
                if adaptationEnabled {
                    Section {
                        Picker(L10n.Routines.AdaptationSettings.adaptationType, selection: $selectedAdaptationType) {
                            ForEach(AdaptationType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        
                        // Show description for selected type
                        Text(selectedAdaptationType.description)
                            .font(.caption)
                            .foregroundColor(theme.theme.palette.textSecondary)
                    } header: {
                        Text(L10n.Routines.Adaptation.type)
                    } footer: {
                        adaptationTypeFooter
                    }

                    // Preview Section
                    Section {
                        adaptationPreview
                    } header: {
                        Text(L10n.Routines.Adaptation.preview)
                    }
                }
            }
            .navigationTitle(L10n.Routines.AdaptationSettings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Routines.AdaptationSettings.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Routines.AdaptationSettings.save) {
                        Task {
                            await saveSettings()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .alert(L10n.Routines.AdaptationSettings.error, isPresented: $showError) {
                Button(L10n.Routines.AdaptationSettings.ok, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private var adaptationTypeFooter: some View {
        switch selectedAdaptationType {
        case .cycle:
            Text(L10n.Routines.Adaptation.cycleDescription)
        case .seasonal:
            Text(L10n.Routines.Adaptation.weatherDescription)
        case .skinState:
            Text(L10n.Routines.Adaptation.skinStateDescription)
        }
    }

    @ViewBuilder
    private var adaptationPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: selectedAdaptationType == .cycle ? "drop.fill" : "sun.max.fill")
                    .foregroundColor(theme.theme.palette.primary)

                Text(L10n.Routines.Adaptation.todaysAdaptation)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(previewText)
                .font(.caption)
                .foregroundColor(theme.theme.palette.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.theme.palette.primary.opacity(0.1))
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .padding(.horizontal)
    }

    private var previewText: String {
        switch selectedAdaptationType {
        case .cycle:
            return L10n.Routines.AdaptationSettings.cyclePreview
        case .seasonal:
            return L10n.Routines.AdaptationSettings.weatherPreview
        case .skinState:
            return L10n.Routines.AdaptationSettings.skinStatePreview
        }
    }

    private func saveSettings() async {
        isSaving = true
        defer { isSaving = false }

        // Check premium requirements for cycle adaptation
        if adaptationEnabled && selectedAdaptationType == .cycle {
            if !premiumManager.canUseCycleAdaptation() {
                await MainActor.run {
                    errorMessage = L10n.Routines.AdaptationSettings.premiumRequired
                    showError = true
                }
                return
            }
        }

        do {
            try await routineService.toggleAdaptation(
                for: routine,
                enabled: adaptationEnabled,
                type: adaptationEnabled ? selectedAdaptationType : nil
            )

            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockRoutine = SavedRoutineModel(
        from: RoutineTemplate(
            id: UUID(),
            routineId: nil,
            title: "Morning Glow",
            description: "Start your day fresh",
            category: .all,
            duration: "10 min",
            difficulty: .beginner,
            tags: ["hydrating"],
            morningSteps: [
                TemplateRoutineStep(title: "Cleanser", why: "Cleanse skin", how: "Apply gently", productType: "cleanser"),
                TemplateRoutineStep(title: "Serum", why: "Treat skin", how: "Pat in", productType: "faceSerum"),
                TemplateRoutineStep(title: "Moisturizer", why: "Hydrate skin", how: "Apply evenly", productType: "moisturizer")
            ],
            eveningSteps: [],
            benefits: ["Hydrated skin"],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist",
            translations: nil
        ),
        isActive: true,
        adaptationEnabled: false
    )

    AdaptationSettingsView(
        routine: mockRoutine,
        routineService: ServiceFactory.shared.createRoutineService()
    )
    .environmentObject(ThemeManager.shared)
}

