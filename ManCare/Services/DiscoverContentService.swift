//
//  DiscoverContentService.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import Foundation

// MARK: - Service Error

enum DiscoverServiceError: Error {
    case fileNotFound
    case decodingFailed(Error)
    case noBannerAvailable
}

// MARK: - Discover Content Service

actor DiscoverContentService {
    private var cachedContent: DiscoverContent?
    private var lastLoadDate: Date?
    
    // MARK: - Public Methods
    
    /// Load content from JSON file
    func loadContent() async throws -> DiscoverContent {
        // Return cached if available and fresh (< 5 minutes old)
        if let cached = cachedContent,
           let lastLoad = lastLoadDate,
           Date().timeIntervalSince(lastLoad) < 300 {
            return cached
        }
        
        let content = try loadFromJSON()
        cachedContent = content
        lastLoadDate = Date()
        
        print("✅ DiscoverContentService: Loaded content from JSON")
        return content
    }

    /// Get the active banner for current date
    func getActiveBanner() async throws -> HeroBanner? {
        let content = try await loadContent()
        return content.hero.isActive ? content.hero : nil
    }

    /// Get fresh routines filtered by relevance
    func getFreshRoutines() async throws -> [FreshRoutine] {
        let content = try await loadContent()
        return filterActiveRoutines(content.routines)
    }

    /// Get current season based on date
    func getCurrentSeason() -> Season {
        return calculateSeasonFromDate(Date())
    }
    /// Check if content should be refreshed
    func shouldRefreshContent(lastRefresh: Date) -> Bool {
        let timeInterval = Date().timeIntervalSince(lastRefresh)
        // Refresh if more than 1 hour has passed
        return timeInterval > 3600
    }
    /// Force refresh cached content
    func refreshContent() async throws -> DiscoverContent {
        cachedContent = nil
        lastLoadDate = nil
        return try await loadContent()
    }
    /// Expose mini guides
    func getMiniGuides() async throws -> [MiniGuide] {
        let content = try await loadContent()
        return content.miniGuides ?? []
    }
    
    // MARK: - Private Helpers
    
    private func loadFromJSON() throws -> DiscoverContent {
        guard let url = Bundle.main.url(forResource: "discover-content", withExtension: "json") else {
            print("❌ DiscoverContentService: discover-content.json not found")
            throw DiscoverServiceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            var content = try decoder.decode(DiscoverContent.self, from: data)
            
            // Update seasonal playbook with current season if needed
            let currentSeason = calculateSeasonFromDate(Date())
            if content.seasonalPlaybook.season != currentSeason {
                // Keep the JSON season for now, but log it
                print("ℹ️ Season mismatch: JSON has \(content.seasonalPlaybook.season.rawValue), current is \(currentSeason.rawValue)")
            }
            
            return content
        } catch {
            print("❌ DiscoverContentService: Failed to decode JSON - \(error)")
            throw DiscoverServiceError.decodingFailed(error)
        }
    }
    
    private func calculateSeasonFromDate(_ date: Date) -> Season {
        return Season.from(date: date)
    }
    
    private func filterActiveRoutines(_ routines: [FreshRoutine]) -> [FreshRoutine] {
        let now = Date()
        return routines.filter { $0.shouldShow(relativeTo: now) }
    }
}

