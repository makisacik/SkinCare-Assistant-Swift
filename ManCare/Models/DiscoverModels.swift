//
//  DiscoverModels.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import Foundation
import SwiftUI

// MARK: - Discover Content

struct DiscoverContent: Codable {
    let hero: HeroBanner
    let routines: [FreshRoutine]
    let seasonalPlaybook: SeasonalPlaybook
    let communityHeat: [TrendingRoutine]
    let miniGuides: [MiniGuide]?
    let lastUpdated: Date
}

// MARK: - Hero Banner

struct HeroBanner: Codable, Identifiable {
    var id: UUID {
        // Generate consistent ID from title for Identifiable conformance
        UUID(uuidString: title.hash.magnitude.description.padding(toLength: 32, withPad: "0", startingAt: 0)) ?? UUID()
    }
    
    let title: String
    let subtitle: String
    let ctaText: String
    let themeColor: String
    let startDate: Date
    let endDate: Date
    let ticker: TickerStats
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, ctaText, themeColor, startDate, endDate, ticker
    }
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    var gradientColors: [Color] {
        let baseColor = Color(hex: themeColor)
        return [
            baseColor.opacity(0.3),
            baseColor.opacity(0.15),
            ThemeManager.shared.theme.palette.background
        ]
    }
}

// MARK: - Ticker Stats

struct TickerStats: Codable {
    let routines: Int
    let guides: Int
    
    var displayText: String {
        "New this week: +\(routines) routines · +\(guides) guides"
    }
}

// MARK: - Fresh Routine

struct FreshRoutine: Codable, Identifiable {
    let id: UUID
    let templateId: UUID
    let badge: RoutineBadge
    let updatedAt: Date
    
    func shouldShow(relativeTo now: Date = Date()) -> Bool {
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: updatedAt, to: now).day ?? 0
        
        switch badge {
        case .new:
            return daysSinceUpdate <= 7
        case .updated:
            return daysSinceUpdate <= 14
        case .trending:
            return daysSinceUpdate <= 30
        }
    }
}

// MARK: - Routine Badge

enum RoutineBadge: String, Codable, CaseIterable {
    case new = "new"
    case updated = "updated"
    case trending = "trending"
    
    var displayText: String {
        switch self {
        case .new: return "New"
        case .updated: return "Updated"
        case .trending: return "Trending"
        }
    }
    
    var color: Color {
        switch self {
        case .new: return Color(hex: "#4A7D5A") // Green
        case .updated: return Color(hex: "#4A5A7D") // Blue
        case .trending: return Color(hex: "#B5828C") // Primary/Pink
        }
    }
    
    var icon: String {
        switch self {
        case .new: return "sparkles"
        case .updated: return "arrow.clockwise"
        case .trending: return "flame.fill"
        }
    }
}

// MARK: - Seasonal Playbook

struct SeasonalPlaybook: Codable {
    let season: Season
    let articles: [String]
    let ctaText: String
    
    var displayTitle: String {
        "\(season.emoji) \(season.displayName) Skin Playbook"
    }
    
    var gradientColors: [Color] {
        season.gradientColors
    }
}

// MARK: - Season

enum Season: String, Codable, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    
    var displayName: String {
        switch self {
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .autumn: return "Autumn"
        case .winter: return "Winter"
        }
    }
    
    var emoji: String {
        switch self {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .autumn: return "🍂"
        case .winter: return "❄️"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .spring:
            return [Color(hex: "#FFE6F0"), Color(hex: "#FFF0E6")]
        case .summer:
            return [Color(hex: "#FFEBCD"), Color(hex: "#FFE4B5")]
        case .autumn:
            return [Color(hex: "#FFE6D1"), Color(hex: "#F5DEB3")]
        case .winter:
            return [Color(hex: "#E6F3FF"), Color(hex: "#F0F8FF")]
        }
    }
    
    static func from(date: Date) -> Season {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .autumn
        default: return .winter
        }
    }
}

// MARK: - Trending Routine

struct TrendingRoutine: Codable, Identifiable {
    var id: UUID {
        templateId
    }
    
    let templateId: UUID
    let saveIncrease: Int
    let period: TrendingPeriod
    
    var displayIncrease: String {
        "↑ \(saveIncrease)%"
    }
}

// MARK: - Trending Period

enum TrendingPeriod: String, Codable, CaseIterable {
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    
    var displayText: String {
        switch self {
        case .thisWeek: return "This week"
        case .thisMonth: return "This month"
        }
    }
}

// MARK: - Refresh Time Helper

struct RefreshTimeHelper {
    static func formatRefreshTime(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        
        if minutes < 5 {
            return "Refreshed just now • new tips every morning ☀️"
        } else if minutes < 60 {
            return "Refreshed \(minutes) min ago • new tips every morning ☀️"
        } else if hours < 24 {
            return "Refreshed \(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = hours / 24
            return "Refreshed \(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Mini Guide

struct MiniGuide: Codable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let minutes: Int
    let imageName: String
    let category: String
}

