//
//  RoutineDetailSheet.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeOfDay: TimeOfDay = .morning
    @State private var isSaved = false
    @State private var showingStepDetail: RoutineStepDetail?

    let routine: RoutineTemplate
    let listViewModel: RoutineListViewModel

    enum TimeOfDay { case morning, evening }

    init(routine: RoutineTemplate, listViewModel: RoutineListViewModel) {
        self.routine = routine
        self.listViewModel = listViewModel
        self._isSaved = State(initialValue: false)
    }

    var body: some View {
        let palette = ThemeManager.shared.theme.palette
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 80))]

        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header (unchanged)
                    HeroHeader(
                        title: routine.title,
                        subtitle: "\(routine.stepCount) steps • \(routine.duration)",
                        imageName: routine.imageName
                    )

                    // Main content card
                    VStack(alignment: .leading, spacing: 20) {

                        // Metrics
                        MetricsPills(
                            palette: palette,
                            stepCount: routine.stepCount,
                            duration: routine.duration
                        )

                        // Description
                        Text(routine.description)
                            .font(.system(size: 16))
                            .foregroundColor(palette.textPrimary)

                        // Tags
                        if !routine.tags.isEmpty {
                            TagsView(tags: routine.tags, palette: palette, columns: columns)
                        }

                        // Time of Day picker
                        TimeOfDayPicker(selectedTimeOfDay: $selectedTimeOfDay, palette: palette)

                        // Benefits
                        if !routine.benefits.isEmpty {
                            BenefitsView(palette: palette, benefits: Array(routine.benefits.prefix(3)))
                        }

                        // Steps
                        StepsSection(
                            palette: palette,
                            steps: selectedTimeOfDay == .morning ? routine.morningSteps : routine.eveningSteps,
                            timeOfDay: selectedTimeOfDay,
                            onStepTap: { stepIndex in
                                showStepDetail(for: stepIndex)
                            }
                        )

                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(palette.cardBackground)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .sheet(item: $showingStepDetail) { stepDetail in
                RoutineStepDetailView(
                    stepDetail: stepDetail,
                    adaptedStep: nil
                )
            }
            .onAppear {
                Task {
                    do {
                        isSaved = try await listViewModel.routineService.isRoutineSaved(routine)
                    } catch {
                        print("❌ Failed to check if routine is saved: \(error)")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isSaved {
                            listViewModel.removeRoutineTemplate(routine)
                        } else {
                            listViewModel.saveRoutineTemplate(routine)
                        }
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(isSaved ? .warning : .success)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            isSaved.toggle()
                        }
                    }) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isSaved ? .red : .white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .scaleEffect(isSaved ? 1.05 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSaved)
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func showStepDetail(for index: Int) {
        let steps = selectedTimeOfDay == .morning ? routine.morningSteps : routine.eveningSteps
        guard index < steps.count else { return }

        let step = steps[index]

        // Use ProductAliasMapping.normalize to intelligently extract product type
        let productType = ProductAliasMapping.normalize(step.title)

        // Create a RoutineStepDetail from the template step
        let stepDetail = RoutineStepDetail(
            id: "template_\(routine.id)_\(selectedTimeOfDay == .morning ? "morning" : "evening")_\(index)",
            title: step.title,
            description: "Step \(index + 1) of your \(selectedTimeOfDay == .morning ? "morning" : "evening") routine",
            stepType: productType,
            timeOfDay: selectedTimeOfDay == .morning ? .morning : .evening,
            why: step.why,
            how: step.how
        )

        showingStepDetail = stepDetail
    }
}

// MARK: - Subviews

private struct HeroHeader: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 340)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 340)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .padding(.top, 60)
        }
        .frame(width: UIScreen.main.bounds.width, height: 340)
        .clipped()
    }
}

private struct TagsView: View {
    let tags: [String]
    let palette: ThemePalette
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(palette.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(palette.primary.opacity(0.1))
                        )
                }
            }
        }
    }
}

private struct TimeOfDayPicker: View {
    @Binding var selectedTimeOfDay: RoutineDetailSheet.TimeOfDay
    let palette: ThemePalette
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            option(title: "Morning", icon: "sun.max.fill", isActive: selectedTimeOfDay == .morning, activeFill: palette.warning) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    selectedTimeOfDay = .morning
                }
            }
            option(title: "Evening", icon: "moon.fill", isActive: selectedTimeOfDay == .evening, activeFill: palette.primary) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    selectedTimeOfDay = .evening
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(palette.border.opacity(0.2), lineWidth: 1)
        )
    }

    private func option(title: String, icon: String, isActive: Bool, activeFill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isActive ? .white : palette.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(activeFill)
                            .matchedGeometryEffect(id: "tod_bg", in: animation)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StepsSection: View {
    let palette: ThemePalette
    let steps: [TemplateRoutineStep]
    let timeOfDay: RoutineDetailSheet.TimeOfDay
    let onStepTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Routine Steps")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps.indices, id: \.self) { i in
                    StepRow(
                        index: i,
                        text: steps[i].title,
                        tint: timeOfDay == .morning ? palette.warning : palette.primary,
                        palette: palette,
                        onTap: { onStepTap(i) }
                    )
                }
            }
        }
    }
}

private struct StepRow: View {
    let index: Int
    let text: String
    let tint: Color
    let palette: ThemePalette
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(tint))

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(palette.textPrimary)
                .lineLimit(2)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(palette.textSecondary.opacity(0.8))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(palette.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(palette.border.opacity(0.12), lineWidth: 1)
        )
        .overlay(
            pressed ? RoundedRectangle(cornerRadius: 12).stroke(tint.opacity(0.3), lineWidth: 2) : nil
        )
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.15)) { pressed = false }
            }
            // Call the tap handler after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onTap()
            }
        }
    }
}

private struct BenefitsView: View {
    let palette: ThemePalette
    let benefits: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Benefits")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(benefits, id: \.self) { b in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(palette.success)
                            .padding(.top, 1)
                        Text(b)
                            .font(.system(size: 14))
                            .foregroundColor(palette.textPrimary)
                    }
                }
            }
        }
    }
}

private struct MetricsPills: View {
    let palette: ThemePalette
    let stepCount: Int
    let duration: String

    var body: some View {
        HStack(spacing: 8) {
            Pill(text: "\(stepCount) steps", icon: "list.number")
            Pill(text: duration, icon: "clock")
        }
    }

    private func Pill(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 12, weight: .semibold))
            Text(text).font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .foregroundColor(palette.textPrimary)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(palette.cardBackground.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(palette.border.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    RoutineDetailSheet(
        routine: RoutineTemplate.featuredRoutines.first!,
        listViewModel: RoutineListViewModel(
            routineService: ServiceFactory.shared.createRoutineService()
        )
    )
}
