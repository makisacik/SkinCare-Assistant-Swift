//
//  DemoVisitTracker.swift
//  ManCare
//
//  Tracks how many times the user has seen the Skin Journey demo
//

import Foundation

class DemoVisitTracker {
    static let shared = DemoVisitTracker()
    
    private let userDefaults = UserDefaults.standard
    private let demoCountKey = "skinJourneyDemoViewCount"
    private let maxDemoViews = 3
    
    private init() {}
    
    /// Returns true if the demo should be shown (visit count < 3)
    func shouldShowDemo() -> Bool {
        let count = userDefaults.integer(forKey: demoCountKey)
        return count < maxDemoViews
    }
    
    /// Increments the view count
    func incrementCount() {
        let currentCount = userDefaults.integer(forKey: demoCountKey)
        userDefaults.set(currentCount + 1, forKey: demoCountKey)
        print("🎬 Skin Journey demo view count: \(currentCount + 1)")
    }
    
    /// Increments count and returns if demo should still show
    func incrementAndCheck() -> Bool {
        incrementCount()
        return shouldShowDemo()
    }
    
    /// Resets the counter (for testing purposes)
    func resetCount() {
        userDefaults.set(0, forKey: demoCountKey)
        print("🔄 Skin Journey demo count reset")
    }
    
    /// Gets current view count
    func getCount() -> Int {
        return userDefaults.integer(forKey: demoCountKey)
    }
}

