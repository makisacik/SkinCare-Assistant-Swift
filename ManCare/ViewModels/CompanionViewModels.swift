//
//  CompanionViewModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Companion Session ViewModel

@MainActor
class CompanionSessionViewModel: ObservableObject {
    @Published var session: CompanionSession?
    @Published var currentState: SessionState = .idle
    @Published var timerState = TimerState()
    @Published var isHandsFreeMode = false
    
    private let sessionStore = SessionStore.shared
    private let hapticsService = HapticsService.shared
    private let notificationService = NotificationService.shared
    private let analyticsService = CompanionAnalyticsService.shared
    private let tipsService = ProductTipsService.shared
    private var routineTrackingService: RoutineTrackingService?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        resumeSession()
    }
    
    func setRoutineTrackingService(_ service: RoutineTrackingService) {
        self.routineTrackingService = service
    }
    func isRoutineCompletedForToday(steps: [CompanionStep]) -> Bool {
        guard let trackingService = routineTrackingService else { return false }

        let completedSteps = steps.filter { step in
            trackingService.isStepCompleted(stepId: step.id)
        }

        return completedSteps.count == steps.count
    }

    func startRoutineAgain(routineId: String, routineName: String, steps: [CompanionStep]) {
        print("🔄 Starting routine again - clearing completed steps")

        // Clear completed steps for today
        if let trackingService = routineTrackingService {
            for step in steps {
                if trackingService.isStepCompleted(stepId: step.id) {
                    trackingService.toggleStepCompletion(
                        stepId: step.id,
                        stepTitle: step.title,
                        stepType: step.stepType,
                        timeOfDay: step.timeOfDay
                    )
                }
            }
        }

        // Start new session
        startSession(routineId: routineId, routineName: routineName, steps: steps)
    }
    private func setupBindings() {
        // Listen for app lifecycle changes
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBackgrounding()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppForegrounding()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Session Management
    
    func startSession(routineId: String, routineName: String, steps: [CompanionStep]) {
        print("🎯 Starting session with \(steps.count) steps")
        // Check if routine is already completed for today
        if isRoutineCompletedForToday(steps: steps) {
            print("📊 Routine already completed for today")
            currentState = .routineAlreadyCompleted
            return
        }

        sessionStore.startSession(routineId: routineId, routineName: routineName, steps: steps)
        session = sessionStore.currentSession
        print("📊 Session created: \(session?.id ?? "nil")")
        print("📈 Current step index: \(session?.currentStepIndex ?? -1)")
        currentState = .stepIntro(0)
        print("🔄 State set to: \(currentState)")

        analyticsService.trackEvent(.companionStart(routineId: routineId, stepCount: steps.count))
    }
    
    func resumeSession() {
        if let existingSession = sessionStore.resumeSession() {
            print("🔄 resumeSession: Resuming existing session")
            print("📊 Session has \(existingSession.stepsCompleted.count) completed steps")
            print("📊 Current step index: \(existingSession.currentStepIndex)")
            print("📊 Steps count: \(existingSession.steps.count)")

            session = existingSession

            // Check if session is already complete
            if existingSession.isComplete {
                print("📊 Session is already complete, setting state to routineComplete")
                currentState = .routineComplete
            } else {
                // Ensure currentStepIndex is within bounds
                let safeIndex = min(existingSession.currentStepIndex, existingSession.steps.count - 1)
                print("📊 Setting state to stepIntro with index: \(safeIndex)")
                currentState = .stepIntro(safeIndex)
            }
        } else {
            print("📭 resumeSession: No existing session to resume")
        }
    }
    
    func completeSession() {
        guard var session = session else { return }
        
        session.completeSession()
        sessionStore.completeSession()
        
        analyticsService.trackEvent(.companionComplete(
            routineId: session.routineId,
            totalDuration: session.totalDurationSeconds,
            skips: session.skips,
            completionRate: session.isComplete ? 1.0 : Double(session.stepsCompleted.count) / Double(session.steps.count)
        ))
        
        hapticsService.routineComplete()
        currentState = .routineComplete
    }
    
    func abandonSession() {
        guard let session = session else { return }
        
        sessionStore.abandonSession()
        
        analyticsService.trackEvent(.companionAbandon(
            routineId: session.routineId,
            currentStep: session.currentStepIndex,
            totalSteps: session.steps.count
        ))
        
        currentState = .idle
        self.session = nil
    }
    
    // MARK: - Step Navigation
    
    func nextStep() {
        guard var session = session else {
            print("❌ nextStep: No session found")
            return
        }
        
        print("🔄 nextStep: Completing step \(session.currentStepIndex) of \(session.steps.count)")
        print("📊 Before completion - Steps completed: \(session.stepsCompleted.count)")

        if let currentStep = session.currentStep {
            print("✅ Completing step: \(currentStep.title) (ID: \(currentStep.id))")
            analyticsService.trackEvent(.stepComplete(
                stepId: currentStep.id,
                actualWait: currentStep.waitSeconds ?? 0,
                wasSkipped: false
            ))
        }

        session.completeCurrentStep()
        print("📊 After completion - Steps completed: \(session.stepsCompleted.count)")
        print("📊 New current step index: \(session.currentStepIndex)")

        // Integrate with RoutineTrackingService
        if let completedStepId = session.stepsCompleted.last,
           let completedStep = session.steps.first(where: { $0.id == completedStepId }),
           let trackingService = routineTrackingService {
            print("🔄 Marking step as completed in RoutineTrackingService: \(completedStep.title)")
            trackingService.toggleStepCompletion(
                stepId: completedStep.id,
                stepTitle: completedStep.title,
                stepType: completedStep.stepType,
                timeOfDay: completedStep.timeOfDay
            )
        }

        sessionStore.updateSession(session)
        self.session = session

        print("💾 Session updated in store")
        
        if session.isComplete {
            print("🎉 Session complete!")
            completeSession()
        } else {
            // Ensure we don't go out of bounds
            let nextIndex = min(session.currentStepIndex, session.steps.count - 1)
            print("➡️ Moving to next step: \(nextIndex)")
            currentState = .stepIntro(nextIndex)
        }
    }
    
    func skipStep() {
        guard var session = session else { return }
        
        if let currentStep = session.currentStep {
            analyticsService.trackEvent(.stepComplete(
                stepId: currentStep.id,
                actualWait: 0,
                wasSkipped: true
            ))
        }
        
        session.skipCurrentStep()
        sessionStore.updateSession(session)
        self.session = session
        
        if session.isComplete {
            completeSession()
        } else {
            // Ensure we don't go out of bounds
            let nextIndex = min(session.currentStepIndex, session.steps.count - 1)
            currentState = .stepIntro(nextIndex)
        }
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        guard let session = session, let step = session.currentStep, step.type == .timed else { return }
        
        timerState = TimerState(
            isRunning: true,
            remainingSeconds: step.waitSeconds ?? 0,
            totalSeconds: step.waitSeconds ?? 0,
            startTime: Date()
        )
        
        currentState = .timerRunning(session.currentStepIndex)
        
        startCountdown()
        
        if let waitSeconds = step.waitSeconds, waitSeconds > 60 {
            notificationService.scheduleTimerNotification(seconds: waitSeconds, stepTitle: step.title)
        }
        
        analyticsService.trackEvent(.timerStart(stepId: step.id, plannedWait: step.waitSeconds ?? 0))
    }
    
    func pauseTimer() {
        timerState.isPaused = true
        timerState.pauseTime = Date()
        currentState = .timerPaused(session?.currentStepIndex ?? 0)
        
        stopCountdown()
        tipsService.pauseTips()
        
        if let step = session?.currentStep {
            analyticsService.trackEvent(.timerPause(stepId: step.id, remainingSeconds: timerState.remainingSeconds))
        }
    }
    
    func resumeTimer() {
        timerState.isPaused = false
        timerState.pauseTime = nil
        currentState = .timerRunning(session?.currentStepIndex ?? 0)
        
        startCountdown()
        tipsService.resumeTips()
    }
    
    func skipTimer() {
        guard let step = session?.currentStep else { return }
        
        analyticsService.trackEvent(.timerSkip(stepId: step.id, remainingSeconds: timerState.remainingSeconds))
        
        stopCountdown()
        timerState = TimerState()

        // Go directly to next step
        nextStep()
    }
    
    func completeTimer() {
        guard let step = session?.currentStep else { return }

        analyticsService.trackEvent(.stepComplete(
            stepId: step.id,
            actualWait: step.waitSeconds ?? 0,
            wasSkipped: false
        ))

        stopCountdown()
        timerState = TimerState()

        // Go to next step
        nextStep()
    }
    
    func adjustTimer(by seconds: Int) {
        let newSeconds = max(timerState.remainingSeconds + seconds, 10)
        let maxSeconds = session?.currentStep?.maxSeconds ?? 600
        let adjustedSeconds = min(newSeconds, maxSeconds)

        // Calculate how much time has already elapsed
        let elapsedSeconds = timerState.totalSeconds - timerState.remainingSeconds

        // Update both remaining and total seconds to maintain progress accuracy
        timerState.remainingSeconds = adjustedSeconds
        timerState.totalSeconds = elapsedSeconds + adjustedSeconds
    }
    
    // MARK: - Private Methods
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        guard timerState.isRunning && !timerState.isPaused else { return }
        
        timerState.remainingSeconds -= 1
        
        if timerState.remainingSeconds <= 0 {
            timerComplete()
        } else if timerState.remainingSeconds <= 10 {
            hapticsService.timerTick()
        }
    }
    
    private func timerComplete() {
        stopCountdown()
        timerState.remainingSeconds = 0
        timerState.isRunning = false
        
        hapticsService.timerComplete()
        notificationService.cancelTimerNotifications()

        // Don't automatically go to next step - wait for user action
    }
    
    private func handleAppBackgrounding() {
        if timerState.isRunning && !timerState.isPaused {
            // Timer will continue in background via local notifications
        }
    }
    
    private func handleAppForegrounding() {
        // Reconcile timer state if needed
        if let startTime = timerState.startTime, timerState.isRunning && !timerState.isPaused {
            let elapsed = Int(Date().timeIntervalSince(startTime))
            let newRemaining = max(0, timerState.totalSeconds - elapsed)
            
            if newRemaining != timerState.remainingSeconds {
                timerState.remainingSeconds = newRemaining
                if newRemaining <= 0 {
                    timerComplete()
                }
            }
        }
    }
    
    deinit {
        // Timer cleanup will happen automatically when the object is deallocated
        // The timer will be invalidated when the object is released
    }
}

