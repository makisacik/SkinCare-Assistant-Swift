//
//  WeatherPreferencesStore.swift
//  ManCare
//
//  Created for weather-based routine adaptation
//

import Foundation
import Combine

@MainActor
final class WeatherPreferencesStore: ObservableObject {
    static let shared = WeatherPreferencesStore()

    @Published private(set) var isWeatherAdaptationEnabled: Bool
    @Published private(set) var locationPermissionState: LocationPermissionState
    @Published private(set) var cachedWeatherData: WeatherData?

    private let adaptationEnabledKey = "weather_adaptation_enabled"
    private let cachedWeatherKey = "cached_weather_data"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        self.isWeatherAdaptationEnabled = UserDefaults.standard.bool(forKey: adaptationEnabledKey)
        self.locationPermissionState = .notDetermined
        self.cachedWeatherData = Self.loadCachedWeather()
    }

    // MARK: - Public Methods

    func setWeatherAdaptationEnabled(_ enabled: Bool) {
        isWeatherAdaptationEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: adaptationEnabledKey)
        print("🌤 Weather adaptation \(enabled ? "enabled" : "disabled")")
    }

    func updateLocationPermissionState(_ state: LocationPermissionState) {
        locationPermissionState = state
        print("📍 Location permission state: \(state.rawValue)")

        // If permission is denied or restricted, disable weather adaptation
        if state == .denied || state == .restricted {
            setWeatherAdaptationEnabled(false)
        }
    }

    func cacheWeatherData(_ data: WeatherData) {
        cachedWeatherData = data
        saveWeatherData(data)
        print("💾 Cached weather data: UV \(data.uvIndex), Temp \(data.temperature)°C")
    }

    func clearCache() {
        cachedWeatherData = nil
        UserDefaults.standard.removeObject(forKey: cachedWeatherKey)
        print("🗑 Cleared weather cache")
    }
    
    var canEnableWeatherAdaptation: Bool {
        return locationPermissionState.isAuthorized
    }
    
    var shouldFetchWeather: Bool {
        guard isWeatherAdaptationEnabled else { return false }
        guard locationPermissionState.isAuthorized else { return false }
        
        // Fetch if no cached data or cache is stale
        if let cached = cachedWeatherData {
            return cached.isStale
        }
        return true
    }
    
    // MARK: - Private Methods
    
    private static func loadCachedWeather() -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: "cached_weather_data") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            
            // Only return if not stale
            if !weatherData.isStale {
                print("✅ Loaded cached weather data from \(weatherData.timestamp)")
                return weatherData
            } else {
                print("⚠️ Cached weather data is stale")
                return nil
            }
        } catch {
            print("❌ Failed to decode cached weather data: \(error)")
            return nil
        }
    }
    
    private func saveWeatherData(_ data: WeatherData) {
        do {
            let encoded = try encoder.encode(data)
            UserDefaults.standard.set(encoded, forKey: cachedWeatherKey)
        } catch {
            print("❌ Failed to encode weather data: \(error)")
        }
    }
}

