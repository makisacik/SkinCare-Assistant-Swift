//
//  CompanionServices.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import UserNotifications
import UIKit

// MARK: - Session Store

@MainActor
class SessionStore: ObservableObject {
    static let shared = SessionStore()
    
    @Published var currentSession: CompanionSession?
    @Published var sessionHistory: [SessionResult] = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionKey = "current_companion_session"
    private let historyKey = "companion_session_history"
    
    private init() {
        loadSessionHistory()
        loadCurrentSession()
    }
    
    // MARK: - Session Management
    
    func startSession(routineId: String, routineName: String, steps: [CompanionStep]) {
        let session = CompanionSession(
            routineId: routineId,
            routineName: routineName,
            steps: steps
        )
        currentSession = session
        saveCurrentSession()
    }
    
    func updateSession(_ session: CompanionSession) {
        print("🔄 updateSession: Updating session \(session.id)")
        print("📊 Session has \(session.stepsCompleted.count) completed steps")
        print("📊 Current step index: \(session.currentStepIndex)")
        currentSession = session
        saveCurrentSession()
        print("💾 Session saved to UserDefaults")
    }
    
    func completeSession() {
        guard var session = currentSession else { return }
        session.completeSession()
        
        let result = SessionResult(session: session)
        sessionHistory.append(result)
        
        currentSession = nil
        saveCurrentSession()
        saveSessionHistory()
    }
    
    func abandonSession() {
        guard var session = currentSession else { return }
        session.status = .abandoned
        session.completeSession()
        
        let result = SessionResult(session: session)
        sessionHistory.append(result)
        
        currentSession = nil
        saveCurrentSession()
        saveSessionHistory()
    }
    
    func resumeSession() -> CompanionSession? {
        return currentSession
    }
    
    // MARK: - Persistence
    
    private func saveCurrentSession() {
        guard let session = currentSession else {
            print("🗑️ saveCurrentSession: No session to save, removing from UserDefaults")
            userDefaults.removeObject(forKey: sessionKey)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(session)
            userDefaults.set(data, forKey: sessionKey)
            print("✅ saveCurrentSession: Session saved successfully")
            print("📊 Saved session has \(session.stepsCompleted.count) completed steps")
        } catch {
            print("❌ Error saving current session: \(error)")
        }
    }
    
    private func loadCurrentSession() {
        guard let data = userDefaults.data(forKey: sessionKey) else {
            print("📭 loadCurrentSession: No saved session found in UserDefaults")
            return
        }
        
        do {
            let session = try JSONDecoder().decode(CompanionSession.self, from: data)
            currentSession = session
            print("✅ loadCurrentSession: Session loaded successfully")
            print("📊 Loaded session has \(session.stepsCompleted.count) completed steps")
            print("📊 Current step index: \(session.currentStepIndex)")
        } catch {
            print("❌ Error loading current session: \(error)")
        }
    }
    
    private func saveSessionHistory() {
        do {
            let data = try JSONEncoder().encode(sessionHistory)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            print("Error saving session history: \(error)")
        }
    }
    
    private func loadSessionHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        
        do {
            sessionHistory = try JSONDecoder().decode([SessionResult].self, from: data)
        } catch {
            print("Error loading session history: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    func getCompletionRate() -> Double {
        guard !sessionHistory.isEmpty else { return 0 }
        let totalRate = sessionHistory.reduce(0) { $0 + $1.completionRate }
        return totalRate / Double(sessionHistory.count)
    }
    
    func getAverageDuration() -> TimeInterval {
        guard !sessionHistory.isEmpty else { return 0 }
        let totalDuration = sessionHistory.reduce(0) { $0 + $1.totalDurationSeconds }
        return Double(totalDuration) / Double(sessionHistory.count)
    }
    
    func getStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Sort sessions by completion date (most recent first)
        let sortedSessions = sessionHistory.sorted { $0.completedAt > $1.completedAt }
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.completedAt)
            if calendar.isDate(sessionDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Haptics Service

class HapticsService {
    static let shared = HapticsService()
    
    private init() {}
    
    func stepCompleted() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func timerTick() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    func timerComplete() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func routineComplete() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Add a second haptic for celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
    
    func buttonTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Notification Service

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        requestPermission()
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleTimerNotification(seconds: Int, stepTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Time to apply \(stepTitle)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(
            identifier: "companion_timer_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelTimerNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let timerRequests = requests.filter { $0.identifier.hasPrefix("companion_timer_") }
            let identifiers = timerRequests.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

// MARK: - Analytics Service

class CompanionAnalyticsService {
    static let shared = CompanionAnalyticsService()
    
    private init() {}
    
    func trackEvent(_ event: CompanionAnalyticsEvent) {
        // In a real app, you would send this to your analytics service
        print("Analytics Event: \(event.name) - \(event.parameters)")
    }
}

struct CompanionAnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    static func companionStart(routineId: String, stepCount: Int) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "companion_start",
            parameters: [
                "routine_id": routineId,
                "step_count": stepCount
            ]
        )
    }
    
    static func stepView(stepId: String, stepOrder: Int, stepType: String) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "step_view",
            parameters: [
                "step_id": stepId,
                "step_order": stepOrder,
                "step_type": stepType
            ]
        )
    }
    
    static func timerStart(stepId: String, plannedWait: Int) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "timer_start",
            parameters: [
                "step_id": stepId,
                "planned_wait": plannedWait
            ]
        )
    }
    
    static func timerPause(stepId: String, remainingSeconds: Int) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "timer_pause",
            parameters: [
                "step_id": stepId,
                "remaining_seconds": remainingSeconds
            ]
        )
    }
    
    static func timerSkip(stepId: String, remainingSeconds: Int) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "timer_skip",
            parameters: [
                "step_id": stepId,
                "remaining_seconds": remainingSeconds
            ]
        )
    }
    
    static func stepComplete(stepId: String, actualWait: Int, wasSkipped: Bool) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "step_complete",
            parameters: [
                "step_id": stepId,
                "actual_wait": actualWait,
                "was_skipped": wasSkipped
            ]
        )
    }
    
    static func companionComplete(routineId: String, totalDuration: Int, skips: Int, completionRate: Double) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "companion_complete",
            parameters: [
                "routine_id": routineId,
                "total_duration": totalDuration,
                "skips": skips,
                "completion_rate": completionRate
            ]
        )
    }
    
    static func companionAbandon(routineId: String, currentStep: Int, totalSteps: Int) -> CompanionAnalyticsEvent {
        return CompanionAnalyticsEvent(
            name: "companion_abandon",
            parameters: [
                "routine_id": routineId,
                "current_step": currentStep,
                "total_steps": totalSteps
            ]
        )
    }
}