// MARK: - Step ViewModel

@MainActor
class StepViewModel: ObservableObject {
    @Published var step: CompanionStep?
    @Published var isCompleted = false
    
    private let hapticsService = HapticsService.shared
    private let analyticsService = CompanionAnalyticsService.shared
    
    func setStep(_ step: CompanionStep) {
        self.step = step
        isCompleted = false
        
        analyticsService.trackEvent(.stepView(
            stepId: step.id,
            stepOrder: step.order,
            stepType: step.type.rawValue
        ))
    }
    
    func completeStep() {
        guard let step = step else { return }
        
        isCompleted = true
        
        if step.haptics {
            hapticsService.stepCompleted()
        }
    }
    
    var stepColor: Color {
        guard let step = step else { return .gray }
        
        switch step.stepType {
        case .cleanser:
            return ThemeManager.shared.theme.palette.info
        case .faceSerum:
            return ThemeManager.shared.theme.palette.primary
        case .moisturizer:
            return ThemeManager.shared.theme.palette.success
        case .sunscreen, .faceSunscreen:
            return ThemeManager.shared.theme.palette.warning
        default:
            return ThemeManager.shared.theme.palette.textMuted
        }
    }
    
    var iconName: String {
        guard let step = step else { return "questionmark.circle" }
        
        switch step.stepType {
        case .cleanser:
            return "drop.fill"
        case .faceSerum:
            return "star.fill"
        case .moisturizer:
            return "drop.circle.fill"
        case .sunscreen, .faceSunscreen:
            return "sun.max.fill"
        default:
            return "questionmark.circle"
        }
    }
}

