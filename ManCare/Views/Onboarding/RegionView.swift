//
//  RegionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RegionView: View {
    
    @Environment(\.colorScheme) private var cs

    @State private var selection: Region? = nil
    @State private var selectedClimateIndex: Int = 0
    var onContinue: (Region) -> Void
    var onBack: () -> Void

    private let regions = Region.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with back button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(ThemeManager.shared.theme.typo.body.weight(.medium))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)

            // Title section
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your climate like?")
                    .font(ThemeManager.shared.theme.typo.h1)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                Text("Your environment affects your skin's UV exposure and hydration needs.")
                    .font(ThemeManager.shared.theme.typo.sub)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            }

            // Climate visualization
            VStack(spacing: 16) {
                // Climate wheel/selector
                ClimateWheel(regions: regions, selectedIndex: $selectedClimateIndex, selection: $selection)

                // Climate details - fixed height
                if let selectedRegion = selection {
                    ClimateDetailCard(region: selectedRegion)
                        .frame(maxHeight: 200)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer(minLength: 8)

            // Continue button
            Button {
                guard let picked = selection else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue(picked)
            } label: {
                Text(selection == nil ? "Continue" : "Continue with \(selection!.title)")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.7 : 1.0)
        }
        .padding(20)
        .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
        .onAppear {
            // Set initial selection to temperate
            selection = .temperate
            selectedClimateIndex = 2
        }
    }
}

// MARK: - Climate Wheel

private struct ClimateWheel: View {
    
    let regions: [Region]
    @Binding var selectedIndex: Int
    @Binding var selection: Region?

    var body: some View {
        VStack(spacing: 12) {
            // Climate wheel
            ZStack {
                // Background circle
                Circle()
                    .fill(ThemeManager.shared.theme.palette.cardBackground.opacity(0.3))
                    .frame(width: 240, height: 240)
                    .overlay(
                        Circle()
                            .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 2)
                    )

                // Climate segments
                ForEach(Array(regions.enumerated()), id: \.offset) { index, region in
                    ClimateSegment(
                        region: region,
                        index: index,
                        totalCount: regions.count,
                        isSelected: selectedIndex == index
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedIndex = index
                            selection = region
                        }
                    }
                }

                // Center info
                VStack(spacing: 4) {
                    if let selectedRegion = selection {
                        Image(systemName: selectedRegion.iconName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(selectedRegion.climateColor)
                        Text(selectedRegion.title)
                            .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.accentBackground)
                        .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 4, x: 0, y: 2)
                )
            }

            // Climate gradient bar
            HStack(spacing: 0) {
                ForEach(Array(regions.enumerated()), id: \.offset) { index, region in
                    Rectangle()
                        .fill(region.climateColor)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack {
                                Spacer()
                                Text(region.title.prefix(3).uppercased())
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                                    .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                            .padding(.bottom, 2)
                        )
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedIndex = index
                                selection = region
                            }
                        }
                }
            }
            .frame(height: 24)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
            )
        }
    }
}

// MARK: - Climate Segment

private struct ClimateSegment: View {
    
    let region: Region
    let index: Int
    let totalCount: Int
    let isSelected: Bool

    private var angle: Double {
        (Double(index) / Double(totalCount)) * 360
    }

    private var segmentAngle: Double {
        360.0 / Double(totalCount)
    }

    var body: some View {
        ZStack {
            // Segment background
            Circle()
                .trim(from: angle / 360, to: (angle + segmentAngle) / 360)
                .stroke(
                    isSelected ? region.climateColor : region.climateColor.opacity(0.3),
                    style: StrokeStyle(lineWidth: isSelected ? 8 : 4, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))

            // Icon
            GeometryReader { geometry in
                Image(systemName: region.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? region.climateColor : region.climateColor.opacity(0.6))
                    .position(
                        x: geometry.size.width / 2 + cos((angle + segmentAngle / 2) * .pi / 180) * 85,
                        y: geometry.size.height / 2 + sin((angle + segmentAngle / 2) * .pi / 180) * 85
                    )
            }
            .frame(width: 200, height: 200)
        }
    }
}

// MARK: - Climate Detail Card

private struct ClimateDetailCard: View {
    
    let region: Region

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(region.climateColor)
                        .frame(width: 50, height: 50)
                    Image(systemName: region.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(region.title)
                        .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    Text(region.temperatureLevel)
                        .font(ThemeManager.shared.theme.typo.caption)
                        .foregroundColor(region.climateColor)
                }

                Spacer()
            }

            // Climate info grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ClimateInfoItem(
                    icon: "sun.max.fill",
                    title: "UV Index",
                    value: region.averageUVIndex,
                    color: ThemeManager.shared.theme.palette.warning
                )

                ClimateInfoItem(
                    icon: "humidity.fill",
                    title: "Humidity",
                    value: region.humidityLevel,
                    color: ThemeManager.shared.theme.palette.info
                )

                ClimateInfoItem(
                    icon: "thermometer",
                    title: "Temperature",
                    value: region.temperatureLevel,
                    color: ThemeManager.shared.theme.palette.error
                )

                ClimateInfoItem(
                    icon: "shield.fill",
                    title: "SPF Need",
                    value: region.averageUVIndex.contains("High") ? "High" : "Moderate",
                    color: ThemeManager.shared.theme.palette.success
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius, style: .continuous)
                .fill(ThemeManager.shared.theme.palette.cardBackground)
                .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cardRadius)
                        .stroke(region.climateColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Climate Info Item

private struct ClimateInfoItem: View {
    
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(ThemeManager.shared.theme.palette.accentBackground.opacity(0.5))
        )
    }
}

#Preview("RegionView - Light") {
    RegionView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.light)
}

#Preview("RegionView - Dark") {
    RegionView(onContinue: { _ in }, onBack: {})
        .preferredColorScheme(.dark)
}
