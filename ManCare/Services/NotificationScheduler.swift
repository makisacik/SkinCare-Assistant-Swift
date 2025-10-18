//
//  NotificationScheduler.swift
//  ManCare
//
//  Created for push notification system
//

import Foundation

// MARK: - Notification Message

struct NotificationMessage {
    let category: NotificationCategory
    let title: String
    let body: String
    let priority: Int
}

// MARK: - Notification Scheduler

class NotificationScheduler {
    static let shared = NotificationScheduler()
    
    private init() {}
    
    // MARK: - Main Scheduling Logic
    
    @MainActor
    func evaluateAndScheduleNext() async {
        print("🔔 Evaluating next notification to schedule...")

        // Check if notifications are enabled by user
        let (isAuthorized, isEnabled) = await NotificationService.shared.getNotificationStatus()
        guard isAuthorized && isEnabled else {
            print("🚫 Notifications are disabled or not authorized, skipping evaluation")
            return
        }

        // Learn patterns if needed
        await NotificationPatternLearner.shared.learnPatternsIfNeeded()
        
        // Gather context
        let context = await NotificationContextProvider.shared.gatherContext()
        
        // Build priority queue of eligible notifications
        let candidates = buildNotificationCandidates(context: context)
        
        guard !candidates.isEmpty else {
            print("ℹ️ No eligible notifications at this time")
            return
        }
        
        // Sort by priority (highest first)
        let sortedCandidates = candidates.sorted { $0.priority > $1.priority }
        
        // Select highest priority
        guard let selectedNotification = sortedCandidates.first else { return }
        
        print("📌 Selected notification: \(selectedNotification.category.rawValue) (priority: \(selectedNotification.priority))")
        
        // Find next valid delivery window
        guard let deliveryDate = findNextDeliveryWindow() else {
            print("⚠️ No valid delivery window found")
            return
        }
        
        // Schedule the notification
        let success = await NotificationService.shared.scheduleSmartNotification(
            category: selectedNotification.category,
            title: selectedNotification.title,
            body: selectedNotification.body,
            deliveryDate: deliveryDate
        )
        
        if success {
            print("✅ Successfully scheduled \(selectedNotification.category.rawValue) for \(deliveryDate)")
        }
    }
    
    // MARK: - Candidate Building
    
    private func buildNotificationCandidates(context: NotificationContext) -> [NotificationMessage] {
        var candidates: [NotificationMessage] = []
        
        // Priority 1: Recovery (missed yesterday)
        if context.missedYesterday {
            candidates.append(NotificationMessage(
                category: .reminder,
                title: L10n.Notifications.Reminder.missedTitle,
                body: L10n.Notifications.Reminder.missedBody,
                priority: 100
            ))
        }
        
        // Priority 2: Streak milestone
        if context.hasStreakMilestone, let milestone = context.streakMilestone {
            let (title, body) = getStreakMessage(milestone: milestone)
            candidates.append(NotificationMessage(
                category: .streak,
                title: title,
                body: body,
                priority: 90
            ))
        }
        
        // Priority 3: Weather adaptation
        if let weather = context.weatherCondition {
            let (title, body) = getWeatherMessage(condition: weather)
            candidates.append(NotificationMessage(
                category: .weather,
                title: title,
                body: body,
                priority: 80
            ))
        }
        
        // Priority 4: Cycle phase tip
        if let phase = context.cyclePhase {
            candidates.append(NotificationMessage(
                category: .cycle,
                title: L10n.Notifications.Cycle.title,
                body: getCycleMessage(phase: phase),
                priority: 70
            ))
        }
        
        // Priority 5: Preferred time reminder
        candidates.append(NotificationMessage(
            category: .reminder,
            title: L10n.Notifications.Reminder.routineTitle,
            body: getTimeBasedReminderMessage(),
            priority: 60
        ))
        
        // Priority 6: Skin goal tip
        if !context.skinConcerns.isEmpty {
            let concern = context.skinConcerns.randomElement()!
            let (title, body) = getSkinGoalMessage(concern: concern)
            candidates.append(NotificationMessage(
                category: .skinGoal,
                title: title,
                body: body,
                priority: 50
            ))
        }
        
        // Priority 7: Feel-good motivation
        candidates.append(NotificationMessage(
            category: .motivation,
            title: L10n.Notifications.Motivation.title,
            body: L10n.Notifications.Motivation.general,
            priority: 40
        ))
        
        return candidates
    }
    
    // MARK: - Message Generators
    
    private func getStreakMessage(milestone: Int) -> (title: String, body: String) {
        switch milestone {
        case 3:
            return (L10n.Notifications.Streak.title, L10n.Notifications.Streak.threeDays)
        case 7:
            return (L10n.Notifications.Streak.title, L10n.Notifications.Streak.sevenDays)
        case 14:
            return (L10n.Notifications.Streak.title, L10n.Notifications.Streak.fourteenDays)
        default:
            return (L10n.Notifications.Streak.title, L10n.Notifications.Streak.general)
        }
    }
    
    private func getWeatherMessage(condition: NotificationContext.WeatherCondition) -> (title: String, body: String) {
        switch condition {
        case .dryAir:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.dryAir)
        case .humid:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.humid)
        case .cold:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.cold)
        case .sunny:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.sunny)
        case .rainy:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.rainy)
        case .seasonalChange:
            return (L10n.Notifications.Weather.title, L10n.Notifications.Weather.seasonal)
        }
    }
    
    private func getCycleMessage(phase: CyclePhase) -> String {
        return phase.skincareTip
    }
    
    private func getSkinGoalMessage(concern: Concern) -> (title: String, body: String) {
        let title = L10n.Notifications.SkinGoal.title
        
        let body: String
        switch concern {
        case .acne:
            body = L10n.Notifications.SkinGoal.acne
        case .dryness:
            body = L10n.Notifications.SkinGoal.dryness
        case .sensitive:
            body = L10n.Notifications.SkinGoal.sensitivity
        default:
            body = L10n.Notifications.SkinGoal.radiance
        }
        
        return (title, body)
    }
    
    private func getTimeBasedReminderMessage() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        if hour >= 5 && hour < 12 {
            return L10n.Notifications.Reminder.morning
        } else if hour >= 12 && hour < 17 {
            return L10n.Notifications.Reminder.afternoon
        } else if hour >= 17 && hour < 22 {
            return L10n.Notifications.Reminder.evening
        } else {
            return L10n.Notifications.Reminder.general
        }
    }
    
    // MARK: - Delivery Window Calculation

    @MainActor
    private func findNextDeliveryWindow() -> Date? {
        // Try to use learned preferred windows first
        if let preferredWindow = NotificationPatternLearner.shared.nextPreferredWindow() {
            // Make sure it's not in quiet hours
            let state = NotificationStateStore.shared.state
            if !state.isInQuietHours(date: preferredWindow) {
                return preferredWindow
            }
        }
        
        // Fallback: next morning at 9 AM
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        guard var deliveryDate = calendar.date(from: components) else { return nil }
        
        // If 9 AM today has passed, move to tomorrow
        if deliveryDate <= now {
            deliveryDate = calendar.date(byAdding: .day, value: 1, to: deliveryDate) ?? deliveryDate
        }
        
        return deliveryDate
    }
}

