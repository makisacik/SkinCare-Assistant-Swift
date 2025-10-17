//
//  LocalizationManager.swift
//  ManCare
//
//  Reactive localization manager for in-app language switching
//

import Foundation
import Combine
import SwiftUI

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    // MARK: - Published Properties
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: Constants.languageKey)
            // Update bundle for localization
            updateCurrentBundle()
        }
    }
    
    // MARK: - Supported Languages
    
    enum Language: String, CaseIterable, Identifiable {
        case english = "en"
        case turkish = "tr"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .turkish: return "Türkçe"
            }
        }
        
        var nativeName: String {
            switch self {
            case .english: return "English"
            case .turkish: return "Türkçe"
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var currentBundle: Bundle?
    private let defaultLanguage: Language = .english
    
    private enum Constants {
        static let languageKey = "app_language"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved language or use device language as fallback
        let savedLanguage = UserDefaults.standard.string(forKey: Constants.languageKey)
        
        if let saved = savedLanguage, Language(rawValue: saved) != nil {
            self.currentLanguage = saved
        } else {
            // Try to match device language
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = Language(rawValue: deviceLanguage)?.rawValue ?? defaultLanguage.rawValue
        }
        
        updateCurrentBundle()
        print("🌍 LocalizationManager initialized with language: \(currentLanguage)")
    }
    
    // MARK: - Public Methods
    
    /// Set the app language
    func setLanguage(_ language: Language) {
        guard language.rawValue != currentLanguage else { return }
        
        print("🌍 Switching language from \(currentLanguage) to \(language.rawValue)")
        currentLanguage = language.rawValue
    }
    
    /// Get localized string from specific table
    func localizedString(_ key: String, table: String? = nil, comment: String = "") -> String {
        guard let bundle = currentBundle else {
            return NSLocalizedString(key, tableName: table, comment: comment)
        }
        
        return bundle.localizedString(forKey: key, value: nil, table: table)
    }
    
    /// Get localized string with arguments
    func localizedString(_ key: String, table: String? = nil, arguments: CVarArg...) -> String {
        let format = localizedString(key, table: table)
        return String(format: format, arguments: arguments)
    }
    
    /// Get the current language enum
    var currentLanguageEnum: Language {
        Language(rawValue: currentLanguage) ?? defaultLanguage
    }
    
    /// Check if current language is RTL
    var isRTL: Bool {
        Locale.characterDirection(forLanguage: currentLanguage) == .rightToLeft
    }
    
    // MARK: - Private Methods
    
    private func updateCurrentBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("⚠️ LocalizationManager: Could not find bundle for language: \(currentLanguage)")
            currentBundle = Bundle.main
            return
        }
        
        currentBundle = bundle
        print("✅ LocalizationManager: Updated bundle for language: \(currentLanguage)")
    }
}

// MARK: - SwiftUI Environment Key

struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localizationManager: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    func withLocalization() -> some View {
        self.environmentObject(LocalizationManager.shared)
    }
}

