//
//  ProductTipsModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation

// MARK: - Product Tip Models

struct ProductTip: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let content: String
    let category: TipCategory
    let productType: ProductType
    let icon: String
    let priority: Int // Higher number = higher priority
    
    init(id: String = UUID().uuidString, title: String, content: String, category: TipCategory, productType: ProductType, icon: String, priority: Int = 1) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.productType = productType
        self.icon = icon
        self.priority = priority
    }
}

enum TipCategory: String, Codable, CaseIterable, Equatable {
    case application = "application"
    case technique = "technique"
    case timing = "timing"
    case benefits = "benefits"
    case commonMistakes = "common_mistakes"
    case proTips = "pro_tips"
    
    var displayName: String {
        switch self {
        case .application: return L10n.Routines.Tips.Category.application
        case .technique: return L10n.Routines.Tips.Category.technique
        case .timing: return L10n.Routines.Tips.Category.timing
        case .benefits: return L10n.Routines.Tips.Category.benefits
        case .commonMistakes: return L10n.Routines.Tips.Category.commonMistakes
        case .proTips: return L10n.Routines.Tips.Category.proTips
        }
    }
    
    var color: String {
        switch self {
        case .application: return "blue"
        case .technique: return "green"
        case .timing: return "orange"
        case .benefits: return "purple"
        case .commonMistakes: return "red"
        case .proTips: return "gold"
        }
    }
}

// MARK: - Tips Data

