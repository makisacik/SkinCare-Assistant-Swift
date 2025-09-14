//
//  CompanionSessionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct CompanionSessionView: View {
    @StateObject private var sessionViewModel = CompanionSessionViewModel()
    @StateObject private var stepViewModel = StepViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let routineId: String
    let routineName: String
    let steps: [CompanionStep]
    let onComplete: (() -> Void)?
    
    init(routineId: String, routineName: String, steps: [CompanionStep], onComplete: (() -> Void)? = nil) {
        self.routineId = routineId
        self.routineName = routineName
        self.steps = steps
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    headerView
                    
                    contentView
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("🚀 CompanionSessionView appeared with \(steps.count) steps")
            print("📋 Steps: \(steps.map { $0.title })")
            print("🆔 Routine ID: \(routineId)")
            print("📝 Routine Name: \(routineName)")
            sessionViewModel.startSession(routineId: routineId, routineName: routineName, steps: steps)
        }
        .onChange(of: sessionViewModel.currentState) { newState in
            print("🔄 State changed to: \(newState)")
            handleStateChange(newState)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.shared.theme.palette.background,
                ThemeManager.shared.theme.palette.surface,
                ThemeManager.shared.theme.palette.background
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top bar with progress and close button
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                Spacer()
                
                // Progress indicator
                if let session = sessionViewModel.session {
                    HStack(spacing: 8) {
                        Text("\(session.currentStepIndex + 1) of \(session.steps.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        ProgressView(value: session.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: ThemeManager.shared.theme.palette.primary))
                            .frame(width: 60)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Routine title
            Text(routineName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch sessionViewModel.currentState {
        case .idle:
            VStack(spacing: 16) {
                ProgressView()
                Text("Preparing Companion Mode...")
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            .padding()

        case .stepIntro(let index):
            if let session = sessionViewModel.session, index < session.steps.count {
                StepIntroView(
                    step: session.steps[index],
                    stepViewModel: stepViewModel,
                    onStartTimer: {
                        sessionViewModel.startTimer()
                    },
                    onCompleteStep: {
                        stepViewModel.completeStep()
                        sessionViewModel.nextStep()
                    },
                    onSkipStep: {
                        sessionViewModel.skipStep()
                    }
                )
            } else {
                Text("Loading step...")
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

        case .timerIdle(let index):
            if let session = sessionViewModel.session, index < session.steps.count {
                StepIntroView(
                    step: session.steps[index],
                    stepViewModel: stepViewModel,
                    onStartTimer: {
                        sessionViewModel.startTimer()
                    },
                    onCompleteStep: {
                        stepViewModel.completeStep()
                        sessionViewModel.nextStep()
                    },
                    onSkipStep: {
                        sessionViewModel.skipStep()
                    }
                )
            } else {
                Text("Loading step...")
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

        case .timerRunning:
            if let session = sessionViewModel.session, let step = session.currentStep {
                TimerView(
                    step: step,
                    timerState: sessionViewModel.timerState,
                    onPause: {
                        if sessionViewModel.timerState.isPaused {
                            sessionViewModel.resumeTimer()
                        } else {
                            sessionViewModel.pauseTimer()
                        }
                    },
                    onSkip: {
                        sessionViewModel.skipTimer()
                    },
                    onAdjust: { delta in
                        sessionViewModel.adjustTimer(by: delta)
                    }
                )
            }

        case .timerPaused:
            if let session = sessionViewModel.session, let step = session.currentStep {
                TimerView(
                    step: step,
                    timerState: sessionViewModel.timerState,
                    onPause: {
                        sessionViewModel.resumeTimer()
                    },
                    onSkip: {
                        sessionViewModel.skipTimer()
                    },
                    onAdjust: { delta in
                        sessionViewModel.adjustTimer(by: delta)
                    }
                )
            }

        case .stepComplete:
            if let session = sessionViewModel.session, let step = session.currentStep {
                StepCompleteView(step: step) {
                    sessionViewModel.nextStep()
                }
            }

        case .routineComplete:
            CompletionView(session: sessionViewModel.session) {
                onComplete?()
                dismiss()
            }
        }
    }
    
    private func handleStateChange(_ newState: SessionState) {
        switch newState {
        case .stepIntro(let stepIndex):
            if let session = sessionViewModel.session, stepIndex < session.steps.count {
                stepViewModel.setStep(session.steps[stepIndex])
            }
            
        case .routineComplete:
            // Session completed
            break
            
        default:
            break
        }
    }
}

// MARK: - Step Intro View

struct StepIntroView: View {
    let step: CompanionStep
    @ObservedObject var stepViewModel: StepViewModel
    let onStartTimer: () -> Void
    let onCompleteStep: () -> Void
    let onSkipStep: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Step icon and title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(stepViewModel.stepColor.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: stepViewModel.iconName)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(stepViewModel.stepColor)
                    }
                    
                    Text(step.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                }
                
                // Instruction
                VStack(spacing: 16) {
                    Text("Instructions")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text(step.instruction)
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                        )
                )
                
                // Action buttons
                VStack(spacing: 16) {
                    if step.type == .timed {
                        Button {
                            onStartTimer()
                        } label: {
                            HStack {
                                Image(systemName: "timer")
                                Text("Start Timer (\(step.waitSeconds ?? 0)s)")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(stepViewModel.stepColor)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack(spacing: 16) {
                        Button {
                            onCompleteStep()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Done")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.success)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.success, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            onSkipStep()
                        } label: {
                            HStack {
                                Image(systemName: "forward.fill")
                                Text("Skip")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Timer View

struct TimerView: View {
    let step: CompanionStep
    let timerState: TimerState
    let onPause: () -> Void
    let onSkip: () -> Void
    let onAdjust: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // Timer circle
            ZStack {
                Circle()
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: timerState.progress)
                    .stroke(
                        ThemeManager.shared.theme.palette.primary,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerState.progress)
                
                VStack(spacing: 8) {
                    Text(timerState.formattedTime)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text(step.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Timer controls
            VStack(spacing: 20) {
                // Adjust buttons
                HStack(spacing: 20) {
                    Button {
                        onAdjust(-15)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    Text("Adjust")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    
                    Button {
                        onAdjust(15)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
                
                // Main control buttons
                HStack(spacing: 20) {
                    Button {
                        onPause()
                    } label: {
                        HStack {
                            Image(systemName: timerState.isPaused ? "play.fill" : "pause.fill")
                            Text(timerState.isPaused ? "Resume" : "Pause")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.primary)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        onSkip()
                    } label: {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text("Skip")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Step Complete View

struct StepCompleteView: View {
    let step: CompanionStep
    let onNext: () -> Void
    
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Checkmark animation
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.theme.palette.success.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCheckmark)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.success)
                    .scaleEffect(showCheckmark ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showCheckmark)
            }
            
            VStack(spacing: 16) {
                Text("Step Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                
                Text(step.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }
            
            Button {
                onNext()
            } label: {
                HStack {
                    Text("Next Step")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.theme.palette.primary)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            showCheckmark = true
        }
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let session: CompanionSession?
    let onComplete: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Celebration animation
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.theme.palette.success.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .scaleEffect(showConfetti ? 1.1 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showConfetti)
                
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.success)
                    .scaleEffect(showConfetti ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: showConfetti)
            }
            
            VStack(spacing: 16) {
                Text("Routine Complete! 🎉")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let session = session {
                    Text("You completed \(session.stepsCompleted.count) of \(session.steps.count) steps")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Stats
            if let session = session {
                VStack(spacing: 12) {
                    StatRow(title: "Total Time", value: formatDuration(session.totalDurationSeconds))
                    StatRow(title: "Steps Skipped", value: "\(session.skips)")
                    StatRow(title: "Completion Rate", value: "\(Int((Double(session.stepsCompleted.count) / Double(session.steps.count)) * 100))%")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeManager.shared.theme.palette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)
            }
            
            Button {
                onComplete()
            } label: {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.theme.palette.primary)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            showConfetti = true
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview("CompanionSessionView") {
    CompanionSessionView(
        routineId: "morning_routine",
        routineName: "Morning Routine",
        steps: [
            CompanionStep(
                id: "step1",
                order: 1,
                title: "Cleanser",
                instruction: "Apply to damp skin and massage gently for 30 seconds",
                type: .timed,
                waitSeconds: 30,
                stepType: .cleanser,
                timeOfDay: .morning
            ),
            CompanionStep(
                id: "step2",
                order: 2,
                title: "Moisturizer",
                instruction: "Apply a pea-sized amount and massage in upward motions",
                type: .instruction,
                stepType: .moisturizer,
                timeOfDay: .morning
            )
        ]
    )
}
