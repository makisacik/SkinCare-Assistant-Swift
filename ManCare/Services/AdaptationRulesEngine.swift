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

    /// Resolve adaptation for a single step (unified method)
    func resolve(
        step: SavedStepDetailModel,
        using rules: [AdaptationRule],
        for contextKey: String,
        timeOfDay: TimeOfDay? = nil,
        activeContexts: [String]? = nil
    ) -> StepAdaptation? {
        // Try new format first if contexts are provided
        if let contexts = activeContexts, let tod = timeOfDay {
            if let adaptation = resolveNewFormat(step: step, rules: rules, activeContexts: contexts, timeOfDay: tod) {
                return adaptation
            }
        }

        // Fall back to legacy format
        return resolveLegacyFormat(step: step, rules: rules, contextKey: contextKey)
    }

    /// Resolve adaptation using legacy format (cycle rules)
    private func resolveLegacyFormat(
        step: SavedStepDetailModel,
        rules: [AdaptationRule],
        contextKey: String
    ) -> StepAdaptation? {
        print("🔍 [AdaptationRulesEngine] Looking for legacy rule for step: '\(step.title)' (stepType: '\(step.stepType)') in context: '\(contextKey)'")
        print("   📋 Step ID: \(step.id)")
        print("   📋 Title (may be localized): '\(step.title)'")
        print("   📋 StepType (MUST BE ENGLISH): '\(step.stepType)' ⚠️ CHECK THIS")

        // Find matching rule for this step's product type and context
        guard let matchingRule = rules.first(where: { rule in
            rule.isLegacyFormat &&
            productTypesMatch(rule.productType ?? "", step.stepType) &&
            rule.contextKey?.lowercased() == contextKey.lowercased()
        }) else {
            print("⚠️ [AdaptationRulesEngine] No matching legacy rule found for '\(step.stepType)' in context '\(contextKey)'")
            return nil
        }

        guard let action = matchingRule.action else { return nil }

        print("✅ [AdaptationRulesEngine] Found legacy rule: '\(matchingRule.id)' for '\(step.stepType)' -> '\(action.emphasis)'")

        // Get localized guidance and warnings
        let localizedGuidance = getLocalizedGuidance(from: action)
        let localizedWarnings = getLocalizedWarnings(from: action)

        print("📝 [AdaptationRulesEngine] Guidance: '\(localizedGuidance ?? "No guidance")'")

        // Build StepAdaptation from rule
        return StepAdaptation(
            stepId: step.id,
            contextKey: contextKey,
            emphasis: action.emphasis,
            guidance: localizedGuidance,
            orderOverride: action.orderPriority,
            warnings: localizedWarnings,
            origin: .default
        )
    }

    /// Get localized guidance from rule action
    private func getLocalizedGuidance(from action: RuleAction) -> String? {
        // Try i18n key first
        if let guidanceKey = action.i18n?.guidanceKey {
            let localized = L10n.Adaptations.guidance(guidanceKey)
            // If localization returns the key itself, it means translation is missing
            if localized != guidanceKey {
                return localized
            }
        }

        // Fall back to legacy template
        return action.guidanceTemplate
    }

    /// Get localized warnings from rule action
    private func getLocalizedWarnings(from action: RuleAction) -> [String] {
        // Try i18n keys first
        if let warningKeys = action.i18n?.warningKeys, !warningKeys.isEmpty {
            let localized = warningKeys.map { L10n.Adaptations.warning($0) }
            // Only use if at least one translation succeeded
            if localized.contains(where: { !warningKeys.contains($0) }) {
                return localized
            }
        }

        // Fall back to legacy warnings
        return action.warnings
    }

    /// Resolve adaptation using new format v1.1 (weather rules)
    private func resolveNewFormat(
        step: SavedStepDetailModel,
        rules: [AdaptationRule],
        activeContexts: [String],
        timeOfDay: TimeOfDay
    ) -> StepAdaptation? {
        print("🔍 [AdaptationRulesEngine] Looking for new format rules for step: '\(step.title)' (stepType: '\(step.stepType)') in contexts: \(activeContexts)")
        print("   📋 Step ID: \(step.id)")
        print("   📋 Title (may be localized): '\(step.title)'")
        print("   📋 StepType (MUST BE ENGLISH): '\(step.stepType)' ⚠️ CHECK THIS")

        // Find all matching rules
        let matchingRules = rules.filter { rule in
            guard rule.isNewFormat else { return false }

            // Check appliesTo matches time of day
            guard let appliesTo = rule.appliesTo else { return false }
            let todMatch = appliesTo == "both" ||
                          (appliesTo == "am" && timeOfDay == .morning) ||
                          (appliesTo == "pm" && timeOfDay == .evening)
            guard todMatch else { return false }

            // Check all when contexts are active
            guard let when = rule.when else { return false }
            let contextsMatch = when.allSatisfy { context in
                activeContexts.contains(context)
            }
            guard contextsMatch else { return false }

            // Check target kinds match step type
            guard let target = rule.target else { return false }
            return target.kinds.contains { kind in
                productTypesMatch(kind, step.stepType)
            }
        }

        guard !matchingRules.isEmpty else {
            print("⚠️ [AdaptationRulesEngine] No matching new format rules found")
            return nil
        }

        // Sort by priority (highest first)
        let sortedRules = matchingRules.sorted { ($0.effects?.priority ?? 0) > ($1.effects?.priority ?? 0) }

        // Apply conflict resolution: suppress > reduce > emphasize > normal
        var finalEmphasis: StepEmphasis = .normal
        var finalGuidance: String? = nil
        var finalWarnings: [String] = []
        var finalOrderPriority: Int? = nil

        for rule in sortedRules {
            guard let effects = rule.effects else { continue }

            print("✅ [AdaptationRulesEngine] Found new rule: '\(rule.id)' priority: \(effects.priority)")

            // Suppress wins over everything
            if effects.suppress == true {
                finalEmphasis = .skip
                finalGuidance = effects.note
                print("🚫 [AdaptationRulesEngine] Rule '\(rule.id)' suppresses step")
                break
            }

            // Apply emphasis if not already set to skip
            if finalEmphasis != .skip, let emphasis = effects.emphasis {
                // Priority order: skip > reduce > emphasize > normal
                if shouldOverrideEmphasis(current: finalEmphasis, new: emphasis) {
                    finalEmphasis = emphasis
                }
            }

            // Accumulate notes (localized if i18n key available)
            let localizedNote = getLocalizedNote(from: effects)
            if let note = localizedNote {
                if finalGuidance == nil {
                    finalGuidance = note
                } else {
                    finalGuidance? += " " + note
                }
            }

            // Use first order priority
            if finalOrderPriority == nil, let priority = effects.priority as Int? {
                // Map priority to order (higher priority = earlier in routine)
                finalOrderPriority = 100 - (priority / 10)
            }
        }

        print("📝 [AdaptationRulesEngine] Final emphasis: \(finalEmphasis), guidance: '\(finalGuidance ?? "none")'")

        // Build StepAdaptation
        return StepAdaptation(
            stepId: step.id,
            contextKey: activeContexts.joined(separator: ","),
            emphasis: finalEmphasis,
            guidance: finalGuidance,
            orderOverride: finalOrderPriority,
            warnings: finalWarnings,
            origin: .default
        )
    }

    /// Get localized note from rule effects
    private func getLocalizedNote(from effects: RuleEffects) -> String? {
        // Try i18n key first
        if let noteKey = effects.i18n?.noteKey {
            let localized = L10n.Adaptations.note(noteKey)
            // If localization returns the key itself, it means translation is missing
            if localized != noteKey {
                return localized
            }
        }

        // Fall back to legacy note
        return effects.note
    }

    /// Determine if new emphasis should override current emphasis
    private func shouldOverrideEmphasis(current: StepEmphasis, new: StepEmphasis) -> Bool {
        let priorityOrder: [StepEmphasis] = [.skip, .reduce, .emphasize, .normal]
        guard let currentIndex = priorityOrder.firstIndex(of: current),
              let newIndex = priorityOrder.firstIndex(of: new) else {
            return false
        }
        return newIndex < currentIndex
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
        // For legacy rules: group by productType + contextKey
        // For new rules: group by target kinds + when contexts
        let groupedRules = Dictionary(grouping: ruleSet.rules) { rule in
            if rule.isLegacyFormat {
                return "\(rule.productType ?? "unknown")_\(rule.contextKey ?? "unknown")"
            } else if rule.isNewFormat {
                let kinds = rule.target?.kinds.joined(separator: ",") ?? "unknown"
                let contexts = rule.when?.joined(separator: ",") ?? "unknown"
                return "\(kinds)_\(contexts)"
            }
            return "invalid_rule"
        }

        for (key, rules) in groupedRules where rules.count > 1 {
            // Don't report duplicates for "invalid_rule" group
            if key != "invalid_rule" {
                errors.append("Duplicate rules for \(key): \(rules.count) rules found")
            }
        }

        // Check for missing briefings
        // Legacy rules have contextKey, new rules have when array
        let contextKeys = Set(ruleSet.rules.compactMap { rule -> [String]? in
            if rule.isLegacyFormat {
                return rule.contextKey.map { [$0] }
            } else if rule.isNewFormat {
                return rule.when
            }
            return nil
        }.flatMap { $0 })
        
        let briefingKeys = Set(ruleSet.briefings.map { $0.contextKey })

        let missingBriefings = contextKeys.subtracting(briefingKeys)
        if !missingBriefings.isEmpty {
            errors.append("Missing briefings for contexts: \(missingBriefings.joined(separator: ", "))")
        }

        return errors
    }
}

