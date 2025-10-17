//
//  WeatherAdaptationCard.swift
//  ManCare
//
//  Created for weather-based routine adaptation
//

import SwiftUI

struct WeatherAdaptationCard: View {
    @StateObject private var preferencesStore = WeatherPreferencesStore.shared
    @StateObject private var locationService = LocationService()
    @State private var weatherData: WeatherData?
    @State private var isLoading = false
    @State private var showingDetailSheet = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if preferencesStore.isWeatherAdaptationEnabled && weatherData != nil {
                // State 2: Active Weather Card
                activeWeatherCard
            } else {
                // State 1: Permission Request Card
                permissionRequestCard
            }
        }
        .padding(.horizontal, 20)
        .task {
            await loadWeatherData()
            await autoEnableIfPermissionGranted()
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let weather = weatherData {
                WeatherDetailSheet(weatherData: weather)
            }
        }
    }

    // MARK: - Auto-enable Helper

    private func autoEnableIfPermissionGranted() async {
        // If user already has location permission but weather adaptation isn't enabled,
        // enable it automatically
        let isEnabled = await preferencesStore.isWeatherAdaptationEnabled
        if locationService.permissionState.isAuthorized && !isEnabled {
            print("📍 Location permission already granted, auto-enabling weather adaptation")
            let weatherService = WeatherService.shared
            do {
                _ = try await weatherService.requestLocationPermissionAndFetch()
            } catch {
                print("⚠️ Failed to auto-enable: \(error)")
            }
        }
    }

    // MARK: - State 1: Permission Request Card

    private var permissionRequestCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Routines.Weather.autoAdapt)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.error)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(L10n.Routines.Weather.description)
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()
            }

            // Weather factors badges
            HStack(spacing: 8) {
                WeatherFactorBadge(icon: "sun.max.fill", label: L10n.Routines.Weather.uv, color: .orange)
                WeatherFactorBadge(icon: "humidity.fill", label: L10n.Routines.Weather.humidity, color: .blue)
                WeatherFactorBadge(icon: "wind", label: L10n.Routines.Weather.wind, color: .cyan)
                WeatherFactorBadge(icon: "thermometer", label: L10n.Routines.Weather.temp, color: .red)
            }

            // Enable button
            Button {
                Task {
                    await enableWeatherAdaptation()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: locationService.permissionState == .denied ? "location.slash.fill" : "location.fill")
                            .font(.system(size: 14, weight: .semibold))

                        Text(locationService.permissionState == .denied ? L10n.Routines.Weather.enableInSettings : L10n.Routines.Weather.enableAdaptation)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(locationService.permissionState == .denied ?
                              ThemeManager.shared.theme.palette.error :
                              ThemeManager.shared.theme.palette.primary)
                )
            }
            .disabled(isLoading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }

    // MARK: - State 2: Active Weather Card

    private var activeWeatherCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with disable button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Routines.Weather.adaptedRoutine)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                    if let weather = weatherData {
                        Text(weather.condition ?? L10n.Routines.Weather.currentConditions)
                            .font(.system(size: 13))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }

                Spacer()

                // Disable button
                Button {
                    preferencesStore.setWeatherAdaptationEnabled(false)
                    weatherData = nil
                } label: {
                    Image(systemName: "circle.slash")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if let weather = weatherData {
                // UV Index - Most Important
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(weather.uvLevel.color.opacity(0.15))
                            .overlay(
                                Circle()
                                    .stroke(ThemeManager.shared.theme.palette.border.opacity(0.3), lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: weather.uvLevel.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Routines.Weather.uvIndex(weather.uvIndex))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        Text("\(weather.uvLevel.displayName) - \(WeatherRecommendation.from(weatherData: weather).spfLevel)")
                            .font(.system(size: 13))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(weather.uvLevel.color.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(weather.uvLevel.color.opacity(0.5), lineWidth: 1)
                        )
                )

                // Weather summary
                HStack(spacing: 16) {
                    WeatherMetric(
                        icon: "thermometer",
                        value: String(format: "%.0f°C", weather.temperature),
                        color: .red
                    )

                    WeatherMetric(
                        icon: "humidity.fill",
                        value: String(format: "%.0f%%", weather.humidity),
                        color: .blue
                    )

                    WeatherMetric(
                        icon: "wind",
                        value: String(format: "%.0f km/h", weather.windSpeed),
                        color: .cyan
                    )
                }

                // Today's tip
                let recommendation = WeatherRecommendation.from(weatherData: weather)
                if let tip = recommendation.generalTips.first {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.info)

                        Text(tip)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .lineLimit(2)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ThemeManager.shared.theme.palette.info.opacity(0.1))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeManager.shared.theme.palette.border.opacity(0.5), lineWidth: 1)
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.08),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
    }

    // MARK: - Actions

    private func enableWeatherAdaptation() async {
        // If permission denied, open settings
        if locationService.permissionState == .denied {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let weatherService = WeatherService.shared
            _ = try await weatherService.requestLocationPermissionAndFetch()
            await loadWeatherData()
        } catch {
            errorMessage = L10n.Routines.Weather.unableToEnable(error: error.localizedDescription)
            print("❌ Failed to enable weather adaptation: \(error)")
        }

        isLoading = false
    }

    private func loadWeatherData() async {
        guard preferencesStore.isWeatherAdaptationEnabled else { return }

        let weatherService = WeatherService.shared
        if let data = await weatherService.getCurrentWeatherData() {
            await MainActor.run {
                self.weatherData = data
            }
        }
    }
}

