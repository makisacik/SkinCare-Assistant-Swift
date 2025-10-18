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
        static var error: String { manager.localizedString("common.error") }
        static var back: String { manager.localizedString("common.back") }
        static var unknownError: String { manager.localizedString("common.unknownError") }
        static var loading: String { manager.localizedString("common.loading") }
        static var pleaseWait: String { manager.localizedString("common.pleaseWait") }
        static var noTipsAvailable: String { manager.localizedString("common.noTipsAvailable") }
        static var enable: String { manager.localizedString("common.enable") }
        static var thisMayTakeAFewSeconds: String { manager.localizedString("common.thisMayTakeAFewSeconds") }
        static var timeOfDay: String { manager.localizedString("common.timeOfDay") }
        static var bullet: String { manager.localizedString("common.bullet") }
        static func tipCounter(current: Int, total: Int) -> String {
            String(format: manager.localizedString("common.tipCounter"), current, total)
        }
        static func stepCounter(current: Int, total: Int) -> String {
            String(format: manager.localizedString("common.stepCounter"), current, total)
        }
        static func pageIndicator(current: Int, total: Int) -> String {
            String(format: manager.localizedString("common.pageIndicator"), current, total)
        }

        // Seasons
        struct Season {
            static var spring: String { manager.localizedString("common.season.spring") }
            static var summer: String { manager.localizedString("common.season.summer") }
            static var autumn: String { manager.localizedString("common.season.autumn") }
            static var winter: String { manager.localizedString("common.season.winter") }
            static var playbookFormat: String { manager.localizedString("common.season.playbookFormat") }
        }
    }

    // MARK: - Premium Errors

    struct Premium {
        struct Error {
            static var notImplemented: String { manager.localizedString("premium.error.notImplemented") }
            static var failedVerification: String { manager.localizedString("premium.error.failedVerification") }
            static var purchaseFailed: String { manager.localizedString("premium.error.purchaseFailed") }
            static var restoreFailed: String { manager.localizedString("premium.error.restoreFailed") }
            static var routineLimitReached: String { manager.localizedString("premium.error.routineLimitReached") }
            static func featureRequiresPremium(_ feature: String) -> String {
                String(format: manager.localizedString("premium.error.featureRequiresPremium"), feature)
            }
        }
    }

    // MARK: - Language

    struct Language {
        static var english: String { manager.localizedString("language.english") }
        static var turkish: String { manager.localizedString("language.turkish") }
    }

    // MARK: - Theme

    struct Theme {
        static var system: String { manager.localizedString("theme.system") }
        static var light: String { manager.localizedString("theme.light") }
        static var dark: String { manager.localizedString("theme.dark") }
    }

    // MARK: - Debug

    struct Debug {
        static var premiumTitle: String { manager.localizedString("debug.premiumTitle") }
        static var premiumStatus: String { manager.localizedString("debug.premiumStatus") }
        static var currentStatus: String { manager.localizedString("debug.currentStatus") }
        static var actions: String { manager.localizedString("debug.actions") }
        static var featureAccess: String { manager.localizedString("debug.featureAccess") }
        static var active: String { manager.localizedString("debug.active") }
        static var inactive: String { manager.localizedString("debug.inactive") }
        static var showPaywall: String { manager.localizedString("debug.showPaywall") }
        static var grantPremium: String { manager.localizedString("debug.grantPremium") }
        static var revokePremium: String { manager.localizedString("debug.revokePremium") }
        static var restorePurchases: String { manager.localizedString("debug.restorePurchases") }
        static var featureCreateRoutines: String { manager.localizedString("debug.featureCreateRoutines") }
        static var featureCycleAdaptation: String { manager.localizedString("debug.featureCycleAdaptation") }
        static var featureSkinJournal: String { manager.localizedString("debug.featureSkinJournal") }
        static var featureWeatherAdaptation: String { manager.localizedString("debug.featureWeatherAdaptation") }
        static var statusUnlimited: String { manager.localizedString("debug.statusUnlimited") }
        static var statusMaxTwo: String { manager.localizedString("debug.statusMaxTwo") }
        static var statusAvailable: String { manager.localizedString("debug.statusAvailable") }
        static var statusPremiumOnly: String { manager.localizedString("debug.statusPremiumOnly") }
        static var statusLocked: String { manager.localizedString("debug.statusLocked") }
        static var testPremiumFooter: String { manager.localizedString("debug.testPremiumFooter") }
    }

    // MARK: - Routines

    struct Routines {
        // General
        static var title: String { manager.localizedString("routines.title", table: "Routines") }
        static var morningRoutine: String { manager.localizedString("routines.morning", table: "Routines") }
        static var eveningRoutine: String { manager.localizedString("routines.evening", table: "Routines") }
        static var weeklyRoutine: String { manager.localizedString("routines.weekly", table: "Routines") }
        static var morningOnly: String { manager.localizedString("routines.morningOnly", table: "Routines") }
        static var eveningOnly: String { manager.localizedString("routines.eveningOnly", table: "Routines") }
        static var weeklyOnly: String { manager.localizedString("routines.weeklyOnly", table: "Routines") }
        static var createRoutine: String { manager.localizedString("routines.create", table: "Routines") }
        static var noRoutines: String { manager.localizedString("routines.noRoutines", table: "Routines") }
        static var yourDailyRoutine: String { manager.localizedString("routines.yourDailyRoutine", table: "Routines") }
        static var myRoutines: String { manager.localizedString("routines.myRoutines", table: "Routines") }
        static var tapToComplete: String { manager.localizedString("routines.tapToComplete", table: "Routines") }
        static var today: String { manager.localizedString("routines.today", table: "Routines") }
        static var chooseRoutine: String { manager.localizedString("routines.chooseRoutine", table: "Routines") }
        static var selectActiveRoutine: String { manager.localizedString("routines.selectActiveRoutine", table: "Routines") }
        static var noSavedRoutines: String { manager.localizedString("routines.noSavedRoutines", table: "Routines") }
        static var saveFromDiscover: String { manager.localizedString("routines.saveFromDiscover", table: "Routines") }

        // Steps
        static var steps: String { manager.localizedString("routines.steps", table: "Routines") }
        static var completed: String { manager.localizedString("routines.completed", table: "Routines") }
        static var products: String { manager.localizedString("routines.products", table: "Routines") }
        static func stepsCount(_ count: Int) -> String {
            String(format: manager.localizedString(count == 1 ? "routines.stepsCountSingle" : "routines.stepsCount", table: "Routines"), count)
        }
        static func productsCount(_ count: Int) -> String {
            String(format: manager.localizedString("routines.productsCount", table: "Routines"), count)
        }
        static func stepsCompleted(completed: Int, total: Int) -> String {
            String(format: manager.localizedString("routines.stepsCompleted", table: "Routines"), completed, total)
        }
        static var stepCompleted: String { manager.localizedString("routines.stepCompleted", table: "Routines") }
        static var stepTapToComplete: String { manager.localizedString("routines.stepTapToComplete", table: "Routines") }
        static func progressFormat(completed: Int, total: Int, completedText: String) -> String {
            String(format: manager.localizedString("routines.progressFormat", table: "Routines"), completed, total, completedText)
        }
        static func progressPercentage(_ percentage: Int) -> String {
            String(format: manager.localizedString("routines.progressPercentage", table: "Routines"), percentage)
        }
        static func sectionSubtitleBullet(_ subtitle: String) -> String {
            String(format: manager.localizedString("routines.sectionSubtitleBullet", table: "Routines"), subtitle)
        }

        static func stepTitle(_ productType: String) -> String {
            let key = "routines.step.\(productType)"
            return manager.localizedString(key, table: "Routines")
        }

        static func guidance(_ key: String) -> String {
            manager.localizedString(key, table: "Routines")
        }


        // Generation Errors
        struct GenerationError {
            static var noRoutineToSave: String { manager.localizedString("routines.generation.error.noRoutineToSave", table: "Routines") }
            static var missingSkinType: String { manager.localizedString("routines.generation.error.missingSkinType", table: "Routines") }
            static var missingConcerns: String { manager.localizedString("routines.generation.error.missingConcerns", table: "Routines") }
            static var missingMainGoal: String { manager.localizedString("routines.generation.error.missingMainGoal", table: "Routines") }
            static var missingSkinTone: String { manager.localizedString("routines.generation.error.missingSkinTone", table: "Routines") }
            static var missingAgeRange: String { manager.localizedString("routines.generation.error.missingAgeRange", table: "Routines") }
            static var missingRegion: String { manager.localizedString("routines.generation.error.missingRegion", table: "Routines") }
            static var generationFailed: String { manager.localizedString("routines.generation.error.generationFailed", table: "Routines") }
            static var saveFailed: String { manager.localizedString("routines.generation.error.saveFailed", table: "Routines") }
        }

        // Results
        struct Result {
            static var personalizedRoutine: String { manager.localizedString("routines.result.personalizedRoutine", table: "Routines") }
            static var basedOnProfile: String { manager.localizedString("routines.result.basedOnProfile", table: "Routines") }
            static var morningRoutine: String { manager.localizedString("routines.result.morningRoutine", table: "Routines") }
            static var eveningRoutine: String { manager.localizedString("routines.result.eveningRoutine", table: "Routines") }
            static var loadingRoutine: String { manager.localizedString("routines.result.loadingRoutine", table: "Routines") }
            static var startJourney: String { manager.localizedString("routines.result.startJourney", table: "Routines") }
            static func stepsCount(_ count: Int) -> String {
                String(format: manager.localizedString(count == 1 ? "routines.result.stepsCountSingle" : "routines.result.stepsCount", table: "Routines"), count)
            }
        }


        // Adaptation Settings
        struct AdaptationSettings {
            static var title: String { manager.localizedString("routines.adaptationSettings.title", table: "Routines") }
            static var adaptationType: String { manager.localizedString("routines.adaptationSettings.adaptationType", table: "Routines") }
            static var cancel: String { manager.localizedString("routines.adaptationSettings.cancel", table: "Routines") }
            static var save: String { manager.localizedString("routines.adaptationSettings.save", table: "Routines") }
            static var error: String { manager.localizedString("routines.adaptationSettings.error", table: "Routines") }
            static var ok: String { manager.localizedString("routines.adaptationSettings.ok", table: "Routines") }
            static var cyclePreview: String { manager.localizedString("routines.adaptationSettings.cyclePreview", table: "Routines") }
            static var weatherPreview: String { manager.localizedString("routines.adaptationSettings.weatherPreview", table: "Routines") }
            static var skinStatePreview: String { manager.localizedString("routines.adaptationSettings.skinStatePreview", table: "Routines") }
            static var premiumRequired: String { manager.localizedString("routines.adaptationSettings.premiumRequired", table: "Routines") }
        }

        // Detail
        struct Detail {
            static var routineComplete: String { manager.localizedString("routines.detail.routineComplete", table: "Routines") }
            static var greatJob: String { manager.localizedString("routines.detail.greatJob", table: "Routines") }
            static var back: String { manager.localizedString("routines.detail.back", table: "Routines") }
            static var stepDetails: String { manager.localizedString("routines.detail.stepDetails", table: "Routines") }
            static var adaptedRoutine: String { manager.localizedString("routines.detail.adaptedRoutine", table: "Routines") }
            static var whyThis: String { manager.localizedString("routines.detail.whyThis", table: "Routines") }

            static var adaptationLevel: String { manager.localizedString("routines.adaptationDetail.adaptationLevel", table: "Routines") }
            static var guidance: String { manager.localizedString("routines.adaptationDetail.guidance", table: "Routines") }
            static var source: String { manager.localizedString("routines.adaptationDetail.source", table: "Routines") }
            static var warnings: String { manager.localizedString("routines.adaptationDetail.warnings", table: "Routines") }
            static var originalInstructions: String { manager.localizedString("routines.adaptationDetail.originalInstructions", table: "Routines") }
            static var cycleAdaptation: String { manager.localizedString("routines.adaptationDetail.cycleAdaptation", table: "Routines") }
            static var weatherAdaptation: String { manager.localizedString("routines.adaptationDetail.weatherAdaptation", table: "Routines") }
            static var basedOnCycle: String { manager.localizedString("routines.adaptationDetail.basedOnCycle", table: "Routines") }
            static var basedOnWeather: String { manager.localizedString("routines.adaptationDetail.basedOnWeather", table: "Routines") }
        }

        // Coach Tips
        struct Coach {
            struct Morning {
                static var hydration: String { manager.localizedString("routines.coach.morning.hydration", table: "Routines") }
                static var spf: String { manager.localizedString("routines.coach.morning.spf", table: "Routines") }
                static var refresh: String { manager.localizedString("routines.coach.morning.refresh", table: "Routines") }
                static var tone: String { manager.localizedString("routines.coach.morning.tone", table: "Routines") }
            }

            struct Evening {
                static var unwind: String { manager.localizedString("routines.coach.evening.unwind", table: "Routines") }
                static var repair: String { manager.localizedString("routines.coach.evening.repair", table: "Routines") }
                static var recovery: String { manager.localizedString("routines.coach.evening.recovery", table: "Routines") }
                static var ritual: String { manager.localizedString("routines.coach.evening.ritual", table: "Routines") }
            }
        }

        // Phase Briefing
        struct PhaseBriefing {
            static func dayOfTotal(day: Int, total: Int) -> String {
                String(format: manager.localizedString("routines.phaseBriefing.dayOfTotal", table: "Routines"), day, total)
            }
            static var cycleAdaptiveRoutines: String { manager.localizedString("routines.phaseBriefing.cycleAdaptiveRoutines", table: "Routines") }
            static var personalizeForEachPhase: String { manager.localizedString("routines.phaseBriefing.personalizeForEachPhase", table: "Routines") }
            static var premium: String { manager.localizedString("routines.phaseBriefing.premium", table: "Routines") }
        }

        // Products
        struct Products {
            static func noProductAdded(_ productType: String) -> String {
                String(format: manager.localizedString("routines.products.noProductAdded", table: "Routines"), productType)
            }
            static func noProductsYet(_ productType: String) -> String {
                String(format: manager.localizedString("routines.products.noProductsYet", table: "Routines"), productType)
            }
            static var scanProduct: String { manager.localizedString("routines.products.scanProduct", table: "Routines") }
            static var scanDescription: String { manager.localizedString("routines.products.scanDescription", table: "Routines") }
            static var addManually: String { manager.localizedString("routines.products.addManually", table: "Routines") }
            static var addManuallyDescription: String { manager.localizedString("routines.products.addManuallyDescription", table: "Routines") }
            static func addNew(_ productType: String) -> String {
                String(format: manager.localizedString("routines.products.addNew", table: "Routines"), productType)
            }
        }

        // Editing
        struct Edit {
            static var title: String { manager.localizedString("routines.edit.title", table: "Routines") }
            static var stepName: String { manager.localizedString("routines.edit.stepName", table: "Routines") }
            static var description: String { manager.localizedString("routines.edit.description", table: "Routines") }
            static var enterDescription: String { manager.localizedString("routines.edit.enterDescription", table: "Routines") }
            static var addNewStep: String { manager.localizedString("routines.edit.addNewStep", table: "Routines") }
            static func addStepDescription(_ timeOfDay: String) -> String {
                String(format: manager.localizedString("routines.edit.addStepDescription", table: "Routines"), timeOfDay)
            }
            static var editedRoutineTitle: String { manager.localizedString("routines.edit.editedRoutineTitle", table: "Routines") }
            static var editedRoutineOneLiner: String { manager.localizedString("routines.edit.editedRoutineOneLiner", table: "Routines") }
            static var enterStepName: String { manager.localizedString("routines.edit.enterStepName", table: "Routines") }
            static var editStep: String { manager.localizedString("routines.edit.editStep", table: "Routines") }
        }

        // Mood
        struct Mood {
            static var title: String { manager.localizedString("routines.mood.title", table: "Routines") }
            static var description: String { manager.localizedString("routines.mood.description", table: "Routines") }
        }

        // UV Index
        struct UV {
            static var question: String { manager.localizedString("routines.uv.question", table: "Routines") }
            static var description: String { manager.localizedString("routines.uv.description", table: "Routines") }
            static var recommended: String { manager.localizedString("routines.uv.recommended", table: "Routines") }
        }

        // Editing
        struct Editing {
            static var title: String { manager.localizedString("routines.editing.title", table: "Routines") }
            static var save: String { manager.localizedString("routines.editing.save", table: "Routines") }
            static var add: String { manager.localizedString("routines.editing.add", table: "Routines") }
            static var noStepsYet: String { manager.localizedString("routines.editing.noStepsYet", table: "Routines") }
            static func addFirstStepDescription(_ timeOfDay: String) -> String {
                String(format: manager.localizedString("routines.editing.addFirstStepDescription", table: "Routines"), timeOfDay)
            }
            static var addFirstStep: String { manager.localizedString("routines.editing.addFirstStep", table: "Routines") }
            static func routineTitle(_ timeOfDay: String) -> String {
                String(format: manager.localizedString("routines.editing.routineTitle", table: "Routines"), timeOfDay)
            }
            static var editedRoutineTitle: String { manager.localizedString("routines.editing.editedRoutineTitle", table: "Routines") }
            static var editedRoutineOneLiner: String { manager.localizedString("routines.editing.editedRoutineOneLiner", table: "Routines") }
        }

        // Preview
        struct Preview {
            static var title: String { manager.localizedString("routines.preview.title", table: "Routines") }
            static var subtitle: String { manager.localizedString("routines.preview.subtitle", table: "Routines") }
            static var saveChanges: String { manager.localizedString("routines.preview.saveChanges", table: "Routines") }
            static var cancel: String { manager.localizedString("routines.preview.cancel", table: "Routines") }
            static var activeSteps: String { manager.localizedString("routines.preview.activeSteps", table: "Routines") }
            static var amPm: String { manager.localizedString("routines.preview.amPm", table: "Routines") }
            static var am: String { manager.localizedString("routines.preview.am", table: "Routines") }
            static var pm: String { manager.localizedString("routines.preview.pm", table: "Routines") }
        }


        // Completion
        struct Completion {
            static var or: String { manager.localizedString("routines.completion.or", table: "Routines") }
            static var addYourProduct: String { manager.localizedString("routines.completion.addYourProduct", table: "Routines") }
            static var cycleAdapted: String { manager.localizedString("routines.completion.cycleAdapted", table: "Routines") }
            static var basedOnWeather: String { manager.localizedString("routines.completion.basedOnWeather", table: "Routines") }
        }

        // Product Selection
        struct ProductSelection {
            static var title: String { manager.localizedString("routines.productSelection.title", table: "Routines") }
            static func subtitle(_ step: String) -> String {
                String(format: manager.localizedString("routines.productSelection.subtitle", table: "Routines"), step)
            }
            static var searchPlaceholder: String { manager.localizedString("routines.productSelection.searchPlaceholder", table: "Routines") }
            static func attach(_ product: String) -> String {
                String(format: manager.localizedString("routines.productSelection.attach", table: "Routines"), product)
            }
            static var addNew: String { manager.localizedString("routines.productSelection.addNew", table: "Routines") }
            static var perfectMatch: String { manager.localizedString("routines.productSelection.perfectMatch", table: "Routines") }
            static var noCompatible: String { manager.localizedString("routines.productSelection.noCompatible", table: "Routines") }
            static func noCompatibleDescription(_ type: String) -> String {
                String(format: manager.localizedString("routines.productSelection.noCompatibleDescription", table: "Routines"), type)
            }
            static func addType(_ type: String) -> String {
                String(format: manager.localizedString("routines.productSelection.addType", table: "Routines"), type)
            }
        }


        // Cycle Promotion
        struct CyclePromotion {
            static var title: String { manager.localizedString("routines.cyclePromotion.title", table: "Routines") }
            static var subtitlePremium: String { manager.localizedString("routines.cyclePromotion.subtitlePremium", table: "Routines") }
            static var subtitleNonPremium: String { manager.localizedString("routines.cyclePromotion.subtitleNonPremium", table: "Routines") }
            static var phaseGentle: String { manager.localizedString("routines.cyclePromotion.phaseGentle", table: "Routines") }
            static var phaseActive: String { manager.localizedString("routines.cyclePromotion.phaseActive", table: "Routines") }
            static var phaseBalanced: String { manager.localizedString("routines.cyclePromotion.phaseBalanced", table: "Routines") }
            static var phaseControl: String { manager.localizedString("routines.cyclePromotion.phaseControl", table: "Routines") }
            static var enableCycleTracking: String { manager.localizedString("routines.cyclePromotion.enableCycleTracking", table: "Routines") }
            static var upgradeToPremium: String { manager.localizedString("routines.cyclePromotion.upgradeToPremium", table: "Routines") }
            static var alertTitle: String { manager.localizedString("routines.cyclePromotion.alertTitle", table: "Routines") }
        }

        // Adaptation Briefing
        struct AdaptationBriefing {
            static var tips: String { manager.localizedString("routines.adaptationBriefing.tips", table: "Routines") }
        }

        // Routine Result Summary
        struct ResultSummary {
            static var title: String { manager.localizedString("routines.resultSummary.title", table: "Routines") }
            static var skinType: String { manager.localizedString("routines.resultSummary.skinType", table: "Routines") }
            static var mainGoal: String { manager.localizedString("routines.resultSummary.mainGoal", table: "Routines") }
            static var focusAreas: String { manager.localizedString("routines.resultSummary.focusAreas", table: "Routines") }
            static func selectedCount(_ count: Int) -> String {
                String(format: manager.localizedString("routines.resultSummary.selectedCount", table: "Routines"), count)
            }
        }

        // Step Adaptation Badge
        struct AdaptationBadge {
            static var skip: String { manager.localizedString("routines.adaptationBadge.skip", table: "Routines") }
            static var reduce: String { manager.localizedString("routines.adaptationBadge.reduce", table: "Routines") }
            static var normal: String { manager.localizedString("routines.adaptationBadge.normal", table: "Routines") }
            static var emphasize: String { manager.localizedString("routines.adaptationBadge.emphasize", table: "Routines") }
        }

        // Cycle Card
        struct CycleCard {
            static func dayNumber(_ day: Int) -> String {
                String(format: manager.localizedString("routines.cycleCard.dayNumber", table: "Routines"), day)
            }
            static func ofTotal(_ total: Int) -> String {
                String(format: manager.localizedString("routines.cycleCard.ofTotal", table: "Routines"), total)
            }
            static var day: String { manager.localizedString("routines.cycleCard.day", table: "Routines") }
        }

        // Weather
        struct Weather {
            struct UVLevel {
                static var low: String { manager.localizedString("routines.weather.uvLevel.low", table: "Routines") }
                static var moderate: String { manager.localizedString("routines.weather.uvLevel.moderate", table: "Routines") }
                static var high: String { manager.localizedString("routines.weather.uvLevel.high", table: "Routines") }
                static var extreme: String { manager.localizedString("routines.weather.uvLevel.extreme", table: "Routines") }
            }

            struct SPF {
                static var spf30: String { manager.localizedString("routines.weather.spf.30", table: "Routines") }
                static var spf3050: String { manager.localizedString("routines.weather.spf.3050", table: "Routines") }
                static var spf50Plus: String { manager.localizedString("routines.weather.spf.50plus", table: "Routines") }
            }

            struct Tip {
                static var activeSafe: String { manager.localizedString("routines.weather.tip.activeSafe", table: "Routines") }
                static var antioxidant: String { manager.localizedString("routines.weather.tip.antioxidant", table: "Routines") }
                static var reapply2h: String { manager.localizedString("routines.weather.tip.reapply2h", table: "Routines") }
                static var addAntioxidant: String { manager.localizedString("routines.weather.tip.addAntioxidant", table: "Routines") }
                static var stayInShade: String { manager.localizedString("routines.weather.tip.stayInShade", table: "Routines") }
                static var protectiveClothing: String { manager.localizedString("routines.weather.tip.protectiveClothing", table: "Routines") }
                static var addHydratingToner: String { manager.localizedString("routines.weather.tip.addHydratingToner", table: "Routines") }
                static var avoidHeavyOils: String { manager.localizedString("routines.weather.tip.avoidHeavyOils", table: "Routines") }
                static var barrierCream: String { manager.localizedString("routines.weather.tip.barrierCream", table: "Routines") }
                static var addCeramide: String { manager.localizedString("routines.weather.tip.addCeramide", table: "Routines") }
                static var oilFree: String { manager.localizedString("routines.weather.tip.oilFree", table: "Routines") }
            }

            struct Warning {
                static var avoidMorningActives: String { manager.localizedString("routines.weather.warning.avoidMorningActives", table: "Routines") }
                static var skipActives: String { manager.localizedString("routines.weather.warning.skipActives", table: "Routines") }
                static var reapply: String { manager.localizedString("routines.weather.warning.reapply", table: "Routines") }
                static var avoidOverExfoliating: String { manager.localizedString("routines.weather.warning.avoidOverExfoliating", table: "Routines") }
                static var skipHarshPeels: String { manager.localizedString("routines.weather.warning.skipHarshPeels", table: "Routines") }
                static var snowReflection: String { manager.localizedString("routines.weather.warning.snowReflection", table: "Routines") }
            }

            struct Texture {
                static var heavyMoisturizers: String { manager.localizedString("routines.weather.texture.heavyMoisturizers", table: "Routines") }
                static var lightGel: String { manager.localizedString("routines.weather.texture.lightGel", table: "Routines") }
                static var richProtective: String { manager.localizedString("routines.weather.texture.richProtective", table: "Routines") }
                static var lightMattifying: String { manager.localizedString("routines.weather.texture.lightMattifying", table: "Routines") }
            }

            static var productTexture: String { manager.localizedString("routines.weather.productTexture", table: "Routines") }
            // Additional properties from the first Weather struct
            static var autoAdapt: String { manager.localizedString("routines.weather.autoAdapt", table: "Routines") }
            static var description: String { manager.localizedString("routines.weather.description", table: "Routines") }
            static var uv: String { manager.localizedString("routines.weather.uv", table: "Routines") }
            static var humidity: String { manager.localizedString("routines.weather.humidity", table: "Routines") }
            static var wind: String { manager.localizedString("routines.weather.wind", table: "Routines") }
            static var temp: String { manager.localizedString("routines.weather.temp", table: "Routines") }
            static var enableInSettings: String { manager.localizedString("routines.weather.enableInSettings", table: "Routines") }
            static var enableAdaptation: String { manager.localizedString("routines.weather.enableAdaptation", table: "Routines") }
            static var adaptedRoutine: String { manager.localizedString("routines.weather.adaptedRoutine", table: "Routines") }
            static var currentConditions: String { manager.localizedString("routines.weather.currentConditions", table: "Routines") }
            static func unableToEnable(error: String) -> String {
                String(format: manager.localizedString("routines.weather.unableToEnable", table: "Routines"), error)
            }
            static var recommendedSPF: String { manager.localizedString("routines.weather.recommendedSPF", table: "Routines") }
            static var temperature: String { manager.localizedString("routines.weather.temperature", table: "Routines") }
            static var windSpeed: String { manager.localizedString("routines.weather.windSpeed", table: "Routines") }
            static var snow: String { manager.localizedString("routines.weather.snow", table: "Routines") }
            static var snowWarning: String { manager.localizedString("routines.weather.snowWarning", table: "Routines") }
            static var details: String { manager.localizedString("routines.weather.details", table: "Routines") }
            static var uvIndexTitle: String { manager.localizedString("routines.weather.uvIndexTitle", table: "Routines") }
            static var environmentalConditions: String { manager.localizedString("routines.weather.environmentalConditions", table: "Routines") }
            static var todaysTips: String { manager.localizedString("routines.weather.todaysTips", table: "Routines") }
            static func uvIndex(_ index: Int) -> String {
                String(format: manager.localizedString("routines.weather.uvIndex", table: "Routines"), index)
            }
            static func level(_ level: Int) -> String {
                String(format: manager.localizedString("routines.weather.level", table: "Routines"), level)
            }
            static func uvLevelDisplay(_ level: String) -> String {
                String(format: manager.localizedString("routines.weather.uvLevelDisplay", table: "Routines"), level)
            }
            static var warnings: String { manager.localizedString("routines.weather.warnings", table: "Routines") }
            static func warningBullet(_ warning: String) -> String {
                String(format: manager.localizedString("routines.weather.warningBullet", table: "Routines"), warning)
            }
            static var tipBullet: String { manager.localizedString("routines.weather.tipBullet", table: "Routines") }
        }

        // Cycle
        struct Cycle {
            struct Phase {
                static var menstrual: String { manager.localizedString("routines.cycle.phase.menstrual", table: "Routines") }
                static var follicular: String { manager.localizedString("routines.cycle.phase.follicular", table: "Routines") }
                static var ovulation: String { manager.localizedString("routines.cycle.phase.ovulation", table: "Routines") }
                static var luteal: String { manager.localizedString("routines.cycle.phase.luteal", table: "Routines") }
            }

            struct PhaseDesc {
                static var menstrual: String { manager.localizedString("routines.cycle.phaseDesc.menstrual", table: "Routines") }
                static var follicular: String { manager.localizedString("routines.cycle.phaseDesc.follicular", table: "Routines") }
                static var ovulation: String { manager.localizedString("routines.cycle.phaseDesc.ovulation", table: "Routines") }
                static var luteal: String { manager.localizedString("routines.cycle.phaseDesc.luteal", table: "Routines") }
            }

            struct Tip {
                static var menstrual: String { manager.localizedString("routines.cycle.tip.menstrual", table: "Routines") }
                static var follicular: String { manager.localizedString("routines.cycle.tip.follicular", table: "Routines") }
                static var ovulation: String { manager.localizedString("routines.cycle.tip.ovulation", table: "Routines") }
                static var luteal: String { manager.localizedString("routines.cycle.tip.luteal", table: "Routines") }
            }
        }

        // Adaptation
        struct Adaptation {
            struct AdaptationType {
                static var cycleTracking: String { manager.localizedString("routines.adaptation.type.cycleTracking", table: "Routines") }
                static var seasonal: String { manager.localizedString("routines.adaptation.type.seasonal", table: "Routines") }
                static var skinState: String { manager.localizedString("routines.adaptation.type.skinState", table: "Routines") }
            }

            struct TypeDesc {
                static var cycle: String { manager.localizedString("routines.adaptation.typeDesc.cycle", table: "Routines") }
                static var seasonal: String { manager.localizedString("routines.adaptation.typeDesc.seasonal", table: "Routines") }
                static var skinState: String { manager.localizedString("routines.adaptation.typeDesc.skinState", table: "Routines") }
            }

            struct Origin {
                static var `default`: String { manager.localizedString("routines.adaptation.origin.default", table: "Routines") }
                static var aiRecommended: String { manager.localizedString("routines.adaptation.origin.aiRecommended", table: "Routines") }
                static var custom: String { manager.localizedString("routines.adaptation.origin.custom", table: "Routines") }
            }

            // Additional properties from the first Adaptation struct
            static var cycleAdaptive: String { manager.localizedString("routines.adaptation.cycleAdaptive", table: "Routines") }
            static var automaticallyAdapts: String { manager.localizedString("routines.adaptation.automaticallyAdapts", table: "Routines") }
            static var howItAdapts: String { manager.localizedString("routines.adaptation.howItAdapts", table: "Routines") }
            static var adaptedToCycle: String { manager.localizedString("routines.adaptation.adaptedToCycle", table: "Routines") }
            static var enableCycleAdaptive: String { manager.localizedString("routines.adaptation.enableCycleAdaptive", table: "Routines") }
            static var adaptiveMode: String { manager.localizedString("routines.adaptation.adaptiveMode", table: "Routines") }
            static var autoAdjust: String { manager.localizedString("routines.adaptation.autoAdjust", table: "Routines") }
            static var adaptation: String { manager.localizedString("routines.adaptation.adaptation", table: "Routines") }
            static var whenEnabled: String { manager.localizedString("routines.adaptation.whenEnabled", table: "Routines") }
            static var type: String { manager.localizedString("routines.adaptation.type", table: "Routines") }
            static var preview: String { manager.localizedString("routines.adaptation.preview", table: "Routines") }
            static var todaysAdaptation: String { manager.localizedString("routines.adaptation.todaysAdaptation", table: "Routines") }

            static func cycleInfo(phase: String, day: Int) -> String {
                String(format: manager.localizedString("routines.adaptation.cycle.info", table: "Routines"), phase, day)
            }
            static var cycleDescription: String { manager.localizedString("routines.adaptation.cycle.description", table: "Routines") }
            static var weatherDescription: String { manager.localizedString("routines.adaptation.weather.description", table: "Routines") }
            static var skinStateDescription: String { manager.localizedString("routines.adaptation.skinState.description", table: "Routines") }

            // Cycle Phase Descriptions
            static var menstrualPhase: String { manager.localizedString("routines.adaptation.cycle.menstrualPhase", table: "Routines") }
            static var follicularPhase: String { manager.localizedString("routines.adaptation.cycle.follicularPhase", table: "Routines") }
            static var ovulationPhase: String { manager.localizedString("routines.adaptation.cycle.ovulationPhase", table: "Routines") }
            static var lutealPhase: String { manager.localizedString("routines.adaptation.cycle.lutealPhase", table: "Routines") }
        }

        // Companion
        struct Companion {
            struct Status {
                static var active: String { manager.localizedString("routines.companion.status.active", table: "Routines") }
                static var paused: String { manager.localizedString("routines.companion.status.paused", table: "Routines") }
                static var completed: String { manager.localizedString("routines.companion.status.completed", table: "Routines") }
                static var abandoned: String { manager.localizedString("routines.companion.status.abandoned", table: "Routines") }
            }

            struct StepType {
                static var instruction: String { manager.localizedString("routines.companion.stepType.instruction", table: "Routines") }
                static var timed: String { manager.localizedString("routines.companion.stepType.timed", table: "Routines") }
            }

            // Additional properties from the first Companion struct
            static var preparing: String { manager.localizedString("routines.companion.preparing", table: "Routines") }
            static var loadingStep: String { manager.localizedString("routines.companion.loadingStep", table: "Routines") }
            static var instructions: String { manager.localizedString("routines.companion.instructions", table: "Routines") }
            static func startTimer(_ seconds: Int) -> String {
                String(format: manager.localizedString("routines.companion.startTimer", table: "Routines"), seconds)
            }
            static var done: String { manager.localizedString("routines.companion.done", table: "Routines") }
            static var skip: String { manager.localizedString("routines.companion.skip", table: "Routines") }
            static var pause: String { manager.localizedString("routines.companion.pause", table: "Routines") }
            static var resume: String { manager.localizedString("routines.companion.resume", table: "Routines") }
            static var proTips: String { manager.localizedString("routines.companion.proTips", table: "Routines") }
            static var adjust: String { manager.localizedString("routines.companion.adjust", table: "Routines") }
            static var complete: String { manager.localizedString("routines.companion.complete", table: "Routines") }
            static func stepsCompleted(completed: Int, total: Int) -> String {
                String(format: manager.localizedString("routines.companion.stepsCompleted", table: "Routines"), completed, total)
            }
            static var doneForToday: String { manager.localizedString("routines.companion.doneForToday", table: "Routines") }
            static var doAgain: String { manager.localizedString("routines.companion.doAgain", table: "Routines") }
            static var doAgainButton: String { manager.localizedString("routines.companion.doAgainButton", table: "Routines") }
            static var totalTime: String { manager.localizedString("routines.companion.totalTime", table: "Routines") }
            static var stepsSkipped: String { manager.localizedString("routines.companion.stepsSkipped", table: "Routines") }
            static var completionRate: String { manager.localizedString("routines.companion.completionRate", table: "Routines") }

            struct Notification {
                static var timerComplete: String { manager.localizedString("routines.companion.notification.timerComplete", table: "Routines") }
                static func timeToApply(_ stepTitle: String) -> String {
                    String(format: manager.localizedString("routines.companion.notification.timeToApply", table: "Routines"), stepTitle)
                }
            }
        }

        // Tips
        struct Tips {
            struct Category {
                static var application: String { manager.localizedString("routines.tips.category.application", table: "Routines") }
                static var technique: String { manager.localizedString("routines.tips.category.technique", table: "Routines") }
                static var timing: String { manager.localizedString("routines.tips.category.timing", table: "Routines") }
                static var benefits: String { manager.localizedString("routines.tips.category.benefits", table: "Routines") }
                static var commonMistakes: String { manager.localizedString("routines.tips.category.commonMistakes", table: "Routines") }
                static var proTips: String { manager.localizedString("routines.tips.category.proTips", table: "Routines") }
            }

            // Cleanser Tips
            struct Cleanser {
                struct GentleCircular {
                    static var title: String { manager.localizedString("routines.tips.cleanser.gentleCircular.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.cleanser.gentleCircular.content", table: "Routines") }
                }
                struct DampSkin {
                    static var title: String { manager.localizedString("routines.tips.cleanser.dampSkin.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.cleanser.dampSkin.content", table: "Routines") }
                }
                struct ThirtySecond {
                    static var title: String { manager.localizedString("routines.tips.cleanser.thirtySecond.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.cleanser.thirtySecond.content", table: "Routines") }
                }
                struct AvoidEye {
                    static var title: String { manager.localizedString("routines.tips.cleanser.avoidEye.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.cleanser.avoidEye.content", table: "Routines") }
                }
                struct Lukewarm {
                    static var title: String { manager.localizedString("routines.tips.cleanser.lukewarm.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.cleanser.lukewarm.content", table: "Routines") }
                }
            }

            // Serum Tips
            struct Serum {
                struct PatDontRub {
                    static var title: String { manager.localizedString("routines.tips.serum.patDontRub.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.serum.patDontRub.content", table: "Routines") }
                }
                struct WaitAbsorption {
                    static var title: String { manager.localizedString("routines.tips.serum.waitAbsorption.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.serum.waitAbsorption.content", table: "Routines") }
                }
                struct LessMore {
                    static var title: String { manager.localizedString("routines.tips.serum.lessMore.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.serum.lessMore.content", table: "Routines") }
                }
                struct TargetAreas {
                    static var title: String { manager.localizedString("routines.tips.serum.targetAreas.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.serum.targetAreas.content", table: "Routines") }
                }
                struct MorningEvening {
                    static var title: String { manager.localizedString("routines.tips.serum.morningEvening.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.serum.morningEvening.content", table: "Routines") }
                }
            }

            // Moisturizer Tips
            struct Moisturizer {
                struct Upward {
                    static var title: String { manager.localizedString("routines.tips.moisturizer.upward.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.moisturizer.upward.content", table: "Routines") }
                }
                struct PeaSized {
                    static var title: String { manager.localizedString("routines.tips.moisturizer.peaSized.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.moisturizer.peaSized.content", table: "Routines") }
                }
                struct NeckDeco {
                    static var title: String { manager.localizedString("routines.tips.moisturizer.neckDeco.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.moisturizer.neckDeco.content", table: "Routines") }
                }
                struct LockMoisture {
                    static var title: String { manager.localizedString("routines.tips.moisturizer.lockMoisture.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.moisturizer.lockMoisture.content", table: "Routines") }
                }
                struct MorningNight {
                    static var title: String { manager.localizedString("routines.tips.moisturizer.morningNight.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.moisturizer.morningNight.content", table: "Routines") }
                }
            }

            // Sunscreen Tips
            struct Sunscreen {
                struct Quarter {
                    static var title: String { manager.localizedString("routines.tips.sunscreen.quarter.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.sunscreen.quarter.content", table: "Routines") }
                }
                struct Reapply {
                    static var title: String { manager.localizedString("routines.tips.sunscreen.reapply.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.sunscreen.reapply.content", table: "Routines") }
                }
                struct Ears {
                    static var title: String { manager.localizedString("routines.tips.sunscreen.ears.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.sunscreen.ears.content", table: "Routines") }
                }
                struct WaitMakeup {
                    static var title: String { manager.localizedString("routines.tips.sunscreen.waitMakeup.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.sunscreen.waitMakeup.content", table: "Routines") }
                }
                struct YearRound {
                    static var title: String { manager.localizedString("routines.tips.sunscreen.yearRound.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.sunscreen.yearRound.content", table: "Routines") }
                }
            }

            // Face Sunscreen Tips
            struct FaceSunscreen {
                struct Gentle {
                    static var title: String { manager.localizedString("routines.tips.faceSunscreen.gentle.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.faceSunscreen.gentle.content", table: "Routines") }
                }
                struct UnderMakeup {
                    static var title: String { manager.localizedString("routines.tips.faceSunscreen.underMakeup.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.faceSunscreen.underMakeup.content", table: "Routines") }
                }
                struct Tzone {
                    static var title: String { manager.localizedString("routines.tips.faceSunscreen.tzone.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.faceSunscreen.tzone.content", table: "Routines") }
                }
                struct NonComedogenic {
                    static var title: String { manager.localizedString("routines.tips.faceSunscreen.nonComedogenic.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.faceSunscreen.nonComedogenic.content", table: "Routines") }
                }
                struct Hairline {
                    static var title: String { manager.localizedString("routines.tips.faceSunscreen.hairline.title", table: "Routines") }
                    static var content: String { manager.localizedString("routines.tips.faceSunscreen.hairline.content", table: "Routines") }
                }
            }
        }

        // Product Type Defaults
        struct ProductType {
            static func description(_ productType: String) -> String {
                let key = "routines.productType.description.\(productType)"
                return manager.localizedString(key, table: "Routines")
            }

            static var defaultWhy: String { manager.localizedString("routines.productType.why.default", table: "Routines") }
            static var defaultHow: String { manager.localizedString("routines.productType.how.default", table: "Routines") }
        }

        // Fallback Routines
        struct Fallback {
            struct Title {
                static var morningCleanser: String { manager.localizedString("routines.fallback.title.morningCleanser", table: "Routines") }
                static var morningToner: String { manager.localizedString("routines.fallback.title.morningToner", table: "Routines") }
                static var morningMoisturizer: String { manager.localizedString("routines.fallback.title.morningMoisturizer", table: "Routines") }
                static var morningSunscreen: String { manager.localizedString("routines.fallback.title.morningSunscreen", table: "Routines") }
                static var eveningCleanser: String { manager.localizedString("routines.fallback.title.eveningCleanser", table: "Routines") }
                static var eveningSerum: String { manager.localizedString("routines.fallback.title.eveningSerum", table: "Routines") }
                static var eveningMoisturizer: String { manager.localizedString("routines.fallback.title.eveningMoisturizer", table: "Routines") }
            }

            struct Desc {
                static var morningCleanser: String { manager.localizedString("routines.fallback.desc.morningCleanser", table: "Routines") }
                static var morningToner: String { manager.localizedString("routines.fallback.desc.morningToner", table: "Routines") }
                static var morningMoisturizer: String { manager.localizedString("routines.fallback.desc.morningMoisturizer", table: "Routines") }
                static var morningSunscreen: String { manager.localizedString("routines.fallback.desc.morningSunscreen", table: "Routines") }
                static var eveningCleanser: String { manager.localizedString("routines.fallback.desc.eveningCleanser", table: "Routines") }
                static var eveningSerum: String { manager.localizedString("routines.fallback.desc.eveningSerum", table: "Routines") }
                static var eveningMoisturizer: String { manager.localizedString("routines.fallback.desc.eveningMoisturizer", table: "Routines") }
            }

            struct Why {
                static var morningCleanser: String { manager.localizedString("routines.fallback.why.morningCleanser", table: "Routines") }
                static var morningToner: String { manager.localizedString("routines.fallback.why.morningToner", table: "Routines") }
                static var morningMoisturizer: String { manager.localizedString("routines.fallback.why.morningMoisturizer", table: "Routines") }
                static var morningSunscreen: String { manager.localizedString("routines.fallback.why.morningSunscreen", table: "Routines") }
                static var eveningCleanser: String { manager.localizedString("routines.fallback.why.eveningCleanser", table: "Routines") }
                static var eveningSerum: String { manager.localizedString("routines.fallback.why.eveningSerum", table: "Routines") }
                static var eveningMoisturizer: String { manager.localizedString("routines.fallback.why.eveningMoisturizer", table: "Routines") }
            }

            struct How {
                static var morningCleanser: String { manager.localizedString("routines.fallback.how.morningCleanser", table: "Routines") }
                static var morningToner: String { manager.localizedString("routines.fallback.how.morningToner", table: "Routines") }
                static var morningMoisturizer: String { manager.localizedString("routines.fallback.how.morningMoisturizer", table: "Routines") }
                static var morningSunscreen: String { manager.localizedString("routines.fallback.how.morningSunscreen", table: "Routines") }
                static var eveningCleanser: String { manager.localizedString("routines.fallback.how.eveningCleanser", table: "Routines") }
                static var eveningSerum: String { manager.localizedString("routines.fallback.how.eveningSerum", table: "Routines") }
                static var eveningMoisturizer: String { manager.localizedString("routines.fallback.how.eveningMoisturizer", table: "Routines") }
            }
        }

        // Editing Service Defaults
        struct EditingService {
            struct DefaultTitle {
                static var cleanser: String { manager.localizedString("routines.editing.defaultTitle.cleanser", table: "Routines") }
                static var faceSerum: String { manager.localizedString("routines.editing.defaultTitle.faceSerum", table: "Routines") }
                static var moisturizer: String { manager.localizedString("routines.editing.defaultTitle.moisturizer", table: "Routines") }
                static var sunscreen: String { manager.localizedString("routines.editing.defaultTitle.sunscreen", table: "Routines") }
            }

            struct DefaultDesc {
                static var cleanser: String { manager.localizedString("routines.editing.defaultDesc.cleanser", table: "Routines") }
                static var faceSerum: String { manager.localizedString("routines.editing.defaultDesc.faceSerum", table: "Routines") }
                static var moisturizer: String { manager.localizedString("routines.editing.defaultDesc.moisturizer", table: "Routines") }
                static var sunscreen: String { manager.localizedString("routines.editing.defaultDesc.sunscreen", table: "Routines") }
            }

            struct DefaultWhy {
                static var cleanser: String { manager.localizedString("routines.editing.defaultWhy.cleanser", table: "Routines") }
                static var faceSerum: String { manager.localizedString("routines.editing.defaultWhy.faceSerum", table: "Routines") }
                static var moisturizer: String { manager.localizedString("routines.editing.defaultWhy.moisturizer", table: "Routines") }
                static var sunscreen: String { manager.localizedString("routines.editing.defaultWhy.sunscreen", table: "Routines") }
            }

            struct DefaultHow {
                static var cleanser: String { manager.localizedString("routines.editing.defaultHow.cleanser", table: "Routines") }
                static var faceSerum: String { manager.localizedString("routines.editing.defaultHow.faceSerum", table: "Routines") }
                static var moisturizer: String { manager.localizedString("routines.editing.defaultHow.moisturizer", table: "Routines") }
                static var sunscreen: String { manager.localizedString("routines.editing.defaultHow.sunscreen", table: "Routines") }
            }

            struct Coach {
                static var perfectMatch: String { manager.localizedString("routines.editing.coach.perfectMatch", table: "Routines") }
                static func perfectMatchMessage(product: String, step: String) -> String {
                    String(format: manager.localizedString("routines.editing.coach.perfectMatchMessage", table: "Routines"), product, step)
                }
                static var typeMismatch: String { manager.localizedString("routines.editing.coach.typeMismatch", table: "Routines") }
                static func typeMismatchMessage(product: String, productType: String, stepType: String) -> String {
                    String(format: manager.localizedString("routines.editing.coach.typeMismatchMessage", table: "Routines"), product, productType, stepType)
                }
                static var findCompatible: String { manager.localizedString("routines.editing.coach.findCompatible", table: "Routines") }
            }
        }

        // Frequency
        struct Frequency {
            static var dailyAM: String { manager.localizedString("routines.frequency.dailyAM", table: "Routines") }
            static var dailyPM: String { manager.localizedString("routines.frequency.dailyPM", table: "Routines") }
            static var both: String { manager.localizedString("routines.frequency.both", table: "Routines") }
            static func weekly(_ times: Int) -> String {
                String(format: manager.localizedString("routines.frequency.weekly", table: "Routines"), times)
            }
            static func custom(_ days: String) -> String {
                String(format: manager.localizedString("routines.frequency.custom", table: "Routines"), days)
            }

            // Descriptions
            struct Description {
                static var dailyAM: String { manager.localizedString("routines.frequency.description.dailyAM", table: "Routines") }
                static var dailyPM: String { manager.localizedString("routines.frequency.description.dailyPM", table: "Routines") }
                static var both: String { manager.localizedString("routines.frequency.description.both", table: "Routines") }
                static func weekly(_ times: Int) -> String {
                    String(format: manager.localizedString("routines.frequency.description.weekly", table: "Routines"), times)
                }
                static func custom(_ days: String) -> String {
                    String(format: manager.localizedString("routines.frequency.description.custom", table: "Routines"), days)
                }

                // Additional properties from the first Frequency struct
                static var daily: String { manager.localizedString("routines.frequency.daily.description", table: "Routines") }
                static var everyOtherDay: String { manager.localizedString("routines.frequency.everyOtherDay.description", table: "Routines") }
                static var twiceWeekly: String { manager.localizedString("routines.frequency.twiceWeekly.description", table: "Routines") }
                static var weekly: String { manager.localizedString("routines.frequency.weekly.description", table: "Routines") }
                static var custom: String { manager.localizedString("routines.frequency.custom.description", table: "Routines") }
            }

            // Additional properties from the first Frequency struct
            static var daily: String { manager.localizedString("routines.frequency.daily", table: "Routines") }
            static var everyOtherDay: String { manager.localizedString("routines.frequency.everyOtherDay", table: "Routines") }
            static var twiceWeekly: String { manager.localizedString("routines.frequency.twiceWeekly", table: "Routines") }
            static var weekly: String { manager.localizedString("routines.frequency.weekly", table: "Routines") }
            static var custom: String { manager.localizedString("routines.frequency.custom", table: "Routines") }
        }

        // Review Prompt
        struct Review {
            static var title: String { manager.localizedString("routines.review.title", table: "Routines") }
            static var message: String { manager.localizedString("routines.review.message", table: "Routines") }
            static var rateNow: String { manager.localizedString("routines.review.rateNow", table: "Routines") }
            static var notNow: String { manager.localizedString("routines.review.notNow", table: "Routines") }
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
        static var whyThis: String { manager.localizedString("routines.detail.whyThis", table: "Routines") }

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

    // MARK: - Onboarding

    struct Onboarding {
        // Welcome Screen
        struct Welcome {
            static var appName: String { manager.localizedString("onboarding.welcome.appName", table: "Onboarding") }
            static var description: String { manager.localizedString("onboarding.welcome.description", table: "Onboarding") }
            static var getStarted: String { manager.localizedString("onboarding.welcome.getStarted", table: "Onboarding") }
            static var skipToHome: String { manager.localizedString("onboarding.welcome.skipToHome", table: "Onboarding") }
        }

        // Create Routine Page
        struct CreateRoutine {
            static var title: String { manager.localizedString("onboarding.createRoutine.title", table: "Onboarding") }
            static var description: String { manager.localizedString("onboarding.createRoutine.description", table: "Onboarding") }
            static var next: String { manager.localizedString("onboarding.createRoutine.next", table: "Onboarding") }
        }

        // Add Products Page
        struct AddProducts {
            static var title: String { manager.localizedString("onboarding.addProducts.title", table: "Onboarding") }
            static var description: String { manager.localizedString("onboarding.addProducts.description", table: "Onboarding") }
            static var next: String { manager.localizedString("onboarding.addProducts.next", table: "Onboarding") }
        }

        // Discover & Track Page
        struct DiscoverTrack {
            static var title: String { manager.localizedString("onboarding.discoverTrack.title", table: "Onboarding") }
            static var description: String { manager.localizedString("onboarding.discoverTrack.description", table: "Onboarding") }
            static var getStarted: String { manager.localizedString("onboarding.discoverTrack.getStarted", table: "Onboarding") }
        }

        // Skin Type Selection
        struct SkinType {
            static var title: String { manager.localizedString("onboarding.skinType.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.skinType.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.skinType.continue", table: "Onboarding") }
            static var tapToSelect: String { manager.localizedString("onboarding.skinType.tapToSelect", table: "Onboarding") }

            // Type Options
            static var oily: String { manager.localizedString("onboarding.skinType.oily", table: "Onboarding") }
            static var oilySubtitle: String { manager.localizedString("onboarding.skinType.oily.subtitle", table: "Onboarding") }
            static var dry: String { manager.localizedString("onboarding.skinType.dry", table: "Onboarding") }
            static var drySubtitle: String { manager.localizedString("onboarding.skinType.dry.subtitle", table: "Onboarding") }
            static var combination: String { manager.localizedString("onboarding.skinType.combination", table: "Onboarding") }
            static var combinationSubtitle: String { manager.localizedString("onboarding.skinType.combination.subtitle", table: "Onboarding") }
            static var normal: String { manager.localizedString("onboarding.skinType.normal", table: "Onboarding") }
            static var normalSubtitle: String { manager.localizedString("onboarding.skinType.normal.subtitle", table: "Onboarding") }
        }

        // Concern Types
        struct ConcernTypes {
            static var acne: String { manager.localizedString("onboarding.concerns.acne", table: "Onboarding") }
            static var acneSubtitle: String { manager.localizedString("onboarding.concerns.acne.subtitle", table: "Onboarding") }
            static var redness: String { manager.localizedString("onboarding.concerns.redness", table: "Onboarding") }
            static var rednessSubtitle: String { manager.localizedString("onboarding.concerns.redness.subtitle", table: "Onboarding") }
            static var blackheads: String { manager.localizedString("onboarding.concerns.blackheads", table: "Onboarding") }
            static var blackheadsSubtitle: String { manager.localizedString("onboarding.concerns.blackheads.subtitle", table: "Onboarding") }
            static var largePores: String { manager.localizedString("onboarding.concerns.largePores", table: "Onboarding") }
            static var largePoresSubtitle: String { manager.localizedString("onboarding.concerns.largePores.subtitle", table: "Onboarding") }
            static var sensitive: String { manager.localizedString("onboarding.concerns.sensitive", table: "Onboarding") }
            static var sensitiveSubtitle: String { manager.localizedString("onboarding.concerns.sensitive.subtitle", table: "Onboarding") }
            static var wrinkles: String { manager.localizedString("onboarding.concerns.wrinkles", table: "Onboarding") }
            static var wrinklesSubtitle: String { manager.localizedString("onboarding.concerns.wrinkles.subtitle", table: "Onboarding") }
            static var dryness: String { manager.localizedString("onboarding.concerns.dryness", table: "Onboarding") }
            static var drynessSubtitle: String { manager.localizedString("onboarding.concerns.dryness.subtitle", table: "Onboarding") }
            static var none: String { manager.localizedString("onboarding.concerns.none", table: "Onboarding") }
            static var noneSubtitle: String { manager.localizedString("onboarding.concerns.none.subtitle", table: "Onboarding") }
        }

        // Main Goal Types
        struct MainGoalTypes {
            static var healthierOverall: String { manager.localizedString("onboarding.mainGoal.healthierOverall", table: "Onboarding") }
            static var healthierOverallSubtitle: String { manager.localizedString("onboarding.mainGoal.healthierOverall.subtitle", table: "Onboarding") }
            static var reduceBreakouts: String { manager.localizedString("onboarding.mainGoal.reduceBreakouts", table: "Onboarding") }
            static var reduceBreakoutsSubtitle: String { manager.localizedString("onboarding.mainGoal.reduceBreakouts.subtitle", table: "Onboarding") }
            static var sootheIrritation: String { manager.localizedString("onboarding.mainGoal.sootheIrritation", table: "Onboarding") }
            static var sootheIrritationSubtitle: String { manager.localizedString("onboarding.mainGoal.sootheIrritation.subtitle", table: "Onboarding") }
            static var preventAging: String { manager.localizedString("onboarding.mainGoal.preventAging", table: "Onboarding") }
            static var preventAgingSubtitle: String { manager.localizedString("onboarding.mainGoal.preventAging.subtitle", table: "Onboarding") }
            static var ageSlower: String { manager.localizedString("onboarding.mainGoal.ageSlower", table: "Onboarding") }
            static var ageSlowerSubtitle: String { manager.localizedString("onboarding.mainGoal.ageSlower.subtitle", table: "Onboarding") }
            static var shinySkin: String { manager.localizedString("onboarding.mainGoal.shinySkin", table: "Onboarding") }
            static var shinySkinSubtitle: String { manager.localizedString("onboarding.mainGoal.shinySkin.subtitle", table: "Onboarding") }
        }

        // Fitzpatrick Types
        struct FitzpatrickTypes {
            static var type1: String { manager.localizedString("onboarding.fitzpatrick.type1", table: "Onboarding") }
            static var type1Description: String { manager.localizedString("onboarding.fitzpatrick.type1.description", table: "Onboarding") }
            static var type1UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type1.uvSensitivity", table: "Onboarding") }
            static var type2: String { manager.localizedString("onboarding.fitzpatrick.type2", table: "Onboarding") }
            static var type2Description: String { manager.localizedString("onboarding.fitzpatrick.type2.description", table: "Onboarding") }
            static var type2UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type2.uvSensitivity", table: "Onboarding") }
            static var type3: String { manager.localizedString("onboarding.fitzpatrick.type3", table: "Onboarding") }
            static var type3Description: String { manager.localizedString("onboarding.fitzpatrick.type3.description", table: "Onboarding") }
            static var type3UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type3.uvSensitivity", table: "Onboarding") }
            static var type4: String { manager.localizedString("onboarding.fitzpatrick.type4", table: "Onboarding") }
            static var type4Description: String { manager.localizedString("onboarding.fitzpatrick.type4.description", table: "Onboarding") }
            static var type4UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type4.uvSensitivity", table: "Onboarding") }
            static var type5: String { manager.localizedString("onboarding.fitzpatrick.type5", table: "Onboarding") }
            static var type5Description: String { manager.localizedString("onboarding.fitzpatrick.type5.description", table: "Onboarding") }
            static var type5UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type5.uvSensitivity", table: "Onboarding") }
            static var type6: String { manager.localizedString("onboarding.fitzpatrick.type6", table: "Onboarding") }
            static var type6Description: String { manager.localizedString("onboarding.fitzpatrick.type6.description", table: "Onboarding") }
            static var type6UvSensitivity: String { manager.localizedString("onboarding.fitzpatrick.type6.uvSensitivity", table: "Onboarding") }
        }

        // Age Range Types
        struct AgeRangeTypes {
            static var teens: String { manager.localizedString("onboarding.ageRange.teens", table: "Onboarding") }
            static var teensDescription: String { manager.localizedString("onboarding.ageRange.teens.description", table: "Onboarding") }
            static var twenties: String { manager.localizedString("onboarding.ageRange.twenties", table: "Onboarding") }
            static var twentiesDescription: String { manager.localizedString("onboarding.ageRange.twenties.description", table: "Onboarding") }
            static var thirties: String { manager.localizedString("onboarding.ageRange.thirties", table: "Onboarding") }
            static var thirtiesDescription: String { manager.localizedString("onboarding.ageRange.thirties.description", table: "Onboarding") }
            static var forties: String { manager.localizedString("onboarding.ageRange.forties", table: "Onboarding") }
            static var fortiesDescription: String { manager.localizedString("onboarding.ageRange.forties.description", table: "Onboarding") }
            static var fifties: String { manager.localizedString("onboarding.ageRange.fifties", table: "Onboarding") }
            static var fiftiesDescription: String { manager.localizedString("onboarding.ageRange.fifties.description", table: "Onboarding") }
            static var sixtiesPlus: String { manager.localizedString("onboarding.ageRange.sixtiesPlus", table: "Onboarding") }
            static var sixtiesPlusDescription: String { manager.localizedString("onboarding.ageRange.sixtiesPlus.description", table: "Onboarding") }
        }

        // Region Types
        struct RegionTypes {
            static var tropical: String { manager.localizedString("onboarding.region.tropical", table: "Onboarding") }
            static var tropicalDescription: String { manager.localizedString("onboarding.region.tropical.description", table: "Onboarding") }
            static var tropicalUvIndex: String { manager.localizedString("onboarding.region.tropical.uvIndex", table: "Onboarding") }
            static var tropicalHumidity: String { manager.localizedString("onboarding.region.tropical.humidity", table: "Onboarding") }
            static var tropicalTemperature: String { manager.localizedString("onboarding.region.tropical.temperature", table: "Onboarding") }

            static var subtropical: String { manager.localizedString("onboarding.region.subtropical", table: "Onboarding") }
            static var subtropicalDescription: String { manager.localizedString("onboarding.region.subtropical.description", table: "Onboarding") }
            static var subtropicalUvIndex: String { manager.localizedString("onboarding.region.subtropical.uvIndex", table: "Onboarding") }
            static var subtropicalHumidity: String { manager.localizedString("onboarding.region.subtropical.humidity", table: "Onboarding") }
            static var subtropicalTemperature: String { manager.localizedString("onboarding.region.subtropical.temperature", table: "Onboarding") }

            static var temperate: String { manager.localizedString("onboarding.region.temperate", table: "Onboarding") }
            static var temperateDescription: String { manager.localizedString("onboarding.region.temperate.description", table: "Onboarding") }
            static var temperateUvIndex: String { manager.localizedString("onboarding.region.temperate.uvIndex", table: "Onboarding") }
            static var temperateHumidity: String { manager.localizedString("onboarding.region.temperate.humidity", table: "Onboarding") }
            static var temperateTemperature: String { manager.localizedString("onboarding.region.temperate.temperature", table: "Onboarding") }

            static var continental: String { manager.localizedString("onboarding.region.continental", table: "Onboarding") }
            static var continentalDescription: String { manager.localizedString("onboarding.region.continental.description", table: "Onboarding") }
            static var continentalUvIndex: String { manager.localizedString("onboarding.region.continental.uvIndex", table: "Onboarding") }
            static var continentalHumidity: String { manager.localizedString("onboarding.region.continental.humidity", table: "Onboarding") }
            static var continentalTemperature: String { manager.localizedString("onboarding.region.continental.temperature", table: "Onboarding") }

            static var mediterranean: String { manager.localizedString("onboarding.region.mediterranean", table: "Onboarding") }
            static var mediterraneanDescription: String { manager.localizedString("onboarding.region.mediterranean.description", table: "Onboarding") }
            static var mediterraneanUvIndex: String { manager.localizedString("onboarding.region.mediterranean.uvIndex", table: "Onboarding") }
            static var mediterraneanHumidity: String { manager.localizedString("onboarding.region.mediterranean.humidity", table: "Onboarding") }
            static var mediterraneanTemperature: String { manager.localizedString("onboarding.region.mediterranean.temperature", table: "Onboarding") }

            static var arctic: String { manager.localizedString("onboarding.region.arctic", table: "Onboarding") }
            static var arcticDescription: String { manager.localizedString("onboarding.region.arctic.description", table: "Onboarding") }
            static var arcticUvIndex: String { manager.localizedString("onboarding.region.arctic.uvIndex", table: "Onboarding") }
            static var arcticHumidity: String { manager.localizedString("onboarding.region.arctic.humidity", table: "Onboarding") }
            static var arcticTemperature: String { manager.localizedString("onboarding.region.arctic.temperature", table: "Onboarding") }

            static var desert: String { manager.localizedString("onboarding.region.desert", table: "Onboarding") }
            static var desertDescription: String { manager.localizedString("onboarding.region.desert.description", table: "Onboarding") }
            static var desertUvIndex: String { manager.localizedString("onboarding.region.desert.uvIndex", table: "Onboarding") }
            static var desertHumidity: String { manager.localizedString("onboarding.region.desert.humidity", table: "Onboarding") }
            static var desertTemperature: String { manager.localizedString("onboarding.region.desert.temperature", table: "Onboarding") }

            static var mountain: String { manager.localizedString("onboarding.region.mountain", table: "Onboarding") }
            static var mountainDescription: String { manager.localizedString("onboarding.region.mountain.description", table: "Onboarding") }
            static var mountainUvIndex: String { manager.localizedString("onboarding.region.mountain.uvIndex", table: "Onboarding") }
            static var mountainHumidity: String { manager.localizedString("onboarding.region.mountain.humidity", table: "Onboarding") }
            static var mountainTemperature: String { manager.localizedString("onboarding.region.mountain.temperature", table: "Onboarding") }
        }

        // Routine Depth Types
        struct RoutineDepthTypes {
            static var simple: String { manager.localizedString("onboarding.routineDepth.simple", table: "Onboarding") }
            static var simpleSubtitle: String { manager.localizedString("onboarding.routineDepth.simple.subtitle", table: "Onboarding") }
            static var simpleDescription: String { manager.localizedString("onboarding.routineDepth.simple.description", table: "Onboarding") }
            static var simpleStepCount: String { manager.localizedString("onboarding.routineDepth.simple.stepCount", table: "Onboarding") }
            static var simpleTimeEstimate: String { manager.localizedString("onboarding.routineDepth.simple.timeEstimate", table: "Onboarding") }
            static var simpleStepGuidance: String { manager.localizedString("onboarding.routineDepth.simple.stepGuidance", table: "Onboarding") }
            static var intermediate: String { manager.localizedString("onboarding.routineDepth.intermediate", table: "Onboarding") }
            static var intermediateSubtitle: String { manager.localizedString("onboarding.routineDepth.intermediate.subtitle", table: "Onboarding") }
            static var intermediateDescription: String { manager.localizedString("onboarding.routineDepth.intermediate.description", table: "Onboarding") }
            static var intermediateStepCount: String { manager.localizedString("onboarding.routineDepth.intermediate.stepCount", table: "Onboarding") }
            static var intermediateTimeEstimate: String { manager.localizedString("onboarding.routineDepth.intermediate.timeEstimate", table: "Onboarding") }
            static var intermediateStepGuidance: String { manager.localizedString("onboarding.routineDepth.intermediate.stepGuidance", table: "Onboarding") }
            static var advanced: String { manager.localizedString("onboarding.routineDepth.advanced", table: "Onboarding") }
            static var advancedSubtitle: String { manager.localizedString("onboarding.routineDepth.advanced.subtitle", table: "Onboarding") }
            static var advancedDescription: String { manager.localizedString("onboarding.routineDepth.advanced.description", table: "Onboarding") }
            static var advancedStepCount: String { manager.localizedString("onboarding.routineDepth.advanced.stepCount", table: "Onboarding") }
            static var advancedTimeEstimate: String { manager.localizedString("onboarding.routineDepth.advanced.timeEstimate", table: "Onboarding") }
            static var advancedStepGuidance: String { manager.localizedString("onboarding.routineDepth.advanced.stepGuidance", table: "Onboarding") }
        }

        // Concern Selection
        struct Concerns {
            static var title: String { manager.localizedString("onboarding.concerns.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.concerns.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.concerns.continue", table: "Onboarding") }
            static var customPlaceholder: String { manager.localizedString("onboarding.concerns.customPlaceholder", table: "Onboarding") }
        }

        // Main Goal
        struct MainGoal {
            static var title: String { manager.localizedString("onboarding.mainGoal.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.mainGoal.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.mainGoal.continue", table: "Onboarding") }
            static var customPlaceholder: String { manager.localizedString("onboarding.mainGoal.customPlaceholder", table: "Onboarding") }
        }

        // Fitzpatrick Skin Tone
        struct Fitzpatrick {
            static var title: String { manager.localizedString("onboarding.fitzpatrick.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.fitzpatrick.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.fitzpatrick.continue", table: "Onboarding") }
        }

        // Age Range
        struct AgeRange {
            static var title: String { manager.localizedString("onboarding.ageRange.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.ageRange.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.ageRange.continue", table: "Onboarding") }
        }

        // Region/Climate
        struct Region {
            static var title: String { manager.localizedString("onboarding.region.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.region.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.region.continue", table: "Onboarding") }
        }

        // Routine Depth
        struct RoutineDepth {
            static var title: String { manager.localizedString("onboarding.routineDepth.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.routineDepth.subtitle", table: "Onboarding") }
            static var `continue`: String { manager.localizedString("onboarding.routineDepth.continue", table: "Onboarding") }
        }

        // Preferences
        struct Preferences {
            static var title: String { manager.localizedString("onboarding.preferences.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.preferences.subtitle", table: "Onboarding") }
            static var continueWithPreferences: String { manager.localizedString("onboarding.preferences.continueWithPreferences", table: "Onboarding") }
            static var skipForNow: String { manager.localizedString("onboarding.preferences.skipForNow", table: "Onboarding") }
            static var continueWithoutAPI: String { manager.localizedString("onboarding.preferences.continueWithoutAPI", table: "Onboarding") }

            // Toggles
            struct FragranceFree {
                static var title: String { manager.localizedString("onboarding.preferences.fragranceFree.title", table: "Onboarding") }
                static var subtitle: String { manager.localizedString("onboarding.preferences.fragranceFree.subtitle", table: "Onboarding") }
            }

            struct SensitiveSkin {
                static var title: String { manager.localizedString("onboarding.preferences.sensitiveSkin.title", table: "Onboarding") }
                static var subtitle: String { manager.localizedString("onboarding.preferences.sensitiveSkin.subtitle", table: "Onboarding") }
            }

            struct Natural {
                static var title: String { manager.localizedString("onboarding.preferences.natural.title", table: "Onboarding") }
                static var subtitle: String { manager.localizedString("onboarding.preferences.natural.subtitle", table: "Onboarding") }
            }

            struct CrueltyFree {
                static var title: String { manager.localizedString("onboarding.preferences.crueltyFree.title", table: "Onboarding") }
                static var subtitle: String { manager.localizedString("onboarding.preferences.crueltyFree.subtitle", table: "Onboarding") }
            }

            struct Vegan {
                static var title: String { manager.localizedString("onboarding.preferences.vegan.title", table: "Onboarding") }
                static var subtitle: String { manager.localizedString("onboarding.preferences.vegan.subtitle", table: "Onboarding") }
            }
        }

        // Cycle Setup
        struct Cycle {
            static var title: String { manager.localizedString("onboarding.cycle.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.cycle.subtitle", table: "Onboarding") }
            static var lastPeriodQuestion: String { manager.localizedString("onboarding.cycle.lastPeriodQuestion", table: "Onboarding") }
            static var averageCycleLength: String { manager.localizedString("onboarding.cycle.averageCycleLength", table: "Onboarding") }
            static func cycleLengthValue(_ days: Int) -> String {
                String(format: manager.localizedString("onboarding.cycle.cycleLengthValue", table: "Onboarding"), days)
            }
            static var cycleLengthRange: String { manager.localizedString("onboarding.cycle.cycleLengthRange", table: "Onboarding") }
            static var periodLength: String { manager.localizedString("onboarding.cycle.periodLength", table: "Onboarding") }
            static func periodLengthValue(_ days: Int) -> String {
                String(format: manager.localizedString("onboarding.cycle.periodLengthValue", table: "Onboarding"), days)
            }
            static var periodLengthRange: String { manager.localizedString("onboarding.cycle.periodLengthRange", table: "Onboarding") }
            static var privacyNote: String { manager.localizedString("onboarding.cycle.privacyNote", table: "Onboarding") }
            static var enableAdaptive: String { manager.localizedString("onboarding.cycle.enableAdaptive", table: "Onboarding") }
            static var skipForNow: String { manager.localizedString("onboarding.cycle.skipForNow", table: "Onboarding") }
            static var selectDate: String { manager.localizedString("onboarding.cycle.selectDate", table: "Onboarding") }

            // Alert
            struct Alert {
                static var title: String { manager.localizedString("onboarding.cycle.alert.title", table: "Onboarding") }
                static var message: String { manager.localizedString("onboarding.cycle.alert.message", table: "Onboarding") }
                static var editFirst: String { manager.localizedString("onboarding.cycle.alert.editFirst", table: "Onboarding") }
                static var `continue`: String { manager.localizedString("onboarding.cycle.alert.continue", table: "Onboarding") }
            }
        }

        // Lifestyle Questions
        struct Lifestyle {
            static var title: String { manager.localizedString("onboarding.lifestyle.title", table: "Onboarding") }
            static var subtitle: String { manager.localizedString("onboarding.lifestyle.subtitle", table: "Onboarding") }
            static var back: String { manager.localizedString("onboarding.lifestyle.back", table: "Onboarding") }

            // Sections
            struct Section {
                static var lifestyle: String { manager.localizedString("onboarding.lifestyle.section.lifestyle", table: "Onboarding") }
                static var skinHabits: String { manager.localizedString("onboarding.lifestyle.section.skinHabits", table: "Onboarding") }
                static var productPreferences: String { manager.localizedString("onboarding.lifestyle.section.productPreferences", table: "Onboarding") }
                static var sensitivity: String { manager.localizedString("onboarding.lifestyle.section.sensitivity", table: "Onboarding") }
            }

            // Questions
            struct Question {
                static var sleepQuality: String { manager.localizedString("onboarding.lifestyle.question.sleepQuality", table: "Onboarding") }
                static var outdoorHours: String { manager.localizedString("onboarding.lifestyle.question.outdoorHours", table: "Onboarding") }
                static var smoke: String { manager.localizedString("onboarding.lifestyle.question.smoke", table: "Onboarding") }
                static var alcohol: String { manager.localizedString("onboarding.lifestyle.question.alcohol", table: "Onboarding") }
                static var exercise: String { manager.localizedString("onboarding.lifestyle.question.exercise", table: "Onboarding") }
                static var routineDepth: String { manager.localizedString("onboarding.lifestyle.question.routineDepth", table: "Onboarding") }
                static var fragranceFree: String { manager.localizedString("onboarding.lifestyle.question.fragranceFree", table: "Onboarding") }
                static var naturalPreference: String { manager.localizedString("onboarding.lifestyle.question.naturalPreference", table: "Onboarding") }
                static var sensitiveSkin: String { manager.localizedString("onboarding.lifestyle.question.sensitiveSkin", table: "Onboarding") }
                static var sunResponse: String { manager.localizedString("onboarding.lifestyle.question.sunResponse", table: "Onboarding") }
            }

            // Sleep Quality Options
            struct SleepQuality {
                static var poor: String { manager.localizedString("onboarding.lifestyle.sleepQuality.poor", table: "Onboarding") }
                static var average: String { manager.localizedString("onboarding.lifestyle.sleepQuality.average", table: "Onboarding") }
                static var good: String { manager.localizedString("onboarding.lifestyle.sleepQuality.good", table: "Onboarding") }
            }

            // Exercise Frequency Options
            struct ExerciseFreq {
                static var none: String { manager.localizedString("onboarding.lifestyle.exerciseFreq.none", table: "Onboarding") }
                static var oneToTwo: String { manager.localizedString("onboarding.lifestyle.exerciseFreq.oneToTwo", table: "Onboarding") }
                static var threeToFour: String { manager.localizedString("onboarding.lifestyle.exerciseFreq.threeToFour", table: "Onboarding") }
                static var fivePlus: String { manager.localizedString("onboarding.lifestyle.exerciseFreq.fivePlus", table: "Onboarding") }
            }

            // Routine Depth Options
            struct RoutineDepthOption {
                static var minimal: String { manager.localizedString("onboarding.lifestyle.routineDepth.minimal", table: "Onboarding") }
                static var standard: String { manager.localizedString("onboarding.lifestyle.routineDepth.standard", table: "Onboarding") }
                static var detailed: String { manager.localizedString("onboarding.lifestyle.routineDepth.detailed", table: "Onboarding") }
            }

            // Sun Response Options
            struct SunResponse {
                static var rarely: String { manager.localizedString("onboarding.lifestyle.sunResponse.rarely", table: "Onboarding") }
                static var sometimes: String { manager.localizedString("onboarding.lifestyle.sunResponse.sometimes", table: "Onboarding") }
                static var easily: String { manager.localizedString("onboarding.lifestyle.sunResponse.easily", table: "Onboarding") }
            }
        }

        // Routine Loading
        struct Loading {
            static var thinking: String { manager.localizedString("onboarding.loading.thinking", table: "Onboarding") }
            static var analyzingSkinType: String { manager.localizedString("onboarding.loading.analyzingSkinType", table: "Onboarding") }
            static var processingConcerns: String { manager.localizedString("onboarding.loading.processingConcerns", table: "Onboarding") }
            static var evaluatingGoal: String { manager.localizedString("onboarding.loading.evaluatingGoal", table: "Onboarding") }
            static var assessingEnvironment: String { manager.localizedString("onboarding.loading.assessingEnvironment", table: "Onboarding") }
            static var preparingResults: String { manager.localizedString("onboarding.loading.preparingResults", table: "Onboarding") }
            static var creatingSlots: String { manager.localizedString("onboarding.loading.creatingSlots", table: "Onboarding") }
            static var optimizing: String { manager.localizedString("onboarding.loading.optimizing", table: "Onboarding") }
            static var finalizing: String { manager.localizedString("onboarding.loading.finalizing", table: "Onboarding") }
        }

        // Common Actions
        struct Common {
            static var `continue`: String { manager.localizedString("onboarding.common.continue", table: "Onboarding") }
            static var next: String { manager.localizedString("onboarding.common.next", table: "Onboarding") }
            static var skip: String { manager.localizedString("onboarding.common.skip", table: "Onboarding") }
            static var back: String { manager.localizedString("onboarding.common.back", table: "Onboarding") }
            static var getStarted: String { manager.localizedString("onboarding.common.getStarted", table: "Onboarding") }
        }

        // Flow Progress
        struct Flow {
            static func stepProgress(current: Int, total: Int) -> String {
                String(format: manager.localizedString("onboarding.flow.stepProgress", table: "Onboarding"), current, total)
            }
            static var stepSkinType: String { manager.localizedString("onboarding.flow.stepSkinType", table: "Onboarding") }
            static var stepConcerns: String { manager.localizedString("onboarding.flow.stepConcerns", table: "Onboarding") }
            static var stepMainGoal: String { manager.localizedString("onboarding.flow.stepMainGoal", table: "Onboarding") }
            static var stepSkinTone: String { manager.localizedString("onboarding.flow.stepSkinTone", table: "Onboarding") }
            static var stepAgeRange: String { manager.localizedString("onboarding.flow.stepAgeRange", table: "Onboarding") }
            static var stepRegion: String { manager.localizedString("onboarding.flow.stepRegion", table: "Onboarding") }
            static var stepRoutineLevel: String { manager.localizedString("onboarding.flow.stepRoutineLevel", table: "Onboarding") }
            static var stepCycleSetup: String { manager.localizedString("onboarding.flow.stepCycleSetup", table: "Onboarding") }
            static var stepPreferences: String { manager.localizedString("onboarding.flow.stepPreferences", table: "Onboarding") }
            static var stepAnalyzing: String { manager.localizedString("onboarding.flow.stepAnalyzing", table: "Onboarding") }
            static var stepResults: String { manager.localizedString("onboarding.flow.stepResults", table: "Onboarding") }
        }
    }

    // MARK: - Myself

    struct Myself {
        // General
        static var title: String { manager.localizedString("myself.title", table: "Myself") }
        static var profile: String { manager.localizedString("myself.profile", table: "Myself") }
        static var edit: String { manager.localizedString("myself.edit", table: "Myself") }
        static var createNewRoutine: String { manager.localizedString("myself.createNewRoutine", table: "Myself") }

        // Greetings
        struct Greeting {
            static func morning(_ name: String) -> String {
                String(format: manager.localizedString("myself.greeting.morning", table: "Myself"), name)
            }
            static func afternoon(_ name: String) -> String {
                String(format: manager.localizedString("myself.greeting.afternoon", table: "Myself"), name)
            }
            static func evening(_ name: String) -> String {
                String(format: manager.localizedString("myself.greeting.evening", table: "Myself"), name)
            }
            static func night(_ name: String) -> String {
                String(format: manager.localizedString("myself.greeting.night", table: "Myself"), name)
            }
        }

        // Tab Titles & Descriptions
        struct Tabs {
            static var timeline: String { manager.localizedString("myself.tabs.timeline", table: "Myself") }
            static var journal: String { manager.localizedString("myself.tabs.journal", table: "Myself") }
            static var insights: String { manager.localizedString("myself.tabs.insights", table: "Myself") }

            static var journalDescription: String { manager.localizedString("myself.tabs.journal.description", table: "Myself") }
            static var insightsDescription: String { manager.localizedString("myself.tabs.insights.description", table: "Myself") }
        }

        // Profile Stats
        struct Stats {
            static var skinType: String { manager.localizedString("myself.stats.skinType", table: "Myself") }
            static var ageRange: String { manager.localizedString("myself.stats.ageRange", table: "Myself") }
            static var skinTone: String { manager.localizedString("myself.stats.skinTone", table: "Myself") }
            static var climate: String { manager.localizedString("myself.stats.climate", table: "Myself") }
        }

        // Insights & Tips
        struct Insights {
            static var title: String { manager.localizedString("myself.insights.title", table: "Myself") }

            struct CombinationLargePores {
                static var title: String { manager.localizedString("myself.insights.combinationLargePores.title", table: "Myself") }
                static var body: String { manager.localizedString("myself.insights.combinationLargePores.body", table: "Myself") }
            }

            struct CompleteProfile {
                static var title: String { manager.localizedString("myself.insights.completeProfile.title", table: "Myself") }
                static var body: String { manager.localizedString("myself.insights.completeProfile.body", table: "Myself") }
            }

            struct ClimateTip {
                static var title: String { manager.localizedString("myself.insights.climateTip.title", table: "Myself") }
                static func body(climate: String, spf: Int) -> String {
                    String(format: manager.localizedString("myself.insights.climateTip.body", table: "Myself"), climate, spf)
                }
            }

            static var yourPreferencesTitle: String { manager.localizedString("myself.insights.yourPreferences.title", table: "Myself") }

            static func morningConsistent(percentage: Int) -> String {
                String(format: manager.localizedString("myself.insights.morningConsistent", table: "Myself"), percentage)
            }

            static func eveningShines(percentage: Int) -> String {
                String(format: manager.localizedString("myself.insights.eveningShines", table: "Myself"), percentage)
            }

            static func equallyConsistent(percentage: Int) -> String {
                String(format: manager.localizedString("myself.insights.equallyConsistent", table: "Myself"), percentage)
            }

            static var buildConsistency: String { manager.localizedString("myself.insights.buildConsistency", table: "Myself") }
        }

        // Preferences
        struct Preferences {
            static var fragranceFree: String { manager.localizedString("myself.preferences.fragranceFree", table: "Myself") }
            static var sensitiveSkin: String { manager.localizedString("myself.preferences.sensitiveSkin", table: "Myself") }
            static var natural: String { manager.localizedString("myself.preferences.natural", table: "Myself") }
            static var crueltyFree: String { manager.localizedString("myself.preferences.crueltyFree", table: "Myself") }
            static var vegan: String { manager.localizedString("myself.preferences.vegan", table: "Myself") }
        }

        // Completion Stats
        struct Completion {
            static func percentage(_ percent: Int) -> String {
                String(format: manager.localizedString("myself.completion.percentage", table: "Myself"), percent)
            }
            static func lastDays(_ days: Int) -> String {
                String(format: manager.localizedString("myself.completion.lastDays", table: "Myself"), days)
            }
            static func countOfTotal(count: Int, total: Int) -> String {
                String(format: manager.localizedString("myself.completion.countOfTotal", table: "Myself"), count, total)
            }
            static func dayNumber(_ day: Int) -> String {
                String(format: manager.localizedString("myself.completion.dayNumber", table: "Myself"), day)
            }
            static func impactChange(sign: String, value: Int) -> String {
                String(format: manager.localizedString("myself.completion.impactChange", table: "Myself"), sign, value)
            }
        }

        // Premium Insights
        struct Premium {
            static var aiPowered: String { manager.localizedString("myself.premium.aiPowered", table: "Myself") }
            static var getInsights: String { manager.localizedString("myself.premium.getInsights", table: "Myself") }
            static var onRoutines: String { manager.localizedString("myself.premium.onRoutines", table: "Myself") }
            static var tryFree: String { manager.localizedString("myself.premium.tryFree", table: "Myself") }
            static var smartAnalysis: String { manager.localizedString("myself.premium.smartAnalysis", table: "Myself") }
            static var productTrends: String { manager.localizedString("myself.premium.productTrends", table: "Myself") }
            static var moodCorrelation: String { manager.localizedString("myself.premium.moodCorrelation", table: "Myself") }
        }

        // Most Used Products
        struct MostUsedProducts {
            static var title: String { manager.localizedString("myself.products.title", table: "Myself") }
            static func rank(_ rank: Int) -> String {
                String(format: manager.localizedString("myself.products.rank", table: "Myself"), rank)
            }
            static var empty: String { manager.localizedString("myself.products.empty", table: "Myself") }
            static var emptySubtitle: String { manager.localizedString("myself.products.emptySubtitle", table: "Myself") }
            static func usedCount(_ count: Int) -> String {
                String(format: manager.localizedString(count == 1 ? "myself.products.usedCount" : "myself.products.usedCountPlural", table: "Myself"), count)
            }
        }

        // Skin Feel Trends
        struct SkinFeel {
            static var title: String { manager.localizedString("myself.skinFeel.title", table: "Myself") }
            static var empty: String { manager.localizedString("myself.skinFeel.empty", table: "Myself") }
            static var emptySubtitle: String { manager.localizedString("myself.skinFeel.emptySubtitle", table: "Myself") }
        }

        // Date Picker
        struct DatePicker {
            static var title: String { manager.localizedString("myself.datePicker.title", table: "Myself") }
            static var subtitle: String { manager.localizedString("myself.datePicker.subtitle", table: "Myself") }
            static var today: String { manager.localizedString("myself.datePicker.today", table: "Myself") }
            static var selectDate: String { manager.localizedString("myself.datePicker.selectDate", table: "Myself") }
        }

        // Edit Profile
        struct EditProfile {
            static var title: String { manager.localizedString("myself.editProfile.title", table: "Myself") }
            static var save: String { manager.localizedString("myself.editProfile.save", table: "Myself") }
            static var cancel: String { manager.localizedString("myself.editProfile.cancel", table: "Myself") }

            // Sections
            static var skin: String { manager.localizedString("myself.editProfile.skin", table: "Myself") }
            static var skinType: String { manager.localizedString("myself.editProfile.skinType", table: "Myself") }
            static var fitzpatrickTone: String { manager.localizedString("myself.editProfile.fitzpatrickTone", table: "Myself") }
            static var concerns: String { manager.localizedString("myself.editProfile.concerns", table: "Myself") }
            static var goalAndPreferences: String { manager.localizedString("myself.editProfile.goalAndPreferences", table: "Myself") }
            static var mainGoal: String { manager.localizedString("myself.editProfile.mainGoal", table: "Myself") }
            static var preferences: String { manager.localizedString("myself.editProfile.preferences", table: "Myself") }
            static var demographics: String { manager.localizedString("myself.editProfile.demographics", table: "Myself") }
            static var ageRange: String { manager.localizedString("myself.editProfile.ageRange", table: "Myself") }
            static var regionClimate: String { manager.localizedString("myself.editProfile.regionClimate", table: "Myself") }
            static var menstruationCycle: String { manager.localizedString("myself.editProfile.menstruationCycle", table: "Myself") }
            static var lastPeriodStart: String { manager.localizedString("myself.editProfile.lastPeriodStart", table: "Myself") }
            static func cycleLength(_ days: Int) -> String {
                String(format: manager.localizedString("myself.editProfile.cycleLength", table: "Myself"), days)
            }
            static func periodLength(_ days: Int) -> String {
                String(format: manager.localizedString("myself.editProfile.periodLength", table: "Myself"), days)
            }
            static func currentPhase(_ phase: String) -> String {
                String(format: manager.localizedString("myself.editProfile.currentPhase", table: "Myself"), phase)
            }
            static func dayOfCycle(day: Int, total: Int) -> String {
                String(format: manager.localizedString("myself.editProfile.dayOfCycle", table: "Myself"), day, total)
            }

            // Preferences Editor
            struct Preferences {
                static var fragranceFree: String { manager.localizedString("myself.editProfile.preferences.fragranceFree", table: "Myself") }
                static var sensitiveSkin: String { manager.localizedString("myself.editProfile.preferences.sensitiveSkin", table: "Myself") }
                static var natural: String { manager.localizedString("myself.editProfile.preferences.natural", table: "Myself") }
                static var crueltyFree: String { manager.localizedString("myself.editProfile.preferences.crueltyFree", table: "Myself") }
                static var vegan: String { manager.localizedString("myself.editProfile.preferences.vegan", table: "Myself") }
            }
        }

        // Cycle Settings
        struct Cycle {
            static var title: String { manager.localizedString("myself.cycle.title", table: "Myself") }
            static var subtitle: String { manager.localizedString("myself.cycle.subtitle", table: "Myself") }
            static var lastPeriodStart: String { manager.localizedString("myself.cycle.lastPeriodStart", table: "Myself") }
            static var averageCycleLength: String { manager.localizedString("myself.cycle.averageCycleLength", table: "Myself") }
            static func cycleLengthValue(_ days: Int) -> String {
                String(format: manager.localizedString("myself.cycle.cycleLengthValue", table: "Myself"), days)
            }
            static var cycleLengthRange: String { manager.localizedString("myself.cycle.cycleLengthRange", table: "Myself") }
            static var periodLength: String { manager.localizedString("myself.cycle.periodLength", table: "Myself") }
            static func periodLengthValue(_ days: Int) -> String {
                String(format: manager.localizedString("myself.cycle.periodLengthValue", table: "Myself"), days)
            }
            static var periodLengthRange: String { manager.localizedString("myself.cycle.periodLengthRange", table: "Myself") }
            static var privacyInfo: String { manager.localizedString("myself.cycle.privacyInfo", table: "Myself") }
            static var saveSettings: String { manager.localizedString("myself.cycle.saveSettings", table: "Myself") }
            static var cancel: String { manager.localizedString("myself.cycle.cancel", table: "Myself") }
            static var selectDate: String { manager.localizedString("myself.cycle.selectDate", table: "Myself") }
        }
    }

    // MARK: - Products

    struct Products {
        // General
        static var title: String { manager.localizedString("products.title", table: "Products") }
        static var subtitle: String { manager.localizedString("products.subtitle", table: "Products") }

        // Empty State
        struct Empty {
            static var title: String { manager.localizedString("products.empty.title", table: "Products") }
            static var subtitle: String { manager.localizedString("products.empty.subtitle", table: "Products") }
        }

        // Add Product
        struct Add {
            static var title: String { manager.localizedString("products.add.title", table: "Products") }
            static var subtitle: String { manager.localizedString("products.add.subtitle", table: "Products") }
            static var scanOption: String { manager.localizedString("products.add.scanOption", table: "Products") }
            static var scanDescription: String { manager.localizedString("products.add.scanDescription", table: "Products") }
            static var manualOption: String { manager.localizedString("products.add.manualOption", table: "Products") }
            static var manualDescription: String { manager.localizedString("products.add.manualDescription", table: "Products") }
            static var getStarted: String { manager.localizedString("products.add.getStarted", table: "Products") }
        }

        // Product Form
        struct Form {
            static var basicInfo: String { manager.localizedString("products.form.basicInfo", table: "Products") }
            static var productName: String { manager.localizedString("products.form.productName", table: "Products") }
            static var productNamePlaceholder: String { manager.localizedString("products.form.productNamePlaceholder", table: "Products") }
            static var brand: String { manager.localizedString("products.form.brand", table: "Products") }
            static var brandPlaceholder: String { manager.localizedString("products.form.brandPlaceholder", table: "Products") }
            static var size: String { manager.localizedString("products.form.size", table: "Products") }
            static var sizePlaceholder: String { manager.localizedString("products.form.sizePlaceholder", table: "Products") }
            static var productCategory: String { manager.localizedString("products.form.productCategory", table: "Products") }
            static var ingredients: String { manager.localizedString("products.form.ingredients", table: "Products") }
            static var addIngredient: String { manager.localizedString("products.form.addIngredient", table: "Products") }
            static var productClaims: String { manager.localizedString("products.form.productClaims", table: "Products") }
            static var description: String { manager.localizedString("products.form.description", table: "Products") }
            static var productDescription: String { manager.localizedString("products.form.productDescription", table: "Products") }
            static var descriptionPlaceholder: String { manager.localizedString("products.form.descriptionPlaceholder", table: "Products") }
            static func characterCount(_ count: Int) -> String {
                String(format: manager.localizedString("products.form.characterCount", table: "Products"), count)
            }
            static var unitMilliliters: String { manager.localizedString("products.form.unitMilliliters", table: "Products") }
            static var unitOunces: String { manager.localizedString("products.form.unitOunces", table: "Products") }
        }

        // Product Type
        struct ProductType {
            static var title: String { manager.localizedString("products.type.title", table: "Products") }
            static var tapToChange: String { manager.localizedString("products.type.tapToChange", table: "Products") }
            static var selectType: String { manager.localizedString("products.type.selectType", table: "Products") }
            static var searchPlaceholder: String { manager.localizedString("products.type.searchPlaceholder", table: "Products") }
        }

        // Product Scanning
        struct Scan {
            static var title: String { manager.localizedString("products.scan.title", table: "Products") }
            static var instruction: String { manager.localizedString("products.scan.instruction", table: "Products") }
            static var photoCapture: String { manager.localizedString("products.scan.photoCapture", table: "Products") }
            static var processing: String { manager.localizedString("products.scan.processing", table: "Products") }
            static func extracted(_ text: String) -> String {
                String(format: manager.localizedString("products.scan.extracted", table: "Products"), text)
            }
            static var success: String { manager.localizedString("products.scan.success", table: "Products") }
            static func byBrand(_ brand: String) -> String {
                String(format: manager.localizedString("products.scan.byBrand", table: "Products"), brand)
            }
            static var retakePhoto: String { manager.localizedString("products.scan.retakePhoto", table: "Products") }
            static var done: String { manager.localizedString("products.scan.done", table: "Products") }

            // Scan Steps
            struct Step {
                static var extractedText: String { manager.localizedString("products.scan.step.extractedText", table: "Products") }
                static var reviewText: String { manager.localizedString("products.scan.step.reviewText", table: "Products") }
                static var productInfo: String { manager.localizedString("products.scan.step.productInfo", table: "Products") }
                static var normalizedProduct: String { manager.localizedString("products.scan.step.normalizedProduct", table: "Products") }
                static var brand: String { manager.localizedString("products.scan.step.brand", table: "Products") }
                static var name: String { manager.localizedString("products.scan.step.name", table: "Products") }
                static var type: String { manager.localizedString("products.scan.step.type", table: "Products") }
                static var confidence: String { manager.localizedString("products.scan.step.confidence", table: "Products") }
                static func normalizationError(_ error: String) -> String {
                    String(format: manager.localizedString("products.scan.step.normalizationError", table: "Products"), error)
                }
                static var normalizeWithGPT: String { manager.localizedString("products.scan.step.normalizeWithGPT", table: "Products") }
                static var normalizing: String { manager.localizedString("products.scan.step.normalizing", table: "Products") }
                static var continueNormalized: String { manager.localizedString("products.scan.step.continueNormalized", table: "Products") }
                static var continueRaw: String { manager.localizedString("products.scan.step.continueRaw", table: "Products") }
                static var cancel: String { manager.localizedString("products.scan.step.cancel", table: "Products") }
                static var unknown: String { manager.localizedString("products.scan.step.unknown", table: "Products") }
                static var step1: String { manager.localizedString("products.scan.step1", table: "Products") }
                static var step2: String { manager.localizedString("products.scan.step2", table: "Products") }
                static var step3: String { manager.localizedString("products.scan.step3", table: "Products") }
                static var step3Database: String { manager.localizedString("products.scan.step3Database", table: "Products") }
            }

            // Scan Status
            struct Status {
                static var ocrFailed: String { manager.localizedString("products.scan.status.ocrFailed", table: "Products") }
                static var normalizationFailed: String { manager.localizedString("products.scan.status.normalizationFailed", table: "Products") }
                static var noData: String { manager.localizedString("products.scan.status.noData", table: "Products") }
                static var lookupCompleted: String { manager.localizedString("products.scan.status.lookupCompleted", table: "Products") }
                static var productAdded: String { manager.localizedString("products.scan.status.productAdded", table: "Products") }
            }
        }

        // Product Detail
        struct Detail {
            static var description: String { manager.localizedString("products.detail.description", table: "Products") }
            static var editProduct: String { manager.localizedString("products.detail.editProduct", table: "Products") }
            static var updateInfo: String { manager.localizedString("products.detail.updateInfo", table: "Products") }
            static var close: String { manager.localizedString("products.detail.close", table: "Products") }
            static var ingredients: String { manager.localizedString("products.detail.ingredients", table: "Products") }
            static var productType: String { manager.localizedString("products.detail.productType", table: "Products") }
            static var size: String { manager.localizedString("products.detail.size", table: "Products") }
            static var deleteProduct: String { manager.localizedString("products.detail.deleteProduct", table: "Products") }
            static var deleteConfirmTitle: String { manager.localizedString("products.detail.deleteConfirmTitle", table: "Products") }
            static func deleteConfirmMessage(_ productName: String) -> String {
                String(format: manager.localizedString("products.detail.deleteConfirmMessage", table: "Products"), productName)
            }
            static func ingredientBullet(_ ingredient: String) -> String {
                String(format: manager.localizedString("products.detail.ingredientBullet", table: "Products"), ingredient)
            }
            static func ingredientNumber(_ number: Int) -> String {
                String(format: manager.localizedString("products.detail.ingredientNumber", table: "Products"), number)
            }
            static func sizeBullet(_ size: String) -> String {
                String(format: manager.localizedString("products.detail.sizeBullet", table: "Products"), size)
            }
            static func keyIngredients(_ ingredients: String) -> String {
                String(format: manager.localizedString("products.detail.keyIngredients", table: "Products"), ingredients)
            }
        }

        // Product Summary
        struct Summary {
            static var title: String { manager.localizedString("products.summary.title", table: "Products") }
            static var subtitle: String { manager.localizedString("products.summary.subtitle", table: "Products") }
        }

        // Product Confirmation
        struct Confirm {
            static var title: String { manager.localizedString("products.confirm.title", table: "Products") }
            static var noneOfThese: String { manager.localizedString("products.confirm.noneOfThese", table: "Products") }
        }

        // Actions
        struct Action {
            static var cancel: String { manager.localizedString("products.action.cancel", table: "Products") }
            static var save: String { manager.localizedString("products.action.save", table: "Products") }
            static var edit: String { manager.localizedString("products.action.edit", table: "Products") }
            static var delete: String { manager.localizedString("products.action.delete", table: "Products") }
            static var adding: String { manager.localizedString("products.action.adding", table: "Products") }
            static var confirmProduct: String { manager.localizedString("products.action.confirmProduct", table: "Products") }
        }

        // Product Slot Edit
        struct Slot {
            struct Edit {
                static var title: String { manager.localizedString("products.slot.edit.title", table: "Products") }
                static func subtitle(_ slotName: String) -> String {
                    String(format: manager.localizedString("products.slot.edit.subtitle", table: "Products"), slotName)
                }
                static var navTitle: String { manager.localizedString("products.slot.edit.navTitle", table: "Products") }
            }
        }

        // Product Claims
        struct Claim {
            static var fragranceFree: String { manager.localizedString("products.claim.fragranceFree", table: "Products") }
            static var sensitiveSafe: String { manager.localizedString("products.claim.sensitiveSafe", table: "Products") }
            static var vegan: String { manager.localizedString("products.claim.vegan", table: "Products") }
            static var crueltyFree: String { manager.localizedString("products.claim.crueltyFree", table: "Products") }
            static var dermatologistTested: String { manager.localizedString("products.claim.dermatologistTested", table: "Products") }
            static var nonComedogenic: String { manager.localizedString("products.claim.nonComedogenic", table: "Products") }
            static var parabenFree: String { manager.localizedString("products.claim.parabenFree", table: "Products") }
            static var sulfateFree: String { manager.localizedString("products.claim.sulfateFree", table: "Products") }
            static var oilFree: String { manager.localizedString("products.claim.oilFree", table: "Products") }

            /// Get localized display name for a claim
            static func displayName(for claim: String) -> String {
                switch claim.lowercased() {
                case "fragrancefree": return fragranceFree
                case "sensitivesafe": return sensitiveSafe
                case "vegan": return vegan
                case "crueltyfree": return crueltyFree
                case "dermatologisttested": return dermatologistTested
                case "noncomedogenic": return nonComedogenic
                case "parabenfree": return parabenFree
                case "sulfatefree": return sulfateFree
                case "oilfree": return oilFree
                default: return claim.capitalized
                }
            }
        }

        // Product Type Names
        struct TypeName {
            static var cleanser: String { manager.localizedString("products.type.cleanser", table: "Products") }
            static var moisturizer: String { manager.localizedString("products.type.moisturizer", table: "Products") }
            static var sunscreen: String { manager.localizedString("products.type.sunscreen", table: "Products") }
            static var toner: String { manager.localizedString("products.type.toner", table: "Products") }
            static var faceSerum: String { manager.localizedString("products.type.faceSerum", table: "Products") }
            static var essence: String { manager.localizedString("products.type.essence", table: "Products") }
            static var exfoliator: String { manager.localizedString("products.type.exfoliator", table: "Products") }
            static var faceMask: String { manager.localizedString("products.type.faceMask", table: "Products") }
            static var facialOil: String { manager.localizedString("products.type.facialOil", table: "Products") }
            static var facialMist: String { manager.localizedString("products.type.facialMist", table: "Products") }
            static var eyeCream: String { manager.localizedString("products.type.eyeCream", table: "Products") }
            static var spotTreatment: String { manager.localizedString("products.type.spotTreatment", table: "Products") }
            static var retinol: String { manager.localizedString("products.type.retinol", table: "Products") }
            static var vitaminC: String { manager.localizedString("products.type.vitaminC", table: "Products") }
            static var niacinamide: String { manager.localizedString("products.type.niacinamide", table: "Products") }
            static var faceSunscreen: String { manager.localizedString("products.type.faceSunscreen", table: "Products") }
            static var bodySunscreen: String { manager.localizedString("products.type.bodySunscreen", table: "Products") }
            static var lipBalm: String { manager.localizedString("products.type.lipBalm", table: "Products") }
            static var shaveCream: String { manager.localizedString("products.type.shaveCream", table: "Products") }
            static var aftershave: String { manager.localizedString("products.type.aftershave", table: "Products") }
            static var shaveGel: String { manager.localizedString("products.type.shaveGel", table: "Products") }
            static var bodyLotion: String { manager.localizedString("products.type.bodyLotion", table: "Products") }
            static var bodyWash: String { manager.localizedString("products.type.bodyWash", table: "Products") }
            static var handCream: String { manager.localizedString("products.type.handCream", table: "Products") }
            static var shampoo: String { manager.localizedString("products.type.shampoo", table: "Products") }
            static var conditioner: String { manager.localizedString("products.type.conditioner", table: "Products") }
            static var hairOil: String { manager.localizedString("products.type.hairOil", table: "Products") }
            static var hairMask: String { manager.localizedString("products.type.hairMask", table: "Products") }
            static var chemicalPeel: String { manager.localizedString("products.type.chemicalPeel", table: "Products") }
            static var micellarWater: String { manager.localizedString("products.type.micellarWater", table: "Products") }
            static var makeupRemover: String { manager.localizedString("products.type.makeupRemover", table: "Products") }
            static var faceWash: String { manager.localizedString("products.type.faceWash", table: "Products") }
            static var cleansingOil: String { manager.localizedString("products.type.cleansingOil", table: "Products") }
            static var cleansingBalm: String { manager.localizedString("products.type.cleansingBalm", table: "Products") }
        }

        // Product Categories
        struct Category {
            static var cleansing: String { manager.localizedString("products.category.cleansing", table: "Products") }
            static var toning: String { manager.localizedString("products.category.toning", table: "Products") }
            static var treatment: String { manager.localizedString("products.category.treatment", table: "Products") }
            static var moisturizing: String { manager.localizedString("products.category.moisturizing", table: "Products") }
            static var sunProtection: String { manager.localizedString("products.category.sunProtection", table: "Products") }
            static var masks: String { manager.localizedString("products.category.masks", table: "Products") }
            static var shaving: String { manager.localizedString("products.category.shaving", table: "Products") }
            static var bodyCare: String { manager.localizedString("products.category.bodyCare", table: "Products") }
            static var hairCare: String { manager.localizedString("products.category.hairCare", table: "Products") }
        }
    }

    // MARK: - SkinJournal

    struct SkinJournal {
        // Daily Mood Tracking Card
        struct DailyLog {
            static var title: String { manager.localizedString("skinJournal.dailyLog.title", table: "SkinJournal") }
            static var capture: String { manager.localizedString("skinJournal.dailyLog.capture", table: "SkinJournal") }
            static var completed: String { manager.localizedString("skinJournal.dailyLog.completed", table: "SkinJournal") }
        }

        // Skin Journey Card
        struct Journey {
            static var title: String { manager.localizedString("skinJournal.journey.title", table: "SkinJournal") }
            static var titleBadge: String { manager.localizedString("skinJournal.journey.titleBadge", table: "SkinJournal") }
            static var tagline: String { manager.localizedString("skinJournal.journey.tagline", table: "SkinJournal") }
            static var trackProgress: String { manager.localizedString("skinJournal.journey.trackProgress", table: "SkinJournal") }
            static var trackProgressWithSelfies: String { manager.localizedString("skinJournal.journey.trackProgressWithSelfies", table: "SkinJournal") }
            static var moreOnJournal: String { manager.localizedString("skinJournal.journey.moreOnJournal", table: "SkinJournal") }
            static var mood: String { manager.localizedString("skinJournal.journey.mood", table: "SkinJournal") }
            static var viewJournal: String { manager.localizedString("skinJournal.journey.viewJournal", table: "SkinJournal") }
            static var startTracking: String { manager.localizedString("skinJournal.journey.startTracking", table: "SkinJournal") }
            static var takeProgressSelfies: String { manager.localizedString("skinJournal.journey.takeProgressSelfies", table: "SkinJournal") }
            static var addFirstEntry: String { manager.localizedString("skinJournal.journey.addFirstEntry", table: "SkinJournal") }
            static func entriesCount(_ count: Int) -> String {
                let suffix = count == 1 ? manager.localizedString("skinJournal.journey.entrySuffix", table: "SkinJournal") : manager.localizedString("skinJournal.journey.entriesSuffix", table: "SkinJournal")
                return String(format: manager.localizedString("skinJournal.journey.entriesCount", table: "SkinJournal"), count, suffix)
            }
            static var addMoreEntries: String { manager.localizedString("skinJournal.journey.addMoreEntries", table: "SkinJournal") }
            static var addAtLeastTwoPhotos: String { manager.localizedString("skinJournal.journey.addAtLeastTwoPhotos", table: "SkinJournal") }
        }

        // Premium Features
        struct Premium {
            static var title: String { manager.localizedString("skinJournal.premium.title", table: "SkinJournal") }
            static var description: String { manager.localizedString("skinJournal.premium.description", table: "SkinJournal") }
            static var upgrade: String { manager.localizedString("skinJournal.premium.upgrade", table: "SkinJournal") }
            static var tryFree: String { manager.localizedString("skinJournal.premium.tryFree", table: "SkinJournal") }
        }

        // Timeline Features
        struct Timeline {
            static var title: String { manager.localizedString("skinJournal.timeline.title", table: "SkinJournal") }
            static var compare: String { manager.localizedString("skinJournal.timeline.compare", table: "SkinJournal") }
            static var startJourney: String { manager.localizedString("skinJournal.timeline.startJourney", table: "SkinJournal") }
            static var entries: String { manager.localizedString("skinJournal.timeline.entries", table: "SkinJournal") }
            static var dayStreak: String { manager.localizedString("skinJournal.timeline.dayStreak", table: "SkinJournal") }
            static var searchNotes: String { manager.localizedString("skinJournal.timeline.searchNotes", table: "SkinJournal") }
            static var before: String { manager.localizedString("skinJournal.timeline.before", table: "SkinJournal") }
            static var after: String { manager.localizedString("skinJournal.timeline.after", table: "SkinJournal") }
            static var selectEntry: String { manager.localizedString("skinJournal.timeline.selectEntry", table: "SkinJournal") }
        }

        // Comparison Demo
        struct Demo {
            static var visualTimeline: String { manager.localizedString("skinJournal.demo.visualTimeline", table: "SkinJournal") }
            static var moodCorrelation: String { manager.localizedString("skinJournal.demo.moodCorrelation", table: "SkinJournal") }
        }

        // Add Entry View
        struct AddEntry {
            static var title: String { manager.localizedString("skinJournal.addEntry.title", table: "SkinJournal") }
            static var back: String { manager.localizedString("skinJournal.addEntry.back", table: "SkinJournal") }
            static var save: String { manager.localizedString("skinJournal.addEntry.save", table: "SkinJournal") }
            static var yourPhoto: String { manager.localizedString("skinJournal.addEntry.yourPhoto", table: "SkinJournal") }
            static var howAreYouFeeling: String { manager.localizedString("skinJournal.addEntry.howAreYouFeeling", table: "SkinJournal") }
            static var selectMood: String { manager.localizedString("skinJournal.addEntry.selectMood", table: "SkinJournal") }
            static var skinFeel: String { manager.localizedString("skinJournal.addEntry.skinFeel", table: "SkinJournal") }
            static var describeSkinFeel: String { manager.localizedString("skinJournal.addEntry.describeSkinFeel", table: "SkinJournal") }
            static var analyzingPhoto: String { manager.localizedString("skinJournal.addEntry.analyzingPhoto", table: "SkinJournal") }
            static var takingAMoment: String { manager.localizedString("skinJournal.addEntry.takingAMoment", table: "SkinJournal") }
            static var noPhotoCaptured: String { manager.localizedString("skinJournal.addEntry.noPhotoCaptured", table: "SkinJournal") }
            static func tagPrefix(_ count: Int) -> String {
                String(format: manager.localizedString("skinJournal.addEntry.tagPrefix", table: "SkinJournal"), count)
            }
        }

        // Comparison View
        struct Comparison {
            static var title: String { manager.localizedString("skinJournal.comparison.title", table: "SkinJournal") }
            static var close: String { manager.localizedString("skinJournal.comparison.close", table: "SkinJournal") }
            static var view: String { manager.localizedString("skinJournal.comparison.view", table: "SkinJournal") }
            static func daysApart(days: Int) -> String {
                let suffix = abs(days) == 1 ? manager.localizedString("skinJournal.comparison.daySuffix", table: "SkinJournal") : manager.localizedString("skinJournal.comparison.daysSuffix", table: "SkinJournal")
                return String(format: manager.localizedString("skinJournal.comparison.daysApart", table: "SkinJournal"), abs(days), suffix)
            }
            static var skinFeel: String { manager.localizedString("skinJournal.comparison.skinFeel", table: "SkinJournal") }
            static var before: String { manager.localizedString("skinJournal.comparison.before", table: "SkinJournal") }
            static var after: String { manager.localizedString("skinJournal.comparison.after", table: "SkinJournal") }
            static var noTags: String { manager.localizedString("skinJournal.comparison.noTags", table: "SkinJournal") }
            static var selectEntries: String { manager.localizedString("skinJournal.comparison.selectEntries", table: "SkinJournal") }
            static func tagBullet(_ tag: String) -> String {
                String(format: manager.localizedString("skinJournal.comparison.tagBullet", table: "SkinJournal"), tag)
            }
        }

        // Camera View
        struct Camera {
            static var initializing: String { manager.localizedString("skinJournal.camera.initializing", table: "SkinJournal") }
            static var analyzing: String { manager.localizedString("skinJournal.camera.analyzing", table: "SkinJournal") }
            static var alignFace: String { manager.localizedString("skinJournal.camera.alignFace", table: "SkinJournal") }
            static var keepCentered: String { manager.localizedString("skinJournal.camera.keepCentered", table: "SkinJournal") }
            static var hideGuide: String { manager.localizedString("skinJournal.camera.hideGuide", table: "SkinJournal") }
            static var showGuide: String { manager.localizedString("skinJournal.camera.showGuide", table: "SkinJournal") }
        }

        // Skin Feel Tags
        struct Tag {
            static var oily: String { manager.localizedString("skinJournal.tag.oily", table: "SkinJournal") }
            static var dry: String { manager.localizedString("skinJournal.tag.dry", table: "SkinJournal") }
            static var smooth: String { manager.localizedString("skinJournal.tag.smooth", table: "SkinJournal") }
            static var rough: String { manager.localizedString("skinJournal.tag.rough", table: "SkinJournal") }
            static var irritated: String { manager.localizedString("skinJournal.tag.irritated", table: "SkinJournal") }
            static var calm: String { manager.localizedString("skinJournal.tag.calm", table: "SkinJournal") }
            static var glowing: String { manager.localizedString("skinJournal.tag.glowing", table: "SkinJournal") }
            static var dull: String { manager.localizedString("skinJournal.tag.dull", table: "SkinJournal") }
            static var sensitive: String { manager.localizedString("skinJournal.tag.sensitive", table: "SkinJournal") }
            static var wrinkles: String { manager.localizedString("skinJournal.tag.wrinkles", table: "SkinJournal") }
            static var dryness: String { manager.localizedString("skinJournal.tag.dryness", table: "SkinJournal") }
        }

        // Mood Tags
        struct Mood {
            static var sleep: String { manager.localizedString("skinJournal.mood.sleep", table: "SkinJournal") }
            static var sun: String { manager.localizedString("skinJournal.mood.sun", table: "SkinJournal") }
            static var diet: String { manager.localizedString("skinJournal.mood.diet", table: "SkinJournal") }
            static var hydration: String { manager.localizedString("skinJournal.mood.hydration", table: "SkinJournal") }
            static var stress: String { manager.localizedString("skinJournal.mood.stress", table: "SkinJournal") }
            static var exercise: String { manager.localizedString("skinJournal.mood.exercise", table: "SkinJournal") }
            static var newProduct: String { manager.localizedString("skinJournal.mood.newProduct", table: "SkinJournal") }
            static var sleepQuality: String { manager.localizedString("skinJournal.mood.sleepQuality", table: "SkinJournal") }
        }

        // Image Analysis Results
        struct Analysis {
            static var notAnalyzed: String { manager.localizedString("skinJournal.analysis.notAnalyzed", table: "SkinJournal") }
            static var darkerAppearance: String { manager.localizedString("skinJournal.analysis.darkerAppearance", table: "SkinJournal") }
            static var moderateTone: String { manager.localizedString("skinJournal.analysis.moderateTone", table: "SkinJournal") }
            static var brightAppearance: String { manager.localizedString("skinJournal.analysis.brightAppearance", table: "SkinJournal") }
            static var veryBright: String { manager.localizedString("skinJournal.analysis.veryBright", table: "SkinJournal") }
            static var normal: String { manager.localizedString("skinJournal.analysis.normal", table: "SkinJournal") }
            static var unableToAnalyze: String { manager.localizedString("skinJournal.analysis.unableToAnalyze", table: "SkinJournal") }
            static var noFaceDetected: String { manager.localizedString("skinJournal.analysis.noFaceDetected", table: "SkinJournal") }
            static var evenSkinTone: String { manager.localizedString("skinJournal.analysis.evenSkinTone", table: "SkinJournal") }
            static var mostlyEvenSkinTone: String { manager.localizedString("skinJournal.analysis.mostlyEvenSkinTone", table: "SkinJournal") }
            static var someUnevenness: String { manager.localizedString("skinJournal.analysis.someUnevenness", table: "SkinJournal") }
            static var significantVariation: String { manager.localizedString("skinJournal.analysis.significantVariation", table: "SkinJournal") }
            static var similarBrightness: String { manager.localizedString("skinJournal.analysis.similarBrightness", table: "SkinJournal") }
            static var slightlyBrighter: String { manager.localizedString("skinJournal.analysis.slightlyBrighter", table: "SkinJournal") }
            static var noticeablyBrighter: String { manager.localizedString("skinJournal.analysis.noticeablyBrighter", table: "SkinJournal") }
            static var muchBrighter: String { manager.localizedString("skinJournal.analysis.muchBrighter", table: "SkinJournal") }
            static var slightlyDarker: String { manager.localizedString("skinJournal.analysis.slightlyDarker", table: "SkinJournal") }
            static var noticeablyDarker: String { manager.localizedString("skinJournal.analysis.noticeablyDarker", table: "SkinJournal") }
            static var muchDarker: String { manager.localizedString("skinJournal.analysis.muchDarker", table: "SkinJournal") }
        }

        // Errors
        struct Error {
            static var photoSaveFailed: String { manager.localizedString("skinJournal.error.photoSaveFailed", table: "SkinJournal") }
            static var saveFailed: String { manager.localizedString("skinJournal.error.saveFailed", table: "SkinJournal") }
            static var updateFailed: String { manager.localizedString("skinJournal.error.updateFailed", table: "SkinJournal") }
            static var deleteFailed: String { manager.localizedString("skinJournal.error.deleteFailed", table: "SkinJournal") }
            static var entryNotFound: String { manager.localizedString("skinJournal.error.entryNotFound", table: "SkinJournal") }
        }
    }

    // MARK: - Paywall

    struct Paywall {
        static var premium: String { manager.localizedString("paywall.premium", table: "Paywall") }
        static var title: String { manager.localizedString("paywall.title", table: "Paywall") }

        // Pricing
        struct Pricing {
            static var trial: String { manager.localizedString("paywall.pricing.trial", table: "Paywall") }
            static var monthly: String { manager.localizedString("paywall.pricing.monthly", table: "Paywall") }
        }

        // Features
        struct Features {
            static var freeWeek: String { manager.localizedString("paywall.features.freeWeek", table: "Paywall") }
            static var cancelAnytime: String { manager.localizedString("paywall.features.cancelAnytime", table: "Paywall") }
            static var createRoutines: String { manager.localizedString("paywall.features.createRoutines", table: "Paywall") }
            static var syncCycle: String { manager.localizedString("paywall.features.syncCycle", table: "Paywall") }
            static var noLimits: String { manager.localizedString("paywall.features.noLimits", table: "Paywall") }
        }

        // Actions
        struct Action {
            static var startFreeTrial: String { manager.localizedString("paywall.action.startFreeTrial", table: "Paywall") }
            static var processing: String { manager.localizedString("paywall.action.processing", table: "Paywall") }
        }

        // Footer
        struct Footer {
            static var secure: String { manager.localizedString("paywall.footer.secure", table: "Paywall") }
        }
    }

    // MARK: - Discover

    struct Discover {
        // General
        static var title: String { manager.localizedString("discover.title", table: "Discover") }
        static var subtitle: String { manager.localizedString("discover.subtitle", table: "Discover") }
        static var allRoutines: String { manager.localizedString("discover.allRoutines", table: "Discover") }
        static var viewAll: String { manager.localizedString("discover.viewAll", table: "Discover") }

        // Error Handling
        static var error: String { manager.localizedString("discover.error", table: "Discover") }
        static var retry: String { manager.localizedString("discover.retry", table: "Discover") }
        static var dismiss: String { manager.localizedString("discover.dismiss", table: "Discover") }

        // Fresh Drops
        struct FreshDrops {
            static var title: String { manager.localizedString("discover.freshDrops.title", table: "Discover") }
            static var subtitle: String { manager.localizedString("discover.freshDrops.subtitle", table: "Discover") }
            static var empty: String { manager.localizedString("discover.freshDrops.empty", table: "Discover") }
            static func stepsAndDuration(steps: Int, duration: String) -> String {
                String(format: manager.localizedString("discover.freshDrops.stepsAndDuration", table: "Discover"), steps, duration)
            }
        }

        // Personalized Routine
        struct Personalized {
            static var title: String { manager.localizedString("discover.personalized.title", table: "Discover") }
            static var subtitle: String { manager.localizedString("discover.personalized.subtitle", table: "Discover") }
            static var createTitle: String { manager.localizedString("discover.personalized.createTitle", table: "Discover") }
            static var customizeInstructions: String { manager.localizedString("discover.personalized.customizeInstructions", table: "Discover") }
            static var saveRoutine: String { manager.localizedString("discover.personalized.saveRoutine", table: "Discover") }
            static var generateRoutine: String { manager.localizedString("discover.personalized.generateRoutine", table: "Discover") }
            static var routineName: String { manager.localizedString("discover.personalized.routineName", table: "Discover") }
            static var defaultName: String { manager.localizedString("discover.personalized.defaultName", table: "Discover") }
            static func defaultNameNumbered(_ number: Int) -> String {
                String(format: manager.localizedString("discover.personalized.defaultNameNumbered", table: "Discover"), number)
            }
            static var routineNamePlaceholder: String { manager.localizedString("discover.personalized.routineNamePlaceholder", table: "Discover") }

            static var skinType: String { manager.localizedString("discover.personalized.skinType", table: "Discover") }
            static func currently(_ value: String) -> String {
                String(format: manager.localizedString("discover.personalized.currently", table: "Discover"), value)
            }
            static var skinConcerns: String { manager.localizedString("discover.personalized.skinConcerns", table: "Discover") }
            static var mainGoal: String { manager.localizedString("discover.personalized.mainGoal", table: "Discover") }
            static var routineComplexity: String { manager.localizedString("discover.personalized.routineComplexity", table: "Discover") }
            static var additionalDetails: String { manager.localizedString("discover.personalized.additionalDetails", table: "Discover") }
            static var shareDetails: String { manager.localizedString("discover.personalized.shareDetails", table: "Discover") }
            static var detailsPlaceholder: String { manager.localizedString("discover.personalized.detailsPlaceholder", table: "Discover") }
            static func characterCount(_ count: Int) -> String {
                String(format: manager.localizedString("discover.personalized.characterCount", table: "Discover"), count)
            }
            static func selected(_ value: String) -> String {
                String(format: manager.localizedString("discover.personalized.selected", table: "Discover"), value)
            }
            static var selectedNone: String { manager.localizedString("discover.personalized.selectedNone", table: "Discover") }
            static var notSelected: String { manager.localizedString("discover.personalized.notSelected", table: "Discover") }
            static func customNotes(_ value: String) -> String {
                String(format: manager.localizedString("discover.personalized.customNotes", table: "Discover"), value)
            }
            static var customNotesNone: String { manager.localizedString("discover.personalized.customNotesNone", table: "Discover") }
            static func customNotesCount(_ count: Int) -> String {
                String(format: manager.localizedString("discover.personalized.customNotesCount", table: "Discover"), count)
            }

            // Loading Statuses
            static var loadingAnalyzing: String { manager.localizedString("discover.personalized.loading.analyzing", table: "Discover") }
            static var loadingProcessing: String { manager.localizedString("discover.personalized.loading.processing", table: "Discover") }
            static var loadingGenerating: String { manager.localizedString("discover.personalized.loading.generating", table: "Discover") }
            static var loadingOptimizing: String { manager.localizedString("discover.personalized.loading.optimizing", table: "Discover") }
            static var loadingFinalizing: String { manager.localizedString("discover.personalized.loading.finalizing", table: "Discover") }
        }

        // Mini Guides
        struct Guides {
            static var title: String { manager.localizedString("discover.guides.title", table: "Discover") }
            static var subtitle: String { manager.localizedString("discover.guides.subtitle", table: "Discover") }
            static func minutes(_ minutes: Int) -> String {
                String(format: manager.localizedString("discover.guides.minutes", table: "Discover"), minutes)
            }
            static func minRead(_ minutes: Int) -> String {
                String(format: manager.localizedString("discover.guides.minRead", table: "Discover"), minutes)
            }
        }

        // Inspirational Quotes
        struct Quotes {
            static var title: String { manager.localizedString("discover.quotes.title", table: "Discover") }
            static var shareFooter: String { manager.localizedString("discover.quotes.shareFooter", table: "Discover") }

            // Fallback Quote
            struct Fallback {
                static var text: String { manager.localizedString("discover.quotes.fallback.text", table: "Discover") }
                static var author: String { manager.localizedString("discover.quotes.fallback.author", table: "Discover") }
                static var category: String { manager.localizedString("discover.quotes.fallback.category", table: "Discover") }
            }

            // Individual Quotes - Access by key
            static func text(for key: String) -> String {
                manager.localizedString("discover.quotes.\(key).text", table: "Discover")
            }

            static func author(for key: String) -> String {
                manager.localizedString("discover.quotes.\(key).author", table: "Discover")
            }

            static func category(for key: String) -> String {
                manager.localizedString("discover.quotes.\(key).category", table: "Discover")
            }
        }

        // Community Heat
        struct Community {
            static var title: String { manager.localizedString("discover.community.title", table: "Discover") }
            static var subtitle: String { manager.localizedString("discover.community.subtitle", table: "Discover") }
            static func updated(_ date: String) -> String {
                String(format: manager.localizedString("discover.community.updated", table: "Discover"), date)
            }
            static var empty: String { manager.localizedString("discover.community.empty", table: "Discover") }
            static func increase(_ percent: Int) -> String {
                String(format: manager.localizedString("discover.community.increase", table: "Discover"), percent)
            }
        }

        // Routine Detail
        struct Detail {
            static var tags: String { manager.localizedString("discover.detail.tags", table: "Discover") }
            static var routineSteps: String { manager.localizedString("discover.detail.routineSteps", table: "Discover") }
            static var benefits: String { manager.localizedString("discover.detail.benefits", table: "Discover") }
            static var morning: String { manager.localizedString("discover.detail.morning", table: "Discover") }
            static var evening: String { manager.localizedString("discover.detail.evening", table: "Discover") }
            static func stepNumber(_ number: Int) -> String {
                String(format: manager.localizedString("discover.detail.stepNumber", table: "Discover"), number)
            }
            static var listBullet: String { manager.localizedString("discover.detail.listBullet", table: "Discover") }
            static func stepDescription(step: Int, timeOfDay: String) -> String {
                String(format: manager.localizedString("discover.detail.stepDescription", table: "Discover"), step, timeOfDay)
            }
        }

        // Time of Day
        struct TimeOfDay {
            static var morning: String { manager.localizedString("discover.timeOfDay.morning", table: "Discover") }
            static var evening: String { manager.localizedString("discover.timeOfDay.evening", table: "Discover") }
        }

        // Routine Badges
        struct Badge {
            static var new: String { manager.localizedString("discover.badge.new", table: "Discover") }
            static var updated: String { manager.localizedString("discover.badge.updated", table: "Discover") }
            static var trending: String { manager.localizedString("discover.badge.trending", table: "Discover") }
        }

        // Trending Period
        struct Trending {
            static var thisWeek: String { manager.localizedString("discover.trending.thisWeek", table: "Discover") }
            static var thisMonth: String { manager.localizedString("discover.trending.thisMonth", table: "Discover") }
        }

        // Refresh Time
        struct Refresh {
            static var justNow: String { manager.localizedString("discover.refresh.justNow", table: "Discover") }
            static func minutesAgo(_ minutes: Int) -> String {
                String(format: manager.localizedString("discover.refresh.minutesAgo", table: "Discover"), minutes)
            }
            static func hoursAgo(_ hours: Int) -> String {
                let suffix = hours == 1 ? "" : manager.localizedString("discover.refresh.hoursSuffix", table: "Discover")
                return String(format: manager.localizedString("discover.refresh.hoursAgo", table: "Discover"), hours, suffix)
            }
            static func daysAgo(_ days: Int) -> String {
                let suffix = days == 1 ? "" : manager.localizedString("discover.refresh.daysSuffix", table: "Discover")
                return String(format: manager.localizedString("discover.refresh.daysAgo", table: "Discover"), days, suffix)
            }
        }

        // Ticker Stats
        struct Ticker {
            static func newThisWeek(routines: Int, guides: Int) -> String {
                String(format: manager.localizedString("discover.ticker.newThisWeek", table: "Discover"), routines, guides)
            }
        }

        // Metrics
        struct Metrics {
            static var steps: String { manager.localizedString("discover.metrics.steps", table: "Discover") }
        }
    }

    // MARK: - Templates

    struct Templates {
        // Categories
        struct Category {
            static func title(_ categoryId: String) -> String {
                manager.localizedString("templates.category.\(categoryId).title", table: "Templates")
            }
            static func description(_ categoryId: String) -> String {
                manager.localizedString("templates.category.\(categoryId).description", table: "Templates")
            }
        }

        // Difficulty
        struct Difficulty {
            static var beginner: String { manager.localizedString("templates.difficulty.beginner", table: "Templates") }
            static var intermediate: String { manager.localizedString("templates.difficulty.intermediate", table: "Templates") }
            static var advanced: String { manager.localizedString("templates.difficulty.advanced", table: "Templates") }
        }

        // Routine Template
        struct Routine {
            static func title(_ routineId: String) -> String {
                manager.localizedString("templates.routine.\(routineId).title", table: "Templates")
            }
            static func description(_ routineId: String) -> String {
                manager.localizedString("templates.routine.\(routineId).description", table: "Templates")
            }
            static func duration(_ routineId: String) -> String {
                manager.localizedString("templates.routine.\(routineId).duration", table: "Templates")
            }
            static func tag(_ routineId: String, index: Int) -> String {
                manager.localizedString("templates.routine.\(routineId).tag\(index)", table: "Templates")
            }
            static func benefit(_ routineId: String, index: Int) -> String {
                manager.localizedString("templates.routine.\(routineId).benefit\(index)", table: "Templates")
            }
            static func stepTitle(_ routineId: String, timeOfDay: String, index: Int) -> String {
                manager.localizedString("templates.routine.\(routineId).\(timeOfDay).step\(index).title", table: "Templates")
            }
            static func stepWhy(_ routineId: String, timeOfDay: String, index: Int) -> String {
                manager.localizedString("templates.routine.\(routineId).\(timeOfDay).step\(index).why", table: "Templates")
            }
            static func stepHow(_ routineId: String, timeOfDay: String, index: Int) -> String {
                manager.localizedString("templates.routine.\(routineId).\(timeOfDay).step\(index).how", table: "Templates")
            }
        }
    }

    // MARK: - Guides

    struct Guides {
        // Mini Guide accessors
        static func guideTitle(_ guideId: String) -> String {
            manager.localizedString("guides.\(guideId).title", table: "Guides")
        }
        static func guideSubtitle(_ guideId: String) -> String {
            manager.localizedString("guides.\(guideId).subtitle", table: "Guides")
        }
        static func guideCategory(_ guideId: String) -> String {
            manager.localizedString("guides.\(guideId).category", table: "Guides")
        }
        
        // Guide content accessors
        static func intro(_ guideId: String) -> String {
            manager.localizedString("guides.\(guideId).intro", table: "Guides")
        }
        
        static func heading(_ guideId: String, level: String, index: Int) -> String {
            manager.localizedString("guides.\(guideId).\(level)_\(index)", table: "Guides")
        }
        
        static func paragraph(_ guideId: String, index: Int) -> String {
            manager.localizedString("guides.\(guideId).p\(index)", table: "Guides")
        }
        
        static func tip(_ guideId: String, index: Int) -> String {
            manager.localizedString("guides.\(guideId).tip\(index)", table: "Guides")
        }
        
        static func listItem(_ guideId: String, listIndex: Int, itemIndex: Int) -> String {
            manager.localizedString("guides.\(guideId).list\(listIndex)_item\(itemIndex)", table: "Guides")
        }
        
        // Default content
        static func defaultIntro(_ category: String) -> String {
            String(format: manager.localizedString("guides.default.intro", table: "Guides"), category)
        }
        
        static func defaultParagraph(_ index: Int) -> String {
            manager.localizedString("guides.default.p\(index)", table: "Guides")
        }
        
        static func defaultHeading(_ level: String, index: Int) -> String {
            manager.localizedString("guides.default.\(level)_\(index)", table: "Guides")
        }
        
        static func defaultListItem(_ listIndex: Int, itemIndex: Int) -> String {
            manager.localizedString("guides.default.list\(listIndex)_item\(itemIndex)", table: "Guides")
        }
        
        static var defaultDisclaimer: String {
            manager.localizedString("guides.default.disclaimer", table: "Guides")
        }
        
        static func content(_ guideId: String, section: String, key: String) -> String {
            manager.localizedString("guides.\(guideId).\(section).\(key)", table: "Guides")
        }

        // Hero Banner
        struct Hero {
            static func title(_ heroId: String) -> String {
                manager.localizedString("guides.hero.\(heroId).title", table: "Guides")
            }
            static func subtitle(_ heroId: String) -> String {
                manager.localizedString("guides.hero.\(heroId).subtitle", table: "Guides")
            }
            static func cta(_ heroId: String) -> String {
                manager.localizedString("guides.hero.\(heroId).cta", table: "Guides")
            }
        }

        // Badges
        struct Badge {
            static var new: String { manager.localizedString("guides.badge.new", table: "Guides") }
            static var updated: String { manager.localizedString("guides.badge.updated", table: "Guides") }
            static var trending: String { manager.localizedString("guides.badge.trending", table: "Guides") }
        }

        // Trending Period
        struct TrendingPeriod {
            static var thisWeek: String { manager.localizedString("guides.trendingPeriod.thisWeek", table: "Guides") }
            static var thisMonth: String { manager.localizedString("guides.trendingPeriod.thisMonth", table: "Guides") }
        }

        // Refresh Time
        struct Refresh {
            static var justNow: String { manager.localizedString("guides.refresh.justNow", table: "Guides") }
            static func minutesAgo(_ minutes: Int) -> String {
                String(format: manager.localizedString("guides.refresh.minutesAgo", table: "Guides"), minutes)
            }
            static func hoursAgo(_ hours: Int) -> String {
                let suffix = hours == 1 ? manager.localizedString("guides.refresh.hourSuffix", table: "Guides") : manager.localizedString("guides.refresh.hoursSuffix", table: "Guides")
                return String(format: manager.localizedString("guides.refresh.hoursAgo", table: "Guides"), hours, suffix)
            }
            static func daysAgo(_ days: Int) -> String {
                let suffix = days == 1 ? manager.localizedString("guides.refresh.daySuffix", table: "Guides") : manager.localizedString("guides.refresh.daysSuffix", table: "Guides")
                return String(format: manager.localizedString("guides.refresh.daysAgo", table: "Guides"), days, suffix)
            }
        }

        // Ticker
        struct Ticker {
            static func newThisWeek(routines: Int, guides: Int) -> String {
                String(format: manager.localizedString("guides.ticker.newThisWeek", table: "Guides"), routines, guides)
            }
        }

        // Seasonal
        struct Seasonal {
            static func article(_ articleId: String) -> String {
                manager.localizedString("guides.seasonal.article.\(articleId)", table: "Guides")
            }
            static var cta: String { manager.localizedString("guides.seasonal.cta", table: "Guides") }
        }

        // Quotes
        struct Quote {
            static func text(_ quoteId: String) -> String {
                manager.localizedString("guides.quote.\(quoteId)", table: "Guides")
            }
            static func author(_ quoteId: String) -> String {
                manager.localizedString("guides.quote.\(quoteId).author", table: "Guides")
            }
        }
    }
}
