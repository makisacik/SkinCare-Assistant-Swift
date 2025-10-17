//
//  CompanionModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Companion Session Models

struct CompanionSession: Identifiable, Codable {
    let id: String
    let routineId: String
    let routineName: String
    let startedAt: Date
    var currentStepIndex: Int
    var remainingSeconds: Int?
    var status: SessionStatus
    var stepsCompleted: [String]
    var totalDurationSeconds: Int
    var skips: Int
    var steps: [CompanionStep]
    
    init(id: String = UUID().uuidString, routineId: String, routineName: String, steps: [CompanionStep]) {
        self.id = id
        self.routineId = routineId
        self.routineName = routineName
        self.startedAt = Date()
        self.currentStepIndex = 0
        self.remainingSeconds = nil
        self.status = .active
        self.stepsCompleted = []
        self.totalDurationSeconds = 0
        self.skips = 0
        self.steps = steps
    }
}

enum SessionStatus: String, Codable, CaseIterable {
    case active, paused, completed, abandoned
    
    var displayName: String {
        switch self {
        case .active: return L10n.Routines.Companion.Status.active
        case .paused: return L10n.Routines.Companion.Status.paused
        case .completed: return L10n.Routines.Companion.Status.completed
        case .abandoned: return L10n.Routines.Companion.Status.abandoned
        }
    }
}

struct CompanionStep: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let instruction: String
    let mediaAssetId: String?
    let type: StepType
    let waitSeconds: Int?
    let minSeconds: Int
    let maxSeconds: Int
    let haptics: Bool
    let stepType: ProductType
    let timeOfDay: TimeOfDay
    
    init(id: String, order: Int, title: String, instruction: String, mediaAssetId: String? = nil, type: StepType, waitSeconds: Int? = nil, minSeconds: Int = 10, maxSeconds: Int = 600, haptics: Bool = true, stepType: ProductType, timeOfDay: TimeOfDay) {
        self.id = id
        self.order = order
        self.title = title
        self.instruction = instruction
        self.mediaAssetId = mediaAssetId
        self.type = type
        self.waitSeconds = waitSeconds
        self.minSeconds = minSeconds
        self.maxSeconds = maxSeconds
        self.haptics = haptics
        self.stepType = stepType
        self.timeOfDay = timeOfDay
    }
}

enum StepType: String, Codable, CaseIterable {
    case instruction, timed
    
    var displayName: String {
        switch self {
        case .instruction: return L10n.Routines.Companion.StepType.instruction
        case .timed: return L10n.Routines.Companion.StepType.timed
        }
    }
}

// MARK: - Session State Machine

enum SessionState: Equatable {
    case idle
    case routineAlreadyCompleted
    case stepIntro(Int)
    case timerIdle(Int)
    case timerRunning(Int)
    case timerPaused(Int)
    case routineComplete
    
    var stepIndex: Int? {
        switch self {
        case .stepIntro(let index), .timerIdle(let index), .timerRunning(let index), .timerPaused(let index):
            return index
        case .idle, .routineAlreadyCompleted, .routineComplete:
            return nil
        }
    }
}

// MARK: - Timer State

struct TimerState {
    var isRunning: Bool = false
    var isPaused: Bool = false
    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    var startTime: Date?
    var pauseTime: Date?
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Session Result

struct SessionResult: Codable {
    let sessionId: String
    let routineId: String
    let completedAt: Date
    let totalDurationSeconds: Int
    let stepsCompleted: [String]
    let skips: Int
    let completionRate: Double
    
    init(session: CompanionSession) {
        self.sessionId = session.id
        self.routineId = session.routineId
        self.completedAt = Date()
        self.totalDurationSeconds = session.totalDurationSeconds
        self.stepsCompleted = session.stepsCompleted
        self.skips = session.skips
        self.completionRate = session.steps.isEmpty ? 0.0 : Double(session.stepsCompleted.count) / Double(session.steps.count)
    }
}

// MARK: - Extensions

extension CompanionStep {
    /// Convert from existing RoutineStepDetail to CompanionStep
    static func from(routineStep: RoutineStepDetail, order: Int) -> CompanionStep {
        // Determine if this step should have a timer based on step type
        let hasTimer = shouldHaveTimer(for: routineStep.stepType)
        let waitSeconds = hasTimer ? getDefaultWaitTime(for: routineStep.stepType) : nil
        
        return CompanionStep(
            id: routineStep.id,
            order: order,
            title: routineStep.title,
            instruction: routineStep.how ?? routineStep.description,
            type: hasTimer ? .timed : .instruction,
            waitSeconds: waitSeconds,
            stepType: routineStep.stepType,
            timeOfDay: routineStep.timeOfDay
        )
    }
    
    private static func shouldHaveTimer(for stepType: ProductType) -> Bool {
        switch stepType {
        case .cleanser, .faceSerum, .moisturizer, .sunscreen, .faceSunscreen:
            return true
        default:
            return false
        }
    }
    
    private static func getDefaultWaitTime(for stepType: ProductType) -> Int {
        switch stepType {
        case .cleanser:
            return 30 // 30 seconds to let cleanser work
        case .faceSerum:
            return 60 // 1 minute for serum absorption
        case .moisturizer:
            return 45 // 45 seconds for moisturizer absorption
        case .sunscreen, .faceSunscreen:
            return 45 // 45 seconds for proper sunscreen application
        default:
            return 30
        }
    }
}

extension CompanionSession {
    var currentStep: CompanionStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        let clampedIndex = min(currentStepIndex, steps.count)
        return Double(clampedIndex) / Double(steps.count)
    }
    
    var isComplete: Bool {
        return currentStepIndex >= steps.count
    }
    
    mutating func completeCurrentStep() {
        guard let step = currentStep else { return }
        stepsCompleted.append(step.id)
        currentStepIndex += 1
        remainingSeconds = nil

        // Ensure currentStepIndex doesn't exceed bounds
        if currentStepIndex > steps.count {
            currentStepIndex = steps.count
        }
    }
    
    mutating func skipCurrentStep() {
        guard let step = currentStep else { return }
        skips += 1
        currentStepIndex += 1
        remainingSeconds = nil

        // Ensure currentStepIndex doesn't exceed bounds
        if currentStepIndex > steps.count {
            currentStepIndex = steps.count
        }
    }
    
    mutating func startTimer(for step: CompanionStep) {
        remainingSeconds = step.waitSeconds
    }
    
    mutating func pauseTimer() {
        status = .paused
    }
    
    mutating func resumeTimer() {
        status = .active
    }
    
    mutating func completeSession() {
        status = .completed
        totalDurationSeconds = Int(Date().timeIntervalSince(startedAt))
    }
}
