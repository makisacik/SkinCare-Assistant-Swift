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
            filename = "seasonal-default-rules"
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
        // Find matching rule for this step's product type and context
        guard let matchingRule = rules.first(where: { rule in
            rule.productType.lowercased() == step.stepType.lowercased() &&
            rule.contextKey.lowercased() == contextKey.lowercased()
        }) else {
            // No adaptation needed - use normal emphasis
            return nil
        }
        
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

