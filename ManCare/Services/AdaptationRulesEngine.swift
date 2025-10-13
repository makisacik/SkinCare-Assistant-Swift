//
//  AdaptationRulesEngine.swift
//  ManCare
//
//  Pure, stateless rule interpreter for routine adaptations
//

import Foundation

// MARK: - Adaptation Rules Engine

class AdaptationRulesEngine {
    
    // MARK: - Rule Set Loading
    
    /// Load rule set from bundle
    func loadRuleSet(type: AdaptationType) -> AdaptationRuleSet? {
        let filename: String
        
        switch type {
        case .cycle:
            filename = "cycle-default-rules"
        case .seasonal:
            filename = "weather-adaptation-rules"
        case .skinState:
            filename = "skinstate-default-rules"
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ AdaptationRulesEngine: Could not find \(filename).json in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let ruleSet = try decoder.decode(AdaptationRuleSet.self, from: data)
            print("✅ AdaptationRulesEngine: Loaded \(ruleSet.rules.count) rules for \(type.rawValue)")
            return ruleSet
        } catch {
            print("❌ AdaptationRulesEngine: Failed to decode \(filename).json - \(error)")
            return nil
        }
    }
    
    // MARK: - Rule Resolution
    
    /// Resolve adaptation for a single step
    func resolve(
        step: SavedStepDetailModel,
        using rules: [AdaptationRule],
        for contextKey: String
    ) -> StepAdaptation? {
        // Debug logging for essence issues
        print("🔍 [AdaptationRulesEngine] Looking for rule for step: '\(step.title)' (stepType: '\(step.stepType)') in context: '\(contextKey)'")
        
        // Find matching rule for this step's product type and context
        guard let matchingRule = rules.first(where: { rule in
            productTypesMatch(rule.productType, step.stepType) &&
            rule.contextKey.lowercased() == contextKey.lowercased()
        }) else {
            // No adaptation needed - use normal emphasis
            print("⚠️ [AdaptationRulesEngine] No matching rule found for '\(step.stepType)' in context '\(contextKey)'")
            return nil
        }
        
        print("✅ [AdaptationRulesEngine] Found rule: '\(matchingRule.id)' for '\(step.stepType)' -> '\(matchingRule.action.emphasis)'")
        print("📝 [AdaptationRulesEngine] Guidance: '\(matchingRule.action.guidanceTemplate ?? "No guidance")'")
        
        // Build StepAdaptation from rule
        return StepAdaptation(
            stepId: step.id,
            contextKey: contextKey,
            emphasis: matchingRule.action.emphasis,
            guidance: matchingRule.action.guidanceTemplate,
            orderOverride: matchingRule.action.orderPriority,
            warnings: matchingRule.action.warnings,
            origin: .default
        )
    }

    // MARK: - Private Helpers

    /// Flexible product type matching with normalization
    private func productTypesMatch(_ ruleType: String, _ stepType: String) -> Bool {
        print("🔍 [AdaptationRulesEngine] Matching: '\(ruleType)' vs '\(stepType)'")
        
        // 1. Exact match
        if ruleType == stepType {
            print("✅ [AdaptationRulesEngine] Exact match: '\(ruleType)' == '\(stepType)'")
            return true
        }

        // 2. Case-insensitive exact match
        if ruleType.lowercased() == stepType.lowercased() {
            print("✅ [AdaptationRulesEngine] Case-insensitive match: '\(ruleType)' == '\(stepType)'")
            return true
        }

        // 3. Normalize both (remove spaces, underscores) and compare
        let normalizedRule = ruleType.replacingOccurrences(of: " ", with: "")
                                    .replacingOccurrences(of: "_", with: "")
                                    .lowercased()
        let normalizedStep = stepType.replacingOccurrences(of: " ", with: "")
                                    .replacingOccurrences(of: "_", with: "")
                                    .lowercased()

        if normalizedRule == normalizedStep {
            print("✅ [AdaptationRulesEngine] Normalized match: '\(ruleType)' <-> '\(stepType)'")
            return true
        }

        // 4. Check if they map to the same ProductType via alias system
        if let ruleProductType = ProductType(rawValue: ruleType),
           let stepProductType = ProductType(rawValue: stepType),
           ruleProductType == stepProductType {
            print("✅ [AdaptationRulesEngine] ProductType enum match: '\(ruleType)' == '\(stepType)'")
            return true
        }

        // 5. Use alias mapping as last resort
        let ruleMapped = ProductAliasMapping.normalize(ruleType)
        let stepMapped = ProductAliasMapping.normalize(stepType)

        if ruleMapped == stepMapped {
            print("✅ [AdaptationRulesEngine] Alias match: '\(ruleType)' -> \(ruleMapped.rawValue), '\(stepType)' -> \(stepMapped.rawValue)")
            return true
        }

        print("❌ [AdaptationRulesEngine] No match found: '\(ruleType)' vs '\(stepType)'")
        return false
    }

    // MARK: - Rule Merging
    
    /// Merge custom rules with base rules (custom rules override base)
    func mergeRules(
        base: [AdaptationRule],
        custom: [AdaptationRule]
    ) -> [AdaptationRule] {
        var merged: [AdaptationRule] = base
        
        // For each custom rule, replace or add
        for customRule in custom {
            if let index = merged.firstIndex(where: { $0.id == customRule.id }) {
                // Replace existing rule
                merged[index] = customRule
            } else if let index = merged.firstIndex(where: {
                $0.productType == customRule.productType &&
                $0.contextKey == customRule.contextKey
            }) {
                // Replace rule with same product type + context
                merged[index] = customRule
            } else {
                // Add new rule
                merged.append(customRule)
            }
        }
        
        return merged
    }
    
    // MARK: - Validation
    
    /// Validate rule set structure
    func validate(ruleSet: AdaptationRuleSet) -> [String] {
        var errors: [String] = []
        
        // Check for duplicate rules (same product type + context)
        let groupedRules = Dictionary(grouping: ruleSet.rules) { rule in
            "\(rule.productType)_\(rule.contextKey)"
        }
        
        for (key, rules) in groupedRules where rules.count > 1 {
            errors.append("Duplicate rules for \(key): \(rules.count) rules found")
        }
        
        // Check for missing briefings
        let contextKeys = Set(ruleSet.rules.map { $0.contextKey })
        let briefingKeys = Set(ruleSet.briefings.map { $0.contextKey })
        
        let missingBriefings = contextKeys.subtracting(briefingKeys)
        if !missingBriefings.isEmpty {
            errors.append("Missing briefings for contexts: \(missingBriefings.joined(separator: ", "))")
        }
        
        return errors
    }
}

