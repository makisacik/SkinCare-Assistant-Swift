//
//  NotificationPatternLearner.swift
//  ManCare
//
//  Created for push notification system
//

import Foundation

// MARK: - Pattern Learner

class NotificationPatternLearner {
    static let shared = NotificationPatternLearner()
    
    private init() {}
    
    // MARK: - Learning Methods
    
    @MainActor
    func learnPatternsIfNeeded() async {
        let stateStore = NotificationStateStore.shared
        let sessionStore = SessionStore.shared
        
        // Check if we should update patterns
        let daysSinceLastUpdate = Calendar.current.dateComponents(
            [.day],
            from: stateStore.state.lastPatternUpdateDate,
            to: Date()
        ).day ?? 0
        
        let shouldUpdate = daysSinceLastUpdate >= 7 || stateStore.state.learnedTimeWindows.isEmpty
        
        guard shouldUpdate else {
            print("ℹ️ Pattern learning not needed yet")
            return
        }
        
        print("🧠 Learning notification patterns from session history...")
        
        let sessions = sessionStore.sessionHistory
        guard sessions.count >= 5 else {
            print("ℹ️ Not enough session data to learn patterns (need 5+, have \(sessions.count))")
            return
        }
        
        // Build histogram of completion times
        let timeWindows = buildTimeWindowHistogram(from: sessions)
        
        // Get top 2-3 windows
        let topWindows = Array(timeWindows.sorted { $0.count > $1.count }.prefix(3))
        
        // Update state
        stateStore.updateState { state in
            state.learnedTimeWindows = topWindows
            state.lastPatternUpdateDate = Date()
        }
        
        print("✅ Learned \(topWindows.count) time windows:")
        for window in topWindows {
            print("   - \(window.timeString): \(window.count) completions")
        }
    }
    
    // MARK: - Histogram Building
    
    private func buildTimeWindowHistogram(from sessions: [SessionResult]) -> [TimeWindow] {
        var buckets: [String: Int] = [:] // Key: "HH:MM", Value: count
        let calendar = Calendar.current
        
        for session in sessions {
            let components = calendar.dateComponents([.hour, .minute], from: session.completedAt)
            guard let hour = components.hour, let minute = components.minute else { continue }
            
            // Round down to 30-minute bucket
            let bucketMinute = (minute / 30) * 30
            let key = String(format: "%02d:%02d", hour, bucketMinute)
            
            buckets[key, default: 0] += 1
        }
        
        // Convert to TimeWindow objects
        return buckets.compactMap { key, count in
            let parts = key.split(separator: ":")
            guard parts.count == 2,
                  let hour = Int(parts[0]),
                  let minute = Int(parts[1]) else { return nil }
            
            return TimeWindow(startHour: hour, startMinute: minute, count: count)
        }
    }
    
    // MARK: - Next Window Calculation

    @MainActor
    func nextPreferredWindow(after date: Date = Date()) -> Date? {
        let windows = NotificationStateStore.shared.state.learnedTimeWindows
        guard !windows.isEmpty else { return nil }
        
        // Find the next window occurrence
        let nextOccurrences = windows.compactMap { $0.nextOccurrence(after: date) }
        return nextOccurrences.min()
    }
}

