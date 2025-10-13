//
//  LocationService.swift
//  ManCare
//
//  Created for weather-based routine adaptation
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var permissionState: LocationPermissionState = .notDetermined
    @Published private(set) var error: Error?
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // We don't need precise location
        updatePermissionState()
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        print("📍 Requesting location permission")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        // Check authorization first
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            print("📍 Location permission not determined, requesting...")
            throw LocationError.permissionNotDetermined
            
        case .denied, .restricted:
            print("❌ Location permission denied or restricted")
            throw LocationError.permissionDenied
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission authorized, fetching location...")
            
        @unknown default:
            throw LocationError.unknown
        }
        
        // If we have a recent location (less than 5 minutes old), return it
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 {
            print("✅ Using cached location from \(location.timestamp)")
            return location
        }
        
        // Request a new location
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    // MARK: - Private Methods
    
    private func updatePermissionState() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            permissionState = .notDetermined
        case .denied:
            permissionState = .denied
        case .restricted:
            permissionState = .restricted
        case .authorizedWhenInUse, .authorizedAlways:
            permissionState = .authorized
        @unknown default:
            permissionState = .notDetermined
        }
        
        print("📍 Location permission state updated: \(permissionState.rawValue)")
        
        // Update the preferences store
        WeatherPreferencesStore.shared.updateLocationPermissionState(permissionState)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📍 Location authorization changed")
        updatePermissionState()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("✅ Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        currentLocation = location
        
        // Resume continuation if waiting
        continuation?.resume(returning: location)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager failed: \(error.localizedDescription)")
        self.error = error
        
        // Resume continuation with error if waiting
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - Location Error

enum LocationError: LocalizedError {
    case permissionNotDetermined
    case permissionDenied
    case locationUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionNotDetermined:
            return "Location permission not determined"
        case .permissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        case .locationUnavailable:
            return "Unable to get current location"
        case .unknown:
            return "Unknown location error"
        }
    }
}

