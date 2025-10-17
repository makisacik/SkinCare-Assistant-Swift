//
//  L10n.swift
//  ManCare
//
//  Type-safe localization accessor layer
//

import Foundation

/// Type-safe localization strings accessor
/// All localized strings should go through this layer
struct L10n {
    private static let manager = LocalizationManager.shared
    
    // MARK: - Common Strings
    
    struct Common {
        static var cancel: String { manager.localizedString("common.cancel") }
        static var save: String { manager.localizedString("common.save") }
        static var done: String { manager.localizedString("common.done") }
        static var delete: String { manager.localizedString("common.delete") }
        static var edit: String { manager.localizedString("common.edit") }
        static var add: String { manager.localizedString("common.add") }
        static var close: String { manager.localizedString("common.close") }
        static var ok: String { manager.localizedString("common.ok") }
        static var yes: String { manager.localizedString("common.yes") }
        static var no: String { manager.localizedString("common.no") }
    }
    
    // MARK: - Routines
    
    struct Routines {
        static var title: String { manager.localizedString("routines.title", table: "Routines") }
        static var morningRoutine: String { manager.localizedString("routines.morning", table: "Routines") }
        static var eveningRoutine: String { manager.localizedString("routines.evening", table: "Routines") }
        static var createRoutine: String { manager.localizedString("routines.create", table: "Routines") }
        static var noRoutines: String { manager.localizedString("routines.noRoutines", table: "Routines") }
        
        static func stepTitle(_ productType: String) -> String {
            let key = "routines.step.\(productType)"
            return manager.localizedString(key, table: "Routines")
        }
        
        static func guidance(_ key: String) -> String {
            manager.localizedString(key, table: "Routines")
        }
    }
    
    // MARK: - Adaptations
    
    struct Adaptations {
        // Cycle phases
        static func cyclePhase(_ phase: String) -> String {
            let key = "adaptations.cycle.phase.\(phase)"
            return manager.localizedString(key, table: "Adaptations")
        }
        
        // Warnings
        static func warning(_ key: String) -> String {
            manager.localizedString(key, table: "Adaptations")
        }
        
        // Guidance
        static func guidance(_ key: String) -> String {
            manager.localizedString(key, table: "Adaptations")
        }
        
        // Weather contexts
        static func weatherContext(_ context: String) -> String {
            let key = "adaptations.weather.context.\(context)"
            return manager.localizedString(key, table: "Adaptations")
        }
        
        // Notes
        static func note(_ key: String) -> String {
            manager.localizedString(key, table: "Adaptations")
        }
    }
    
    // MARK: - Completions
    
    struct Completions {
        static var productsUsed: String { manager.localizedString("completions.productsUsed", table: "Completions") }
        static var routinesCompleted: String { manager.localizedString("completions.routinesCompleted", table: "Completions") }
        static var morningRoutine: String { manager.localizedString("completions.morningRoutine", table: "Completions") }
        static var eveningRoutine: String { manager.localizedString("completions.eveningRoutine", table: "Completions") }
        static var noProductsUsed: String { manager.localizedString("completions.noProductsUsed", table: "Completions") }
        static var noRoutinesCompleted: String { manager.localizedString("completions.noRoutinesCompleted", table: "Completions") }
        static var completeStepsToSee: String { manager.localizedString("completions.completeStepsToSee", table: "Completions") }
        
        // Timeline
        static var timeline: String { manager.localizedString("completions.timeline", table: "Completions") }
        static var journal: String { manager.localizedString("completions.journal", table: "Completions") }
        static var insights: String { manager.localizedString("completions.insights", table: "Completions") }
        
        // Insights
        static var yourInsights: String { manager.localizedString("completions.yourInsights", table: "Completions") }
        static var lastNDays: String { manager.localizedString("completions.lastNDays", table: "Completions") }
        static var currentStreak: String { manager.localizedString("completions.currentStreak", table: "Completions") }
        static var dayInRow: String { manager.localizedString("completions.dayInRow", table: "Completions") }
        static var daysInRow: String { manager.localizedString("completions.daysInRow", table: "Completions") }
        static var weekly: String { manager.localizedString("completions.weekly", table: "Completions") }
        static var monthly: String { manager.localizedString("completions.monthly", table: "Completions") }
        static var morning: String { manager.localizedString("completions.morning", table: "Completions") }
        static var evening: String { manager.localizedString("completions.evening", table: "Completions") }
        static var daysCompleted: String { manager.localizedString("completions.daysCompleted", table: "Completions") }
        static var loadingInsights: String { manager.localizedString("completions.loadingInsights", table: "Completions") }
        static var consistencyInsight: String { manager.localizedString("completions.consistencyInsight", table: "Completions") }
        static var adaptationImpact: String { manager.localizedString("completions.adaptationImpact", table: "Completions") }
        static var thisWeekVsLastWeek: String { manager.localizedString("completions.thisWeekVsLastWeek", table: "Completions") }
    }
    
    // MARK: - Settings
    
    struct Settings {
        static var editProfile: String { manager.localizedString("settings.editProfile") }
        static var language: String { manager.localizedString("settings.language") }
        static var premium: String { manager.localizedString("settings.premium") }
        static var enablePremium: String { manager.localizedString("settings.enablePremium") }
        static var disablePremium: String { manager.localizedString("settings.disablePremium") }
    }
    
    // MARK: - Tabs
    
    struct Tabs {
        static var routines: String { manager.localizedString("tabs.routines") }
        static var discover: String { manager.localizedString("tabs.discover") }
        static var products: String { manager.localizedString("tabs.products") }
        static var myself: String { manager.localizedString("tabs.myself") }
    }
}

