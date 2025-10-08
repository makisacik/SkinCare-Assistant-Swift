//
//  MenstruationCycleModels.swift
//  ManCare
//
//  Created for menstruation cycle tracking feature
//

import Foundation
import SwiftUI

// MARK: - Menstruation Cycle Phase

enum CyclePhase: String, CaseIterable, Identifiable, Codable {
    case menstrual
    case follicular
    case ovulation
    case luteal
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .menstrual: return "Menstrual"
        case .follicular: return "Follicular"
        case .ovulation: return "Ovulation"
        case .luteal: return "Luteal"
        }
    }
    
    var description: String {
        switch self {
        case .menstrual: return "Days 1-5"
        case .follicular: return "Days 6-13"
        case .ovulation: return "Days 14-16"
        case .luteal: return "Days 17-28"
        }
    }
    
    var skincareTip: String {
        switch self {
        case .menstrual:
            return "Your skin may be more sensitive. Focus on gentle, hydrating products and avoid harsh treatments."
        case .follicular:
            return "Your skin is glowing! This is a great time to try new products or treatments."
        case .ovulation:
            return "Skin looks its best! Maintain your routine and enjoy your natural glow."
        case .luteal:
            return "Oil production increases. Use lighter moisturizers and add clay masks to control shine."
        }
    }
    
    var iconName: String {
        switch self {
        case .menstrual: return "drop.fill"
        case .follicular: return "sparkles"
        case .ovulation: return "sun.max.fill"
        case .luteal: return "moon.fill"
        }
    }
    
    // Theme colors for the cycle wheel
    var gradientColors: [Color] {
        switch self {
        case .menstrual:
            return [
                ThemeManager.shared.theme.palette.error.opacity(0.3),
                ThemeManager.shared.theme.palette.error.opacity(0.2)
            ]
        case .follicular:
            return [
                ThemeManager.shared.theme.palette.success.opacity(0.3),
                ThemeManager.shared.theme.palette.success.opacity(0.2)
            ]
        case .ovulation:
            return [
                ThemeManager.shared.theme.palette.warning.opacity(0.3),
                ThemeManager.shared.theme.palette.warning.opacity(0.2)
            ]
        case .luteal:
            return [
                ThemeManager.shared.theme.palette.primary.opacity(0.3),
                ThemeManager.shared.theme.palette.primary.opacity(0.2)
            ]
        }
    }
    
    var mainColor: Color {
        switch self {
        case .menstrual: return ThemeManager.shared.theme.palette.error
        case .follicular: return ThemeManager.shared.theme.palette.success
        case .ovulation: return ThemeManager.shared.theme.palette.warning
        case .luteal: return ThemeManager.shared.theme.palette.primary
        }
    }
}

// MARK: - Cycle Data

struct CycleData: Codable {
    var lastPeriodStartDate: Date
    var averageCycleLength: Int // days
    var periodLength: Int // days
    
    init(lastPeriodStartDate: Date = Date(), averageCycleLength: Int = 28, periodLength: Int = 5) {
        self.lastPeriodStartDate = lastPeriodStartDate
        self.averageCycleLength = averageCycleLength
        self.periodLength = periodLength
    }
    
    // Calculate current day in cycle
    func currentDayInCycle(for date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: lastPeriodStartDate, to: date).day ?? 0
        let dayInCycle = (daysSinceStart % averageCycleLength) + 1
        return max(1, min(dayInCycle, averageCycleLength))
    }
    
    // Get current phase based on day in cycle
    func currentPhase(for date: Date = Date()) -> CyclePhase {
        let day = currentDayInCycle(for: date)
        
        if day <= periodLength {
            return .menstrual
        } else if day <= 13 {
            return .follicular
        } else if day <= 16 {
            return .ovulation
        } else {
            return .luteal
        }
    }
    
    // Calculate progress through current phase (0.0 to 1.0)
    func phaseProgress(for date: Date = Date()) -> Double {
        let day = currentDayInCycle(for: date)
        let phase = currentPhase(for: date)
        
        switch phase {
        case .menstrual:
            return Double(day - 1) / Double(periodLength)
        case .follicular:
            return Double(day - periodLength) / Double(13 - periodLength)
        case .ovulation:
            return Double(day - 14) / 3.0
        case .luteal:
            return Double(day - 17) / Double(averageCycleLength - 17)
        }
    }
}

// MARK: - Cycle Store

class CycleStore: ObservableObject {
    @Published var cycleData: CycleData
    
    private let storageKey = "user_cycle_data"
    
    init() {
        // Load saved data or create default
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(CycleData.self, from: data) {
            self.cycleData = decoded
        } else {
            // Default example data for demonstration
            // Set last period start to 10 days ago for demo purposes
            let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
            self.cycleData = CycleData(lastPeriodStartDate: tenDaysAgo)
            save()
        }
    }
    
    func updateCycleData(_ newData: CycleData) {
        cycleData = newData
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(cycleData) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
