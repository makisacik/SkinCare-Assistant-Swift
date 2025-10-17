//
//  EditProfileView.swift
//  ManCare
//
//  Created by AI Assistant on 6.10.2025.
//

import SwiftUI

struct EditProfileView: View {
    let initialProfile: UserProfile?
    let onCancel: () -> Void
    let onSave: (UserProfile) -> Void

    @State private var draft: UserProfileDraft
    @StateObject private var cycleStore = CycleStore()
    @State private var lastPeriodStartDate: Date
    @State private var averageCycleLength: Int
    @State private var periodLength: Int

    init(initialProfile: UserProfile?, onCancel: @escaping () -> Void, onSave: @escaping (UserProfile) -> Void) {
        self.initialProfile = initialProfile
        self.onCancel = onCancel
        self.onSave = onSave
        _draft = State(initialValue: UserProfileDraft(from: initialProfile))

        // Initialize cycle data with current values
        let store = CycleStore()
        _lastPeriodStartDate = State(initialValue: store.cycleData.lastPeriodStartDate)
        _averageCycleLength = State(initialValue: store.cycleData.averageCycleLength)
        _periodLength = State(initialValue: store.cycleData.periodLength)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(L10n.Myself.EditProfile.skin) {
                    Picker(L10n.Myself.EditProfile.skinType, selection: Binding(get: { draft.skinType ?? .normal }, set: { draft.skinType = $0 })) {
                        ForEach(SkinType.allCases) { Text($0.title).tag($0) }
                    }

                    Picker(L10n.Myself.EditProfile.fitzpatrickTone, selection: Binding(get: { draft.fitzpatrickSkinTone ?? .type3 }, set: { draft.fitzpatrickSkinTone = $0 })) {
                        ForEach(FitzpatrickSkinTone.allCases) { Text($0.title).tag($0) }
                    }

                    NavigationLink(L10n.Myself.EditProfile.concerns) {
                        ConcernsEditor(selections: $draft.concerns)
                    }
                }

                Section(L10n.Myself.EditProfile.goalAndPreferences) {
                    Picker(L10n.Myself.EditProfile.mainGoal, selection: Binding(get: { draft.mainGoal ?? .healthierOverall }, set: { draft.mainGoal = $0 })) {
                        ForEach(MainGoal.allCases) { Text($0.title).tag($0) }
                    }

                    PreferencesEditor(preferences: Binding(get: { draft.preferences ?? Preferences(fragranceFreeOnly: false, suitableForSensitiveSkin: false, naturalIngredients: false, crueltyFree: false, veganFriendly: false) }, set: { draft.preferences = $0 }))
                }

                Section(L10n.Myself.EditProfile.demographics) {
                    Picker(L10n.Myself.EditProfile.ageRange, selection: Binding(get: { draft.ageRange ?? .twenties }, set: { draft.ageRange = $0 })) {
                        ForEach(AgeRange.allCases) { Text($0.title).tag($0) }
                    }

                    Picker(L10n.Myself.EditProfile.regionClimate, selection: Binding(get: { draft.region ?? .temperate }, set: { draft.region = $0 })) {
                        ForEach(Region.allCases) { Text($0.title).tag($0) }
                    }
                }

                Section(L10n.Myself.EditProfile.menstruationCycle) {
                    DatePicker(L10n.Myself.EditProfile.lastPeriodStart,
                              selection: $lastPeriodStartDate,
                              in: ...Date(),
                              displayedComponents: .date)

                    Stepper(L10n.Myself.EditProfile.cycleLength(averageCycleLength),
                           value: $averageCycleLength,
                           in: 21...45)

                    Stepper(L10n.Myself.EditProfile.periodLength(periodLength),
                           value: $periodLength,
                           in: 2...10)

                    // Show current phase info
                    let currentData = CycleData(lastPeriodStartDate: lastPeriodStartDate,
                                               averageCycleLength: averageCycleLength,
                                               periodLength: periodLength)
                    let phase = currentData.currentPhase()
                    let dayInCycle = currentData.currentDayInCycle()

                    HStack {
                        Image(systemName: phase.iconName)
                            .foregroundColor(phase.mainColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Myself.EditProfile.currentPhase(phase.title))
                                .font(.subheadline)
                            Text(L10n.Myself.EditProfile.dayOfCycle(day: dayInCycle, total: averageCycleLength))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(L10n.Myself.EditProfile.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Myself.EditProfile.save) {
                        if let p = draft.toProfile() {
                            // Save profile
                            onSave(p)

                            // Save cycle data
                            let newCycleData = CycleData(
                                lastPeriodStartDate: lastPeriodStartDate,
                                averageCycleLength: averageCycleLength,
                                periodLength: periodLength
                            )
                            cycleStore.updateCycleData(newCycleData)
                        } else {
                            print("❌ EditProfileView: draft invalid on Save")
                        }
                    }
                        .disabled(!draft.isValid)
                }
            }
            .onAppear {
                // Initialize required fields with sensible defaults to enable Save
                if draft.skinType == nil { draft.skinType = .normal }
                if draft.mainGoal == nil { draft.mainGoal = .healthierOverall }
                if draft.fitzpatrickSkinTone == nil { draft.fitzpatrickSkinTone = .type3 }
                if draft.ageRange == nil { draft.ageRange = .twenties }
                if draft.region == nil { draft.region = .temperate }
            }
        }
    }
}

private struct ConcernsEditor: View {
    @Binding var selections: Set<Concern>

    var body: some View {
        List {
            ForEach(Concern.allCases) { c in
                MultipleSelectionRow(title: c.title, isSelected: selections.contains(c)) {
                    if selections.contains(c) { selections.remove(c) } else { selections.insert(c) }
                }
            }
        }
        .navigationTitle(L10n.Myself.EditProfile.concerns)
    }
}

private struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected { Image(systemName: "checkmark").foregroundColor(.accentColor) }
            }
        }
    }
}

private struct PreferencesEditor: View {
    @Binding var preferences: Preferences

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(L10n.Myself.EditProfile.Preferences.fragranceFree, isOn: Binding(get: { preferences.fragranceFreeOnly }, set: { preferences = Preferences(fragranceFreeOnly: $0, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle(L10n.Myself.EditProfile.Preferences.sensitiveSkin, isOn: Binding(get: { preferences.suitableForSensitiveSkin }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: $0, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle(L10n.Myself.EditProfile.Preferences.natural, isOn: Binding(get: { preferences.naturalIngredients }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: $0, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle(L10n.Myself.EditProfile.Preferences.crueltyFree, isOn: Binding(get: { preferences.crueltyFree }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: $0, veganFriendly: preferences.veganFriendly) }))
            Toggle(L10n.Myself.EditProfile.Preferences.vegan, isOn: Binding(get: { preferences.veganFriendly }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: $0) }))
        }
    }
}


