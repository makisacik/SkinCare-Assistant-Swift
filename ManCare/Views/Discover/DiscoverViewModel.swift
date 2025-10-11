//
//  DiscoverViewModel.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DiscoverViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var freshRoutines: [FreshRoutine] = []
    @Published var trendingRoutines: [(routine: RoutineTemplate, increase: Int)] = []
    @Published var miniGuides: [MiniGuide] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Dependencies

    private let contentService: DiscoverContentService
    private let routineStore: RoutineStore
    
    // MARK: - Initialization
    
    init(contentService: DiscoverContentService, routineStore: RoutineStore) {
        self.contentService = contentService
        self.routineStore = routineStore
        print("📊 DiscoverViewModel initialized")
    }
    
    // MARK: - Content Loading
    
    func loadContent() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let content = try await contentService.loadContent()

            // Update fresh routines
            freshRoutines = try await contentService.getFreshRoutines()

            // Mini guides
            miniGuides = try await contentService.getMiniGuides()

            // Load trending routines
            await loadTrendingRoutines(from: content.communityHeat)

            isLoading = false

            print("✅ DiscoverViewModel: Content loaded successfully")
        } catch {
            self.error = error
            self.isLoading = false
            print("❌ DiscoverViewModel: Failed to load content - \(error)")
        }
    }

    func refreshContent() async {
        print("🔄 DiscoverViewModel: Refreshing content...")

        do {
            let content = try await contentService.refreshContent()

            freshRoutines = try await contentService.getFreshRoutines()

            miniGuides = try await contentService.getMiniGuides()

            await loadTrendingRoutines(from: content.communityHeat)

            print("✅ DiscoverViewModel: Content refreshed")
        } catch {
            self.error = error
            print("❌ DiscoverViewModel: Failed to refresh - \(error)")
        }
    }
    
    // MARK: - Trending Routines
    
    private func loadTrendingRoutines(from trendingData: [TrendingRoutine]) async {
        var loadedRoutines: [(routine: RoutineTemplate, increase: Int)] = []
        
        for trending in trendingData {
            if let template = getRoutineTemplate(byId: trending.templateId) {
                loadedRoutines.append((routine: template, increase: trending.saveIncrease))
            }
        }
        
        // Sort by save increase
        trendingRoutines = loadedRoutines.sorted { $0.increase > $1.increase }
    }
    
    // MARK: - Helper Methods
    
    func getRoutineTemplate(for freshRoutine: FreshRoutine) -> RoutineTemplate? {
        return getRoutineTemplate(byId: freshRoutine.templateId)
    }
    
    func getRoutineTemplate(byId id: UUID) -> RoutineTemplate? {
        // Since RoutineTemplate generates new UUIDs each time,
        // we'll use a simple index-based approach for now
        // In production, you'd want stable IDs or title-based matching
        let index = abs(id.hashValue) % RoutineTemplate.allRoutines.count
        return RoutineTemplate.allRoutines[safe: index] ?? RoutineTemplate.allRoutines.first
    }
    
    func getBadgeColor(_ badge: RoutineBadge) -> Color {
        return badge.color
    }

    // MARK: - Error Handling
    
    func clearError() {
        error = nil
    }
    
    func retry() async {
        await loadContent()
    }
}

// MARK: - Preview Support

#if DEBUG
extension DiscoverViewModel {
    static let preview: DiscoverViewModel = {
        let service = DiscoverContentService()
        let store = RoutineStore()
        return DiscoverViewModel(contentService: service, routineStore: store)
    }()
}
#endif

