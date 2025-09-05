//
//  APIRequestExample.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - API Request Structure Example

/*
 The GPTService sends exactly this structure to the OpenAI Chat Completions API:

 POST https://api.openai.com/v1/chat/completions
 Content-Type: application/json
 Authorization: Bearer YOUR_API_KEY

 {
   "model": "gpt-4o-mini",
   "messages": [
     {
       "role": "system",
       "content": "You are ManCare's skincare co-pilot for men.\nReturn ONLY valid JSON matching the schema exactly. No extra text.\nRules:\n- Safe, realistic, concise.\n- Align to skin type, concerns, main goal, preferences.\n- If info is missing, choose sensible defaults and note them.\n- No brand names or store links; use ingredient-level constraints.\n- Include guardrails (cautions, when_to_stop).\n- Keep language simple/neutral.\n- Locale-aware where needed.\n\nSCHEMA:\n{...json schema...}"
     },
     {
       "role": "user",
       "content": "Generate a routine for this user in EXACT schema. Return JSON only.\n\nselectedSkinType: oily\nselectedConcerns: [\"acne\", \"blackheads\"]\nselectedMainGoal: reduceBreakouts\nselectedPreferences: {\n  fragranceFreeOnly: true,\n  suitableForSensitiveSkin: true,\n  naturalIngredients: false,\n  crueltyFree: true,\n  veganFriendly: false\n}\nlifestyle: null\nlocale: en-US"
     }
   ],
   "temperature": 0.4,
   "response_format": {
     "type": "json_object"
   }
 }

 The API will respond with a JSON object matching the RoutineResponse schema.
 */

// MARK: - Request Builder Example

struct APIRequestBuilder {
    static func buildRequest(
        model: String = "gpt-4o-mini",
        systemPrompt: String,
        userPrompt: String,
        temperature: Double = 0.4
    ) -> [String: Any] {
        return [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user", 
                    "content": userPrompt
                ]
            ],
            "temperature": temperature,
            "response_format": [
                "type": "json_object"
            ]
        ]
    }
}


/* Response example
 
 SCHEMA:
 {
   "version": "string",
   "locale": "string",
   "summary": {
     "title": "string",
     "one_liner": "string"
   },
   "routine": {
     "depth": "minimal|standard|detailed",
     "morning": [ { "step": "cleanser|treatment|moisturizer|sunscreen|optional",
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
     } ],
     "evening": [ { "step": "cleanser|treatment|moisturizer|sunscreen|optional",
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
     } ],
     "weekly":  [ { "step": "optional",
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
     } ]
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
       "step": "cleanser|treatment|moisturizer|sunscreen|optional",
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
       "budget": "low|mid|high",
       "notes": "string"
     }
   ]
 }
    - User Prompt: Generate a routine for this user in EXACT schema. Return JSON only.

 selectedSkinType: normal
 selectedConcerns: ["blackheads"]
 selectedMainGoal: healthierOverall
 selectedPreferences: {
   fragranceFreeOnly: false,
   suitableForSensitiveSkin: false,
   naturalIngredients: false,
   crueltyFree: true,
   veganFriendly: false
 }
 lifestyle: null
 locale: en-US
 📤 Full Request JSON:
 {"messages":[{"role":"system","content":"You are ManCare's skincare co-pilot for men.\nReturn ONLY valid JSON matching the schema exactly. No extra text.\nRules:\n- Safe, realistic, concise.\n- Align to skin type, concerns, main goal, preferences.\n- If info is missing, choose sensible defaults and note them.\n- No brand names or store links; use ingredient-level constraints.\n- Include guardrails (cautions, when_to_stop).\n- Keep language simple\/neutral.\n- Locale-aware where needed.\n\nSCHEMA:\n{\n  \"version\": \"string\",\n  \"locale\": \"string\",\n  \"summary\": {\n    \"title\": \"string\",\n    \"one_liner\": \"string\"\n  },\n  \"routine\": {\n    \"depth\": \"minimal|standard|detailed\",\n    \"morning\": [ { \"step\": \"cleanser|treatment|moisturizer|sunscreen|optional\",\n                   \"name\": \"string\",\n                   \"why\": \"string\",\n                   \"how\": \"string\",\n                   \"constraints\": {\n                     \"spf\": 0,\n                     \"fragrance_free\": true,\n                     \"sensitive_safe\": true,\n                     \"vegan\": true,\n                     \"cruelty_free\": true,\n                     \"avoid_ingredients\": [\"string\"],\n                     \"prefer_ingredients\": [\"string\"]\n                   }\n    } ],\n    \"evening\": [ { \"step\": \"cleanser|treatment|moisturizer|sunscreen|optional\",\n                   \"name\": \"string\",\n                   \"why\": \"string\",\n                   \"how\": \"string\",\n                   \"constraints\": {\n                     \"spf\": 0,\n                     \"fragrance_free\": true,\n                     \"sensitive_safe\": true,\n                     \"vegan\": true,\n                     \"cruelty_free\": true,\n                     \"avoid_ingredients\": [\"string\"],\n                     \"prefer_ingredients\": [\"string\"]\n                   }\n    } ],\n    \"weekly\":  [ { \"step\": \"optional\",\n                   \"name\": \"string\",\n                   \"why\": \"string\",\n                   \"how\": \"string\",\n                   \"constraints\": {\n                     \"spf\": 0,\n                     \"fragrance_free\": true,\n                     \"sensitive_safe\": true,\n                     \"vegan\": true,\n                     \"cruelty_free\": true,\n                     \"avoid_ingredients\": [\"string\"],\n                     \"prefer_ingredients\": [\"string\"]\n                   }\n    } ]\n  },\n  \"guardrails\": {\n    \"cautions\": [\"string\"],\n    \"when_to_stop\": [\"string\"],\n    \"sun_notes\": \"string\"\n  },\n  \"adaptation\": {\n    \"for_skin_type\": \"string\",\n    \"for_concerns\": [\"string\"],\n    \"for_preferences\": [\"string\"]\n  },\n  \"product_slots\": [\n    {\n      \"slot_id\": \"string\",\n      \"step\": \"cleanser|treatment|moisturizer|sunscreen|optional\",\n      \"time\": \"AM|PM|Weekly\",\n      \"constraints\": {\n        \"spf\": 0,\n        \"fragrance_free\": true,\n        \"sensitive_safe\": true,\n        \"vegan\": true,\n        \"cruelty_free\": true,\n        \"avoid_ingredients\": [\"string\"],\n        \"prefer_ingredients\": [\"string\"]\n      },\n      \"budget\": \"low|mid|high\",\n      \"notes\": \"string\"\n    }\n  ]\n}"},{"role":"user","content":"Generate a routine for this user in EXACT schema. Return JSON only.\n\nselectedSkinType: normal\nselectedConcerns: [\"blackheads\"]\nselectedMainGoal: healthierOverall\nselectedPreferences: {\n  fragranceFreeOnly: false,\n  suitableForSensitiveSkin: false,\n  naturalIngredients: false,\n  crueltyFree: true,\n  veganFriendly: false\n}\nlifestyle: null\nlocale: en-US"}],"response_format":{"type":"json_object"},"temperature":0.4,"model":"gpt-4o-mini"}
 📤 End of Request JSON
 ❌ Error generating routine: TimeoutError(message: "Request timed out")
 nw_read_request_report [C1] Receive failed with error "Operation timed out"
 nw_read_request_report [C1] Receive failed with error "Operation timed out"
 nw_read_request_report [C1] Receive failed with error "Operation timed out"
 nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
 
 */
