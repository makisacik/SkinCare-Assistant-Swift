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
        
        // Cache the weather data
        preferencesStore.cacheWeatherData(weatherData)
        
        return weatherData
    }
    
    func getCurrentWeatherData() async -> WeatherData? {
        // Use mock data if configured (for development/testing)
        if Config.useMockWeatherData {
            print("🧪 Using mock weather data (Config.useMockWeatherData = true)")
            return MockWeatherService.shared.getMockWeatherData()
        }
        
        // Check if we should fetch new data
        guard preferencesStore.shouldFetchWeather else {
            print("ℹ️ Using cached weather data")
            return preferencesStore.cachedWeatherData
        }
        
        // Try to fetch new data
        if #available(iOS 16.0, *) {
            do {
                return try await fetchCurrentWeather()
            } catch {
                print("⚠️ Failed to fetch weather, using cached data: \(error.localizedDescription)")
                return preferencesStore.cachedWeatherData
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
            // Wait a bit for the permission dialog
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        // Check if we have permission now
        guard locationService.permissionState.isAuthorized else {
            throw LocationError.permissionDenied
        }
        
        // Enable weather adaptation
        preferencesStore.setWeatherAdaptationEnabled(true)
        
        // Fetch weather data
        return await getCurrentWeatherData()
    }
}

// MARK: - Mock Weather Service (for testing/preview)

final class MockWeatherService {
    static let shared = MockWeatherService()
    
    func getMockWeatherData() -> WeatherData {
        return WeatherData(
            uvIndex: 7,
            humidity: 45.0,
            windSpeed: 15.0,
            temperature: 22.0,
            hasSnow: false,
            timestamp: Date(),
            condition: "Partly Cloudy"
        )
    }
    
    func fetchCurrentWeather() async throws -> WeatherData {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return getMockWeatherData()
    }
}

