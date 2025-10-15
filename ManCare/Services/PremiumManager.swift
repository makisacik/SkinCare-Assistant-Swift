//
//  PremiumManager.swift
//  ManCare
//
//  Created by AI Assistant
//

import Foundation
import StoreKit
import Combine

// MARK: - Premium Manager

@MainActor
final class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Error>?
    private let premiumKey = "user_is_premium"
    
    // For testing purposes - will be replaced with real StoreKit later
    private let testMode = true
    
    // MARK: - Init
    
    private init() {
        // Load initial premium status
        loadPremiumStatus()
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        print("🔐 PremiumManager initialized - Premium: \(isPremium)")
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Check if user is premium
    func checkPremiumStatus() {
        loadPremiumStatus()
    }
    
    /// Purchase premium (test mode)
    func purchasePremium() async throws {
        isLoading = true
        defer { isLoading = false }
        
        if testMode {
            // Simulate purchase delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Grant premium
            grantPremium()
            print("✅ Test premium purchase successful")
        } else {
            // Real StoreKit integration will go here
            throw PremiumError.notImplemented
        }
    }
    
    /// Restore purchases
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        if testMode {
            // In test mode, check if user had premium before
            let hadPremium = UserDefaults.standard.bool(forKey: premiumKey)
            if hadPremium {
                grantPremium()
                print("✅ Test premium restored")
            } else {
                print("ℹ️ No premium to restore")
            }
        } else {
            // Real StoreKit restore will go here
            throw PremiumError.notImplemented
        }
    }
    
    /// Grant premium status (for testing "Start my week free")
    func grantPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
        print("👑 Premium status granted")
    }
    
    /// Revoke premium status (for testing)
    func revokePremium() {
        isPremium = false
        UserDefaults.standard.set(false, forKey: premiumKey)
        print("❌ Premium status revoked")
    }
    
    // MARK: - Feature Checks
    
    /// Check if user can create more routines
    func canCreateRoutine() async -> Bool {
        if isPremium {
            return true
        }
        
        // Non-premium users can only have 2 routines
        do {
            let store = RoutineStore()
            let routines = try await store.fetchSavedRoutines()
            let canCreate = routines.count < 2
            print("🔍 Can create routine: \(canCreate) (current: \(routines.count)/2)")
            return canCreate
        } catch {
            print("❌ Error checking routine count: \(error)")
            return false
        }
    }
    
    /// Check if user can use cycle adaptation
    func canUseCycleAdaptation() -> Bool {
        let canUse = isPremium
        print("🔍 Can use cycle adaptation: \(canUse)")
        return canUse
    }
    
    /// Check if user can use skin journal
    func canUseSkinJournal() -> Bool {
        let canUse = isPremium
        print("🔍 Can use skin journal: \(canUse)")
        return canUse
    }
    
    /// Check if user can use weather adaptation
    func canUseWeatherAdaptation() -> Bool {
        // Weather adaptation is free for all users
        return true
    }
    
    // MARK: - Private Methods
    
    private func loadPremiumStatus() {
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transaction updates
            // This will be implemented with real StoreKit
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update premium status based on transaction
                    await MainActor.run {
                        self.grantPremium()
                    }
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check if the transaction is verified
        switch result {
        case .unverified:
            throw PremiumError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Premium Error

enum PremiumError: LocalizedError {
    case notImplemented
    case failedVerification
    case purchaseFailed
    case restoreFailed
    case routineLimitReached
    case featureRequiresPremium(String)
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This feature is not yet implemented"
        case .failedVerification:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        case .restoreFailed:
            return "Restore failed"
        case .routineLimitReached:
            return "You've reached your routine limit. Upgrade to premium to create unlimited routines."
        case .featureRequiresPremium(let featureName):
            return "\(featureName) requires a premium subscription"
        }
    }
}

