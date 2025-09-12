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

    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    /// Inject your API key from Secrets/Keychain/Environment.
    public init(apiKey: String,
                model: String = "gpt-4o-mini",
                session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    // MARK: Public API

    /// High-level call: builds system+user prompts and returns a typed RoutineResponse.
    func generateRoutine(for request: ManCareRoutineRequest,
                         routineDepthFallback: String? = nil,
                         timeout: TimeInterval = 60) async throws -> RoutineResponse {
        let system = Self.systemPrompt(schemaJSON: Self.schemaJSON)
        let user = Self.userPrompt(from: request, routineDepthFallback: routineDepthFallback)
        let json = try await completeJSON(systemPrompt: system, userPrompt: user, timeout: timeout)
        // Decode strictly into your RoutineResponse model
        do {
            let decoder = JSONDecoder()
            let data = Data(json.utf8)
            let routine = try decoder.decode(RoutineResponse.self, from: data)
            
            // Validate the decoded response
            print("✅ Successfully decoded RoutineResponse")
            print("   - Version: \(routine.version)")
            print("   - Locale: \(routine.locale)")
            print("   - Summary: \(routine.summary.title)")
            print("   - Morning steps: \(routine.routine.morning.count)")
            print("   - Evening steps: \(routine.routine.evening.count)")
            print("   - Weekly steps: \(routine.routine.weekly?.count ?? 0)")
            
            return routine
        } catch {
            print("❌ Failed to decode RoutineResponse: \(error)")
            print("📄 Raw JSON that failed to decode:")
            print(json)
            throw GPTServiceError.decodingFailed(String(describing: error))
        }
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
            temperature: 0.4,
            response_format: .init(type: "json_object")
        )

        let encoder = JSONEncoder()
        guard let payload = try? encoder.encode(body) else {
            throw GPTServiceError.encodingFailed
        }

        // Log the request being sent
        print("📤 Sending API Request:")
        print("   - Model: \(body.model)")
        print("   - Temperature: \(body.temperature)")
        print("   - Response Format: \(body.response_format.type)")
        print("   - System Prompt: \(body.messages[0].content)")
        print("   - User Prompt: \(body.messages[1].content)")
        if let requestJSON = String(data: payload, encoding: .utf8) {
            print("📤 Full Request JSON:")
            print(requestJSON)
            print("📤 End of Request JSON")
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.httpBody = payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout

        // Retry policy: 3 tries, exponential backoff 0.8^attempt * 2s jitter
        let maxAttempts = 3
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                let (data, resp) = try await session.data(for: request)
                guard let http = resp as? HTTPURLResponse else {
                    throw GPTServiceError.requestFailed(-1, "No HTTPURLResponse")
                }
                
                print("📥 HTTP Response:")
                print("   - Status Code: \(http.statusCode)")
                print("   - Headers: \(http.allHeaderFields)")
                
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

                // Log the raw JSON response
                print("🔍 Raw API Response:")
                print(content)
                print("🔍 End of Raw Response")

                // Validate that it is JSON
                if Self.isValidJSONObjectString(content) {
                    return content
                } else {
                    throw GPTServiceError.invalidJSON(content)
                }
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    let backoff = pow(2.0, Double(attempt - 1)) + Double.random(in: 0...0.8)
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
        """
        You are ManCare's skincare co-pilot for men.
        Return ONLY valid JSON matching the schema exactly. No extra text.
        Rules:
        - Safe, realistic, concise.
        - Align to skin type, concerns, main goal, Fitzpatrick skin tone, age range, region, and preferences.
        - Consider UV sensitivity based on Fitzpatrick type and regional climate.
        - Age-appropriate recommendations (teens: gentle prevention, 30s+: anti-aging, 50s+: intensive care).
        - Regional considerations: high UV areas need stronger SPF, dry climates need more hydration.
        - If info is missing, choose sensible defaults and note them.
        - No brand names or store links; use ingredient-level constraints.
        - Include guardrails (cautions, when_to_stop).
        - Keep language simple/neutral.
        - Locale-aware where needed.

        SCHEMA:
        \(schemaJSON)
        """
    }

    /// Builds the user prompt from the collected inputs.
    private static func userPrompt(from req: ManCareRoutineRequest,
                                   routineDepthFallback: String?) -> String {
        // Serialize your collected payload as a JSON-like block to reduce LLM drift.
        var lines: [String] = []
        lines.append("Generate a routine for this user in EXACT schema. Return JSON only.\n")
        lines.append("selectedSkinType: \(req.selectedSkinType)")
        lines.append("selectedConcerns: \(req.selectedConcerns)")
        lines.append("selectedMainGoal: \(req.selectedMainGoal)")
        lines.append("fitzpatrickSkinTone: \(req.fitzpatrickSkinTone)")
        lines.append("ageRange: \(req.ageRange)")
        lines.append("region: \(req.region)")

        if let prefs = req.selectedPreferences {
            lines.append("""
            selectedPreferences: {
              fragranceFreeOnly: \(prefs.fragranceFreeOnly),
              suitableForSensitiveSkin: \(prefs.suitableForSensitiveSkin),
              naturalIngredients: \(prefs.naturalIngredients),
              crueltyFree: \(prefs.crueltyFree),
              veganFriendly: \(prefs.veganFriendly)
            }
            """)
        } else {
            lines.append("selectedPreferences: null")
        }

        if let ls = req.lifestyle {
            // Only include provided keys to avoid contradicting defaults
            var kv: [String] = []
            if let v = ls.sleepQuality { kv.append("sleepQuality: \(v)") }
            if let v = ls.exerciseFrequency { kv.append("exerciseFrequency: \(v)") }
            if let v = ls.routineDepthPreference { kv.append("routineDepthPreference: \(v)") }
            if let v = ls.sunResponse { kv.append("sunResponse: \(v)") }
            if let v = ls.outdoorHours { kv.append("outdoorHours: \(v)") }
            if let v = ls.smokes { kv.append("smokes: \(v)") }
            if let v = ls.drinksAlcohol { kv.append("drinksAlcohol: \(v)") }
            if let v = ls.fragranceFree { kv.append("fragranceFree: \(v)") }
            if let v = ls.naturalPreference { kv.append("naturalPreference: \(v)") }
            if let v = ls.sensitiveSkin { kv.append("sensitiveSkin: \(v)") }
            lines.append("lifestyle: { \(kv.joined(separator: ", ")) }")
        } else {
            lines.append("lifestyle: null")
        }

        if let depth = routineDepthFallback {
            lines.append("fallbackDepth: \(depth)")
        }
        lines.append("locale: \(req.locale)")
        return lines.joined(separator: "\n")
    }

    /// JSON Schema (exact structure your app expects).
    private static let schemaJSON: String = {
        // Matches the `RoutineResponse` model exactly
        """
        {
          "version": "string",
          "locale": "string",
          "summary": {
            "title": "string",
            "one_liner": "string"
          },
          "routine": {
            "depth": "minimal|standard|detailed",
            "morning": [
              {
                "step": "cleanser|moisturizer|sunscreen|toner|faceSerum|exfoliator|faceMask|facialOil|facialMist|eyeCream|spotTreatment|retinol|vitaminC|niacinamide|faceSunscreen|bodySunscreen|lipBalm|shaveCream|aftershave|shaveGel|bodyLotion|bodyWash|handCream|shampoo|conditioner|hairOil|hairMask|chemicalPeel|micellarWater|makeupRemover|faceWash|cleansingOil|cleansingBalm",
                "name": "string",
                "why": "string",
                "how": "string",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": true,
                  "sensitive_safe": true,
                  "vegan": true,
                  "cruelty_free": true,
                  "avoid_ingredients": ["string"],
                  "prefer_ingredients": ["string"]
                }
              }
            ],
            "evening": [
              {
                "step": "cleanser|moisturizer|sunscreen|toner|faceSerum|exfoliator|faceMask|facialOil|facialMist|eyeCream|spotTreatment|retinol|vitaminC|niacinamide|faceSunscreen|bodySunscreen|lipBalm|shaveCream|aftershave|shaveGel|bodyLotion|bodyWash|handCream|shampoo|conditioner|hairOil|hairMask|chemicalPeel|micellarWater|makeupRemover|faceWash|cleansingOil|cleansingBalm",
                "name": "string",
                "why": "string",
                "how": "string",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": true,
                  "sensitive_safe": true,
                  "vegan": true,
                  "cruelty_free": true,
                  "avoid_ingredients": ["string"],
                  "prefer_ingredients": ["string"]
                }
              }
            ],
            "weekly": [
              {
                "step": "faceSerum",
                "name": "string",
                "why": "string",
                "how": "string",
                "constraints": {
                  "spf": 0,
                  "fragrance_free": true,
                  "sensitive_safe": true,
                  "vegan": true,
                  "cruelty_free": true,
                  "avoid_ingredients": ["string"],
                  "prefer_ingredients": ["string"]
                }
              }
            ]
          },
          "guardrails": {
            "cautions": ["string"],
            "when_to_stop": ["string"],
            "sun_notes": "string"
          },
          "adaptation": {
            "for_skin_type": "string",
            "for_concerns": ["string"],
            "for_preferences": ["string"]
          },
          "product_slots": [
            {
              "slot_id": "string",
              "step": "cleanser|moisturizer|sunscreen|toner|faceSerum|exfoliator|faceMask|facialOil|facialMist|eyeCream|spotTreatment|retinol|vitaminC|niacinamide|faceSunscreen|bodySunscreen|lipBalm|shaveCream|aftershave|shaveGel|bodyLotion|bodyWash|handCream|shampoo|conditioner|hairOil|hairMask|chemicalPeel|micellarWater|makeupRemover|faceWash|cleansingOil|cleansingBalm",
              "time": "AM|PM|Weekly",
              "constraints": {
                "spf": 0,
                "fragrance_free": true,
                "sensitive_safe": true,
                "vegan": true,
                "cruelty_free": true,
                "avoid_ingredients": ["string"],
                "prefer_ingredients": ["string"]
              },
              "notes": "string"
            }
          ]
        }
        """
    }()
}
