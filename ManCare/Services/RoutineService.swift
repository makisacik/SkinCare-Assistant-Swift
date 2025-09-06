//
//  RoutineService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Lifestyle Information

struct LifestyleInfo: Codable {
    let sleepQuality: SleepQuality?
    let exerciseFrequency: ExerciseFrequency?
    let routineDepthPreference: RoutineDepthPreference?
    let sunResponse: SunResponse?
    let outdoorHours: Int?
    let smokes: Bool?
    let drinksAlcohol: Bool?
    let fragranceFree: Bool?
    let naturalPreference: Bool?
    let sensitiveSkin: Bool?
}

enum SleepQuality: String, Codable, CaseIterable {
    case poor, average, good
}

enum ExerciseFrequency: String, Codable, CaseIterable {
    case none, oneToTwo, threeToFour, fivePlus
}

enum RoutineDepthPreference: String, Codable, CaseIterable {
    case minimal, standard, detailed
}

enum SunResponse: String, Codable, CaseIterable {
    case rarely, sometimes, easily
}

// MARK: - Routine Service

class RoutineService: ObservableObject {
    static let shared = RoutineService()
    
    private init() {}
    
    // MARK: - System Prompt
    
    private let systemPrompt = """
    You are a professional skincare expert and dermatologist with extensive knowledge of men's skincare routines. Your expertise includes understanding different skin types, common concerns, and effective treatment approaches.

    Your task is to generate a comprehensive, personalized skincare routine based on the user's specific needs, preferences, and lifestyle factors.

    Guidelines:
    1. Always prioritize skin health and safety
    2. Consider the user's skin type, concerns, and main goals
    3. Respect their preferences (fragrance-free, sensitive skin, etc.)
    4. Provide clear explanations for each step
    5. Include appropriate guardrails and cautions
    6. Suggest realistic, achievable routines
    7. Consider lifestyle factors that might affect skin health

    Return your response as a valid JSON object matching the RoutineResponse structure.
    """
    
    // MARK: - Prompt Generation
    
    func generateUserPrompt(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo? = nil,
        locale: String = "en-US"
    ) -> String {
        var prompt = """
        Generate a routine for this user.

        selectedSkinType: \(skinType.rawValue)
        selectedConcerns: [\(concerns.map { $0.rawValue }.joined(separator: ", "))]
        selectedMainGoal: \(mainGoal.rawValue)
        selectedPreferences: {
          fragranceFreeOnly: \(preferences?.fragranceFreeOnly ?? false),
          suitableForSensitiveSkin: \(preferences?.suitableForSensitiveSkin ?? false),
          naturalIngredients: \(preferences?.naturalIngredients ?? false),
          crueltyFree: \(preferences?.crueltyFree ?? false),
          veganFriendly: \(preferences?.veganFriendly ?? false)
        }
        """
        
        if let lifestyle = lifestyle {
            prompt += "\nlifestyle: {"
            
            if let sleepQuality = lifestyle.sleepQuality {
                prompt += "\n  sleepQuality: \(sleepQuality.rawValue),"
            }
            if let exerciseFrequency = lifestyle.exerciseFrequency {
                prompt += "\n  exerciseFrequency: \(exerciseFrequency.rawValue),"
            }
            if let routineDepthPreference = lifestyle.routineDepthPreference {
                prompt += "\n  routineDepthPreference: \(routineDepthPreference.rawValue),"
            }
            if let sunResponse = lifestyle.sunResponse {
                prompt += "\n  sunResponse: \(sunResponse.rawValue),"
            }
            if let outdoorHours = lifestyle.outdoorHours {
                prompt += "\n  outdoorHours: \(outdoorHours),"
            }
            if let smokes = lifestyle.smokes {
                prompt += "\n  smokes: \(smokes),"
            }
            if let drinksAlcohol = lifestyle.drinksAlcohol {
                prompt += "\n  drinksAlcohol: \(drinksAlcohol),"
            }
            if let fragranceFree = lifestyle.fragranceFree {
                prompt += "\n  fragranceFree: \(fragranceFree),"
            }
            if let naturalPreference = lifestyle.naturalPreference {
                prompt += "\n  naturalPreference: \(naturalPreference),"
            }
            if let sensitiveSkin = lifestyle.sensitiveSkin {
                prompt += "\n  sensitiveSkin: \(sensitiveSkin)"
            }
            
            prompt += "\n}"
        }
        
        prompt += "\nlocale: \(locale)"
        
        return prompt
    }
    
    // MARK: - API Call
    
    func generateRoutine(
        skinType: SkinType,
        concerns: Set<Concern>,
        mainGoal: MainGoal,
        preferences: Preferences?,
        lifestyle: LifestyleInfo? = nil,
        apiKey: String
    ) async throws -> RoutineResponse {
        
        let userPrompt = generateUserPrompt(
            skinType: skinType,
            concerns: concerns,
            mainGoal: mainGoal,
            preferences: preferences,
            lifestyle: lifestyle
        )
        
        return try await callChatGPTAPI(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            apiKey: apiKey
        )
    }
    
    // MARK: - ChatGPT API Integration
    
    private func callChatGPTAPI(
        systemPrompt: String,
        userPrompt: String,
        apiKey: String
    ) async throws -> RoutineResponse {
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw RoutineServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatGPTRequest(
            model: "gpt-4o",
            messages: [
                ChatGPTMessage(role: "system", content: systemPrompt),
                ChatGPTMessage(role: "user", content: userPrompt)
            ],
            temperature: 0.4,
            responseFormat: ChatGPTResponseFormat(type: "json_object")
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw RoutineServiceError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RoutineServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw RoutineServiceError.apiError(httpResponse.statusCode)
        }
        
        do {
            let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            guard let content = chatGPTResponse.choices.first?.message.content else {
                throw RoutineServiceError.noContent
            }
            
            guard let jsonData = content.data(using: .utf8) else {
                throw RoutineServiceError.invalidJSON
            }
            
            let routineResponse = try JSONDecoder().decode(RoutineResponse.self, from: jsonData)
            return routineResponse
            
        } catch {
            if error is RoutineServiceError {
                throw error
            } else {
                throw RoutineServiceError.decodingError
            }
        }
    }
}

// MARK: - ChatGPT API Models

private struct ChatGPTRequest: Codable {
    let model: String
    let messages: [ChatGPTMessage]
    let temperature: Double
    let responseFormat: ChatGPTResponseFormat
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case responseFormat = "response_format"
    }
}

private struct ChatGPTMessage: Codable {
    let role: String
    let content: String
}

private struct ChatGPTResponseFormat: Codable {
    let type: String
}

private struct ChatGPTResponse: Codable {
    let choices: [ChatGPTChoice]
}

private struct ChatGPTChoice: Codable {
    let message: ChatGPTMessage
}

// MARK: - Errors

enum RoutineServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case invalidResponse
    case apiError(Int)
    case noContent
    case invalidJSON
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code):
            return "API error with status code: \(code)"
        case .noContent:
            return "No content in API response"
        case .invalidJSON:
            return "Invalid JSON in response"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
