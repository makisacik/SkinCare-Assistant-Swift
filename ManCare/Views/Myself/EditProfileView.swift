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
    let onGenerate: (UserProfile) -> Void

    @State private var draft: UserProfileDraft

    init(initialProfile: UserProfile?, onCancel: @escaping () -> Void, onSave: @escaping (UserProfile) -> Void, onGenerate: @escaping (UserProfile) -> Void) {
        self.initialProfile = initialProfile
        self.onCancel = onCancel
        self.onSave = onSave
        self.onGenerate = onGenerate
        _draft = State(initialValue: UserProfileDraft(from: initialProfile))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Skin") {
                    Picker("Skin Type", selection: Binding(get: { draft.skinType ?? .normal }, set: { draft.skinType = $0 })) {
                        ForEach(SkinType.allCases) { Text($0.title).tag($0) }
                    }

                    Picker("Fitzpatrick Tone", selection: Binding(get: { draft.fitzpatrickSkinTone ?? .type3 }, set: { draft.fitzpatrickSkinTone = $0 })) {
                        ForEach(FitzpatrickSkinTone.allCases) { Text($0.title).tag($0) }
                    }

                    NavigationLink("Concerns") {
                        ConcernsEditor(selections: $draft.concerns)
                    }
                }

                Section("Goal & Preferences") {
                    Picker("Main Goal", selection: Binding(get: { draft.mainGoal ?? .healthierOverall }, set: { draft.mainGoal = $0 })) {
                        ForEach(MainGoal.allCases) { Text($0.title).tag($0) }
                    }

                    PreferencesEditor(preferences: Binding(get: { draft.preferences ?? Preferences(fragranceFreeOnly: false, suitableForSensitiveSkin: false, naturalIngredients: false, crueltyFree: false, veganFriendly: false) }, set: { draft.preferences = $0 }))
                }

                Section("Demographics & Climate") {
                    Picker("Age Range", selection: Binding(get: { draft.ageRange ?? .twenties }, set: { draft.ageRange = $0 })) {
                        ForEach(AgeRange.allCases) { Text($0.title).tag($0) }
                    }

                    Picker("Region/Climate", selection: Binding(get: { draft.region ?? .temperate }, set: { draft.region = $0 })) {
                        ForEach(Region.allCases) { Text($0.title).tag($0) }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let p = draft.toProfile() {
                            onSave(p)
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
            .safeAreaInset(edge: .bottom) {
                Button {
                    if let p = draft.toProfile() { onGenerate(p) }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Create New Routine")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!draft.isValid)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
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
        .navigationTitle("Concerns")
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
            Toggle("Fragrance-free", isOn: Binding(get: { preferences.fragranceFreeOnly }, set: { preferences = Preferences(fragranceFreeOnly: $0, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle("Suitable for sensitive skin", isOn: Binding(get: { preferences.suitableForSensitiveSkin }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: $0, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle("Natural ingredients", isOn: Binding(get: { preferences.naturalIngredients }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: $0, crueltyFree: preferences.crueltyFree, veganFriendly: preferences.veganFriendly) }))
            Toggle("Cruelty-free", isOn: Binding(get: { preferences.crueltyFree }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: $0, veganFriendly: preferences.veganFriendly) }))
            Toggle("Vegan-friendly", isOn: Binding(get: { preferences.veganFriendly }, set: { preferences = Preferences(fragranceFreeOnly: preferences.fragranceFreeOnly, suitableForSensitiveSkin: preferences.suitableForSensitiveSkin, naturalIngredients: preferences.naturalIngredients, crueltyFree: preferences.crueltyFree, veganFriendly: $0) }))
        }
    }
}


