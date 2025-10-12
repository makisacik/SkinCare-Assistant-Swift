//
//  PersonalizedRoutineFlow.swift
//  ManCare
//
//  Simplified personalized routine creation using existing models
//

import SwiftUI

// MARK: - Personalized Routine Request

struct PersonalizedRoutineRequest {
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    let customDetails: String
}

// MARK: - Personalized Routine Preferences View

struct PersonalizedRoutinePreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var skinType: SkinType = .combination
    @State private var selectedConcerns: Set<Concern> = []
    @State private var mainGoal: MainGoal = .reduceBreakouts
    @State private var customDetails: String = ""
    
    let onGenerate: (PersonalizedRoutineRequest) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        skinTypeSection
                        concernsSection
                        goalSection
                        customDetailsSection
                        generateButton
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.shared.theme.palette.background,
                ThemeManager.shared.theme.palette.surface.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                
                Text("Create Your Personalized Routine")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Spacer()
            }
            
            Text("Tell us about your skin and preferences to get a custom routine tailored just for you")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var skinTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's your skin type?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(SkinType.allCases, id: \.self) { type in
                    Button(action: { skinType = type }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.iconName)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(skinType == type ? .white : ThemeManager.shared.theme.palette.primary)
                            
                            Text(type.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(skinType == type ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(skinType == type ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(skinType == type ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: skinType == type ? 0 : 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var concernsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are your main skin concerns?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Concern.allCases.filter { $0 != .none }, id: \.self) { concern in
                    Button(action: {
                        if selectedConcerns.contains(concern) {
                            selectedConcerns.remove(concern)
                        } else {
                            selectedConcerns.insert(concern)
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: concern.iconName)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(selectedConcerns.contains(concern) ? .white : ThemeManager.shared.theme.palette.primary)
                            
                            Text(concern.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedConcerns.contains(concern) ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedConcerns.contains(concern) ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedConcerns.contains(concern) ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: selectedConcerns.contains(concern) ? 0 : 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's your main skincare goal?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(MainGoal.allCases, id: \.self) { goal in
                    Button(action: { mainGoal = goal }) {
                        VStack(spacing: 8) {
                            Image(systemName: goal.iconName)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(mainGoal == goal ? .white : ThemeManager.shared.theme.palette.primary)
                            
                            Text(goal.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(mainGoal == goal ? .white : ThemeManager.shared.theme.palette.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(mainGoal == goal ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.surfaceAlt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(mainGoal == goal ? ThemeManager.shared.theme.palette.primary : ThemeManager.shared.theme.palette.border, lineWidth: mainGoal == goal ? 0 : 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var customDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any additional details?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            
            Text("Share any specific concerns, allergies, or preferences to help us create the perfect routine for you")
                .font(.system(size: 14))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            TextEditor(text: $customDetails)
                .frame(minHeight: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.surfaceAlt)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                        )
                )
                .font(.system(size: 16))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var generateButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            let request = PersonalizedRoutineRequest(
                skinType: skinType,
                concerns: selectedConcerns,
                mainGoal: mainGoal,
                customDetails: customDetails
            )
            
            onGenerate(request)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Generate My Routine")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primary,
                        ThemeManager.shared.theme.palette.primaryLight
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: ThemeManager.shared.theme.palette.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(selectedConcerns.isEmpty)
        .opacity(selectedConcerns.isEmpty ? 0.6 : 1.0)
    }
}


#Preview {
    PersonalizedRoutinePreferencesView { request in
        print("Generated request: \(request)")
    }
}
