//
//  WeatherModels.swift
//  ManCare
//
//  Created for weather-based routine adaptation
//

import Foundation
import SwiftUI

// MARK: - Weather Data

struct WeatherData: Codable, Equatable {
    let uvIndex: Int
    let humidity: Double  // 0-100%
    let windSpeed: Double // km/h
    let temperature: Double // Celsius
    let hasSnow: Bool
    let timestamp: Date
    let condition: String? // Optional weather condition description

    var uvLevel: UVLevel {
        UVLevel.from(uvIndex: uvIndex)
    }

    var isStale: Bool {
        Date().timeIntervalSince(timestamp) > 3600 // 1 hour
    }

    init(uvIndex: Int, humidity: Double, windSpeed: Double, temperature: Double, hasSnow: Bool, timestamp: Date = Date(), condition: String? = nil) {
        self.uvIndex = uvIndex
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.temperature = temperature
        self.hasSnow = hasSnow
        self.timestamp = timestamp
        self.condition = condition
    }
}

// MARK: - UV Level

enum UVLevel: String, Codable {
    case low        // 0-2
    case moderate   // 3-7
    case high       // 8-10
    case extreme    // 11+

    static func from(uvIndex: Int) -> UVLevel {
        switch uvIndex {
        case 0...2:
            return .low
        case 3...7:
            return .moderate
        case 8...10:
            return .high
        default:
            return .extreme
        }
    }

    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        case .extreme:
            return "Extreme"
        }
    }

    var color: Color {
        switch self {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .orange
        case .extreme:
            return .red
        }
    }

    var icon: String {
        switch self {
        case .low:
            return "sun.min"
        case .moderate:
            return "sun.max"
        case .high:
            return "sun.max.fill"
        case .extreme:
            return "exclamationmark.triangle.fill"
        }
    }

    var contextKey: String {
        switch self {
        case .low:
            return "uv_low"
        case .moderate:
            return "uv_moderate"
        case .high:
            return "uv_high"
        case .extreme:
            return "uv_extreme"
        }
    }
}

// MARK: - Weather Recommendation

struct WeatherRecommendation: Equatable {
    let spfLevel: String
    let textureAdjustment: String?
    let activeIngredientWarnings: [String]
    let generalTips: [String]

    init(spfLevel: String, textureAdjustment: String? = nil, activeIngredientWarnings: [String] = [], generalTips: [String] = []) {
        self.spfLevel = spfLevel
        self.textureAdjustment = textureAdjustment
        self.activeIngredientWarnings = activeIngredientWarnings
        self.generalTips = generalTips
    }

    static func from(weatherData: WeatherData) -> WeatherRecommendation {
        var spfLevel = "SPF 30"
        var textureAdjustment: String?
        var warnings: [String] = []
        var tips: [String] = []

        // UV Index recommendations
        switch weatherData.uvLevel {
        case .low:
            spfLevel = "SPF 30"
            tips.append("Actives like retinoids are safe to use")
        case .moderate:
            spfLevel = "SPF 30-50"
            tips.append("Antioxidant serum recommended")
        case .high:
            spfLevel = "SPF 50+"
            warnings.append("Avoid retinoids and acids in morning routine")
            tips.append("Reapply sunscreen every 2 hours")
            tips.append("Add antioxidant serum (Vit C, EGCG)")
        case .extreme:
            spfLevel = "SPF 50+"
            warnings.append("Skip retinoids and strong acids today")
            warnings.append("Reapply sunscreen every 1-2 hours")
            tips.append("Stay in shade during peak hours (10am-4pm)")
            tips.append("Wear protective clothing")
        }

        // Humidity adjustments
        if weatherData.humidity < 35 {
            textureAdjustment = "Use heavier moisturizers and occlusives"
            tips.append("Add hydrating toner or HA serum")
            warnings.append("Avoid over-exfoliating in dry conditions")
        } else if weatherData.humidity > 70 {
            textureAdjustment = "Use lighter gel moisturizers"
            tips.append("Avoid thick occlusives or heavy oils")
        }

        // Wind adjustments
        if weatherData.windSpeed > 25 {
            tips.append("Apply barrier cream or balm")
            warnings.append("Skip harsh peels and strong retinoids")
        }

        // Temperature adjustments
        if weatherData.temperature < 8 {
            if textureAdjustment == nil {
                textureAdjustment = "Use richer, more protective moisturizers"
            }
            tips.append("Add ceramide or squalane for barrier support")
        } else if weatherData.temperature > 30 {
            if textureAdjustment == nil {
                textureAdjustment = "Use lighter, mattifying products"
            }
            tips.append("Choose oil-free formulations")
        }

        // Snow reflection
        if weatherData.hasSnow {
            warnings.append("Snow reflects UV rays - treat as high UV day")
        }

        return WeatherRecommendation(
            spfLevel: spfLevel,
            textureAdjustment: textureAdjustment,
            activeIngredientWarnings: warnings,
            generalTips: tips
        )
    }
}

// MARK: - Weather Adaptation Context

struct WeatherAdaptationContext: Equatable {
    let weatherData: WeatherData
    let date: Date

    /// Get active context keys based on weather data thresholds
    /// Matches the thresholds defined in weather-adaptation-rules.json
    var contextKeys: [String] {
        var keys: [String] = []

        // UV context (thresholds from rules JSON)
        if weatherData.uvIndex >= 11 {
            keys.append("uv_extreme")
        } else if weatherData.uvIndex >= 8 {
            keys.append("uv_high")
        } else if weatherData.uvIndex >= 3 {
            keys.append("uv_moderate")
        } else {
            keys.append("uv_low")
        }

        // Humidity context (< 35% or > 70%)
        if weatherData.humidity < 35 {
            keys.append("low_humidity")
        } else if weatherData.humidity > 70 {
            keys.append("high_humidity")
        }

        // Wind context (> 25 km/h)
        if weatherData.windSpeed > 25 {
            keys.append("windy")
        }

        // Temperature context (< 8°C or > 26°C)
        if weatherData.temperature < 8 {
            keys.append("cold")
        } else if weatherData.temperature > 26 {
            keys.append("hot")
        }

        // Snow context
        if weatherData.hasSnow {
            keys.append("snow")
        }

        return keys
    }

    init(weatherData: WeatherData, date: Date = Date()) {
        self.weatherData = weatherData
        self.date = date
    }

    /// Check if all given contexts are active
    func matches(contexts: [String]) -> Bool {
        let activeKeys = Set(contextKeys)
        return contexts.allSatisfy { activeKeys.contains($0) }
    }
}

// MARK: - Location Permission State

enum LocationPermissionState: String {
    case notDetermined
    case denied
    case authorized
    case restricted

    var isAuthorized: Bool {
        return self == .authorized
    }
}

