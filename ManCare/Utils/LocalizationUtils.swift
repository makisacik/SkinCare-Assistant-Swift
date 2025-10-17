//
//  LocalizationUtils.swift
//  ManCare
//
//  Utility functions for localization support
//

import Foundation

enum LocalizationUtils {
    
    // MARK: - Device Locale Detection
    
    /// Get the device's locale language, returning only supported languages
    /// Returns "en" for English or "tr" for Turkish, defaulting to "en" for unsupported languages
    static func deviceLocaleLanguage() -> String {
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Only return supported languages, otherwise default to English
        let supportedCodes = supportedLanguageCodes()
        if supportedCodes.contains(deviceLanguage) {
            return deviceLanguage
        }
        
        return "en" // Default to English
    }
    
    /// Get array of supported language codes
    static func supportedLanguageCodes() -> [String] {
        return ["en", "tr"]
    }
    
    /// Get array of supported languages from LocalizationManager
    static func supportedLanguages() -> [LocalizationManager.Language] {
        return [.english, .turkish]
    }
    
    /// Get languages to show in picker: Always English + device locale (if different)
    static func availableLanguagesForPicker() -> [LocalizationManager.Language] {
        let deviceLang = deviceLocaleLanguage()
        
        var languages: [LocalizationManager.Language] = [.english]
        
        // Add device locale if it's not English
        if deviceLang != "en", let deviceLanguageEnum = LocalizationManager.Language(rawValue: deviceLang) {
            languages.append(deviceLanguageEnum)
        }
        
        return languages
    }
    
    // MARK: - Locale-Specific Logic
    
    /// Check if device locale requires translation
    static func shouldTranslateForDevice() -> Bool {
        return deviceLocaleLanguage() != "en"
    }
    
    /// Get target language for translation (device locale if not English, otherwise nil)
    static func targetTranslationLanguage() -> String? {
        let deviceLang = deviceLocaleLanguage()
        return deviceLang != "en" ? deviceLang : nil
    }
}

