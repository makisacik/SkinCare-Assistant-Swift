//
//  GPTService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Public Input Types (match your flow)
public struct ManCareRoutineRequest: Codable {
    public let selectedSkinType: String                // "oily" | "dry" | "combination" | "normal"
    public let selectedConcerns: [String]              // e.g. ["acne","blackheads"]
    public let selectedMainGoal: String                // "healthierOverall" | "reduceBreakouts" | "sootheIrritation" | "preventAging" | "ageSlower" | "shinySkin"
    public let fitzpatrickSkinTone: String             // "type1" | "type2" | "type3" | "type4" | "type5" | "type6"
    public let ageRange: String                        // "teens" | "twenties" | "thirties" | "forties" | "fifties" | "sixtiesPlus"
    public let region: String                          // "tropical" | "subtropical" | "temperate" | "continental" | "mediterranean" | "arctic" | "desert" | "mountain"
    public let selectedPreferences: PreferencesPayload?
    public let lifestyle: LifestylePayload?
    public let locale: String                          // e.g. "en-US"

    public init(selectedSkinType: String,
                selectedConcerns: [String],
                selectedMainGoal: String,
                fitzpatrickSkinTone: String,
                ageRange: String,
                region: String,
                selectedPreferences: PreferencesPayload?,
                lifestyle: LifestylePayload?,
                locale: String = "en-US") {
        self.selectedSkinType = selectedSkinType
        self.selectedConcerns = selectedConcerns
        self.selectedMainGoal = selectedMainGoal
        self.fitzpatrickSkinTone = fitzpatrickSkinTone
        self.ageRange = ageRange
        self.region = region
        self.selectedPreferences = selectedPreferences
        self.lifestyle = lifestyle
        self.locale = locale
    }
}

public struct PreferencesPayload: Codable {
    public let fragranceFreeOnly: Bool
    public let suitableForSensitiveSkin: Bool
    public let naturalIngredients: Bool
    public let crueltyFree: Bool
    public let veganFriendly: Bool
}

public struct LifestylePayload: Codable {
    public let sleepQuality: String?           // "poor" | "average" | "good"
    public let exerciseFrequency: String?      // "none" | "oneToTwo" | "threeToFour" | "fivePlus"
    public let routineDepthPreference: String? // "minimal" | "standard" | "detailed"
    public let sunResponse: String?            // "rarely" | "sometimes" | "easily"
    public let outdoorHours: Int?
    public let smokes: Bool?
    public let drinksAlcohol: Bool?
    public let fragranceFree: Bool?
    public let naturalPreference: Bool?
    public let sensitiveSkin: Bool?
}

// MARK: - Service

public final class GPTService {
    public enum GPTServiceError: Error {
        case encodingFailed
        case requestFailed(Int, String)
        case emptyChoices
        case decodingFailed(String)
        case invalidJSON(String)
    }
    
    // Shared instance
    public static let shared = GPTService(apiKey: Config.openAIAPIKey)

    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Simple cache for similar requests
    private static var responseCache: [String: RoutineResponse] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.mancare.gptcache", attributes: .concurrent)

