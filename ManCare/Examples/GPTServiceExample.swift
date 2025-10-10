//
//  GPTServiceExample.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Example Usage

/*
 Example usage of GPTService:

 let service = GPTService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
 // Uses gpt-4o-mini model by default for cost efficiency

 let req = ManCareRoutineRequest(
     selectedSkinType: "oily",
     selectedConcerns: ["acne", "blackheads", "largePores"],
     selectedMainGoal: "reduceBreakouts",
     selectedPreferences: .init(
         fragranceFreeOnly: true,
         suitableForSensitiveSkin: true,
         naturalIngredients: false,
         crueltyFree: true,
         veganFriendly: false
     ),
     lifestyle: .init(
         sleepQuality: "average",
         exerciseFrequency: "threeToFour",
         routineDepthPreference: "standard",
         sunResponse: "sometimes",
         outdoorHours: 2,
         smokes: false,
         drinksAlcohol: false,
         fragranceFree: nil,
         naturalPreference: nil,
         sensitiveSkin: nil
     ),
     locale: "en-US"
 )

 Task {
     do {
         let routine: RoutineResponse = try await service.generateRoutine(for: req, routineDepthFallback: "standard")
         // Update your UI/state with `routine`
         print("Routine version:", routine.version)
     } catch {
         // Handle + show a friendly error
         print("Failed:", error)
     }
 }
 */

// MARK: - Integration with App Models

extension GPTService {
    /// Convenience method to create a ManCareRoutineRequest from app models
    static func createRequest(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        fitzpatrickSkinTone: FitzpatrickSkinTone,
        ageRange: AgeRange,
        region: Region,
        routineDepth: RoutineDepth? = nil,
        preferences: Preferences?,
        lifestyle: LifestyleAnswers? = nil,
        locale: String = "en-US"
    ) -> ManCareRoutineRequest {

        let preferencesPayload = preferences.map { prefs in
            PreferencesPayload(
                fragranceFreeOnly: prefs.fragranceFreeOnly,
                suitableForSensitiveSkin: prefs.suitableForSensitiveSkin,
                naturalIngredients: prefs.naturalIngredients,
                crueltyFree: prefs.crueltyFree,
                veganFriendly: prefs.veganFriendly
            )
        }

        let lifestylePayload = lifestyle.map { ls in
            LifestylePayload(
                sleepQuality: ls.sleep?.rawValue,
                exerciseFrequency: ls.exercise?.rawValue,
                routineDepthPreference: ls.routineDepth?.rawValue,
                sunResponse: ls.sunResponse?.rawValue,
                outdoorHours: ls.outdoorHours,
                smokes: ls.smokes,
                drinksAlcohol: ls.drinksAlcohol,
                fragranceFree: ls.fragranceFree,
                naturalPreference: ls.naturalPreference,
                sensitiveSkin: ls.sensitiveSkin
            )
        }

        return ManCareRoutineRequest(
            selectedSkinType: skinType.rawValue,
            selectedConcerns: concerns.map { $0.rawValue },
            selectedMainGoal: mainGoal.rawValue,
            fitzpatrickSkinTone: fitzpatrickSkinTone.rawValue,
            ageRange: ageRange.rawValue,
            region: region.rawValue,
            routineDepth: routineDepth?.rawValue,
            selectedPreferences: preferencesPayload,
            lifestyle: lifestylePayload,
            locale: locale
        )
    }
}
