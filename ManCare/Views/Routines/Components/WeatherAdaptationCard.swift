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
                    Text("Auto-adapt by weather/UV")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.error)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Get personalized recommendations based on real-time weather conditions in your area.")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()
            }

            // Weather factors badges
            HStack(spacing: 8) {
                WeatherFactorBadge(icon: "sun.max.fill", label: "UV", color: .orange)
                WeatherFactorBadge(icon: "humidity.fill", label: "Humidity", color: .blue)
                WeatherFactorBadge(icon: "wind", label: "Wind", color: .cyan)
                WeatherFactorBadge(icon: "thermometer", label: "Temp", color: .red)
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

                        Text(locationService.permissionState == .denied ? "Enable in Settings" : "Enable Weather Adaptation")
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
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }

    // MARK: - State 2: Active Weather Card

    private var activeWeatherCard: some View {
        Button {
            showingDetailSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header with toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weather-Adapted Routine")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)

                        if let weather = weatherData {
                            Text(weather.condition ?? "Current conditions")
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
                        Image(systemName: "xmark.circle.fill")
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
                                .fill(weather.uvLevel.color.opacity(0.2))
                                .frame(width: 44, height: 44)

                            Image(systemName: weather.uvLevel.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(weather.uvLevel.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("UV Index: \(weather.uvIndex)")
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
                            .fill(weather.uvLevel.color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(weather.uvLevel.color.opacity(0.3), lineWidth: 1)
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#E3F2FD"),
                                Color(hex: "#BBDEFB"),
                                Color(hex: "#90CAF9").opacity(0.5),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#90CAF9"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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
            errorMessage = "Unable to enable: \(error.localizedDescription)"
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
                        title: "UV Index",
                        icon: weatherData.uvLevel.icon,
                        iconColor: weatherData.uvLevel.color,
                        content: {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Level: \(weatherData.uvIndex)")
                                        .font(.system(size: 24, weight: .bold))
                                    Text("(\(weatherData.uvLevel.displayName))")
                                        .font(.system(size: 16))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                }

                                let recommendation = WeatherRecommendation.from(weatherData: weatherData)

                                WeatherDetailRow(label: "Recommended SPF", value: recommendation.spfLevel)

                                if !recommendation.activeIngredientWarnings.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("⚠️ Warnings")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(ThemeManager.shared.theme.palette.error)

                                        ForEach(recommendation.activeIngredientWarnings, id: \.self) { warning in
                                            Text("• \(warning)")
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
                        title: "Environmental Conditions",
                        icon: "cloud.fill",
                        iconColor: .blue,
                        content: {
                            VStack(spacing: 8) {
                                WeatherDetailRow(
                                    label: "Temperature",
                                    value: String(format: "%.1f°C", weatherData.temperature)
                                )
                                WeatherDetailRow(
                                    label: "Humidity",
                                    value: String(format: "%.0f%%", weatherData.humidity)
                                )
                                WeatherDetailRow(
                                    label: "Wind Speed",
                                    value: String(format: "%.1f km/h", weatherData.windSpeed)
                                )
                                if weatherData.hasSnow {
                                    WeatherDetailRow(label: "Snow", value: "Yes - UV reflection risk")
                                }
                            }
                        }
                    )

                    // Recommendations
                    let recommendation = WeatherRecommendation.from(weatherData: weatherData)
                    if !recommendation.generalTips.isEmpty {
                        WeatherDetailSection(
                            title: "Today's Tips",
                            icon: "lightbulb.fill",
                            iconColor: .yellow,
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(recommendation.generalTips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
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
                            title: "Product Texture",
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
            .navigationTitle("Weather Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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