    /// Inject your API key from Secrets/Keychain/Environment.
    public init(apiKey: String,
                model: String = "gpt-3.5-turbo",
                session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    // MARK: Public API

    /// High-level call: builds system+user prompts and returns a typed RoutineResponse.
    func generateRoutine(for request: ManCareRoutineRequest,
                         routineDepthFallback: String? = nil,
                         timeout: TimeInterval = 30,
                         enhanceWithProductInfo: Bool = false) async throws -> RoutineResponse {
        // Check cache first for similar requests
        let cacheKey = createCacheKey(for: request)
        if let cachedResponse = Self.cacheQueue.sync(execute: { Self.responseCache[cacheKey] }) {
            #if DEBUG
            print("🚀 Using cached response for faster delivery")
            #endif
            return cachedResponse
        }

        let system = Self.systemPrompt(schemaJSON: Self.schemaJSON)
        let user = Self.userPrompt(from: request, routineDepthFallback: routineDepthFallback)
        let json = try await completeJSON(systemPrompt: system, userPrompt: user, timeout: timeout)
        // Decode strictly into your RoutineResponse model
        do {
            let decoder = JSONDecoder()
            let data = Data(json.utf8)
            let routine = try decoder.decode(RoutineResponse.self, from: data)

            // Enhance the routine with ProductTypeDatabase information (optional for performance)
            let finalRoutine = enhanceWithProductInfo ? enhanceRoutineWithProductInfo(routine) : routine

            // Cache the response for future similar requests
            Self.cacheQueue.async(flags: .barrier) {
                Self.responseCache[cacheKey] = finalRoutine
                // Keep cache size reasonable (max 50 entries)
                if Self.responseCache.count > 50 {
                    let keysToRemove = Array(Self.responseCache.keys.prefix(10))
                    keysToRemove.forEach { Self.responseCache.removeValue(forKey: $0) }
                }
            }

            // Validate the decoded response
            #if DEBUG
            print("✅ Successfully decoded RoutineResponse: \(finalRoutine.summary.title)")
            #endif

            return finalRoutine
        } catch {
            print("❌ Failed to decode RoutineResponse: \(error)")
            #if DEBUG
            print("📄 Raw JSON that failed to decode:")
            print(json)
            #endif
            throw GPTServiceError.decodingFailed(String(describing: error))
        }
    }

    /// Enhance routine steps with ProductTypeDatabase information for better normalization
    func enhanceRoutineWithProductInfo(_ routine: RoutineResponse) -> RoutineResponse {
        let enhancedMorning = routine.routine.morning.map { enhanceStep($0) }
        let enhancedEvening = routine.routine.evening.map { enhanceStep($0) }
        let enhancedWeekly = routine.routine.weekly?.map { enhanceStep($0) }

        let enhancedRoutine = Routine(
            depth: routine.routine.depth,
            morning: enhancedMorning,
            evening: enhancedEvening,
            weekly: enhancedWeekly
        )

        return RoutineResponse(
            version: routine.version,
            locale: routine.locale,
            summary: routine.summary,
            routine: enhancedRoutine,
            guardrails: routine.guardrails,
            adaptation: routine.adaptation,
            productSlots: routine.productSlots
        )
    }

    /// Enhance routine asynchronously in background for better performance
    func enhanceRoutineAsync(_ routine: RoutineResponse) async -> RoutineResponse {
        return await Task.detached {
            return self.enhanceRoutineWithProductInfo(routine)
        }.value
    }

    /// Create cache key for request
    private func createCacheKey(for request: ManCareRoutineRequest) -> String {
        let concerns = request.selectedConcerns.sorted().joined(separator: ",")
        let prefs = request.selectedPreferences.map { "\($0.fragranceFreeOnly),\($0.suitableForSensitiveSkin),\($0.naturalIngredients),\($0.crueltyFree),\($0.veganFriendly)" } ?? "none"
        return "\(request.selectedSkinType)|\(concerns)|\(request.selectedMainGoal)|\(request.fitzpatrickSkinTone)|\(request.ageRange)|\(request.region)|\(prefs)"
    }

    /// Enhance a single step with ProductTypeDatabase information
    private func enhanceStep(_ step: APIRoutineStep) -> APIRoutineStep {
        // Create a step name that combines the product type and the name
        let stepName = "\(step.name) - \(step.why)"

        // Get enhanced information from ProductTypeDatabase
        let productInfo = ProductTypeDatabase.getInfo(for: stepName)

        // Use the enhanced information to improve the step
        return APIRoutineStep(
            step: step.step,
            name: productInfo.name, // Use the actual product name from our database
            why: productInfo.why,   // Use our specific "why" information
            how: productInfo.how,   // Use our specific "how" information
            constraints: step.constraints // Keep the original constraints from GPT
        )
    }

    // MARK: - Core JSON completion with retries

    private struct ChatMessage: Codable {
        let role: String
        let content: String
    }

    private struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
        let temperature: Double
        let response_format: ResponseFormat

        struct ResponseFormat: Codable { let type: String }
    }