// MARK: - Timer ViewModel

@MainActor
class TimerViewModel: ObservableObject {
    @Published var timerState = TimerState()
    @Published var isRunning = false
    @Published var isPaused = false
    
    private let hapticsService = HapticsService.shared
    private var timer: Timer?
    
    func startTimer(seconds: Int) {
        timerState = TimerState(
            isRunning: true,
            remainingSeconds: seconds,
            totalSeconds: seconds,
            startTime: Date()
        )
        isRunning = true
        isPaused = false
        
        startCountdown()
    }
    
    func pauseTimer() {
        timerState.isPaused = true
        timerState.pauseTime = Date()
        isPaused = true
        
        stopCountdown()
    }
    
    func resumeTimer() {
        timerState.isPaused = false
        timerState.pauseTime = nil
        isPaused = false
        
        startCountdown()
    }
    
    func stopTimer() {
        stopCountdown()
        timerState = TimerState()
        isRunning = false
        isPaused = false
    }
    
    func adjustTimer(by seconds: Int) {
        let newSeconds = max(timerState.remainingSeconds + seconds, 10)
        let adjustedSeconds = min(newSeconds, 600) // Max 10 minutes

        // Calculate how much time has already elapsed
        let elapsedSeconds = timerState.totalSeconds - timerState.remainingSeconds

        // Update both remaining and total seconds to maintain progress accuracy
        timerState.remainingSeconds = adjustedSeconds
        timerState.totalSeconds = elapsedSeconds + adjustedSeconds
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        guard timerState.isRunning && !timerState.isPaused else { return }
        
        timerState.remainingSeconds -= 1
        
        if timerState.remainingSeconds <= 0 {
            timerComplete()
        } else if timerState.remainingSeconds <= 10 {
            hapticsService.timerTick()
        }
    }
    
    private func timerComplete() {
        stopCountdown()
        timerState.remainingSeconds = 0
        isRunning = false
        isPaused = false
        
        hapticsService.timerComplete()
    }
    
    deinit {
        // Timer cleanup will happen automatically when the object is deallocated
        // The timer will be invalidated when the object is released
    }
}
