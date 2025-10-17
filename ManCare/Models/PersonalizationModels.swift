//
//  PersonalizationModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Fitzpatrick Skin Tone Scale

enum FitzpatrickSkinTone: String, CaseIterable, Identifiable, Codable {
    case type1, type2, type3, type4, type5, type6
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .type1: return L10n.Onboarding.FitzpatrickTypes.type1
        case .type2: return L10n.Onboarding.FitzpatrickTypes.type2
        case .type3: return L10n.Onboarding.FitzpatrickTypes.type3
        case .type4: return L10n.Onboarding.FitzpatrickTypes.type4
        case .type5: return L10n.Onboarding.FitzpatrickTypes.type5
        case .type6: return L10n.Onboarding.FitzpatrickTypes.type6
        }
    }
    
    var description: String {
        switch self {
        case .type1: return L10n.Onboarding.FitzpatrickTypes.type1Description
        case .type2: return L10n.Onboarding.FitzpatrickTypes.type2Description
        case .type3: return L10n.Onboarding.FitzpatrickTypes.type3Description
        case .type4: return L10n.Onboarding.FitzpatrickTypes.type4Description
        case .type5: return L10n.Onboarding.FitzpatrickTypes.type5Description
        case .type6: return L10n.Onboarding.FitzpatrickTypes.type6Description
        }
    }
    
    var uvSensitivity: String {
        switch self {
        case .type1: return L10n.Onboarding.FitzpatrickTypes.type1UvSensitivity
        case .type2: return L10n.Onboarding.FitzpatrickTypes.type2UvSensitivity
        case .type3: return L10n.Onboarding.FitzpatrickTypes.type3UvSensitivity
        case .type4: return L10n.Onboarding.FitzpatrickTypes.type4UvSensitivity
        case .type5: return L10n.Onboarding.FitzpatrickTypes.type5UvSensitivity
        case .type6: return L10n.Onboarding.FitzpatrickTypes.type6UvSensitivity
        }
    }
    
    var recommendedSPF: Int {
        switch self {
        case .type1: return 50
        case .type2: return 30
        case .type3: return 30
        case .type4: return 15
        case .type5: return 15
        case .type6: return 15
        }
    }
    
    var iconName: String {
        switch self {
        case .type1: return "sun.max.fill"
        case .type2: return "sun.max"
        case .type3: return "sun.min"
        case .type4: return "sun.min.fill"
        case .type5: return "moon.fill"
        case .type6: return "moon"
        }
    }
    
    var skinColor: Color {
        switch self {
        case .type1: return Color(red: 0.95, green: 0.85, blue: 0.75) // Very fair
        case .type2: return Color(red: 0.90, green: 0.80, blue: 0.70) // Fair
        case .type3: return Color(red: 0.85, green: 0.75, blue: 0.65) // Light olive
        case .type4: return Color(red: 0.70, green: 0.60, blue: 0.50) // Moderate brown
        case .type5: return Color(red: 0.55, green: 0.45, blue: 0.35) // Dark brown
        case .type6: return Color(red: 0.40, green: 0.30, blue: 0.20) // Very dark
        }
    }
    
    var textColor: Color {
        switch self {
        case .type1, .type2, .type3: return Color.black  // Keep these as they're for skin tone representation
        case .type4, .type5, .type6: return Color.white  // Keep these as they're for skin tone representation
        }
    }
}

// MARK: - Age Range

enum AgeRange: String, CaseIterable, Identifiable, Codable {
    case teens, twenties, thirties, forties, fifties, sixtiesPlus
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .teens: return L10n.Onboarding.AgeRangeTypes.teens
        case .twenties: return L10n.Onboarding.AgeRangeTypes.twenties
        case .thirties: return L10n.Onboarding.AgeRangeTypes.thirties
        case .forties: return L10n.Onboarding.AgeRangeTypes.forties
        case .fifties: return L10n.Onboarding.AgeRangeTypes.fifties
        case .sixtiesPlus: return L10n.Onboarding.AgeRangeTypes.sixtiesPlus
        }
    }
    
    var description: String {
        switch self {
        case .teens: return L10n.Onboarding.AgeRangeTypes.teensDescription
        case .twenties: return L10n.Onboarding.AgeRangeTypes.twentiesDescription
        case .thirties: return L10n.Onboarding.AgeRangeTypes.thirtiesDescription
        case .forties: return L10n.Onboarding.AgeRangeTypes.fortiesDescription
        case .fifties: return L10n.Onboarding.AgeRangeTypes.fiftiesDescription
        case .sixtiesPlus: return L10n.Onboarding.AgeRangeTypes.sixtiesPlusDescription
        }
    }
    
    var iconName: String {
        switch self {
        case .teens: return "person.fill"
        case .twenties: return "person.2.fill"
        case .thirties: return "person.3.fill"
        case .forties: return "person.crop.circle.fill"
        case .fifties: return "person.crop.circle.badge.checkmark"
        case .sixtiesPlus: return "person.crop.circle.badge.plus"
        }
    }
}

// MARK: - Region/Climate