    private struct ChatResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable { let role: String; let content: String }
            let index: Int
            let message: Message
        }
        let choices: [Choice]
    }

    /// Sends a chat completion request forcing JSON output and returns the raw JSON string.
    public func completeJSON(systemPrompt: String,
                              userPrompt: String,
                              timeout: TimeInterval) async throws -> String {
        let body = ChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: 0.1,
            response_format: .init(type: "json_object")
        )

        let encoder = JSONEncoder()
        guard let payload = try? encoder.encode(body) else {
            throw GPTServiceError.encodingFailed
        }

        // Log the request being sent (reduced logging for performance)
        #if DEBUG
        print("📤 Sending API Request: \(body.model) (temp: \(body.temperature))")
        #endif

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.httpBody = payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout

        // Retry policy: 2 tries with shorter backoff for faster recovery
        let maxAttempts = 2
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                let (data, resp) = try await session.data(for: request)
                guard let http = resp as? HTTPURLResponse else {
                    throw GPTServiceError.requestFailed(-1, "No HTTPURLResponse")
                }

                #if DEBUG
                print("📥 HTTP Response: \(http.statusCode)")
                #endif

                guard (200..<300).contains(http.statusCode) else {
                    let bodyText = String(data: data, encoding: .utf8) ?? ""
                    print("❌ HTTP Error Response Body:")
                    print(bodyText)
                    throw GPTServiceError.requestFailed(http.statusCode, bodyText)
                }

                let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
                guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
                    throw GPTServiceError.emptyChoices
                }

                #if DEBUG
                print("🔍 API Response received (\(content.count) chars)")
                #endif

                // Validate that it is JSON
                if Self.isValidJSONObjectString(content) {
                    return content
                } else {
                    throw GPTServiceError.invalidJSON(content)
                }
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    // Shorter backoff: 1 second + small jitter
                    let backoff = 1.0 + Double.random(in: 0...0.5)
                    try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    continue
                }
            }
        }
        throw lastError ?? GPTServiceError.requestFailed(-1, "Unknown error")
    }

    private static func isValidJSONObjectString(_ s: String) -> Bool {
        guard let data = s.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    // MARK: - Prompt Builders

    /// System prompt with embedded schema and rules (JSON only).
    private static func systemPrompt(schemaJSON: String) -> String {
        return """
        You are a skincare expert. Return ONLY valid JSON matching the schema exactly.

        Rules: Safe, realistic, concise. Align to skin type, concerns, main goal, Fitzpatrick skin tone, age range, region, and preferences. Age-appropriate recommendations. No brand names. Include guardrails.

        PRODUCT TYPES: cleanser, moisturizer, sunscreen, faceSerum, exfoliator, faceMask

        Use exact product type names from schema. "name" field: descriptive names like "Gentle Cleanser", "Vitamin C Serum". "step" field: must match available product types exactly.

        SCHEMA:
        \(schemaJSON)
        """
    }

    /// Get product type information for the system prompt (optimized)
    private static func getProductTypeInfo() -> String {
        // Use a more concise version to reduce token count
        let productTypes = ProductType.allCases.map { $0.rawValue }.joined(separator: ", ")

        return """
        Available product types: \(productTypes)

        Categories: Cleansing, Toning, Treatment, Moisturizing, Sun Protection, Masks, Shaving, Body Care, Hair Care
        """
    }

    /// Builds the user prompt from the collected inputs.
    private static func userPrompt(from req: ManCareRoutineRequest,
                                   routineDepthFallback: String?) -> String {
        // Ultra-concise format to minimize token count
        var parts: [String] = []
        parts.append("Skin:\(req.selectedSkinType)")
        parts.append("Concerns:\(req.selectedConcerns.joined(separator: ","))")
        parts.append("Goal:\(req.selectedMainGoal)")
        parts.append("Tone:\(req.fitzpatrickSkinTone)")
        parts.append("Age:\(req.ageRange)")
        parts.append("Region:\(req.region)")

        if let prefs = req.selectedPreferences {
            let prefsStr = "fragranceFree:\(prefs.fragranceFreeOnly),sensitive:\(prefs.suitableForSensitiveSkin),natural:\(prefs.naturalIngredients),crueltyFree:\(prefs.crueltyFree),vegan:\(prefs.veganFriendly)"
            parts.append("Prefs:\(prefsStr)")
        }

        if let ls = req.lifestyle {
            var kv: [String] = []
            if let v = ls.sleepQuality { kv.append("sleep:\(v)") }
            if let v = ls.exerciseFrequency { kv.append("exercise:\(v)") }
            if let v = ls.routineDepthPreference { kv.append("depth:\(v)") }
            if let v = ls.sunResponse { kv.append("sun:\(v)") }
            if let v = ls.outdoorHours { kv.append("outdoor:\(v)") }
            if let v = ls.smokes { kv.append("smokes:\(v)") }
            if let v = ls.drinksAlcohol { kv.append("alcohol:\(v)") }
            if let v = ls.fragranceFree { kv.append("fragrance:\(v)") }
            if let v = ls.naturalPreference { kv.append("natural:\(v)") }
            if let v = ls.sensitiveSkin { kv.append("sensitive:\(v)") }
            if !kv.isEmpty {
                parts.append("Lifestyle:\(kv.joined(separator: ","))")
            }
        }

        if let depth = routineDepthFallback {
            parts.append("Depth:\(depth)")
        }
        parts.append("Locale:\(req.locale)")
        return parts.joined(separator: " ")
    }

    /// JSON Schema (minimal for faster processing).
    private static let schemaJSON: String = {
        // Minimal schema to reduce token count
        return """
        {
          "version": "string",
          "locale": "string",
          "summary": {"title": "string", "one_liner": "string"},
          "routine": {
            "depth": "standard",
            "morning": [{"step": "cleanser|moisturizer|sunscreen|faceSerum", "name": "string", "why": "string", "how": "string", "constraints": {"spf": 0, "fragrance_free": true, "sensitive_safe": true, "vegan": true, "cruelty_free": true, "avoid_ingredients": [], "prefer_ingredients": []}}],
            "evening": [{"step": "cleanser|moisturizer|faceSerum|exfoliator", "name": "string", "why": "string", "how": "string", "constraints": {"spf": 0, "fragrance_free": true, "sensitive_safe": true, "vegan": true, "cruelty_free": true, "avoid_ingredients": [], "prefer_ingredients": []}}],
            "weekly": [{"step": "faceMask|exfoliator", "name": "string", "why": "string", "how": "string", "constraints": {"spf": 0, "fragrance_free": true, "sensitive_safe": true, "vegan": true, "cruelty_free": true, "avoid_ingredients": [], "prefer_ingredients": []}}]
          },
          "guardrails": {"cautions": ["string"], "when_to_stop": ["string"], "sun_notes": "string"},
          "adaptation": {"for_skin_type": "string", "for_concerns": ["string"], "for_preferences": ["string"]},
          "product_slots": []
        }
        """
    }()
}
