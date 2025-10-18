//
//  NotificationState.swift
//  ManCare
//
//  Created for push notification system
//

import Foundation

// MARK: - Notification Category

enum NotificationCategory: String, Codable, CaseIterable {
    case streak
    case reminder
    case weather
    case cycle
    case skinGoal
    case motivation
    
    var cooldownDays: Int {
        switch self {
        case .streak: return 3
        case .reminder: return 1
        case .weather: return 2
        case .cycle: return 3
        case .skinGoal: return 3
        case .motivation: return 4
        }
    }
}

// MARK: - Time Window

struct TimeWindow: Codable, Equatable {
    let startHour: Int
    let startMinute: Int
    let count: Int // Number of completions in this window
    
    var timeString: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }
    
    func isInWindow(date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return false }
        
        // Check if within 30-minute window
        if hour == startHour {
            return minute >= startMinute && minute < startMinute + 30
        } else if hour == startHour + 1 && startMinute >= 30 {
            return minute < (startMinute + 30) - 60
        }
        return false
    }
    
    func nextOccurrence(after date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = startHour
        components.minute = startMinute
        components.second = 0
        
        guard var nextDate = calendar.date(from: components) else { return nil }
        
        // If the time today has passed, move to tomorrow
        if nextDate <= date {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }
        
        return nextDate
    }
}

// MARK: - Notification State

class NotificationState: Codable {
    var lastSentTimestamps: [NotificationCategory: Date]
    var learnedTimeWindows: [TimeWindow]
    var lastAppOpenTimestamp: Date
    var unopenedNotificationCount: Int
    var sentNotificationHistory: [Date] // Last 7 days of sent notifications
    var permissionStatus: String
    var lastPatternUpdateDate: Date
    
    init() {
        self.lastSentTimestamps = [:]
        self.learnedTimeWindows = []
        self.lastAppOpenTimestamp = Date()
        self.unopenedNotificationCount = 0
        self.sentNotificationHistory = []
        self.permissionStatus = "notDetermined"
        self.lastPatternUpdateDate = Date.distantPast
    }
    
    // MARK: - Guardrail Checks
    
    func canSendNotification(category: NotificationCategory, currentDate: Date = Date()) -> Bool {
        // Check daily cap (1 per day)
        if sentNotificationToday(currentDate: currentDate) {
            print("🚫 Daily cap reached")
            return false
        }
        
        // Check weekly cap (4 per 7 days)
        if sentNotificationsInLastWeek() >= 4 {
            print("🚫 Weekly cap reached")
            return false
        }
        
        // Check minimum interval (20 hours)
        if let lastSent = mostRecentSentTimestamp(), currentDate.timeIntervalSince(lastSent) < 20 * 3600 {
            print("🚫 Minimum interval not met")
            return false
        }
        
        // Check quiet hours (22:00 - 08:00)
        if isInQuietHours(date: currentDate) {
            print("🚫 In quiet hours")
            return false
        }
        
        // Check category cooldown
        if let lastSentForCategory = lastSentTimestamps[category] {
            let cooldownInterval = TimeInterval(category.cooldownDays * 24 * 3600)
            if currentDate.timeIntervalSince(lastSentForCategory) < cooldownInterval {
                print("🚫 Category \(category.rawValue) in cooldown")
                return false
            }
        }
        
        return true
    }
    
    func shouldSuppressNotifications(lastCompletionDate: Date?, currentDate: Date = Date()) -> Bool {
        // Suppress if completed routine in last 3 hours
        if let lastCompletion = lastCompletionDate,
           currentDate.timeIntervalSince(lastCompletion) < 3 * 3600 {
            print("🚫 Recently completed routine")
            return true
        }
        
        // Suppress if opened app in last 2 hours
        if currentDate.timeIntervalSince(lastAppOpenTimestamp) < 2 * 3600 {
            print("🚫 Recently opened app")
            return true
        }
        
        return false
    }
    
    func applyFatigueProbability() -> Double {
        // If 2 unopened notifications, halve send probability
        return unopenedNotificationCount >= 2 ? 0.5 : 1.0
    }
    
    // MARK: - Helper Methods
    
    func sentNotificationToday(currentDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return sentNotificationHistory.contains { notification in
            calendar.isDate(notification, inSameDayAs: currentDate)
        }
    }
    
    func sentNotificationsInLastWeek() -> Int {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        return sentNotificationHistory.filter { $0 > weekAgo }.count
    }
    
    func mostRecentSentTimestamp() -> Date? {
        return sentNotificationHistory.max()
    }
    
    func isInQuietHours(date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour >= 22 || hour < 8
    }
    
    func recordSentNotification(category: NotificationCategory, date: Date = Date()) {
        lastSentTimestamps[category] = date
        sentNotificationHistory.append(date)
        
        // Keep only last 7 days
        let weekAgo = date.addingTimeInterval(-7 * 24 * 3600)
        sentNotificationHistory = sentNotificationHistory.filter { $0 > weekAgo }
        
        unopenedNotificationCount += 1
    }
    
    func recordAppOpen(date: Date = Date()) {
        lastAppOpenTimestamp = date
        unopenedNotificationCount = 0
    }
}

// MARK: - Notification State Store

@MainActor
class NotificationStateStore: ObservableObject {
    static let shared = NotificationStateStore()
    
    @Published private(set) var state: NotificationState
    
    private let storageKey = "notification_state_v1"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        self.state = Self.load() ?? NotificationState()
    }
    
    func updateState(_ updater: (inout NotificationState) -> Void) {
        updater(&state)
        save()
    }
    
    private static func load() -> NotificationState? {
        guard let data = UserDefaults.standard.data(forKey: "notification_state_v1") else {
            print("📭 No saved notification state found")
            return nil
        }
        
        do {
            let state = try JSONDecoder().decode(NotificationState.self, from: data)
            print("✅ Loaded notification state")
            return state
        } catch {
            print("❌ Failed to decode notification state: \(error)")
            return nil
        }
    }
    
    private func save() {
        do {
            let data = try encoder.encode(state)
            UserDefaults.standard.set(data, forKey: storageKey)
            print("💾 Saved notification state")
        } catch {
            print("❌ Failed to encode notification state: \(error)")
        }
    }
}

