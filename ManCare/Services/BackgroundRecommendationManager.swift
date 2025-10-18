//
//  BackgroundRecommendationManager.swift
//  ManCare
//
//  Manages background generation of product recommendations
//

import Foundation

final class BackgroundRecommendationManager {
    // MARK: - Singleton
    
    static let shared = BackgroundRecommendationManager()
    
    // MARK: - Dependencies
    
    private let recommendationService: ProductRecommendationService
    
    // MARK: - State
    
    private var isGenerating = false
    private let maxRetries = 2
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let hasGeneratedInitialRecommendations = "hasGeneratedInitialRecommendations"
        static let recommendationGenerationAttempts = "recommendationGenerationAttempts"
    }
    
    // MARK: - Initialization
    
    private init(recommendationService: ProductRecommendationService = .shared) {
        self.recommendationService = recommendationService
    }
    
    // MARK: - Public API
    
    /// Start background generation for a routine
    func startGeneration(for routine: SavedRoutineModel) {
        // Check if already generated
        if hasGeneratedRecommendations {
            print("ℹ️ Recommendations already generated, skipping")
            return
        }
        
        // Check if already generating
        guard !isGenerating else {
            print("ℹ️ Already generating recommendations, skipping")
            return
        }
        
        print("🚀 Starting background product recommendation generation...")
        isGenerating = true
        
        // Launch detached task to avoid blocking UI
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            await self.performGenerationWithRetries(for: routine)
        }
    }
    
    // MARK: - Private Methods
    
    private func performGenerationWithRetries(for routine: SavedRoutineModel) async {
        var attempts = getAttemptCount()
        
        while attempts < maxRetries {
            do {
                print("🔄 ========================================")
                print("🔄 ATTEMPT \(attempts + 1) of \(maxRetries)")
                print("🔄 Routine ID: \(routine.id)")
                print("🔄 Routine Title: \(routine.title)")
                print("🔄 Step Count: \(routine.stepDetails.count)")
                print("🔄 ========================================")
                
                // Generate recommendations
                try await recommendationService.generateRecommendations(for: routine)
                
                // Success! Mark as complete
                print("✅ ========================================")
                print("✅ BACKGROUND GENERATION COMPLETE!")
                print("✅ ========================================")
                markAsGenerated()
                resetAttempts()
                
                await MainActor.run {
                    self.isGenerating = false
                }
                
                return
                
            } catch {
                print("❌ ========================================")
                print("❌ ATTEMPT \(attempts + 1) FAILED")
                print("❌ Error: \(error)")
                print("❌ Localized: \(error.localizedDescription)")
                if let gptError = error as? GPTService.GPTServiceError {
                    print("❌ GPT Error Type: \(gptError)")
                }
                print("❌ ========================================")
                attempts += 1
                incrementAttempts()
                
                // Wait before retry (exponential backoff)
                if attempts < maxRetries {
                    let delay = pow(2.0, Double(attempts)) // 2, 4 seconds
                    print("⏳ Waiting \(delay) seconds before retry...")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    print("❌ Max retries reached, giving up on background generation")
                }
            }
        }
        
        // Failed after all retries
        await MainActor.run {
            self.isGenerating = false
        }
    }
    
    // MARK: - UserDefaults Management
    
    private var hasGeneratedRecommendations: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasGeneratedInitialRecommendations)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasGeneratedInitialRecommendations)
        }
    }
    
    private func markAsGenerated() {
        hasGeneratedRecommendations = true
    }
    
    private func getAttemptCount() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.recommendationGenerationAttempts)
    }
    
    private func incrementAttempts() {
        let current = getAttemptCount()
        UserDefaults.standard.set(current + 1, forKey: Keys.recommendationGenerationAttempts)
    }
    
    private func resetAttempts() {
        UserDefaults.standard.removeObject(forKey: Keys.recommendationGenerationAttempts)
    }
    
    // MARK: - Testing/Debug Helpers
    
    /// Reset generation state (for testing)
    func resetGenerationState() {
        hasGeneratedRecommendations = false
        resetAttempts()
        isGenerating = false
        print("🔄 Reset recommendation generation state")
    }
}

