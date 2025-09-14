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
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
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
            session = existingSession
            currentState = .stepIntro(existingSession.currentStepIndex)
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
        guard var session = session else { return }
        
        if let currentStep = session.currentStep {
            analyticsService.trackEvent(.stepComplete(
                stepId: currentStep.id,
                actualWait: currentStep.waitSeconds ?? 0,
                wasSkipped: false
            ))
        }
        
        session.completeCurrentStep()
        sessionStore.updateSession(session)
        self.session = session
        
        if session.isComplete {
            completeSession()
        } else {
            currentState = .stepIntro(session.currentStepIndex)
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
            currentState = .stepIntro(session.currentStepIndex)
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
        
        if let step = session?.currentStep {
            analyticsService.trackEvent(.timerPause(stepId: step.id, remainingSeconds: timerState.remainingSeconds))
        }
    }
    
    func resumeTimer() {
        timerState.isPaused = false
        timerState.pauseTime = nil
        currentState = .timerRunning(session?.currentStepIndex ?? 0)
        
        startCountdown()
    }
    
    func skipTimer() {
        guard let step = session?.currentStep else { return }
        
        analyticsService.trackEvent(.timerSkip(stepId: step.id, remainingSeconds: timerState.remainingSeconds))
        
        stopCountdown()
        timerState = TimerState()
        currentState = .stepComplete(session?.currentStepIndex ?? 0)
    }
    
    func adjustTimer(by seconds: Int) {
        let newSeconds = max(timerState.remainingSeconds + seconds, 10)
        let maxSeconds = session?.currentStep?.maxSeconds ?? 600
        timerState.remainingSeconds = min(newSeconds, maxSeconds)
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
        timerState = TimerState()
        currentState = .stepComplete(session?.currentStepIndex ?? 0)
        
        hapticsService.timerComplete()
        notificationService.cancelTimerNotifications()
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
        timerState.remainingSeconds = min(newSeconds, 600) // Max 10 minutes
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