// MARK: - Weather Factor Badge

private struct WeatherFactorBadge: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Weather Metric

private struct WeatherMetric: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.5))
        )
    }
}

// MARK: - Weather Detail Sheet

private struct WeatherDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let weatherData: WeatherData

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // UV Section
                    WeatherDetailSection(
                        title: L10n.Routines.Weather.uvIndexTitle,
                        icon: weatherData.uvLevel.icon,
                        iconColor: weatherData.uvLevel.color,
                        content: {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(L10n.Routines.Weather.level(weatherData.uvIndex))
                                        .font(.system(size: 24, weight: .bold))
                                    Text(L10n.Routines.Weather.uvLevelDisplay(weatherData.uvLevel.displayName))
                                        .font(.system(size: 16))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }

                                let recommendation = WeatherRecommendation.from(weatherData: weatherData)

                                WeatherDetailRow(label: L10n.Routines.Weather.recommendedSPF, value: recommendation.spfLevel)

                                if !recommendation.activeIngredientWarnings.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L10n.Routines.Weather.warnings)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(ThemeManager.shared.theme.palette.error)

                                        ForEach(recommendation.activeIngredientWarnings, id: \.self) { warning in
                                            Text(L10n.Routines.Weather.warningBullet(warning))
                                                .font(.system(size: 13))
                                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(ThemeManager.shared.theme.palette.error.opacity(0.1))
                                    )
                                }
                            }
                        }
                    )

                    // Environmental Conditions
                    WeatherDetailSection(
                        title: L10n.Routines.Weather.environmentalConditions,
                        icon: "cloud.fill",
                        iconColor: .blue,
                        content: {
                            VStack(spacing: 8) {
                                WeatherDetailRow(
                                    label: L10n.Routines.Weather.temperature,
                                    value: String(format: "%.1f°C", weatherData.temperature)
                                )
                                WeatherDetailRow(
                                    label: L10n.Routines.Weather.humidity,
                                    value: String(format: "%.0f%%", weatherData.humidity)
                                )
                                WeatherDetailRow(
                                    label: L10n.Routines.Weather.windSpeed,
                                    value: String(format: "%.1f km/h", weatherData.windSpeed)
                                )
                                if weatherData.hasSnow {
                                    WeatherDetailRow(label: L10n.Routines.Weather.snow, value: L10n.Routines.Weather.snowWarning)
                                }
                            }
                        }
                    )

                    // Recommendations
                    let recommendation = WeatherRecommendation.from(weatherData: weatherData)
                    if !recommendation.generalTips.isEmpty {
                        WeatherDetailSection(
                            title: L10n.Routines.Weather.todaysTips,
                            icon: "lightbulb.fill",
                            iconColor: .yellow,
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(recommendation.generalTips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text(L10n.Routines.Weather.tipBullet)
                                            Text(tip)
                                                .font(.system(size: 14))
                                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                        }
                                    }
                                }
                            }
                        )
                    }

                    if let textureAdjustment = recommendation.textureAdjustment {
                        WeatherDetailSection(
                            title: L10n.Routines.Weather.productTexture,
                            icon: "drop.fill",
                            iconColor: .purple,
                            content: {
                                Text(textureAdjustment)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            }
                        )
                    }
                }
                .padding(20)
            }
            .background(ThemeManager.shared.theme.palette.background)
            .navigationTitle(L10n.Routines.Weather.details)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Weather Detail Section

private struct WeatherDetailSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }
}

// MARK: - Weather Detail Row

private struct WeatherDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    WeatherAdaptationCard()
}

