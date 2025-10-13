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
                            Text("Adaptive Mode")
                                .font(.headline)

                            Text("Automatically adjust routine based on context")
                                .font(.caption)
                                .foregroundColor(theme.theme.palette.textSecondary)
                        }
                    }
                    .tint(theme.theme.palette.primary)
                } header: {
                    Text("Adaptation")
                } footer: {
                    Text("When enabled, your routine will adapt based on the selected context type.")
                }

                // Adaptation Type Selection
                if adaptationEnabled {
                    Section {
                        Picker("Adaptation Type", selection: $selectedAdaptationType) {
                            ForEach(AdaptationType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        
                        // Show description for selected type
                        Text(selectedAdaptationType.description)
                            .font(.caption)
                            .foregroundColor(theme.theme.palette.textSecondary)
                    } header: {
                        Text("Type")
                    } footer: {
                        adaptationTypeFooter
                    }

                    // Preview Section
                    Section {
                        adaptationPreview
                    } header: {
                        Text("Preview")
                    }
                }
            }
            .navigationTitle("Adaptation Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveSettings()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private var adaptationTypeFooter: some View {
        switch selectedAdaptationType {
        case .cycle:
            Text("Your routine will adapt based on your menstruation cycle phase.")
        case .seasonal:
            Text("Your routine will adapt based on real-time weather including UV index, humidity, wind, and temperature. Location permission required.")
        case .skinState:
            Text("Your routine will adapt based on your current skin condition.")
        }
    }

    @ViewBuilder
    private var adaptationPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: selectedAdaptationType == .cycle ? "drop.fill" : "sun.max.fill")
                    .foregroundColor(theme.theme.palette.primary)

                Text("Today's Adaptation")
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
            return "Your routine will be customized based on your current cycle phase, with emphasis on gentle care during sensitive phases and intensive treatments during resilient phases."
        case .seasonal:
            return "Your routine will adapt based on real-time weather conditions including UV index, humidity, wind, and temperature. Get SPF recommendations, texture adjustments, and active ingredient warnings tailored to today's weather."
        case .skinState:
            return "Your routine will respond to your current skin condition, adapting to breakouts, dryness, or sensitivity."
        }
    }

    private func saveSettings() async {
        isSaving = true
        defer { isSaving = false }

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
            title: "Morning Glow",
            description: "Start your day fresh",
            category: .all,
            stepCount: 5,
            duration: "10 min",
            difficulty: .beginner,
            tags: ["hydrating"],
            morningSteps: ["Cleanser", "Serum", "Moisturizer"],
            eveningSteps: [],
            benefits: ["Hydrated skin"],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist"
        ),
        isActive: true,
        adaptationEnabled: false
    )

    return AdaptationSettingsView(
        routine: mockRoutine,
        routineService: ServiceFactory.shared.createRoutineService()
    )
    .environmentObject(ThemeManager.shared)
}

