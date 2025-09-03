//
//  LifestyleQuestionsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - Model

struct LifestyleAnswers: Codable, Equatable {
    enum SleepQuality: String, CaseIterable, Identifiable, Codable { case poor, average, good
        var id: String { rawValue }; var label: String { rawValue.capitalized } }
    enum ExerciseFreq: String, CaseIterable, Identifiable, Codable { case none, oneToTwo, threeToFour, fivePlus
        var id: String { rawValue }
        var label: String {
            switch self {
            case .none: return "None"
            case .oneToTwo: return "1–2 / week"
            case .threeToFour: return "3–4 / week"
            case .fivePlus: return "5+ / week"
            }
        }
    }
    enum RoutineDepth: String, CaseIterable, Identifiable, Codable { case minimal, standard, detailed
        var id: String { rawValue }
        var label: String {
            switch self {
            case .minimal:  return "2–3 steps"
            case .standard: return "3–4 steps"
            case .detailed: return "4–5 steps"
            }
        }
    }
    enum SunResponse: String, CaseIterable, Identifiable, Codable { case rarely, sometimes, easily
        var id: String { rawValue }
        var label: String {
            switch self {
            case .rarely:   return "Rarely burns"
            case .sometimes:return "Sometimes burns"
            case .easily:   return "Easily burns"
            }
        }
    }

    // Optional fields – leave nil if user skips or doesn't know
    var sleep: SleepQuality? = nil
    var outdoorHours: Int? = nil           // per day
    var smokes: Bool? = nil
    var drinksAlcohol: Bool? = nil
    var exercise: ExerciseFreq? = nil
    var fragranceFree: Bool? = nil
    var naturalPreference: Bool? = nil
    var routineDepth: RoutineDepth? = nil
    var sensitiveSkin: Bool? = nil
    var sunResponse: SunResponse? = nil
}

// MARK: - View

struct LifestyleQuestionsView: View {
    @Environment(\.themeManager) private var tm
    @Environment(\.colorScheme)  private var cs