struct ProductTipsData {
    static var allTips: [ProductTip] {
        [
            // Cleanser Tips
            ProductTip(
                title: L10n.Routines.Tips.Cleanser.GentleCircular.title,
                content: L10n.Routines.Tips.Cleanser.GentleCircular.content,
                category: .technique,
                productType: .cleanser,
                icon: "hand.draw",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Cleanser.DampSkin.title,
                content: L10n.Routines.Tips.Cleanser.DampSkin.content,
                category: .application,
                productType: .cleanser,
                icon: "drop.circle",
                priority: 4
            ),
            ProductTip(
                title: L10n.Routines.Tips.Cleanser.ThirtySecond.title,
                content: L10n.Routines.Tips.Cleanser.ThirtySecond.content,
                category: .timing,
                productType: .cleanser,
                icon: "timer",
                priority: 5
            ),
            ProductTip(
                title: L10n.Routines.Tips.Cleanser.AvoidEye.title,
                content: L10n.Routines.Tips.Cleanser.AvoidEye.content,
                category: .application,
                productType: .cleanser,
                icon: "eye",
                priority: 2
            ),
            ProductTip(
                title: L10n.Routines.Tips.Cleanser.Lukewarm.title,
                content: L10n.Routines.Tips.Cleanser.Lukewarm.content,
                category: .technique,
                productType: .cleanser,
                icon: "thermometer",
                priority: 3
            ),

            // Face Serum Tips
            ProductTip(
                title: L10n.Routines.Tips.Serum.PatDontRub.title,
                content: L10n.Routines.Tips.Serum.PatDontRub.content,
                category: .technique,
                productType: .faceSerum,
                icon: "hand.point.up",
                priority: 4
            ),
            ProductTip(
                title: L10n.Routines.Tips.Serum.WaitAbsorption.title,
                content: L10n.Routines.Tips.Serum.WaitAbsorption.content,
                category: .timing,
                productType: .faceSerum,
                icon: "clock",
                priority: 5
            ),
            ProductTip(
                title: L10n.Routines.Tips.Serum.LessMore.title,
                content: L10n.Routines.Tips.Serum.LessMore.content,
                category: .application,
                productType: .faceSerum,
                icon: "drop",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Serum.TargetAreas.title,
                content: L10n.Routines.Tips.Serum.TargetAreas.content,
                category: .technique,
                productType: .faceSerum,
                icon: "target",
                priority: 2
            ),
            ProductTip(
                title: L10n.Routines.Tips.Serum.MorningEvening.title,
                content: L10n.Routines.Tips.Serum.MorningEvening.content,
                category: .timing,
                productType: .faceSerum,
                icon: "sun.max",
                priority: 3
            ),

            // Moisturizer Tips
            ProductTip(
                title: L10n.Routines.Tips.Moisturizer.Upward.title,
                content: L10n.Routines.Tips.Moisturizer.Upward.content,
                category: .technique,
                productType: .moisturizer,
                icon: "arrow.up",
                priority: 4
            ),
            ProductTip(
                title: L10n.Routines.Tips.Moisturizer.PeaSized.title,
                content: L10n.Routines.Tips.Moisturizer.PeaSized.content,
                category: .application,
                productType: .moisturizer,
                icon: "circle.grid.cross",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Moisturizer.NeckDeco.title,
                content: L10n.Routines.Tips.Moisturizer.NeckDeco.content,
                category: .application,
                productType: .moisturizer,
                icon: "person.crop.rectangle",
                priority: 2
            ),
            ProductTip(
                title: L10n.Routines.Tips.Moisturizer.LockMoisture.title,
                content: L10n.Routines.Tips.Moisturizer.LockMoisture.content,
                category: .technique,
                productType: .moisturizer,
                icon: "lock",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Moisturizer.MorningNight.title,
                content: L10n.Routines.Tips.Moisturizer.MorningNight.content,
                category: .timing,
                productType: .moisturizer,
                icon: "moon",
                priority: 2
            ),

            // Sunscreen Tips
            ProductTip(
                title: L10n.Routines.Tips.Sunscreen.Quarter.title,
                content: L10n.Routines.Tips.Sunscreen.Quarter.content,
                category: .application,
                productType: .sunscreen,
                icon: "spoon",
                priority: 5
            ),
            ProductTip(
                title: L10n.Routines.Tips.Sunscreen.Reapply.title,
                content: L10n.Routines.Tips.Sunscreen.Reapply.content,
                category: .timing,
                productType: .sunscreen,
                icon: "clock.arrow.circlepath",
                priority: 4
            ),
            ProductTip(
                title: L10n.Routines.Tips.Sunscreen.Ears.title,
                content: L10n.Routines.Tips.Sunscreen.Ears.content,
                category: .application,
                productType: .sunscreen,
                icon: "ear",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Sunscreen.WaitMakeup.title,
                content: L10n.Routines.Tips.Sunscreen.WaitMakeup.content,
                category: .timing,
                productType: .sunscreen,
                icon: "paintbrush",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.Sunscreen.YearRound.title,
                content: L10n.Routines.Tips.Sunscreen.YearRound.content,
                category: .benefits,
                productType: .sunscreen,
                icon: "cloud.sun",
                priority: 4
            ),

            // Face Sunscreen Tips (same as sunscreen but with face-specific content)
            ProductTip(
                title: L10n.Routines.Tips.FaceSunscreen.Gentle.title,
                content: L10n.Routines.Tips.FaceSunscreen.Gentle.content,
                category: .technique,
                productType: .faceSunscreen,
                icon: "hand.point.up.braille",
                priority: 4
            ),
            ProductTip(
                title: L10n.Routines.Tips.FaceSunscreen.UnderMakeup.title,
                content: L10n.Routines.Tips.FaceSunscreen.UnderMakeup.content,
                category: .application,
                productType: .faceSunscreen,
                icon: "paintpalette",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.FaceSunscreen.Tzone.title,
                content: L10n.Routines.Tips.FaceSunscreen.Tzone.content,
                category: .technique,
                productType: .faceSunscreen,
                icon: "target",
                priority: 2
            ),
            ProductTip(
                title: L10n.Routines.Tips.FaceSunscreen.NonComedogenic.title,
                content: L10n.Routines.Tips.FaceSunscreen.NonComedogenic.content,
                category: .benefits,
                productType: .faceSunscreen,
                icon: "checkmark.shield",
                priority: 3
            ),
            ProductTip(
                title: L10n.Routines.Tips.FaceSunscreen.Hairline.title,
                content: L10n.Routines.Tips.FaceSunscreen.Hairline.content,
                category: .application,
                productType: .faceSunscreen,
                icon: "arrow.up.and.down.and.arrow.left.and.right",
                priority: 2
            )
        ]
    }
    
    static func getTips(for productType: ProductType) -> [ProductTip] {
        return allTips
            .filter { $0.productType == productType }
            .sorted { $0.priority > $1.priority }
    }
    
    static func getRandomTip(for productType: ProductType) -> ProductTip? {
        let tips = getTips(for: productType)
        return tips.randomElement()
    }
    
    static func getTipsByCategory(for productType: ProductType, category: TipCategory) -> [ProductTip] {
        return allTips
            .filter { $0.productType == productType && $0.category == category }
            .sorted { $0.priority > $1.priority }
    }
}
