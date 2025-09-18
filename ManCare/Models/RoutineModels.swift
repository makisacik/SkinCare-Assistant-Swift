//
//  RoutineModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 18.09.2025.
//

import Foundation
import CoreData

// MARK: - SavedStepDetailModel (Swift Model)

struct SavedStepDetailModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let stepDescription: String
    // iconName is computed from stepType, not stored
    let stepType: String
    let timeOfDay: String
    let why: String?
    let how: String?
    let order: Int

    // Computed property - iconName is derived from stepType, not stored
    var iconName: String {
        guard let productType = ProductType(rawValue: stepType) else {
            return ProductIconManager.getFallbackIcon()
        }
        return ProductIconManager.getIconName(for: productType)
    }

    init(id: UUID = UUID(), title: String, stepDescription: String, stepType: String, timeOfDay: String, why: String? = nil, how: String? = nil, order: Int) {
        self.id = id
        self.title = title
        self.stepDescription = stepDescription
        self.stepType = stepType
        self.timeOfDay = timeOfDay
        self.why = why
        self.how = how
        self.order = order
    }

    init(from entity: SavedStepDetailEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.stepDescription = entity.stepDescription ?? ""
        // iconName is computed from stepType, not stored
        self.stepType = entity.stepType ?? ""
        self.timeOfDay = entity.timeOfDay ?? ""
        self.why = entity.why
        self.how = entity.how
        self.order = Int(entity.order)
    }
}

// MARK: - SavedRoutineModel (Swift Model)

struct SavedRoutineModel: Identifiable, Codable {
    let id: UUID
    let templateId: UUID
    let title: String
    let description: String
    let category: RoutineCategory
    let stepCount: Int
    let duration: String
    let difficulty: RoutineTemplate.Difficulty
    let tags: [String]
    let morningSteps: [String]
    let eveningSteps: [String]

    // Computed property for backward compatibility
    var steps: [String] {
        return morningSteps + eveningSteps
    }
    let benefits: [String]
    let isFeatured: Bool
    let isPremium: Bool
    let savedDate: Date
    let isActive: Bool
    let stepDetails: [SavedStepDetailModel]

    init(from template: RoutineTemplate, isActive: Bool = false) {
        self.id = UUID()
        self.templateId = template.id
        self.title = template.title
        self.description = template.description
        self.category = template.category
        self.stepCount = template.stepCount
        self.duration = template.duration
        self.difficulty = template.difficulty
        self.tags = template.tags
        self.morningSteps = template.morningSteps
        self.eveningSteps = template.eveningSteps
        self.benefits = template.benefits
        self.isFeatured = template.isFeatured
        self.isPremium = template.isPremium
        self.savedDate = Date()
        self.isActive = isActive
        // Create step details from template steps using ProductTypeDatabase
        var allStepDetails: [SavedStepDetailModel] = []

        // Add morning steps
        for (index, stepName) in template.morningSteps.enumerated() {
            let productInfo = ProductTypeDatabase.getInfo(for: stepName)
            allStepDetails.append(SavedStepDetailModel(
                title: productInfo.name,
                stepDescription: productInfo.description,
                stepType: ProductTypeDatabase.getStepType(for: stepName),
                timeOfDay: "morning",
                why: productInfo.why,
                how: productInfo.how,
                order: index
            ))
        }

        // Add evening steps
        for (index, stepName) in template.eveningSteps.enumerated() {
            let productInfo = ProductTypeDatabase.getInfo(for: stepName)
            allStepDetails.append(SavedStepDetailModel(
                title: productInfo.name,
                stepDescription: productInfo.description,
                stepType: ProductTypeDatabase.getStepType(for: stepName),
                timeOfDay: "evening",
                why: productInfo.why,
                how: productInfo.how,
                order: index + template.morningSteps.count
            ))
        }

        self.stepDetails = allStepDetails
    }

    init(templateId: UUID, title: String, description: String, category: RoutineCategory, stepCount: Int, duration: String, difficulty: RoutineTemplate.Difficulty, tags: [String], morningSteps: [String], eveningSteps: [String], benefits: [String], isFeatured: Bool, isPremium: Bool, savedDate: Date, isActive: Bool, stepDetails: [SavedStepDetailModel] = []) {
        self.id = UUID()
        self.templateId = templateId
        self.title = title
        self.description = description
        self.category = category
        self.stepCount = stepCount
        self.duration = duration
        self.difficulty = difficulty
        self.tags = tags
        self.morningSteps = morningSteps
        self.eveningSteps = eveningSteps
        self.benefits = benefits
        self.isFeatured = isFeatured
        self.isPremium = isPremium
        self.savedDate = savedDate
        self.isActive = isActive
        self.stepDetails = stepDetails
    }

    init(from entity: SavedRoutineEntity) {
        self.id = entity.id ?? UUID()
        self.templateId = entity.templateId ?? UUID()
        self.title = entity.title ?? ""
        self.description = entity.routineDescription ?? ""
        self.category = RoutineCategory(rawValue: entity.category ?? "all") ?? .all
        self.stepCount = Int(entity.stepCount)
        self.duration = entity.duration ?? ""
        self.difficulty = RoutineTemplate.Difficulty(rawValue: entity.difficulty ?? "beginner") ?? .beginner
        self.tags = entity.tags as? [String] ?? []
        // For backward compatibility, we'll need to split the steps into morning/evening
        // For now, we'll put all steps in morning and leave evening empty
        let allSteps = entity.steps as? [String] ?? []
        self.morningSteps = allSteps
        self.eveningSteps = []
        self.benefits = entity.benefits as? [String] ?? []
        self.isFeatured = entity.isFeatured
        self.isPremium = entity.isPremium
        self.savedDate = entity.savedDate ?? Date()
        self.isActive = entity.isActive
        // Convert step details from Core Data entities
        self.stepDetails = (entity.stepDetails as? Set<SavedStepDetailEntity>)?.compactMap { stepEntity in
            SavedStepDetailModel(from: stepEntity)
        }.sorted { $0.order < $1.order } ?? []
    }
}
