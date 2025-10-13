//
//  WeatherService.swift
//  ManCare
//
//  Created for weather-based routine adaptation
//

import Foundation
import WeatherKit
import CoreLocation

final class WeatherService {
    static let shared = WeatherService()

    private let weatherService = WeatherKit.WeatherService.shared
    private let locationService: LocationService
    private let preferencesStore = WeatherPreferencesStore.shared

    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }

    // MARK: - Public Methods

    @available(iOS 16.0, *)
    func fetchCurrentWeather() async throws -> WeatherData {
        print("🌤 Fetching current weather...")

        // Get current location
        let location = try await locationService.getCurrentLocation()

        // Fetch weather from WeatherKit
        let weather = try await weatherService.weather(for: location)

        // Extract relevant data
        let current = weather.currentWeather
        let dailyForecast = weather.dailyForecast.first

        // Get UV index from daily forecast (current weather doesn't always have UV)
        let uvIndex = dailyForecast?.uvIndex.value ?? 0

        // Get humidity (as percentage)
        let humidity = current.humidity * 100

        // Get wind speed (convert m/s to km/h)
        let windSpeedKmh = current.wind.speed.value * 3.6

        // Get temperature in Celsius
        let temperature = current.temperature.value

        // Check for snow
        let hasSnow = current.condition.description.lowercased().contains("snow") ||
                      current.condition == .snow ||
                      current.condition == .blowingSnow ||
                      current.condition == .heavySnow ||
                      current.condition == .flurries

        let weatherData = WeatherData(
            uvIndex: uvIndex,
            humidity: humidity,
            windSpeed: windSpeedKmh,
            temperature: temperature,
            hasSnow: hasSnow,
            timestamp: Date(),
            condition: current.condition.description
        )

        print("✅ Weather fetched: UV \(uvIndex), Temp \(temperature)°C, Humidity \(humidity)%, Wind \(windSpeedKmh) km/h")

        // Cache the weather data on main thread
        await MainActor.run {
            preferencesStore.cacheWeatherData(weatherData)
        }

        return weatherData
    }

    func getCurrentWeatherData() async -> WeatherData? {
        // Use mock data if configured (for development/testing)
        if Config.useMockWeatherData {
            print("🧪 Using mock weather data (Config.useMockWeatherData = true)")
            return MockWeatherService.shared.getMockWeatherData()
        }

        // Check if we should fetch new data (access main actor property)
        let shouldFetch = await preferencesStore.shouldFetchWeather
        guard shouldFetch else {
            print("ℹ️ Using cached weather data")
            return await preferencesStore.cachedWeatherData
        }

        // Try to fetch new data
        if #available(iOS 16.0, *) {
            do {
                return try await fetchCurrentWeather()
            } catch {
                print("⚠️ Failed to fetch weather, using cached data: \(error.localizedDescription)")
                return await preferencesStore.cachedWeatherData
            }
        } else {
            print("⚠️ WeatherKit requires iOS 16.0+")
            return nil
        }
    }

    func requestLocationPermissionAndFetch() async throws -> WeatherData? {
        // Request permission if not determined
        if locationService.permissionState == .notDetermined {
            locationService.requestLocationPermission()

            // Wait for user to respond to permission dialog
            // Poll the permission state for up to 30 seconds
            var attempts = 0
            while locationService.permissionState == .notDetermined && attempts < 60 {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                attempts += 1
            }

            print("📍 Permission dialog completed after \(Double(attempts) * 0.5) seconds")
        }

        // Check if we have permission now
        guard locationService.permissionState.isAuthorized else {
            print("❌ Location permission not granted: \(locationService.permissionState.rawValue)")
            throw LocationError.permissionDenied
        }

        print("✅ Location permission granted, proceeding with weather setup")

        // Enable weather adaptation (access main actor method)
        await preferencesStore.setWeatherAdaptationEnabled(true)

        // Auto-enable weather adaptation on active routine
        await enableWeatherAdaptationOnActiveRoutine()

        // Fetch weather data
        return await getCurrentWeatherData()
    }

    private func enableWeatherAdaptationOnActiveRoutine() async {
        do {
            let routineStore = RoutineStore()
            if let activeRoutine = try await routineStore.fetchActiveRoutine() {
                let currentTypes = activeRoutine.activeAdaptationTypes

                // Check if weather is already enabled
                if currentTypes.contains(.seasonal) {
                    print("ℹ️ Weather adaptation already enabled on routine")
                    return
                }

                // Add weather to existing types (or enable both if only cycle)
                var newTypes = currentTypes
                if !newTypes.contains(.seasonal) {
                    newTypes.append(.seasonal)
                }

                // Always enable adaptation and add weather type
                try await routineStore.updateAdaptationSettings(
                    routineId: activeRoutine.id,
                    enabled: true,
                    type: .seasonal  // For backward compat, set primary type
                )

                if currentTypes.contains(.cycle) {
                    print("✅ Added weather adaptation alongside cycle tracking: \(activeRoutine.title)")
                    print("📋 Active types: cycle + seasonal")
                } else {
                    print("✅ Enabled weather adaptation on active routine: \(activeRoutine.title)")
                }
            }
        } catch {
            print("⚠️ Failed to enable weather adaptation on routine: \(error)")
        }
    }
}

// MARK: - Mock Weather Service (for testing/preview)

final class MockWeatherService {
    static let shared = MockWeatherService()

    func getMockWeatherData() -> WeatherData {
        return WeatherData(
            uvIndex: 9,  // Changed from 7 to 9 (HIGH UV) to see visible adaptations
            humidity: 45.0,
            windSpeed: 15.0,
            temperature: 22.0,
            hasSnow: false,
            timestamp: Date(),
            condition: "Sunny"
        )
    }

    func fetchCurrentWeather() async throws -> WeatherData {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return getMockWeatherData()
    }
}

