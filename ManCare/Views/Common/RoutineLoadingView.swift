//
//  RoutineLoadingView.swift
//  ManCare
//
//  A modern loading screen with animated gradient background,
//  morphing ring, and rotating status messages.
//  Specifically designed for routine creation flows.
//  Works with ThemeManager palette & typography.

import SwiftUI

struct RoutineLoadingView: View {
    @Environment(\.colorScheme)  private var cs

    // Public API
    let statuses: [String]
    var stepInterval: TimeInterval = 1.6
    var autoFinish: Bool = true
    var onCancel: (() -> Void)? = nil
    var onFinished: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil

    // Internal state
    @State private var idx: Int = 0
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // MARK: Ring Loader
                ZStack {
                    // subtle halo
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 8)

                    MorphingRing(progress: progress)
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .fill(AngularGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.shared.theme.palette.secondaryLight,
                                ThemeManager.shared.theme.palette.primary,
                                ThemeManager.shared.theme.palette.secondaryLight,
                                ThemeManager.shared.theme.palette.primaryLight
                            ]),
                            center: .center
                        ))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: rotation)
                        .shadow(color: ThemeManager.shared.theme.palette.secondary.opacity(0.35), radius: 12, x: 0, y: 8)

                    // pulsing inner dot
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.secondary)
                        .frame(width: pulse ? 14 : 10, height: pulse ? 14 : 10)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                }

                // MARK: Status text
                VStack(spacing: 6) {
                    Text(currentStatus)
                        .font(ThemeManager.shared.theme.typo.h3)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    Text(hintText)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

                // Action buttons
                VStack(spacing: 12) {
                    // (Optional) Cancel
                    if onCancel != nil {
                        Button("Cancel") {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            stopTimer()
                            onCancel?()
                        }
                        .buttonStyle(GhostButtonStyle())
                        .frame(maxWidth: 280)
                    }

                    // (Optional) Back
                    if onBack != nil {
                        Button("Back") {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            stopTimer()
                            onBack?()
                        }
                        .buttonStyle(GhostButtonStyle())
                        .frame(maxWidth: 280)
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            ThemeManager.shared.refreshForSystemChange(cs)
            start()
        }
        .onDisappear {
            stopTimer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(currentStatus))
        .accessibilityHint(Text("Please wait while we prepare your results"))
    }

    private var currentStatus: String {
        guard !statuses.isEmpty else { return "Loading…" }
        return statuses[max(0, min(idx, statuses.count - 1))]
    }

    private var hintText: String {
        // a subtle, consistent helper line
        "This may take a few seconds."
    }

    // MARK: Lifecycle
    private func start() {
        // animate ring + pulse
        rotation = 360
        pulse.toggle()

        // progress anim (visual only; you can bind real progress here)
        withAnimation(.easeInOut(duration: stepInterval).repeatForever(autoreverses: true)) {
            progress = 0.85
        }

        guard statuses.count > 0 else { return }
        // step through messages
        let t = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { _ in
            let next = idx + 1
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()

            if next < statuses.count {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                    idx = next
                }
            } else {
                stopTimer()
                if autoFinish {
                    // small delay to let the last status breathe
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        onFinished?()
                    }
                }
            }
        }
        timer = t
        RunLoop.current.add(t, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Animated Background

private struct AnimatedGradientBackground: View {
    @State private var move: Bool = false

    var body: some View {
        LinearGradient(
            colors: [
                ThemeManager.shared.theme.palette.surface,                // Surface color
                ThemeManager.shared.theme.palette.surfaceAlt,             // Surface alt
                ThemeManager.shared.theme.palette.accentBackground        // Accent background
            ],
            startPoint: move ? .topLeading : .bottomTrailing,
            endPoint: move ? .bottomTrailing : .topLeading
        )
        .overlay(
            RadialGradient(
                colors: [
                    ThemeManager.shared.theme.palette.secondary.opacity(0.25),
                    .clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 480
            )
        )
        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: move)
        .onAppear { move.toggle() }
    }
}

// MARK: - Morphing Ring Shape

private struct MorphingRing: Shape {
    // progress modulates the ring’s open/close and subtle wobble
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let line: CGFloat = 12
        let insetRect = rect.insetBy(dx: line, dy: line)

        // open arc window that breathes with progress
        let openness = CGFloat(0.28 + 0.15 * sin(Double(progress) * .pi))
        let start = -CGFloat.pi / 2
        let end = start + (2 * .pi) * (1 - openness)

        p.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                 radius: min(insetRect.width, insetRect.height) / 2,
                 startAngle: .radians(Double(start)),
                 endAngle: .radians(Double(end)),
                 clockwise: false)
        return p
    }
}

// MARK: - Previews

#Preview("Routine Loading – Light") {
    RoutineLoadingView(
        statuses: [
            "Analyzing your skin type…",
            "Preparing routine results…",
            "Selecting targeted tips…",
            "Optimizing for your goals…"
        ],
        onFinished: {},
        onBack: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Routine Loading – Dark") {
    RoutineLoadingView(
        statuses: [
            "Analyzing your skin type…",
            "Preparing routine results…",
            "Selecting targeted tips…",
            "Optimizing for your goals…"
        ],
        onFinished: {},
        onBack: {}
    )
    .preferredColorScheme(.dark)
}
