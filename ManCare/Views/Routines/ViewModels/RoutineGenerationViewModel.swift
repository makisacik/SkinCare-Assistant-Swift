//
//  RoutineGenerationViewModel.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Routine Generation View Model

@MainActor
final class RoutineGenerationViewModel: ObservableObject {
    // MARK: - Published Properties (UI State Only)
    @Published var isGenerating = false
    @Published var isSaving = false
    @Published var error: Error?
    @Published var generatedRoutine: RoutineResponse?
    @Published var savedRoutine: SavedRoutineModel?
    
    // MARK: - Dependencies
    private let routineService: RoutineServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        isGenerating || isSaving
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    var hasGeneratedRoutine: Bool {
        generatedRoutine != nil
    }
    
    // MARK: - Initialization
    
    init(routineService: RoutineServiceProtocol) {
        self.routineService = routineService
        print("🤖 RoutineGenerationViewModel initialized")
    }
    
    // MARK: - Generation Methods
    
    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) {
        isGenerating = true
        error = nil
        generatedRoutine = nil
        savedRoutine = nil
        
        Task {
            do {
                let routine = try await routineService.generateRoutine(
                    skinType: skinType,
                    concerns: concerns,
                    mainGoal: mainGoal,
                    fitzpatrickSkinTone: fitzpatrickSkinTone,
                    ageRange: ageRange,
                    region: region,
                    preferences: preferences,
                    lifestyle: lifestyle
                )
                
                await MainActor.run {
                    self.generatedRoutine = routine
                    self.isGenerating = false
                }
                
                print("✅ Routine generated successfully: \(routine.summary.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isGenerating = false
                }
                print("❌ Failed to generate routine: \(error)")
            }
        }
    }
    
    func generateAndSaveRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil
    ) {
        isGenerating = true
        error = nil
        generatedRoutine = nil
        savedRoutine = nil
        
        Task {
            do {
                let savedRoutine = try await routineService.generateAndSaveInitialRoutine(
                    skinType: skinType,
                    concerns: concerns,
                    mainGoal: mainGoal,
                    fitzpatrickSkinTone: fitzpatrickSkinTone,
                    ageRange: ageRange,
                    region: region,
                    preferences: preferences,
                    lifestyle: lifestyle
                )
                
                await MainActor.run {
                    self.savedRoutine = savedRoutine
                    self.isGenerating = false
                }
                
                print("✅ Routine generated and saved: \(savedRoutine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isGenerating = false
                }
                print("❌ Failed to generate and save routine: \(error)")
            }
        }
    }
    
    // MARK: - Save Methods
    
    func saveGeneratedRoutine() {
        guard let routine = generatedRoutine else {
            error = RoutineGenerationError.noRoutineToSave
            return
        }
        
        isSaving = true
        error = nil
        savedRoutine = nil
        
        Task {
            do {
                let savedRoutine = try await routineService.saveInitialRoutine(from: routine)
                
                await MainActor.run {
                    self.savedRoutine = savedRoutine
                    self.isSaving = false
                }
                
                print("✅ Generated routine saved: \(savedRoutine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isSaving = false
                }
                print("❌ Failed to save generated routine: \(error)")
            }
        }
    }
    
    func saveRoutineTemplate(_ template: RoutineTemplate) {
        isSaving = true
        error = nil
        savedRoutine = nil
        
        Task {
            do {
                let savedRoutine = try await routineService.saveRoutine(template)
                
                await MainActor.run {
                    self.savedRoutine = savedRoutine
                    self.isSaving = false
                }
                
                print("✅ Routine template saved: \(savedRoutine.title)")
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isSaving = false
                }
                print("❌ Failed to save routine template: \(error)")
            }
        }
    }
    
    // MARK: - State Management
    
    func clearError() {
        error = nil
    }
    
    func reset() {
        isGenerating = false
        isSaving = false
        error = nil
        generatedRoutine = nil
        savedRoutine = nil
        print("🔄 RoutineGenerationViewModel reset")
    }
    
    // MARK: - Validation
    
    func canGenerateRoutine(
        skinType: SkinType?,
        concerns: Set<Concern>?,
        mainGoal: MainGoal?,
        fitzpatrickSkinTone: FitzpatrickSkinTone?,
        ageRange: AgeRange?,
        region: Region?
    ) -> Bool {
        return skinType != nil && 
               concerns != nil && 
               !concerns!.isEmpty && 
               mainGoal != nil &&
               fitzpatrickSkinTone != nil &&
               ageRange != nil &&
               region != nil
    }
    
    func validateGenerationParameters(
        skinType: SkinType?,
        concerns: Set<Concern>?,
        mainGoal: MainGoal?,
        fitzpatrickSkinTone: FitzpatrickSkinTone?,
        ageRange: AgeRange?,
        region: Region?
    ) -> RoutineGenerationError? {
        if skinType == nil {
            return .missingSkinType
        }
        
        if concerns == nil || concerns!.isEmpty {
            return .missingConcerns
        }
        
        if mainGoal == nil {
            return .missingMainGoal
        }
        
        if fitzpatrickSkinTone == nil {
            return .missingFitzpatrickSkinTone
        }
        
        if ageRange == nil {
            return .missingAgeRange
        }
        
        if region == nil {
            return .missingRegion
        }
        
        return nil
    }
}

// MARK: - Supporting Types

enum RoutineGenerationError: LocalizedError {
    case noRoutineToSave
    case missingSkinType
    case missingConcerns
    case missingMainGoal
    case missingFitzpatrickSkinTone
    case missingAgeRange
    case missingRegion
    case generationFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .noRoutineToSave:
            return "No routine available to save"
        case .missingSkinType:
            return "Please select your skin type"
        case .missingConcerns:
            return "Please select at least one skin concern"
        case .missingMainGoal:
            return "Please select your main skincare goal"
        case .missingFitzpatrickSkinTone:
            return "Please select your skin tone"
        case .missingAgeRange:
            return "Please select your age range"
        case .missingRegion:
            return "Please select your region"
        case .generationFailed:
            return "Failed to generate routine"
        case .saveFailed:
            return "Failed to save routine"
        }
    }
}

// MARK: - Preview Support

#if DEBUG
extension RoutineGenerationViewModel {
    static let preview: RoutineGenerationViewModel = {
        let mockService = ServiceFactory.shared.createMockRoutineService()
        let vm = RoutineGenerationViewModel(routineService: mockService)
        // Add mock data for previews
        return vm
    }()
}
#endif
