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
        print("🔍 RoutineAdapterService.getSnapshot called for: \(routine.title)")
        print("🔍 Adaptation enabled: \(routine.adaptationEnabled)")
        print("🔍 Adaptation type (legacy): \(routine.adaptationType?.rawValue ?? "nil")")

        guard routine.adaptationEnabled else {
            print("⚠️ RoutineAdapterService: Adaptation not enabled for routine \(routine.title)")
            return nil
        }

        // Smart adaptation: Apply both cycle and weather if weather preferences are enabled
        var adaptationTypes: [AdaptationType] = []

        // Add the routine's configured type
        if let type = routine.adaptationType {
            adaptationTypes.append(type)
        }

        // Also add weather if globally enabled (works alongside cycle)
        let weatherEnabled = await WeatherPreferencesStore.shared.isWeatherAdaptationEnabled
        if weatherEnabled && !adaptationTypes.contains(.seasonal) {
            adaptationTypes.append(.seasonal)
            print("🌤 Adding weather adaptation alongside \(routine.adaptationType?.rawValue ?? "base") routine")
        }

        print("🔍 Applying adaptation types: \(adaptationTypes.map { $0.rawValue })")

        guard !adaptationTypes.isEmpty else {
            print("⚠️ RoutineAdapterService: No adaptation types to apply")
            return nil
        }

        // Check cache first
        if let cached = snapshotCache.get(routineId: routine.id, date: date) {
            return cached
        }

        print("🔄 RoutineAdapterService: Generating snapshot for \(routine.title) on \(date)")
        print("📋 Adaptation types count: \(adaptationTypes.count)")
        print("📋 Adaptation types: \(adaptationTypes.map { $0.rawValue }.joined(separator: " + "))")

        // Apply all adaptation types and merge results
        // Cycle wins conflicts if both are enabled
        let adaptedSteps = await applyMultipleAdaptations(
            routine: routine,
            types: adaptationTypes,
            date: date
        )

        print("✅ Adapted \(adaptedSteps.count) steps (\(adaptedSteps.filter { !$0.shouldShow }.count) skipped)")
        print("📊 Non-normal steps: \(adaptedSteps.filter { $0.emphasisLevel != .normal }.count)")

        // Get briefing from primary type (first in list)
        let primaryType = adaptationTypes.first!
        let contextKey = await getContextKey(for: primaryType, date: date)
        let ruleSet = rulesEngine.loadRuleSet(type: primaryType)
        let briefing = ruleSet?.briefings.first { $0.contextKey == contextKey } ?? createDefaultBriefing(for: contextKey)

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

    // MARK: - Multiple Adaptations

    private func applyMultipleAdaptations(
        routine: SavedRoutineModel,
        types: [AdaptationType],
        date: Date
    ) async -> [AdaptedStepDetail] {
        print("🔄 Applying \(types.count) adaptation types: \(types.map { $0.rawValue })")

        // Collect all adaptations for each step
        var stepAdaptations: [UUID: [StepAdaptation]] = [:]

        for adaptationType in types {
            print("📋 Processing \(adaptationType.rawValue) adaptation...")

            // Load rules for this type
            guard let ruleSet = rulesEngine.loadRuleSet(type: adaptationType) else {
                print("❌ Failed to load rules for \(adaptationType.rawValue)")
                continue
            }

            // Get context
            let contextKey = await getContextKey(for: adaptationType, date: date)

            // Get active contexts for weather
            var activeContexts: [String]? = nil
            if adaptationType == .seasonal {
                if let weatherData = await weatherService.getCurrentWeatherData() {
                    let context = WeatherAdaptationContext(weatherData: weatherData, date: date)
                    activeContexts = context.contextKeys
                    print("🌤 Active weather contexts: \(activeContexts ?? [])")
                }
            }

            // Resolve adaptations for each step
            for step in routine.stepDetails {
                let adaptation = rulesEngine.resolve(
                    step: step,
                    using: ruleSet.rules,
                    for: contextKey,
                    timeOfDay: step.timeOfDayEnum,
                    activeContexts: activeContexts
                )

                if let adaptation = adaptation {
                    if stepAdaptations[step.id] == nil {
                        stepAdaptations[step.id] = []
                    }
                    stepAdaptations[step.id]?.append(adaptation)
                }
            }
        }

        // Merge adaptations for each step with cycle winning conflicts
        let adaptedSteps = routine.stepDetails.map { step -> AdaptedStepDetail in
            let adaptations = stepAdaptations[step.id] ?? []

            // Merge adaptations with cycle winning
            let finalAdaptation = mergeAdaptations(adaptations, cycleWins: types.contains(.cycle))

            let displayOrder = finalAdaptation?.orderOverride ?? step.order

            return AdaptedStepDetail(
                baseStep: step,
                adaptation: finalAdaptation,
                displayOrder: displayOrder
            )
        }.sorted { $0.displayOrder < $1.displayOrder }

        return adaptedSteps
    }

    /// Merge multiple adaptations for a single step
    /// Cycle wins conflicts ONLY if cycle has non-normal emphasis
    /// If cycle is normal and weather is not, weather applies
    private func mergeAdaptations(_ adaptations: [StepAdaptation], cycleWins: Bool) -> StepAdaptation? {
        guard !adaptations.isEmpty else { return nil }
        if adaptations.count == 1 { return adaptations.first }

        // Separate cycle and non-cycle adaptations
        let cycleAdaptation = adaptations.first(where: { ["menstrual", "follicular", "ovulatory", "luteal"].contains($0.contextKey) })
        let otherAdaptations = adaptations.filter { !["menstrual", "follicular", "ovulatory", "luteal"].contains($0.contextKey) }

        // If cycle wins mode and cycle has a NON-NORMAL emphasis, use it
        if cycleWins, let cycle = cycleAdaptation, cycle.emphasis != .normal {
            print("🏆 Cycle adaptation wins conflict for step (cycle: \(cycle.emphasis.rawValue))")
            return cycle
        }

        // If cycle is normal or doesn't exist, check for non-normal adaptations from other types
        let nonNormalAdaptations = (otherAdaptations + (cycleAdaptation.map { [$0] } ?? [])).filter { $0.emphasis != .normal }

        if let bestAdaptation = nonNormalAdaptations.first {
            let source = ["menstrual", "follicular", "ovulatory", "luteal"].contains(bestAdaptation.contextKey) ? "cycle" : "weather"
            print("✅ Using \(source) adaptation (emphasis: \(bestAdaptation.emphasis.rawValue))")
            return bestAdaptation
        }

        // If all are normal, use any one (doesn't matter)
        return adaptations.first
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

