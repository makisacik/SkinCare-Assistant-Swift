//
//  RoutineAdapterService.swift
//  ManCare
//
//  Orchestrator for routine adaptation system
//

import Foundation

// MARK: - Routine Adapter Protocol

protocol RoutineAdapterProtocol {
    func getSnapshot(
        routine: SavedRoutineModel,
        for date: Date
    ) async -> RoutineSnapshot?
    
    func shouldAdapt(routine: SavedRoutineModel) -> Bool
}

// MARK: - Routine Adapter Service

class RoutineAdapterService: RoutineAdapterProtocol {
    
    // MARK: - Dependencies
    
    private let cycleStore: CycleStore
    private let rulesEngine: AdaptationRulesEngine
    private let snapshotCache: SnapshotCache
    private let weatherService: WeatherService
    
    // MARK: - Initialization
    
    init(cycleStore: CycleStore, rulesEngine: AdaptationRulesEngine, snapshotCache: SnapshotCache, weatherService: WeatherService = WeatherService.shared) {
        self.cycleStore = cycleStore
        self.rulesEngine = rulesEngine
        self.snapshotCache = snapshotCache
        self.weatherService = weatherService
        print("🔧 RoutineAdapterService initialized")
    }
    
    // MARK: - Public Methods
    
    func shouldAdapt(routine: SavedRoutineModel) -> Bool {
        return routine.adaptationEnabled
    }
    
    func getSnapshot(
        routine: SavedRoutineModel,
        for date: Date
    ) async -> RoutineSnapshot? {
        guard routine.adaptationEnabled else {
            print("⚠️ RoutineAdapterService: Adaptation not enabled for routine \(routine.title)")
            return nil
        }
        
        guard let adaptationType = routine.adaptationType else {
            print("⚠️ RoutineAdapterService: No adaptation type set for routine \(routine.title)")
            return nil
        }
        
        // Check cache first
        if let cached = snapshotCache.get(routineId: routine.id, date: date) {
            return cached
        }
        
        print("🔄 RoutineAdapterService: Generating snapshot for \(routine.title) on \(date)")
        
        // 1. Determine context key (phase from CycleStore or weather data)
        let contextKey = await getContextKey(for: adaptationType, date: date)
        print("📍 Context: \(contextKey)")
        
        // 2. Load rules
        guard let ruleSet = rulesEngine.loadRuleSet(type: adaptationType) else {
            print("❌ RoutineAdapterService: Failed to load rule set for \(adaptationType.rawValue)")
            return nil
        }
        
        // 3. Resolve adaptations for each step
        let adaptedSteps = routine.stepDetails.map { step -> AdaptedStepDetail in
            let adaptation = rulesEngine.resolve(
                step: step,
                using: ruleSet.rules,
                for: contextKey
            )

            let displayOrder = adaptation?.orderOverride ?? step.order

            return AdaptedStepDetail(
                baseStep: step,
                adaptation: adaptation,
                displayOrder: displayOrder
            )
        }.sorted { $0.displayOrder < $1.displayOrder }
        
        print("✅ Adapted \(adaptedSteps.count) steps (\(adaptedSteps.filter { !$0.shouldShow }.count) skipped)")
        
        // 4. Get briefing
        let briefing = ruleSet.briefings.first { $0.contextKey == contextKey } ?? createDefaultBriefing(for: contextKey)
        
        let snapshot = RoutineSnapshot(
            baseRoutine: routine,
            contextKey: contextKey,
            date: date,
            adaptedSteps: adaptedSteps,
            briefing: briefing
        )
        
        // Cache it
        snapshotCache.set(snapshot, for: routine.id, date: date)
        
        return snapshot
    }
    
    // MARK: - Private Helpers
    
    private func getContextKey(for type: AdaptationType, date: Date) async -> String {
        switch type {
        case .cycle:
            return cycleStore.cycleData.currentPhase(for: date).rawValue
        case .seasonal:
            return await getWeatherContextKey(date: date)
        case .skinState:
            return "normal"
        }
    }
    
    private func getWeatherContextKey(date: Date) async -> String {
        // Try to get current weather data
        if let weatherData = await weatherService.getCurrentWeatherData() {
            let context = WeatherAdaptationContext(weatherData: weatherData, date: date)

            // Return the primary context key (UV level is most important)
            // Note: The rules engine will match against all context keys in the context
            return context.weatherData.uvLevel.contextKey
        } else {
            // Fallback to season-based context if weather data unavailable
            print("⚠️ Weather data unavailable, falling back to season")
            return getCurrentSeason(date: date)
        }
    }

    private func getCurrentSeason(date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        // Simple season detection for Northern Hemisphere
        switch month {
        case 12, 1, 2:
            return "winter"
        case 3, 4, 5:
            return "spring"
        case 6, 7, 8:
            return "summer"
        case 9, 10, 11:
            return "fall"
        default:
            return "unknown"
        }
    }
    
    private func createDefaultBriefing(for contextKey: String) -> PhaseBriefing {
        return PhaseBriefing(
            contextKey: contextKey,
            title: contextKey.capitalized,
            summary: "Continue with your regular routine.",
            tips: [],
            generalWarnings: []
        )
    }
}