    @State private var answers = LifestyleAnswers()
    var onContinue: (LifestyleAnswers) -> Void = { _ in }
    var onSkip: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil



    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header with back button
                HStack {
                    if let onBack = onBack {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onBack()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(tm.theme.typo.body.weight(.medium))
                            }
                            .foregroundColor(tm.theme.palette.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .padding(.top, 8)

                // Title section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lifestyle Questions")
                        .font(tm.theme.typo.h1)
                        .foregroundColor(tm.theme.palette.textPrimary)
                    Text("Help us understand your daily habits and preferences to create a more personalized routine.")
                        .font(tm.theme.typo.sub)
                        .foregroundColor(tm.theme.palette.textSecondary)
                }
                .padding(.top, 8)

                Group { // Lifestyle
                    SectionHeader(title: "Lifestyle")
                    SegmentedCard(title: "Sleep Quality",
                                  items: LifestyleAnswers.SleepQuality.allCases.map(\.label),
                                  selectionIndex: bindingIndex(
                                    from: answers.sleep,
                                    allCases: LifestyleAnswers.SleepQuality.allCases
                                  ) { answers.sleep = $0 })
                    StepRow(title: "Time outdoors (hrs/day)",
                            value: Binding(
                                get: { answers.outdoorHours ?? 0 },
                                set: { answers.outdoorHours = $0 }
                            ),
                            range: 0...10,
                            step: 1)
                    ToggleRow(title: "Do you smoke?", value: Binding(get: { answers.smokes ?? false },
                                                                     set: { answers.smokes = $0 }))
                    ToggleRow(title: "Do you drink alcohol?", value: Binding(get: { answers.drinksAlcohol ?? false },
                                                                              set: { answers.drinksAlcohol = $0 }))
                    SegmentedCard(title: "Exercise Frequency",
                                  items: LifestyleAnswers.ExerciseFreq.allCases.map(\.label),
                                  selectionIndex: bindingIndex(
                                    from: answers.exercise,
                                    allCases: LifestyleAnswers.ExerciseFreq.allCases
                                  ) { answers.exercise = $0 })
                }
                .themedCard()

                Group { // Skin habits & goals
                    SectionHeader(title: "Skin Habits & Goals")
                    SegmentedCard(title: "Desired Routine Depth",
                                  items: LifestyleAnswers.RoutineDepth.allCases.map(\.label),
                                  selectionIndex: bindingIndex(
                                    from: answers.routineDepth,
                                    allCases: LifestyleAnswers.RoutineDepth.allCases
                                  ) { answers.routineDepth = $0 })
                }
                .themedCard()

                Group { // Product preferences
                    SectionHeader(title: "Product Preferences")
                    ToggleRow(title: "Fragrance-free only",
                              value: Binding(get: { answers.fragranceFree ?? false },
                                             set: { answers.fragranceFree = $0 }))
                    ToggleRow(title: "Prefer natural/clean formulas",
                              value: Binding(get: { answers.naturalPreference ?? false },
                                             set: { answers.naturalPreference = $0 }))
                }
                .themedCard()

                Group { // Sensitivities & sun
                    SectionHeader(title: "Sensitivity & Sun")
                    ToggleRow(title: "Sensitive skin",
                              value: Binding(get: { answers.sensitiveSkin ?? false },
                                             set: { answers.sensitiveSkin = $0 }))
                    SegmentedCard(title: "In the sun, your skin…",
                                  items: LifestyleAnswers.SunResponse.allCases.map(\.label),
                                  selectionIndex: bindingIndex(
                                    from: answers.sunResponse,
                                    allCases: LifestyleAnswers.SunResponse.allCases
                                  ) { answers.sunResponse = $0 })
                }
                .themedCard()

                // Actions
                VStack(spacing: 12) {
                    Button("Continue") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onContinue(answers)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    if let onSkip {
                        Button("Skip for now") {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onSkip()
                        }
                        .buttonStyle(GhostButtonStyle())
                    }
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .background(tm.theme.palette.bg.ignoresSafeArea())
        .onChange(of: cs) { newScheme in
            tm.refreshForSystemChange(newScheme)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper to bind segmented selection by index
    private func bindingIndex<T: Identifiable & Equatable>(from value: T?,
                                                           allCases: [T],
                                                           onChange: @escaping (T?) -> Void) -> Binding<Int?> {
        Binding<Int?>(
            get: {
                guard let v = value, let idx = allCases.firstIndex(of: v) else { return nil }
                return idx
            },
            set: { newIdx in
                if let i = newIdx, i >= 0 && i < allCases.count {
                    onChange(allCases[i])
                } else {
                    onChange(nil)
                }
            }
        )
    }
}

// MARK: - Subviews

private struct SectionHeader: View {
    @Environment(\.themeManager) private var tm
    let title: String
    var body: some View {
        Text(title)
            .font(tm.theme.typo.h3)
            .foregroundColor(tm.theme.palette.textPrimary)
            .padding(.bottom, 4)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct ToggleRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    @Binding var value: Bool
    var body: some View {
        HStack {
            Text(title)
                .font(tm.theme.typo.body)
                .foregroundColor(tm.theme.palette.textPrimary)
            Spacer()
            Toggle("", isOn: $value)
                .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}

private struct StepRow: View {
    @Environment(\.themeManager) private var tm
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(tm.theme.typo.body)
                    .foregroundColor(tm.theme.palette.textPrimary)
                Spacer()
                Text("\(value)")
                    .font(tm.theme.typo.title)
                    .foregroundColor(tm.theme.palette.secondary)
            }
            Slider(value: Binding(get: {
                Double(value)
            }, set: { newVal in
                value = min(max(Int(newVal.rounded()), range.lowerBound), range.upperBound)
            }), in: Double(range.lowerBound)...Double(range.upperBound), step: Double(step))
        }
        .padding(.vertical, 6)
    }
}

private struct SegmentedCard: View {
    @Environment(\.themeManager) private var tm
    let title: String
    let items: [String]
    @Binding var selectionIndex: Int?

    init(title: String, items: [String], selectionIndex: Binding<Int?>) {
        self.title = title
        self.items = items
        self._selectionIndex = selectionIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(tm.theme.typo.body.weight(.semibold))
                .foregroundColor(tm.theme.palette.textPrimary)

            // Pills
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    let isSelected = selectionIndex == i
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectionIndex = (selectionIndex == i) ? nil : i
                        }
                    } label: {
                        Text(items[i])
                            .font(tm.theme.typo.sub.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? tm.theme.palette.secondary : tm.theme.palette.separator.opacity(0.35))
                            .foregroundColor(isSelected ? .white : tm.theme.palette.textPrimary)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// Simple flow layout for pills using LazyVGrid
private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let lineSpacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: spacing)
        ], spacing: lineSpacing) {
            content
        }
    }
}

// MARK: - Previews

#Preview("Lifestyle – Light") {
    let tm = ThemeManager()
    LifestyleQuestionsView(
        onContinue: { _ in },
        onSkip: nil,
        onBack: {}
    )
        .themed(tm)
        .preferredColorScheme(.light)
}

#Preview("Lifestyle – Dark") {
    let tm = ThemeManager()
    LifestyleQuestionsView(
        onContinue: { _ in },
        onSkip: nil,
        onBack: {}
    )
        .themed(tm)
        .preferredColorScheme(.dark)
}
