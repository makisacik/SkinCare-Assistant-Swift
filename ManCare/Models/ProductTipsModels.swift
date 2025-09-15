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
        case .application: return "Application"
        case .technique: return "Technique"
        case .timing: return "Timing"
        case .benefits: return "Benefits"
        case .commonMistakes: return "Common Mistakes"
        case .proTips: return "Pro Tips"
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
    static let allTips: [ProductTip] = [
        // Cleanser Tips
        ProductTip(
            title: "Gentle Circular Motion",
            content: "Use gentle circular motions when massaging your cleanser. This helps remove dirt and oil without irritating your skin.",
            category: .technique,
            productType: .cleanser,
            icon: "hand.draw",
            priority: 3
        ),
        ProductTip(
            title: "Damp Skin First",
            content: "Always apply cleanser to damp skin. This helps the product spread evenly and work more effectively.",
            category: .application,
            productType: .cleanser,
            icon: "drop.circle",
            priority: 4
        ),
        ProductTip(
            title: "30-Second Rule",
            content: "Massage your cleanser for at least 30 seconds. This gives it time to break down makeup, sunscreen, and impurities.",
            category: .timing,
            productType: .cleanser,
            icon: "timer",
            priority: 5
        ),
        ProductTip(
            title: "Avoid Eye Area",
            content: "Be careful around the delicate eye area. Use a separate gentle eye makeup remover for that region.",
            category: .application,
            productType: .cleanser,
            icon: "eye",
            priority: 2
        ),
        ProductTip(
            title: "Lukewarm Water",
            content: "Rinse with lukewarm water. Hot water can strip your skin of natural oils, while cold water won't remove the cleanser effectively.",
            category: .technique,
            productType: .cleanser,
            icon: "thermometer",
            priority: 3
        ),
        
        // Face Serum Tips
        ProductTip(
            title: "Pat, Don't Rub",
            content: "Gently pat your serum into your skin rather than rubbing. This helps the active ingredients penetrate better.",
            category: .technique,
            productType: .faceSerum,
            icon: "hand.point.up",
            priority: 4
        ),
        ProductTip(
            title: "Wait for Absorption",
            content: "Wait 1-2 minutes for your serum to fully absorb before applying moisturizer. This prevents pilling and ensures maximum effectiveness.",
            category: .timing,
            productType: .faceSerum,
            icon: "clock",
            priority: 5
        ),
        ProductTip(
            title: "Less is More",
            content: "Use only 2-3 drops of serum. More product doesn't mean better results and can cause irritation.",
            category: .application,
            productType: .faceSerum,
            icon: "drop",
            priority: 3
        ),
        ProductTip(
            title: "Target Problem Areas",
            content: "Focus on areas that need the most attention, like fine lines, dark spots, or areas of concern.",
            category: .technique,
            productType: .faceSerum,
            icon: "target",
            priority: 2
        ),
        ProductTip(
            title: "Morning vs Evening",
            content: "Use vitamin C serums in the morning and retinol serums at night for optimal results.",
            category: .timing,
            productType: .faceSerum,
            icon: "sun.max",
            priority: 3
        ),
        
        // Moisturizer Tips
        ProductTip(
            title: "Upward Motion",
            content: "Apply moisturizer using upward, outward motions. This helps fight gravity and keeps your skin looking lifted.",
            category: .technique,
            productType: .moisturizer,
            icon: "arrow.up",
            priority: 4
        ),
        ProductTip(
            title: "Pea-Sized Amount",
            content: "A pea-sized amount is usually enough for your face. Too much can clog pores and feel heavy.",
            category: .application,
            productType: .moisturizer,
            icon: "circle.grid.cross",
            priority: 3
        ),
        ProductTip(
            title: "Neck and Décolletage",
            content: "Don't forget your neck and décolletage! These areas show signs of aging just like your face.",
            category: .application,
            productType: .moisturizer,
            icon: "person.crop.rectangle",
            priority: 2
        ),
        ProductTip(
            title: "Lock in Moisture",
            content: "Apply moisturizer while your skin is still slightly damp from cleansing. This helps lock in extra moisture.",
            category: .technique,
            productType: .moisturizer,
            icon: "lock",
            priority: 3
        ),
        ProductTip(
            title: "Morning vs Night",
            content: "Use lighter moisturizers in the morning and richer ones at night when your skin repairs itself.",
            category: .timing,
            productType: .moisturizer,
            icon: "moon",
            priority: 2
        ),
        
        // Sunscreen Tips
        ProductTip(
            title: "Quarter Teaspoon Rule",
            content: "Use about a quarter teaspoon of sunscreen for your face. This ensures you get the full SPF protection.",
            category: .application,
            productType: .sunscreen,
            icon: "spoon",
            priority: 5
        ),
        ProductTip(
            title: "Reapply Every 2 Hours",
            content: "Reapply sunscreen every 2 hours when outdoors. Even water-resistant formulas need regular reapplication.",
            category: .timing,
            productType: .sunscreen,
            icon: "clock.arrow.circlepath",
            priority: 4
        ),
        ProductTip(
            title: "Don't Forget Ears",
            content: "Apply sunscreen to your ears, neck, and any exposed skin. These areas are often forgotten but still need protection.",
            category: .application,
            productType: .sunscreen,
            icon: "ear",
            priority: 3
        ),
        ProductTip(
            title: "Wait Before Makeup",
            content: "Wait 2-3 minutes after applying sunscreen before putting on makeup. This prevents pilling and ensures even coverage.",
            category: .timing,
            productType: .sunscreen,
            icon: "paintbrush",
            priority: 3
        ),
        ProductTip(
            title: "Year-Round Protection",
            content: "Wear sunscreen every day, even in winter and on cloudy days. UV rays can penetrate clouds and cause damage.",
            category: .benefits,
            productType: .sunscreen,
            icon: "cloud.sun",
            priority: 4
        ),
        
        // Face Sunscreen Tips (same as sunscreen but with face-specific content)
        ProductTip(
            title: "Gentle Application",
            content: "Use gentle patting motions when applying face sunscreen. This prevents tugging on delicate facial skin.",
            category: .technique,
            productType: .faceSunscreen,
            icon: "hand.point.up.braille",
            priority: 4
        ),
        ProductTip(
            title: "Under Makeup",
            content: "Face sunscreen works great under makeup. Look for formulas labeled 'primer' or 'makeup-friendly'.",
            category: .application,
            productType: .faceSunscreen,
            icon: "paintpalette",
            priority: 3
        ),
        ProductTip(
            title: "T-Zone Focus",
            content: "Pay extra attention to your T-zone (forehead, nose, chin) as these areas tend to be oilier and need more protection.",
            category: .technique,
            productType: .faceSunscreen,
            icon: "target",
            priority: 2
        ),
        ProductTip(
            title: "Non-Comedogenic",
            content: "Choose non-comedogenic face sunscreens to avoid clogging pores and causing breakouts.",
            category: .benefits,
            productType: .faceSunscreen,
            icon: "checkmark.shield",
            priority: 3
        ),
        ProductTip(
            title: "Blend to Hairline",
            content: "Blend sunscreen all the way to your hairline and jawline. Don't stop at obvious boundaries.",
            category: .application,
            productType: .faceSunscreen,
            icon: "arrow.up.and.down.and.arrow.left.and.right",
            priority: 2
        )
    ]
    
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
