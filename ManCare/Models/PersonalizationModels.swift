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
        case .type1: return "Type I - Very Fair"
        case .type2: return "Type II - Fair"
        case .type3: return "Type III - Light Olive"
        case .type4: return "Type IV - Moderate Brown"
        case .type5: return "Type V - Dark Brown"
        case .type6: return "Type VI - Very Dark"
        }
    }
    
    var description: String {
        switch self {
        case .type1: return "Always burns, never tans"
        case .type2: return "Usually burns, tans minimally"
        case .type3: return "Sometimes burns, tans gradually"
        case .type4: return "Rarely burns, tans easily"
        case .type5: return "Very rarely burns, tans very easily"
        case .type6: return "Never burns, tans very easily"
        }
    }
    
    var uvSensitivity: String {
        switch self {
        case .type1: return "Extremely high"
        case .type2: return "High"
        case .type3: return "Moderate"
        case .type4: return "Low"
        case .type5: return "Very low"
        case .type6: return "Minimal"
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
        case .teens: return "Teens (13-19)"
        case .twenties: return "20s"
        case .thirties: return "30s"
        case .forties: return "40s"
        case .fifties: return "50s"
        case .sixtiesPlus: return "60+"
        }
    }
    
    var description: String {
        switch self {
        case .teens: return "Focus on prevention and gentle care"
        case .twenties: return "Build healthy habits and prevent early aging"
        case .thirties: return "Address first signs of aging"
        case .forties: return "Target fine lines and skin texture"
        case .fifties: return "Combat deeper wrinkles and loss of firmness"
        case .sixtiesPlus: return "Maintain skin health and hydration"
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
        case .tropical: return "Tropical"
        case .subtropical: return "Subtropical"
        case .temperate: return "Temperate"
        case .continental: return "Continental"
        case .mediterranean: return "Mediterranean"
        case .arctic: return "Arctic/Cold"
        case .desert: return "Desert"
        case .mountain: return "Mountain/High Altitude"
        }
    }
    
    var description: String {
        switch self {
        case .tropical: return "Hot, humid climate year-round"
        case .subtropical: return "Warm, humid summers, mild winters"
        case .temperate: return "Moderate temperatures, four seasons"
        case .continental: return "Hot summers, cold winters"
        case .mediterranean: return "Hot, dry summers, mild winters"
        case .arctic: return "Very cold, dry climate"
        case .desert: return "Hot, dry climate with low humidity"
        case .mountain: return "High altitude, intense UV exposure"
        }
    }
    
    var averageUVIndex: String {
        switch self {
        case .tropical: return "Very High (8-11)"
        case .subtropical: return "High (6-8)"
        case .temperate: return "Moderate (3-6)"
        case .continental: return "Moderate to High (4-7)"
        case .mediterranean: return "High (6-9)"
        case .arctic: return "Low to Moderate (1-4)"
        case .desert: return "Very High (8-11)"
        case .mountain: return "Extreme (9-12)"
        }
    }
    
    var humidityLevel: String {
        switch self {
        case .tropical: return "Very High"
        case .subtropical: return "High"
        case .temperate: return "Moderate"
        case .continental: return "Low to Moderate"
        case .mediterranean: return "Low"
        case .arctic: return "Very Low"
        case .desert: return "Very Low"
        case .mountain: return "Low"
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
        case .arctic: return Color(red: 0.8, green: 0.9, blue: 1.0) // Light blue
        case .desert: return Color(red: 0.9, green: 0.7, blue: 0.3) // Sandy
        case .mountain: return Color(red: 0.5, green: 0.3, blue: 0.2) // Brown
        }
    }

    var temperatureLevel: String {
        switch self {
        case .tropical: return "Hot & Humid"
        case .subtropical: return "Warm & Humid"
        case .temperate: return "Moderate"
        case .continental: return "Hot/Cold"
        case .mediterranean: return "Warm & Dry"
        case .arctic: return "Very Cold"
        case .desert: return "Hot & Dry"
        case .mountain: return "Cool & Dry"
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
