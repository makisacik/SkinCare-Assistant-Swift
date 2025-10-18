//
//  NotificationContextProvider.swift
//  ManCare
//
//  Created for push notification system
//

import Foundation

// MARK: - Notification Context

struct NotificationContext {
    let currentStreak: Int
    let hasStreakMilestone: Bool
    let streakMilestone: Int?
    let lastCompletionDate: Date?
    let missedYesterday: Bool
    let weatherCondition: WeatherCondition?
    let cyclePhase: CyclePhase?
    let skinConcerns: Set<Concern>
    let lastAppOpenDate: Date
    
    enum WeatherCondition {
        case dryAir
        case humid
        case cold
        case sunny
        case rainy
        case seasonalChange
    }
}

// MARK: - Context Provider

class NotificationContextProvider {
    static let shared = NotificationContextProvider()
    
    private init() {}
    
    // MARK: - Main Context Gathering
    
    @MainActor
    func gatherContext() async -> NotificationContext {
        let streak = await getStreak()
        let (hasMilestone, milestone) = checkStreakMilestone(streak: streak)
        let lastCompletion = await getLastCompletionDate()
        let missedYesterday = await checkMissedYesterday()
        let weather = await getWeatherCondition()
        let cycle = await getCyclePhase()
        let concerns = getSkinConcerns()
        let lastOpen = NotificationStateStore.shared.state.lastAppOpenTimestamp
        
        return NotificationContext(
            currentStreak: streak,
            hasStreakMilestone: hasMilestone,
            streakMilestone: milestone,
            lastCompletionDate: lastCompletion,
            missedYesterday: missedYesterday,
            weatherCondition: weather,
            cyclePhase: cycle,
            skinConcerns: concerns,
            lastAppOpenDate: lastOpen
        )
    }
    
    // MARK: - Streak Data
    
    @MainActor
    private func getStreak() -> Int {
        return SessionStore.shared.getStreak()
    }
    
    private func checkStreakMilestone(streak: Int) -> (hasMilestone: Bool, milestone: Int?) {
        let milestones = [3, 7, 14]
        if milestones.contains(streak) {
            return (true, streak)
        }
        return (false, nil)
    }
    
    // MARK: - Completion Data
    
    @MainActor
    private func getLastCompletionDate() -> Date? {
        let sessions = SessionStore.shared.sessionHistory
        return sessions.last?.completedAt
    }
    
    @MainActor
    private func checkMissedYesterday() -> Bool {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        let sessions = SessionStore.shared.sessionHistory
        let hasYesterdayCompletion = sessions.contains { session in
            calendar.isDate(session.completedAt, inSameDayAs: yesterday)
        }
        
        let hasTodayCompletion = sessions.contains { session in
            calendar.isDate(session.completedAt, inSameDayAs: Date())
        }
        
        // Missed if no completion yesterday AND no completion today
        return !hasYesterdayCompletion && !hasTodayCompletion
    }
    
    // MARK: - Weather Data
    
    private func getWeatherCondition() async -> NotificationContext.WeatherCondition? {
        guard let weatherData = await WeatherService.shared.getCurrentWeatherData() else {
            return nil
        }
        
        // Prioritize conditions
        if weatherData.humidity < 30 {
            return .dryAir
        } else if weatherData.humidity > 70 {
            return .humid
        } else if weatherData.temperature < 10 {
            return .cold
        } else if weatherData.hasSnow {
            return .cold
        } else if weatherData.uvIndex >= 7 {
            return .sunny
        } else if weatherData.condition?.lowercased().contains("rain") == true {
            return .rainy
        }
        
        // Check for seasonal change (simplified)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        if [3, 6, 9, 12].contains(month) { // Start of seasons
            let day = calendar.component(.day, from: Date())
            if day <= 7 { // First week of season change month
                return .seasonalChange
            }
        }
        
        return nil
    }
    
    // MARK: - Cycle Data
    
    @MainActor
    private func getCyclePhase() -> CyclePhase? {
        let cycleStore = CycleStore()
        return cycleStore.cycleData.currentPhase()
    }
    
    // MARK: - Skin Profile Data
    
    private func getSkinConcerns() -> Set<Concern> {
        return UserProfileStore.shared.currentProfile?.concerns ?? []
    }
}