enum Region: String, CaseIterable, Identifiable, Codable {
    case tropical, subtropical, temperate, continental, mediterranean, arctic, desert, mountain
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .tropical: return L10n.Onboarding.RegionTypes.tropical
        case .subtropical: return L10n.Onboarding.RegionTypes.subtropical
        case .temperate: return L10n.Onboarding.RegionTypes.temperate
        case .continental: return L10n.Onboarding.RegionTypes.continental
        case .mediterranean: return L10n.Onboarding.RegionTypes.mediterranean
        case .arctic: return L10n.Onboarding.RegionTypes.arctic
        case .desert: return L10n.Onboarding.RegionTypes.desert
        case .mountain: return L10n.Onboarding.RegionTypes.mountain
        }
    }
    
    var description: String {
        switch self {
        case .tropical: return L10n.Onboarding.RegionTypes.tropicalDescription
        case .subtropical: return L10n.Onboarding.RegionTypes.subtropicalDescription
        case .temperate: return L10n.Onboarding.RegionTypes.temperateDescription
        case .continental: return L10n.Onboarding.RegionTypes.continentalDescription
        case .mediterranean: return L10n.Onboarding.RegionTypes.mediterraneanDescription
        case .arctic: return L10n.Onboarding.RegionTypes.arcticDescription
        case .desert: return L10n.Onboarding.RegionTypes.desertDescription
        case .mountain: return L10n.Onboarding.RegionTypes.mountainDescription
        }
    }
    
    var averageUVIndex: String {
        switch self {
        case .tropical: return L10n.Onboarding.RegionTypes.tropicalUvIndex
        case .subtropical: return L10n.Onboarding.RegionTypes.subtropicalUvIndex
        case .temperate: return L10n.Onboarding.RegionTypes.temperateUvIndex
        case .continental: return L10n.Onboarding.RegionTypes.continentalUvIndex
        case .mediterranean: return L10n.Onboarding.RegionTypes.mediterraneanUvIndex
        case .arctic: return L10n.Onboarding.RegionTypes.arcticUvIndex
        case .desert: return L10n.Onboarding.RegionTypes.desertUvIndex
        case .mountain: return L10n.Onboarding.RegionTypes.mountainUvIndex
        }
    }
    
    var humidityLevel: String {
        switch self {
        case .tropical: return L10n.Onboarding.RegionTypes.tropicalHumidity
        case .subtropical: return L10n.Onboarding.RegionTypes.subtropicalHumidity
        case .temperate: return L10n.Onboarding.RegionTypes.temperateHumidity
        case .continental: return L10n.Onboarding.RegionTypes.continentalHumidity
        case .mediterranean: return L10n.Onboarding.RegionTypes.mediterraneanHumidity
        case .arctic: return L10n.Onboarding.RegionTypes.arcticHumidity
        case .desert: return L10n.Onboarding.RegionTypes.desertHumidity
        case .mountain: return L10n.Onboarding.RegionTypes.mountainHumidity
        }
    }
    
    var iconName: String {
        switch self {
        case .tropical: return "leaf.fill"
        case .subtropical: return "sun.max.fill"
        case .temperate: return "cloud.sun.fill"
        case .continental: return "thermometer.sun.fill"
        case .mediterranean: return "sun.and.horizon.fill"
        case .arctic: return "snowflake"
        case .desert: return "sun.dust.fill"
        case .mountain: return "mountain.2.fill"
        }
    }

    var climateColor: Color {
        switch self {
        case .tropical: return Color(red: 0.2, green: 0.8, blue: 0.3) // Vibrant green
        case .subtropical: return Color(red: 0.4, green: 0.9, blue: 0.2) // Bright green
        case .temperate: return Color(red: 0.3, green: 0.6, blue: 0.9) // Blue
        case .continental: return Color(red: 0.8, green: 0.4, blue: 0.2) // Orange
        case .mediterranean: return Color(red: 1.0, green: 0.6, blue: 0.0) // Golden
        case .arctic: return Color(red: 0.3, green: 0.7, blue: 1.0) // Bright blue
        case .desert: return Color(red: 0.9, green: 0.7, blue: 0.3) // Sandy
        case .mountain: return Color(red: 0.5, green: 0.3, blue: 0.2) // Brown
        }
    }

    var temperatureLevel: String {
        switch self {
        case .tropical: return L10n.Onboarding.RegionTypes.tropicalTemperature
        case .subtropical: return L10n.Onboarding.RegionTypes.subtropicalTemperature
        case .temperate: return L10n.Onboarding.RegionTypes.temperateTemperature
        case .continental: return L10n.Onboarding.RegionTypes.continentalTemperature
        case .mediterranean: return L10n.Onboarding.RegionTypes.mediterraneanTemperature
        case .arctic: return L10n.Onboarding.RegionTypes.arcticTemperature
        case .desert: return L10n.Onboarding.RegionTypes.desertTemperature
        case .mountain: return L10n.Onboarding.RegionTypes.mountainTemperature
        }
    }
}

// MARK: - User Profile

struct UserProfile: Codable {
    let skinType: SkinType
    let concerns: Set<Concern>
    let mainGoal: MainGoal
    let fitzpatrickSkinTone: FitzpatrickSkinTone
    let ageRange: AgeRange
    let region: Region
    let preferences: Preferences?
    let lifestyle: LifestyleAnswers?
    
    init(skinType: SkinType,
         concerns: Set<Concern>,
         mainGoal: MainGoal,
         fitzpatrickSkinTone: FitzpatrickSkinTone,
         ageRange: AgeRange,
         region: Region,
         preferences: Preferences? = nil,
         lifestyle: LifestyleAnswers? = nil) {
        self.skinType = skinType
        self.concerns = concerns
        self.mainGoal = mainGoal
        self.fitzpatrickSkinTone = fitzpatrickSkinTone
        self.ageRange = ageRange
        self.region = region
        self.preferences = preferences
        self.lifestyle = lifestyle
    }
}
