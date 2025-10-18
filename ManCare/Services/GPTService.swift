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
    public let routineDepth: String?                   // "simple" | "intermediate" | "advanced"
    public let selectedPreferences: PreferencesPayload?
    public let lifestyle: LifestylePayload?
    public let locale: String                          // e.g. "en-US"
    public let customDetails: String?                  // Custom text/details from user
        public let i18nLanguages: [String]?                // e.g. ["en","tr"]

    public init(selectedSkinType: String,
                selectedConcerns: [String],
                selectedMainGoal: String,
                fitzpatrickSkinTone: String,
                ageRange: String,
                region: String,
                routineDepth: String? = nil,
                selectedPreferences: PreferencesPayload?,
                lifestyle: LifestylePayload?,
                locale: String = "en-US",
                customDetails: String? = nil,
                i18nLanguages: [String]? = nil) {
        self.selectedSkinType = selectedSkinType
        self.selectedConcerns = selectedConcerns
        self.selectedMainGoal = selectedMainGoal
        self.fitzpatrickSkinTone = fitzpatrickSkinTone
        self.ageRange = ageRange
        self.region = region
        self.routineDepth = routineDepth
        self.selectedPreferences = selectedPreferences
        self.lifestyle = lifestyle
        self.locale = locale
        self.customDetails = customDetails
            self.i18nLanguages = i18nLanguages
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

    // Shared instance for general use (GPT-4o-mini)
    public static let shared = GPTService(apiKey: Config.openAIAPIKey)

    // Specialized instance for routine creation (GPT-3.5-turbo)
    public static let routineService = createRoutineService(apiKey: Config.openAIAPIKey)

    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Simple cache for similar requests
    private static var responseCache: [String: RoutineResponse] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.mancare.gptcache", attributes: .concurrent)

    /// Inject your API key from Secrets/Keychain/Environment.
    public init(apiKey: String,
                model: String = "gpt-4o-mini",
                session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    /// Create a specialized instance for routine creation (uses GPT-3.5-turbo)
    public static func createRoutineService(apiKey: String) -> GPTService {
        return GPTService(apiKey: apiKey, model: "gpt-3.5-turbo")
    }

    // MARK: Public API

    /// High-level call: builds system+user prompts and returns a typed RoutineResponse.
    func generateRoutine(for request: ManCareRoutineRequest,
                         routineDepthFallback: String? = nil,
                         timeout: TimeInterval = 40,
                         enhanceWithProductInfo: Bool = false) async throws -> RoutineResponse {
        // Check cache first for similar requests
        let cacheKey = createCacheKey(for: request)
        if let cachedResponse = Self.cacheQueue.sync(execute: { Self.responseCache[cacheKey] }) {
            #if DEBUG
            print("🚀 Using cached response for faster delivery")
            #endif
            return cachedResponse
        }

        let system = Self.systemPrompt(schemaJSON: Self.schemaJSON, routineDepth: request.routineDepth)
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
            productSlots: routine.productSlots,
            i18n: routine.i18n
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
        let depth = request.routineDepth ?? "intermediate"
        return "\(request.selectedSkinType)|\(concerns)|\(request.selectedMainGoal)|\(request.fitzpatrickSkinTone)|\(request.ageRange)|\(request.region)|\(depth)|\(prefs)"
    }

    // MARK: - Product Recommendations

    /// Generate product recommendations for each step in a routine
    func generateProductRecommendations(for routine: SavedRoutineModel, locale: String) async throws -> ProductRecommendationResponse {
        print("🛍️ Generating product recommendations for routine: \(routine.title)")

        // Detect country from locale
        let country = Self.detectCountry(from: locale)
        print("🌍 Detected country: \(country) from locale: \(locale)")

        // Build request payload
        let routineSteps = routine.stepDetails.map { step in
            ProductRecommendationRequest.RoutineStepRequest(
                stepId: step.id.uuidString,
                productType: step.stepType,
                stepTitle: step.title,
                stepDescription: step.stepDescription
            )
        }

        let request = ProductRecommendationRequest(
            routineSteps: routineSteps,
            locale: locale,
            country: country
        )

        // Build prompts
        let systemPrompt = Self.productRecommendationSystemPrompt()
        let userPrompt = Self.productRecommendationUserPrompt(from: request)

        // Call GPT API with GPT-4o-mini for cost-effective, reliable recommendations
        print("📤 Requesting product recommendations from GPT-4o-mini...")
        print("⏱️ Using 120 second timeout and 8000 max tokens")
        print("📊 Requesting 2 products per step for \(routineSteps.count) routine steps (= ~\(routineSteps.count * 2) total products)")
        let json = try await completeJSONWithModel(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            model: "gpt-4o-mini",
            timeout: 120,
            maxTokens: 8000
        )

        // Decode response
        do {
            let decoder = JSONDecoder()
            let data = Data(json.utf8)

            #if DEBUG
            print("📄 Raw JSON response (first 500 chars):")
            print(String(json.prefix(500)))
            #endif

            let response = try decoder.decode(ProductRecommendationResponse.self, from: data)

            print("✅ Successfully decoded \(response.recommendations.count) step recommendations")
            for stepRec in response.recommendations {
                print("   - \(stepRec.productType): \(stepRec.products.count) products")
                for product in stepRec.products {
                    print("      • \(product.brand) - \(product.name)")
                }
            }

            return response
        } catch {
            print("❌ Failed to decode ProductRecommendationResponse: \(error)")
            print("📄 Raw JSON that failed to decode:")
            print(json)
            throw GPTServiceError.decodingFailed(String(describing: error))
        }
    }

    /// Detect country from locale string
    private static func detectCountry(from locale: String) -> String {
        let lowercased = locale.lowercased()

        // Common locale patterns
        if lowercased.hasPrefix("tr") {
            return "Turkey"
        } else if lowercased.hasPrefix("en-us") || lowercased.hasPrefix("us") {
            return "United States"
        } else if lowercased.hasPrefix("en-gb") || lowercased.hasPrefix("gb") {
            return "United Kingdom"
        } else if lowercased.hasPrefix("en-ca") || lowercased.hasPrefix("ca") {
            return "Canada"
        } else if lowercased.hasPrefix("en-au") || lowercased.hasPrefix("au") {
            return "Australia"
        } else if lowercased.hasPrefix("de") {
            return "Germany"
        } else if lowercased.hasPrefix("fr") {
            return "France"
        } else if lowercased.hasPrefix("es") {
            return "Spain"
        } else if lowercased.hasPrefix("it") {
            return "Italy"
        } else if lowercased.hasPrefix("ja") || lowercased.hasPrefix("jp") {
            return "Japan"
        } else if lowercased.hasPrefix("ko") || lowercased.hasPrefix("kr") {
            return "South Korea"
        } else if lowercased.hasPrefix("zh") || lowercased.hasPrefix("cn") {
            return "China"
        } else if lowercased.hasPrefix("pt-br") || lowercased.hasPrefix("br") {
            return "Brazil"
        } else if lowercased.hasPrefix("pt") {
            return "Portugal"
        } else if lowercased.hasPrefix("ru") {
            return "Russia"
        } else if lowercased.hasPrefix("ar") {
            return "Argentina"
        } else if lowercased.hasPrefix("mx") {
            return "Mexico"
        } else if lowercased.hasPrefix("in") {
            return "India"
        } else if lowercased.hasPrefix("en") {
            return "United States" // Default English to US
        } else {
            return "International" // Generic fallback
        }
    }

    /// System prompt for product recommendations
    private static func productRecommendationSystemPrompt() -> String {
        return """
        You are an expert skincare product recommender with deep knowledge of global skincare markets, product formulations, and pricing. You have access to comprehensive databases of real skincare products worldwide.

        Your task is to recommend specific, real, currently available skincare products for each step in a user's personalized routine.

        REQUIREMENTS:
        1. For EACH routine step, recommend EXACTLY 2 products from different price ranges to give users options

        2. ONLY recommend REAL, currently available products from established brands in the user's country
           - Verify the product actually exists and is sold in that market
           - Use accurate brand names, product names, and formulations

        3. For each product, provide:
           - Exact brand name (spell correctly)
           - Full official product name
           - 3-5 key active ingredients (use INCI names)
           - Concise reason why this product suits their routine step (1-2 sentences max)
           - Product size (e.g., "50ml", "100ml")
           - Purchase link if available (otherwise omit)
           - Brief 1-sentence product description

        4. If the user's locale is NOT English, provide smart translations:
           - For product names: Keep brand-specific names intact (e.g., "All About Eyes"), but translate generic skincare terms
             Example: "All About Eyes Moisturizer" → "All About Eyes Nemlendirici" (keep "All About Eyes", translate "Moisturizer")
             Example: "Hydrating Facial Cleanser" → "Nemlendirici Yüz Temizleyici" (generic product, fully translate)
           - Translate descriptions and recommendation reasons naturally
           - DO NOT translate ingredient names - keep them in INCI/Latin scientific names (universal standard)
           - DO NOT translate brand names or trademarked product names
           - Ensure translations are culturally appropriate

        6. Quality standards:
           - Ensure products match the step's ProductType and purpose precisely
           - Prioritize dermatologist-tested and well-reviewed products
           - Include a mix of well-known and specialized brands
           - Ensure product recommendations complement each other in the routine

        RESPONSE FORMAT:
        Return compact JSON with this structure:
        {
          "recommendations": [
            {
              "stepId": "uuid-string",
              "productType": "cleanser",
              "products": [
                {
                  "brand": "CeraVe",
                  "name": "Hydrating Facial Cleanser",
                  "nameTranslated": "Nemlendirici Yüz Temizleyici" (only if locale != en; translate generic terms only),
                  "ingredients": ["Ceramides", "Hyaluronic Acid", "Glycerin"],
                  "reason": "Maintains skin barrier with gentle cleansing",
                  "reasonTranslated": "Cildin doğal bariyerini koruyarak nazikçe temizler" (only if locale != en),
                  "size": "236ml",
                  "purchaseLink": null,
                  "description": "Gentle cleanser for all skin types",
                  "descriptionTranslated": "Tüm cilt tipleri için nazik temizleyici" (only if locale != en)
                },
                {
                  "brand": "Clinique",
                  "name": "All About Eyes",
                  "nameTranslated": "All About Eyes" (keep brand product names intact),
                  "ingredients": ["Caffeine", "Peptides", "Hyaluronic Acid"],
                  "reason": "Reduces puffiness and dark circles",
                  "reasonTranslated": "Şişlikleri ve göz altı morlukları azaltır",
                  "size": "15ml",
                  "purchaseLink": null,
                  "description": "Refreshing eye cream for all skin types",
                  "descriptionTranslated": "Tüm cilt tipleri için ferahlatıcı göz kremi"
                }
              ]
            }
          ]
        }

        IMPORTANT: Keep responses concise. Use 1 sentence for reasons and descriptions. Omit fields like purchaseLink if unknown (use null). Be thorough but brief to ensure complete JSON response.
        """
    }

    /// User prompt for product recommendations
    private static func productRecommendationUserPrompt(from request: ProductRecommendationRequest) -> String {
        var prompt = """
        Generate product recommendations for my skincare routine.

        USER LOCATION:
        - Country: \(request.country)
        - Locale: \(request.locale)

        ROUTINE STEPS TO RECOMMEND FOR:
        """

        for (index, step) in request.routineSteps.enumerated() {
            prompt += """


            \(index + 1). Step ID: \(step.stepId)
               Product Type: \(step.productType)
               Title: \(step.stepTitle)
               Description: \(step.stepDescription)
            """
        }

        prompt += """


        Please provide 2 product recommendations for EACH step above.
        Ensure products are available in \(request.country) and provide variety in options.
        """

        // Add translation instruction
        if !request.locale.lowercased().hasPrefix("en") {
            prompt += """


            IMPORTANT: Since the user's locale is \(request.locale), please provide smart translations:
            - For PRODUCT NAMES: Keep brand-specific product names intact (e.g., "All About Eyes" stays "All About Eyes")
              BUT translate generic skincare terms (e.g., "Moisturizer" → "Nemlendirici", "Cleanser" → "Temizleyici")
              Example: "All About Eyes Moisturizer" should become "All About Eyes Nemlendirici" in Turkish
              Example: "Hydrating Facial Cleanser" should become "Nemlendirici Yüz Temizleyici" in Turkish
            - Translate descriptions and recommendation reasons fully to the target language
            - DO NOT translate ingredient names - keep them in INCI/Latin scientific names (these are universal)
            - DO NOT translate brand names or trademarked product names
            - Include English version in base fields and translated versions in *Translated fields
            - Omit ingredientsTranslated field entirely (ingredients stay universal)
            """
        }

        return prompt
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
        let max_tokens: Int?

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

    /// Sends a chat completion request forcing JSON output with a custom model and returns the raw JSON string.
    public func completeJSONWithModel(systemPrompt: String,
                                       userPrompt: String,
                                       model: String,
                                       timeout: TimeInterval,
                                       maxTokens: Int? = nil) async throws -> String {
        let body = ChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: 0.1,
            response_format: .init(type: "json_object"),
            max_tokens: maxTokens
        )

        let encoder = JSONEncoder()
        guard let payload = try? encoder.encode(body) else {
            throw GPTServiceError.encodingFailed
        }

        // Log the request being sent
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

                // For large responses, skip pre-validation and let the actual decoder handle it
                // This avoids false negatives with complex JSON structures
                return content
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

    /// Sends a chat completion request forcing JSON output and returns the raw JSON string.
    public func completeJSON(systemPrompt: String,
                              userPrompt: String,
                              timeout: TimeInterval) async throws -> String {
        let body = ChatRequest(
            model: self.model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: 0.1,
            response_format: .init(type: "json_object"),
            max_tokens: nil
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
    private static func systemPrompt(schemaJSON: String, routineDepth: String? = nil) -> String {
        // Get routine depth guidance
        let depthGuidance: String
        if let depth = routineDepth {
            switch depth {
            case "simple":
                depthGuidance = """

                ROUTINE DEPTH: SIMPLE (3-4 steps per routine)
                - Morning: cleanser, moisturizer, sunscreen (+ optional faceSerum)
                - Evening: cleanser, faceSerum, moisturizer
                - Keep it minimal and focused on essentials
                - NO weekly steps needed
                """
            case "intermediate":
                depthGuidance = """

                ROUTINE DEPTH: INTERMEDIATE (5-6 steps per routine)
                - Morning: cleanser, toner or essence, faceSerum, moisturizer, eyeCream (optional), sunscreen
                - Evening: cleanser, toner, faceSerum, eyeCream (optional), moisturizer
                - Balanced approach with key treatments
                - NO weekly steps needed
                """
            case "advanced":
                depthGuidance = """

                ROUTINE DEPTH: ADVANCED (7-9 steps per routine)
                - Morning: cleanser, toner, essence, multiple serums, eyeCream, moisturizer, facialOil (optional), sunscreen
                - Evening: cleansingOil, cleanser, toner, essence, faceSerum, eyeCream, moisturizer, facialOil
                - Comprehensive multi-step routine with layered treatments
                - NO weekly steps needed
                """
            default:
                depthGuidance = "\n\nROUTINE DEPTH: INTERMEDIATE (5-6 steps per routine) - NO weekly steps needed"
            }
        } else {
            depthGuidance = "\n\nROUTINE DEPTH: INTERMEDIATE (5-6 steps per routine) - Default if not specified - NO weekly steps needed"
        }

        return """
        You are a skincare expert. Return ONLY valid JSON matching the schema exactly.

        Rules: Safe, realistic, comprehensive within depth constraints. Align to skin type, concerns, main goal, Fitzpatrick skin tone, age range, region, and preferences. Age-appropriate recommendations. No brand names. Include guardrails. DO NOT include weekly steps - only morning and evening routines.\(depthGuidance)

        \(Self.getProductTypeInfo())

        LANGUAGE OUTPUT:
        - The primary response fields (summary, routine, guardrails) should be in the request locale language.
        - MANDATORY: Always include an "i18n" object with translations for the languages specified in the request (e.g., when "i18n:en,tr" is provided).
        - The i18n object structure: for each language code (e.g., "en", "tr"), provide an object containing:
          * "routine": {"title": "...", "one_liner": "..."}
          * "steps": {"morning": [...], "evening": [...], "weekly": [...]}
          * "guardrails": {"cautions": [...], "when_to_stop": [...], "sun_notes": "..."}
        - This is CRITICAL for performance - do not skip the i18n field.

        CRITICAL:
        1. Use exact camelCase product type names (e.g., "cleansingOil" not "oil cleanser", "faceSerum" not "serum", "eyeCream" not "eye cream")
        2. "name" field: descriptive names like "Gentle Cleanser", "Vitamin C Serum"
        3. "step" field: must match available product types exactly
        4. ALWAYS include "constraints" field for every step (use empty object {} if no specific constraints)

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

        // Add routine depth (use from request or fallback)
        if let depth = req.routineDepth ?? routineDepthFallback {
            parts.append("RoutineLevel:\(depth)")
        }

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

        // Add custom details if provided
        if let customDetails = req.customDetails, !customDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("CustomDetails:\(customDetails.trimmingCharacters(in: .whitespacesAndNewlines))")
        }

        parts.append("Locale:\(req.locale)")
        if let langs = req.i18nLanguages, !langs.isEmpty {
            parts.append("i18n:\(langs.joined(separator: ","))")
        }
        return parts.joined(separator: " ")
    }

    /// JSON Schema (minimal for faster processing).
    private static let schemaJSON: String = {
        // Minimal schema to reduce token count
        return """
        {
          "version": "string (required)",
          "locale": "string (required)",
          "summary": {"title": "string", "one_liner": "string"},
          "routine": {
            "depth": "simple|intermediate|advanced",
            "morning": [{"step": "cleanser|toner|essence|faceSerum|eyeCream|moisturizer|sunscreen", "name": "string", "why": "string", "how": "string", "constraints": {}}],
            "evening": [{"step": "cleansingOil|cleanser|toner|essence|faceSerum|exfoliator|eyeCream|moisturizer|facialOil", "name": "string", "why": "string", "how": "string", "constraints": {}}]
          },
          "guardrails": {"cautions": ["string"], "when_to_stop": ["string"], "sun_notes": "string"},
          "adaptation": {"for_skin_type": "string", "for_concerns": ["string"], "for_preferences": ["string"]},
          "product_slots": [],
          "i18n": {
            "REQUIRED - MUST INCLUDE ALL LANGUAGES FROM REQUEST": "For each language code provided in i18n request parameter",
            "example_structure": {
              "en": {"routine": {"title": "...", "one_liner": "..."}, "steps": {"morning": [{"name": "...", "why": "...", "how": "..."}], "evening": [...]}, "guardrails": {"cautions": [...], "when_to_stop": [...], "sun_notes": "..."}},
              "tr": {"routine": {"title": "...", "one_liner": "..."}, "steps": {"morning": [...], "evening": [...]}, "guardrails": {...}}
            }
          }
        }
        """
    }()
}
