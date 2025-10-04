//
//  RoutineDetailSheet.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isStepsExpanded = false

    let routine: RoutineTemplate
    let listViewModel: RoutineListViewModel

    var body: some View {
        let palette = ThemeManager.shared.theme.palette
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 80))]

        let morningStepsToShow: [String] = {
            if isStepsExpanded { return routine.morningSteps }
            return Array(routine.morningSteps.prefix(2))
        }()

        let eveningStepsToShow: [String] = {
            if isStepsExpanded { return routine.eveningSteps }
            return Array(routine.eveningSteps.prefix(2))
        }()

        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HeroHeader(
                        title: routine.title,
                        subtitle: "\(routine.stepCount) steps • \(routine.duration)",
                        imageName: routine.imageName
                    )

                    VStack(alignment: .leading, spacing: 20) {

                        // Description
                        Text(routine.description)
                            .font(.system(size: 16))
                            .foregroundColor(palette.textPrimary)

                        // Tags
                        if !routine.tags.isEmpty {
                            TagsView(tags: routine.tags, palette: palette, columns: columns)
                        }

                        // Steps
                        StepsSection(
                            palette: palette,
                            morningSteps: morningStepsToShow,
                            eveningSteps: eveningStepsToShow,
                            isExpanded: isStepsExpanded,
                            totalStepsCount: routine.steps.count,
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isStepsExpanded.toggle()
                                }
                            }
                        )

                        // CTA
                        CTAButton(
                            title: "Add to My Routines",
                            palette: palette,
                            action: {
                                listViewModel.saveRoutineTemplate(routine)
                                dismiss()
                            }
                        )
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(palette.background)
                    )
                    .padding(.horizontal, 16)
                }
            }
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(palette.primary)
                }
            }
        }
    }
}

// MARK: - Subviews

private struct HeroHeader: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(24)
            }
        }
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

private struct StepsSection: View {
    let palette: ThemePalette
    let morningSteps: [String]
    let eveningSteps: [String]
    let isExpanded: Bool
    let totalStepsCount: Int
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Routine Steps")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(palette.textPrimary)

            if !morningSteps.isEmpty {
                SectionHeader(systemName: "sun.max.fill", title: "Morning", tint: palette.warning)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(morningSteps.indices, id: \.self) { i in
                        StepRow(index: i, text: morningSteps[i], tint: palette.warning, palette: palette)
                    }
                }
            }

            if !eveningSteps.isEmpty {
                SectionHeader(systemName: "moon.fill", title: "Evening", tint: palette.primary)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(eveningSteps.indices, id: \.self) { i in
                        StepRow(index: i, text: eveningSteps[i], tint: palette.primary, palette: palette)
                    }
                }
            }

            if totalStepsCount > 3 {
                Button(action: onToggle) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show less" : "+ \(totalStepsCount - 3) more steps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(palette.primary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(palette.primary)
                    }
                    .padding(.top, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SectionHeader: View {
    let systemName: String
    let title: String
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(tint)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.top, 4)
    }
}

private struct StepRow: View {
    let index: Int
    let text: String
    let tint: Color
    let palette: ThemePalette

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(tint))

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(palette.textPrimary)

            Spacer()
        }
    }
}

private struct CTAButton: View {
    let title: String
    let palette: ThemePalette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(palette.primary)
            )
        }
    }
}

#Preview {
    RoutineDetailSheet(
        routine: RoutineTemplate.featuredRoutines.first!,
        listViewModel: RoutineListViewModel(routineService: ServiceFactory.shared.createRoutineService())
    )
}
