//
//  LocalizationUtils.swift
//  ManCare
//
//  Utility functions for localization support
//

import Foundation

enum LocalizationUtils {
    
    // MARK: - Device Locale Detection
    
    /// Get the device's actual locale language (raw, before any filtering)
    static func rawDeviceLocaleLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }

    /// Get the device's locale language, returning only if it exists in app localizations
    /// Returns nil if the device language is not available in the app
    static func deviceLocaleLanguage() -> String? {
        let deviceLanguage = rawDeviceLocaleLanguage()

        // Check if this language exists in the app's localizations
        if localizationExists(for: deviceLanguage) {
            return deviceLanguage
        }

        return nil
    }

    /// Check if a localization bundle exists for the given language code
    static func localizationExists(for languageCode: String) -> Bool {
        // Check if the .lproj bundle exists for this language
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        return path != nil
    }

    /// Get array of all available language codes (from actual .lproj folders)
    static func availableLanguageCodes() -> [String] {
        var languages: [String] = ["en"] // English is always available

        // Check for other localizations
        let possibleLanguages = ["tr", "de", "fr", "es", "it", "ja", "ko", "zh-Hans", "zh-Hant", "pt", "ru"]
        for lang in possibleLanguages {
            if localizationExists(for: lang) {
                languages.append(lang)
            }
        }

        return languages
    }

    /// Get array of supported languages from LocalizationManager that actually exist
    static func availableLanguages() -> [LocalizationManager.Language] {
        return LocalizationManager.Language.allCases.filter { lang in
            localizationExists(for: lang.rawValue)
        }
    }

    /// Get languages to show in picker based on business logic:
    /// - If device locale is English OR doesn't exist in app → return empty array (no picker shown)
    /// - If device locale exists in app → return [English, Device Locale]
    static func availableLanguagesForPicker() -> [LocalizationManager.Language] {
        guard let deviceLang = deviceLocaleLanguage(), deviceLang != "en" else {
            // Device is English or locale not supported → no language picker
            return []
        }

        // Device locale exists and is not English → show both English and device locale
        guard let deviceLanguageEnum = LocalizationManager.Language(rawValue: deviceLang) else {
            return []
        }

        return [.english, deviceLanguageEnum]
    }

    /// Get the app language to use on startup based on business logic:
    /// - If device locale exists in app → use device locale
    /// - Otherwise → use English
    static func initialAppLanguage() -> String {
        return deviceLocaleLanguage() ?? "en"
    }

    // MARK: - Translation Logic

    /// Get languages to request from GPT for i18n
    /// - If current language is English → return ["en"] (GPT will copy English data to i18n)
    /// - If current language is not English AND exists → return ["en", currentLanguage]
    /// This ensures we always have i18n data in Core Data, simplifying data handling
    static func i18nLanguagesForGPT(currentLanguage: String) -> [String] {
        if currentLanguage == "en" {
            // For English users, still request i18n with English
            // GPT will duplicate the English content in i18n["en"]
            return ["en"]
        }

        // For non-English users, request both English and their language
        return ["en", currentLanguage]
    }
}

