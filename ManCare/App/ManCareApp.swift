//
//  ManCareApp.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI
import BackgroundTasks

@main
struct ManCareApp: App {
    // Create services using factory
    private let routineService: RoutineServiceProtocol

    // Localization manager for reactive language switching
    @StateObject private var localizationManager = LocalizationManager.shared

    // Background task identifier
    private let notificationSchedulerTaskID = "com.mancare.notification-scheduler"

    // Scene phase for background handling
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Use factory to create dependencies
        self.routineService = ServiceFactory.shared.createRoutineService()

        // Register background task
        registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingFlowView()
                .environmentObject(localizationManager)
                .onAppear {
                    scheduleBackgroundTask()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                // Schedule background task when app enters background
                scheduleBackgroundTask()
                print("📱 App entered background, scheduled notification evaluation")
            } else if newPhase == .active {
                // Record app open when app becomes active
                Task { @MainActor in
                    NotificationStateStore.shared.updateState { state in
                        state.recordAppOpen()
                    }
                    print("📱 App became active, recorded app open")
                }
            }
        }
    }

    // MARK: - Background Task Management

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: notificationSchedulerTaskID, using: nil) { task in
            Task {
                await self.handleBackgroundRefresh()
                self.scheduleBackgroundTask()
                task.setTaskCompleted(success: true)
            }
        }
        print("✅ Registered background task: \(notificationSchedulerTaskID)")
    }

    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: notificationSchedulerTaskID)

        // Schedule for 12-24 hours from now (let iOS decide optimal time)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 3600) // 12 hours

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Scheduled background task for notification evaluation")
        } catch {
            print("❌ Failed to schedule background task: \(error)")
        }
    }

    @MainActor
    private func handleBackgroundRefresh() async {
        print("🔄 Background refresh: evaluating notifications...")
        await NotificationScheduler.shared.evaluateAndScheduleNext()
    }
}
