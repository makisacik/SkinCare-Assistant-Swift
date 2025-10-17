//
//  LanguageService.swift
//  ManCare
//
//  Translation service for GPT integration
//  Translates user input to English for processing, then back to user's language
//

import Foundation

final class LanguageService {
    static let shared = LanguageService()

    // MARK: - Dependencies

    private let gptService: GPTService
    private let cache: TranslationCache

    // MARK: - Initialization

    init(gptService: GPTService = GPTService.shared) {
        self.gptService = gptService
        self.cache = TranslationCache()
        print("🔧 LanguageService initialized")
    }

    // MARK: - Public Methods

    /// Translate text from user's language to English for GPT processing
    func translateToEnglish(_ text: String, from sourceLanguage: String) async throws -> String {
        // Skip if already English
        guard sourceLanguage != "en" else { return text }

        // Check cache first
        if let cached = cache.get(text: text, sourceLang: sourceLanguage, targetLang: "en") {
            print("💾 Using cached translation: \(text) -> \(cached)")
            return cached
        }

        print("🔄 Translating to English: \(text)")

        let systemPrompt = """
        You are a professional translator. Translate accurately and naturally.
        Return ONLY the translated text as a JSON object with a "translation" field.
        """

        let userPrompt = """
        Translate the following text from \(languageName(for: sourceLanguage)) to English:

        \(text)
        """

        let jsonResponse = try await gptService.completeJSON(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            timeout: 30
        )

        // Parse JSON response
        struct TranslationResponse: Codable {
            let translation: String
        }

        let data = Data(jsonResponse.utf8)
        let decoded = try JSONDecoder().decode(TranslationResponse.self, from: data)
        let translated = decoded.translation.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cache the translation
        cache.set(text: text, translation: translated, sourceLang: sourceLanguage, targetLang: "en")

        print("✅ Translated to English: \(translated)")
        return translated
    }

    /// Translate text from English to user's language for display
    func translateFromEnglish(_ text: String, to targetLanguage: String) async throws -> String {
        // Skip if target is English
        guard targetLanguage != "en" else { return text }

        // Check cache first
        if let cached = cache.get(text: text, sourceLang: "en", targetLang: targetLanguage) {
            print("💾 Using cached translation: \(text) -> \(cached)")
            return cached
        }

        print("🔄 Translating from English to \(targetLanguage): \(text)")

        let systemPrompt = """
        You are a professional translator. Translate accurately and naturally.
        Maintain the tone and style of the original text.
        Return ONLY the translated text as a JSON object with a "translation" field.
        """

        let userPrompt = """
        Translate the following text from English to \(languageName(for: targetLanguage)):

        \(text)
        """

        let jsonResponse = try await gptService.completeJSON(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            timeout: 30
        )

        // Parse JSON response
        struct TranslationResponse: Codable {
            let translation: String
        }

        let data = Data(jsonResponse.utf8)
        let decoded = try JSONDecoder().decode(TranslationResponse.self, from: data)
        let translated = decoded.translation.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cache the translation
        cache.set(text: text, translation: translated, sourceLang: "en", targetLang: targetLanguage)

        print("✅ Translated to \(targetLanguage): \(translated)")
        return translated
    }

    /// Translate an array of strings
    func translateArray(_ texts: [String], from sourceLanguage: String, to targetLanguage: String) async throws -> [String] {
        guard sourceLanguage != targetLanguage else { return texts }

        return try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, text) in texts.enumerated() {
                group.addTask {
                    let translated: String
                    if sourceLanguage == "en" {
                        translated = try await self.translateFromEnglish(text, to: targetLanguage)
                    } else {
                        translated = try await self.translateToEnglish(text, from: sourceLanguage)
                    }
                    return (index, translated)
                }
            }

            var results: [(Int, String)] = []
            for try await result in group {
                results.append(result)
            }

            // Sort by index to maintain order
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

    // MARK: - Private Helpers

    private func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "tr": return "Turkish"
        default: return code
        }
    }
}

// MARK: - Translation Cache

final class TranslationCache {
    private var cache: [String: String] = [:]
    private let queue = DispatchQueue(label: "com.mancare.translationcache", attributes: .concurrent)

    private func cacheKey(text: String, sourceLang: String, targetLang: String) -> String {
        return "\(sourceLang):\(targetLang):\(text.prefix(100))" // Limit key size
    }

    func get(text: String, sourceLang: String, targetLang: String) -> String? {
        queue.sync {
            cache[cacheKey(text: text, sourceLang: sourceLang, targetLang: targetLang)]
        }
    }

    func set(text: String, translation: String, sourceLang: String, targetLang: String) {
        queue.async(flags: .barrier) {
            self.cache[self.cacheKey(text: text, sourceLang: sourceLang, targetLang: targetLang)] = translation

            // Limit cache size
            if self.cache.count > 1000 {
                // Remove oldest entries (simplified - in production, use LRU)
                let keysToRemove = Array(self.cache.keys.prefix(200))
                keysToRemove.forEach { self.cache.removeValue(forKey: $0) }
            }
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

