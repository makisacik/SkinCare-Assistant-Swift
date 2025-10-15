//
//  RoutineTemplateModels.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Routine Category

enum RoutineCategory: String, CaseIterable, Codable {
    case all = "all"
    case korean = "korean"
    case antiAging = "anti_aging"
    case acne = "acne"
    case minimalist = "minimalist"
    case sensitive = "sensitive"
    case oily = "oily"
    case dry = "dry"
    case combination = "combination"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .korean: return "Korean"
        case .antiAging: return "Anti-Aging"
        case .acne: return "Acne"
        case .minimalist: return "Minimalist"
        case .sensitive: return "Sensitive"
        case .oily: return "Oily Skin"
        case .dry: return "Dry Skin"
        case .combination: return "Combination"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "sparkles"
        case .korean: return "leaf.fill"
        case .antiAging: return "clock.fill"
        case .acne: return "target"
        case .minimalist: return "minus.circle.fill"
        case .sensitive: return "heart.fill"
        case .oily: return "drop.fill"
        case .dry: return "sun.max.fill"
        case .combination: return "circle.grid.2x2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return ThemeManager.shared.theme.palette.primary
        case .korean: return Color(red: 0.2, green: 0.8, blue: 0.3) // Green
        case .antiAging: return Color(red: 0.8, green: 0.4, blue: 0.8) // Purple
        case .acne: return Color(red: 0.9, green: 0.3, blue: 0.3) // Red
        case .minimalist: return Color(red: 0.3, green: 0.6, blue: 0.9) // Blue
        case .sensitive: return Color(red: 1.0, green: 0.6, blue: 0.8) // Pink
        case .oily: return Color(red: 0.4, green: 0.7, blue: 0.9) // Light Blue
        case .dry: return Color(red: 0.9, green: 0.7, blue: 0.3) // Orange
        case .combination: return Color(red: 0.6, green: 0.4, blue: 0.8) // Violet
        }
    }
    
    var description: String {
        switch self {
        case .all: return "All routine types"
        case .korean: return "Korean skincare philosophy"
        case .antiAging: return "Target fine lines and wrinkles"
        case .acne: return "Clear and prevent breakouts"
        case .minimalist: return "Simple, essential steps"
        case .sensitive: return "Gentle, soothing care"
        case .oily: return "Control excess oil"
        case .dry: return "Intensive hydration"
        case .combination: return "Balance different skin zones"
        }
    }
}

// MARK: - Template Routine Step

struct TemplateRoutineStep: Codable, Equatable {
    let title: String
    let why: String
    let how: String

    init(title: String, why: String, how: String) {
        self.title = title
        self.why = why
        self.how = how
    }
}

// MARK: - Routine Template

struct RoutineTemplate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: RoutineCategory
    let duration: String
    let difficulty: Difficulty
    let tags: [String]
    let morningSteps: [TemplateRoutineStep]
    let eveningSteps: [TemplateRoutineStep]
    let benefits: [String]
    let isFeatured: Bool
    let isPremium: Bool
    let imageName: String

    // Computed properties
    var stepCount: Int {
        return morningSteps.count + eveningSteps.count
    }

    // Computed property for backward compatibility
    var steps: [TemplateRoutineStep] {
        return morningSteps + eveningSteps
    }

    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var title: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
        
        var color: Color {
            switch self {
            case .beginner: return Color.green
            case .intermediate: return Color.orange
            case .advanced: return Color.red
            }
        }
    }
}

// MARK: - Sample Data

extension RoutineTemplate {
    // Stable UUIDs for specific routines
    static let koreanGlassSkinId = UUID(uuidString: "A1111111-1111-1111-1111-111111111111")!
    static let acneClearId = UUID(uuidString: "A2222222-2222-2222-2222-222222222222")!
    static let antiAgingId = UUID(uuidString: "A3333333-3333-3333-3333-333333333333")!
    static let minimalistId = UUID(uuidString: "A4444444-4444-4444-4444-444444444444")!
    static let sensitiveId = UUID(uuidString: "A5555555-5555-5555-5555-555555555555")!
    static let oilyId = UUID(uuidString: "A6666666-6666-6666-6666-666666666666")!
    static let dryId = UUID(uuidString: "A7777777-7777-7777-7777-777777777777")!
    static let combinationId = UUID(uuidString: "A8888888-8888-8888-8888-888888888888")!
    static let advancedKoreanId = UUID(uuidString: "A9999999-9999-9999-9999-999999999999")!
    static let teenAcneId = UUID(uuidString: "AA111111-1111-1111-1111-111111111111")!
    static let matureSkinId = UUID(uuidString: "AB111111-1111-1111-1111-111111111111")!

    static let featuredRoutines: [RoutineTemplate] = [
        RoutineTemplate(
            id: koreanGlassSkinId,
            title: "Korean Glass Skin",
            description: "Achieve that coveted dewy, glass-like complexion with this comprehensive Korean skincare routine.",
            category: .korean,
            duration: "15-20 min",
            difficulty: .intermediate,
            tags: ["Hydration", "Glow", "Multi-step", "Popular"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Water-based Cleanser",
                    why: "Removes overnight sebum and impurities without stripping skin's natural moisture barrier, preparing it for optimal product absorption",
                    how: "Wet your face with lukewarm water. Apply a small amount and gently massage in circular motions for 30-60 seconds. Rinse thoroughly and pat dry with a clean towel."
                ),
                TemplateRoutineStep(
                    title: "Toner",
                    why: "Balances skin's pH level after cleansing and creates the perfect environment for subsequent products to penetrate deeply",
                    how: "Pour toner onto your palms or a cotton pad. Gently pat or sweep across your face and neck, avoiding the eye area. Let it absorb for 30 seconds."
                ),
                TemplateRoutineStep(
                    title: "Essence",
                    why: "Delivers the first layer of lightweight hydration and preps skin for better absorption of serums and treatments",
                    how: "Pour a few drops into your palms. Gently pat into skin from the center of your face moving outward. Press lightly to help absorption."
                ),
                TemplateRoutineStep(
                    title: "Serum",
                    why: "Provides concentrated active ingredients targeting specific concerns like brightening, anti-aging, or hydration",
                    how: "Apply 2-3 drops to your face and neck. Gently press and pat the serum in, avoiding tugging. Wait 60 seconds before next step."
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Seals in all previous layers of hydration and creates a protective barrier to prevent transepidermal water loss",
                    how: "Warm a dime-sized amount between your palms. Apply using gentle upward and outward motions on face and neck. Don't forget your neck!"
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "Protects skin from UV damage that causes 90% of visible aging, dark spots, and texture issues",
                    how: "Apply two finger-lengths of sunscreen to all exposed areas. Wait 15 minutes before sun exposure. Reapply every 2 hours when outdoors."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Oil Cleanser",
                    why: "Dissolves makeup, sunscreen, and oil-based impurities that water-based cleansers can't remove effectively",
                    how: "Apply to dry skin and massage for 1-2 minutes. Add water to emulsify into a milky texture, then rinse thoroughly with lukewarm water."
                ),
                TemplateRoutineStep(
                    title: "Water-based Cleanser",
                    why: "Second cleanse removes remaining water-based debris and ensures completely clean skin for maximum treatment absorption",
                    how: "Apply to damp skin and massage gently in circular motions for 60 seconds. Rinse thoroughly with lukewarm water and pat dry."
                ),
                TemplateRoutineStep(
                    title: "Exfoliant",
                    why: "Gently removes dead skin cells that can cause dullness and clog pores, revealing brighter, smoother skin underneath",
                    how: "Apply to clean, dry skin avoiding the eye area. Leave on for 10-15 minutes, then rinse. Use 2-3 times per week, not daily."
                ),
                TemplateRoutineStep(
                    title: "Sheet Mask",
                    why: "Provides intensive hydration and nutrients in a concentrated treatment that penetrates deeply for maximum glow",
                    how: "Apply mask to clean face, smoothing out air bubbles. Relax for 15-20 minutes. Remove and pat in remaining essence. Use 2-3x per week."
                ),
                TemplateRoutineStep(
                    title: "Eye Cream",
                    why: "Targets the delicate eye area with specialized ingredients to reduce puffiness, dark circles, and fine lines",
                    how: "Gently dab a rice grain-sized amount around the orbital bone using your ring finger. Pat from inner to outer corner. Never pull or tug."
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Locks in all the layered treatments and provides overnight hydration while your skin is in repair mode",
                    how: "Apply a generous amount using upward and outward motions. Your evening moisturizer can be richer than your morning one."
                )
            ],
            benefits: [
                "Deep hydration",
                "Improved skin texture",
                "Radiant glow",
                "Reduced fine lines"
            ],
            isFeatured: true,
            isPremium: false,
            imageName: "routine-korean"
        ),
        RoutineTemplate(
            id: acneClearId,
            title: "Acne Clear Routine",
            description: "Combat breakouts and prevent future acne with this targeted routine for clear, healthy skin.",
            category: .acne,
            duration: "8-12 min",
            difficulty: .beginner,
            tags: ["Acne", "Salicylic Acid", "Gentle", "Effective"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes excess oil and impurities without over-stripping, which can trigger more oil production and worsen acne",
                    how: "Use lukewarm water and massage gently for 60 seconds. Avoid hot water and harsh scrubbing. Pat dry with a clean towel."
                ),
                TemplateRoutineStep(
                    title: "Salicylic Acid Toner",
                    why: "Penetrates into pores to dissolve oil and debris, preventing clogs that lead to blackheads and breakouts",
                    how: "Apply to a cotton pad or directly to palms. Gently sweep or pat across face, focusing on acne-prone areas. Start every other day if new to BHA."
                ),
                TemplateRoutineStep(
                    title: "Niacinamide Serum",
                    why: "Reduces inflammation, regulates oil production, and helps fade post-acne marks without irritation",
                    how: "Apply 2-3 drops to face and neck. Pat gently to absorb. Wait 60 seconds before moisturizer. Can be used morning and night."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Maintains skin barrier health without clogging pores. Even oily, acne-prone skin needs hydration to prevent overproduction of oil",
                    how: "Use a gel or water-based moisturizer. Apply a thin layer and let it absorb fully. Look for non-comedogenic labels."
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "Prevents dark spots from healing acne and protects skin from damage. Many acne treatments increase sun sensitivity",
                    how: "Apply oil-free, non-comedogenic SPF 30+. Use two finger-lengths and reapply if spending time outdoors."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes the day's accumulation of oil, dirt, and bacteria without stripping or irritating compromised skin",
                    how: "Massage for 60 seconds with lukewarm water. Be gentle around active breakouts. Rinse thoroughly and pat dry."
                ),
                TemplateRoutineStep(
                    title: "Salicylic Acid Toner",
                    why: "Evening application allows BHA to work overnight, unclogging pores and preventing new breakouts while you sleep",
                    how: "Apply to clean, dry skin. Focus on T-zone and acne-prone areas. Skip if using other strong actives like retinol tonight."
                ),
                TemplateRoutineStep(
                    title: "Niacinamide Serum",
                    why: "Calms inflammation from the day, reduces redness, and works synergistically with BHA to control breakouts",
                    how: "Apply 2-3 drops after toner. Pat gently and let absorb. Wait a minute before next step."
                ),
                TemplateRoutineStep(
                    title: "Spot Treatment",
                    why: "Delivers concentrated acne-fighting ingredients directly to active breakouts for faster healing",
                    how: "Apply a small amount directly to active pimples only, not all over. Use a clean finger or cotton swab. Let dry completely."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Seals in treatments and prevents skin from getting too dry, which paradoxically can make acne worse",
                    how: "Apply after spot treatment has dried. Use a thin layer. Choose gel or water-based formulas for acne-prone skin."
                )
            ],
            benefits: [
                "Reduces active breakouts",
                "Prevents new acne",
                "Minimizes pores",
                "Soothes inflammation"
            ],
            isFeatured: true,
            isPremium: false,
            imageName: "routine-acne"
        ),
        RoutineTemplate(
            id: antiAgingId,
            title: "Anti-Aging Essentials",
            description: "Combat signs of aging with this powerful routine featuring proven anti-aging ingredients.",
            category: .antiAging,
            duration: "12-15 min",
            difficulty: .intermediate,
            tags: ["Retinol", "Vitamin C", "Anti-aging", "Firming"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes overnight buildup without stripping mature skin, which tends to be drier and more delicate",
                    how: "Use a cream or oil-based cleanser with lukewarm water. Massage gently for 60 seconds, rinse thoroughly, and pat dry."
                ),
                TemplateRoutineStep(
                    title: "Vitamin C Serum",
                    why: "Powerful antioxidant that brightens, evens tone, boosts collagen production, and protects against free radical damage from UV and pollution",
                    how: "Apply 3-4 drops to clean skin in the morning. Gently press into face and neck. Wait 60-90 seconds before next step. Store in cool, dark place."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Attracts and holds up to 1000x its weight in water, plumping fine lines and maintaining skin's youthful bounce",
                    how: "Apply to slightly damp skin for best absorption. Use 2-3 drops and pat gently. Follow quickly with moisturizer to seal in hydration."
                ),
                TemplateRoutineStep(
                    title: "Rich Moisturizer",
                    why: "Provides essential lipids and ceramides that decline with age, strengthening skin barrier and preventing moisture loss",
                    how: "Warm a generous amount between palms. Press and pat into skin using upward motions. Focus on areas prone to dryness and lines."
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "UV exposure causes 90% of visible aging. Daily SPF is the single most effective anti-aging measure you can take",
                    how: "Apply broad-spectrum SPF 50 as final step. Use two finger-lengths and reapply every 2 hours if outdoors. Don't skip on cloudy days."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes the day's sunscreen, pollution, and makeup without disrupting your skin's protective barrier",
                    how: "Double cleanse if wearing sunscreen: first with oil cleanser, then water-based. Massage for 60 seconds each, rinse with lukewarm water."
                ),
                TemplateRoutineStep(
                    title: "Retinol Treatment",
                    why: "Gold-standard anti-aging ingredient that increases cell turnover, boosts collagen, reduces wrinkles, and evens skin tone",
                    how: "Apply pea-sized amount to dry skin, avoiding eye area. Start 2x per week, gradually increase. Always use sunscreen the next day. Wait 20 min before moisturizer."
                ),
                TemplateRoutineStep(
                    title: "Peptide Serum",
                    why: "Peptides signal skin to produce more collagen and elastin, improving firmness and reducing the appearance of fine lines",
                    how: "Apply 2-3 drops after retinol has absorbed. Pat gently into face and neck. Peptides work well with retinol for enhanced results."
                ),
                TemplateRoutineStep(
                    title: "Eye Cream",
                    why: "Eye area skin is thinner and shows aging signs first. Specialized ingredients target crow's feet, dark circles, and puffiness",
                    how: "Use ring finger to gently pat a rice grain amount around orbital bone. Never tug or pull. Apply from inner to outer corner."
                ),
                TemplateRoutineStep(
                    title: "Rich Moisturizer",
                    why: "Nighttime is when skin repairs itself. A rich moisturizer supports this process with nourishing ingredients and deep hydration",
                    how: "Apply generously as the final step to seal in all treatments. Can be slightly richer than morning moisturizer. Don't forget neck and chest."
                )
            ],
            benefits: [
                "Reduces fine lines",
                "Improves skin firmness",
                "Brightens complexion",
                "Stimulates collagen"
            ],
            isFeatured: true,
            isPremium: true,
            imageName: "routine-anti-aging"
        )
    ]
    
    static let allRoutines: [RoutineTemplate] = featuredRoutines + [
        // Additional routines
        RoutineTemplate(
            id: minimalistId,
            title: "Minimalist Daily",
            description: "Keep it simple with just the essentials for busy mornings and evenings.",
            category: .minimalist,
            duration: "3-5 min",
            difficulty: .beginner,
            tags: ["Quick", "Simple", "Essential", "Beginner"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes overnight oil and prepares skin for the day. A simple cleanse is all most people need in the morning",
                    how: "Wet face, apply cleanser, massage for 30 seconds, rinse with lukewarm water, pat dry. That's it!"
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Hydrates and protects your skin barrier. Essential for all skin types, even if you have oily skin",
                    how: "Apply a dime-sized amount to face and neck while skin is slightly damp for better absorption. Let it sink in."
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "The single most important anti-aging step. Protects from UV damage that causes wrinkles, dark spots, and skin cancer",
                    how: "Apply SPF 30+ as your final morning step. Use about two finger-lengths for face and neck. Reapply if outdoors for extended periods."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Removes the day's buildup of oil, dirt, sweat, and sunscreen so your skin can breathe and repair overnight",
                    how: "Massage cleanser for 60 seconds to thoroughly remove sunscreen and impurities. Rinse well with lukewarm water and pat dry."
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Nighttime hydration supports your skin's natural repair process while you sleep. Can be slightly richer than morning version",
                    how: "Apply to clean, slightly damp skin. Use gentle upward strokes. This is the perfect time for your skin to absorb nutrients."
                )
            ],
            benefits: [
                "Quick and easy",
                "Perfect for beginners",
                "Covers basics",
                "Time-efficient"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-minimalist"
        ),
        RoutineTemplate(
            id: sensitiveId,
            title: "Sensitive Skin Soother",
            description: "Gentle, calming routine designed for sensitive and reactive skin types.",
            category: .sensitive,
            duration: "6-8 min",
            difficulty: .beginner,
            tags: ["Gentle", "Calming", "Fragrance-free", "Sensitive"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Cream Cleanser",
                    why: "Cleanses without stripping or irritating sensitive skin. Cream formulas are gentler than foaming ones that can disrupt the barrier",
                    how: "Use lukewarm (not hot) water. Massage gently without rubbing hard. Rinse thoroughly and pat (don't rub) dry with a soft towel."
                ),
                TemplateRoutineStep(
                    title: "Soothing Toner",
                    why: "Calms inflammation and redness while delivering gentle hydration. Look for centella, green tea, or colloidal oatmeal",
                    how: "Apply with clean hands by gently patting into skin. Avoid rubbing or using cotton pads which can cause friction and irritation."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Provides gentle, non-irritating hydration. Works for all skin types without risk of sensitivity or breakouts",
                    how: "Apply to damp skin for maximum absorption. Use gentle patting motions. Follow with moisturizer to lock in hydration."
                ),
                TemplateRoutineStep(
                    title: "Barrier Repair Cream",
                    why: "Strengthens compromised skin barrier with ceramides and niacinamide. Reduces sensitivity over time and protects against irritants",
                    how: "Apply a generous layer to lock in previous products. Look for fragrance-free formulas with ceramides. Use morning and night."
                ),
                TemplateRoutineStep(
                    title: "Mineral Sunscreen",
                    why: "Physical sunscreens with zinc oxide or titanium dioxide are less likely to irritate than chemical filters",
                    how: "Apply SPF 30+ as final step. Mineral sunscreens sit on top of skin rather than absorbing, making them ideal for sensitive skin."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Cream Cleanser",
                    why: "Removes the day's buildup gently without causing irritation or compromising your skin's protective barrier",
                    how: "Double cleanse if needed: oil cleanser first for sunscreen, then cream cleanser. Be extra gentle around irritated areas."
                ),
                TemplateRoutineStep(
                    title: "Soothing Toner",
                    why: "Evening application helps calm any daytime irritation and preps skin for better absorption of repair ingredients",
                    how: "Pat gently into clean skin. This is the perfect time to use cooling, soothing ingredients to reduce redness from the day."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Nighttime hydration supports barrier repair while you sleep without risk of irritation or sensitivity",
                    how: "Apply to slightly damp skin. Layer under your barrier cream for maximum hydration and healing overnight."
                ),
                TemplateRoutineStep(
                    title: "Barrier Repair Cream",
                    why: "Overnight is when skin repairs itself. A rich barrier cream supports this with ceramides, cholesterol, and fatty acids",
                    how: "Apply generously as your final step. Can use a heavier layer than morning. Wake up to calmer, stronger skin."
                )
            ],
            benefits: [
                "Reduces irritation",
                "Strengthens skin barrier",
                "Gentle on sensitive skin",
                "Calming ingredients"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-sensitive"
        ),
        RoutineTemplate(
            id: oilyId,
            title: "Oily Skin Control",
            description: "Manage excess oil and shine while maintaining healthy, balanced skin.",
            category: .oily,
            duration: "8-10 min",
            difficulty: .beginner,
            tags: ["Oil Control", "Mattifying", "Pore Care", "Lightweight"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gel Cleanser",
                    why: "Removes excess sebum and overnight oil without over-stripping, which can trigger even more oil production",
                    how: "Use a gentle gel or foaming cleanser. Massage for 60 seconds with lukewarm water. Avoid hot water which stimulates oil glands."
                ),
                TemplateRoutineStep(
                    title: "BHA Toner",
                    why: "Salicylic acid penetrates oil-filled pores to prevent clogs and breakouts while controlling shine",
                    how: "Apply with cotton pad or hands to clean skin. Focus on T-zone. Start with every other day if new to BHAs to avoid irritation."
                ),
                TemplateRoutineStep(
                    title: "Niacinamide Serum",
                    why: "Clinically proven to regulate sebum production by up to 50% while reducing pore appearance",
                    how: "Apply 2-3 drops to entire face. Pairs well with BHA. Works best with consistent daily use over 4-8 weeks."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Even oily skin needs hydration. Skipping moisturizer signals skin to produce MORE oil to compensate",
                    how: "Use gel or water-based formula. Apply thin layer while skin is slightly damp. Look for oil-free, non-comedogenic labels."
                ),
                TemplateRoutineStep(
                    title: "Oil-free Sunscreen",
                    why: "Protects without adding grease. Many acne treatments increase sun sensitivity, making SPF essential",
                    how: "Choose mattifying or gel sunscreen formulas. Apply SPF 30+ as final step. Reapply if outdoors."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gel Cleanser",
                    why: "Removes the day's oil, sunscreen, and impurities that can clog pores and cause breakouts overnight",
                    how: "Double cleanse if wearing heavy sunscreen: oil cleanser first, then gel cleanser. Massage thoroughly for 60 seconds."
                ),
                TemplateRoutineStep(
                    title: "BHA Toner",
                    why: "Evening application allows salicylic acid to work overnight, unclogging pores and preventing morning shine",
                    how: "Apply to clean, dry skin. Can use daily in PM if skin tolerates it. Skip if using retinol on same night."
                ),
                TemplateRoutineStep(
                    title: "Niacinamide Serum",
                    why: "Nighttime is when skin repairs. Niacinamide reduces oil production and inflammation while you sleep",
                    how: "Apply after toner. Can layer with BHA safely. Use nightly for best results in controlling daytime oil."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Prevents overnight moisture loss which can trigger rebound oil production the next day",
                    how: "Apply thin layer. Evening moisturizer can be same as morning or slightly more hydrating if needed."
                ),
                TemplateRoutineStep(
                    title: "Clay Mask",
                    why: "Weekly deep treatment absorbs excess oil, unclogs pores, and provides deep cleansing for clearer skin",
                    how: "Use 1-2x per week after cleansing. Apply thin layer, leave 10-15 minutes. Don't let it completely dry out. Rinse thoroughly."
                )
            ],
            benefits: [
                "Controls excess oil",
                "Minimizes pores",
                "Reduces shine",
                "Prevents breakouts"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-oily"
        ),
        RoutineTemplate(
            id: dryId,
            title: "Dry Skin Hydration",
            description: "Intensive hydration routine to quench thirsty, dry skin and restore moisture barrier.",
            category: .dry,
            duration: "10-12 min",
            difficulty: .beginner,
            tags: ["Hydration", "Moisture", "Rich", "Nourishing"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Cream Cleanser",
                    why: "Hydrating cream formula cleanses without stripping natural oils that dry skin desperately needs",
                    how: "Massage cream cleanser onto dry or damp skin for 60 seconds. Use lukewarm water to rinse. Pat dry gently - never rub."
                ),
                TemplateRoutineStep(
                    title: "Hydrating Toner",
                    why: "Delivers first layer of hydration and preps skin to absorb more moisture from subsequent products",
                    how: "Apply to damp skin by patting with hands. Look for glycerin, hyaluronic acid, or ceramides. Layer multiple times if very dry."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Attracts up to 1000x its weight in water, providing intense hydration that plumps and smooths dry, flaky skin",
                    how: "Apply to damp skin for maximum efficacy. Use 2-3 drops. Follow immediately with moisturizer to lock in the water it attracts."
                ),
                TemplateRoutineStep(
                    title: "Rich Serum",
                    why: "Delivers concentrated nourishing ingredients that penetrate deep into dry, dehydrated skin",
                    how: "Apply 3-4 drops after hyaluronic acid. Look for ceramides, peptides, or nourishing oils. Pat gently to absorb."
                ),
                TemplateRoutineStep(
                    title: "Heavy Moisturizer",
                    why: "Creates protective barrier to prevent transepidermal water loss, the main cause of dry skin",
                    how: "Apply generously while skin is still damp. Look for thick creams with ceramides, shea butter, or squalane. Don't be stingy!"
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "UV damage breaks down skin barrier, making dryness worse. Choose hydrating SPF formulas",
                    how: "Use cream-based SPF 30+, not gel formulas. Apply generously. Many moisturizing sunscreens can double as extra hydration."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Cream Cleanser",
                    why: "Evening cleanse removes the day's buildup while maintaining essential moisture your dry skin needs overnight",
                    how: "Use oil cleanser first for sunscreen, then cream cleanser. Be extra gentle - dry skin is more prone to irritation."
                ),
                TemplateRoutineStep(
                    title: "Hydrating Toner",
                    why: "Nighttime toner delivers hydration and prepares skin for maximum absorption of rich treatments",
                    how: "Apply multiple layers (7-skin method) for extra hydration. Pat each layer until absorbed before adding next."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Overnight hydration allows HA to work while skin is in repair mode, waking up to plumper, dewier skin",
                    how: "Apply to damp skin. For very dry skin, mix a drop with your moisturizer for extra boost."
                ),
                TemplateRoutineStep(
                    title: "Rich Serum",
                    why: "Night is when skin repairs itself. Rich serums provide nutrients and moisture to support this process",
                    how: "Apply generously after HA. Can use more at night than morning. Focus on extra dry areas."
                ),
                TemplateRoutineStep(
                    title: "Heavy Moisturizer",
                    why: "Overnight occlusive moisturizer prevents water loss while you sleep, the most critical time for dry skin",
                    how: "Apply thick layer as last step before oil. Look for sleeping masks or night creams specifically for dry skin."
                ),
                TemplateRoutineStep(
                    title: "Facial Oil",
                    why: "Seals everything in with nourishing oils. Last step ensures maximum moisture retention through the night",
                    how: "Warm 3-5 drops between palms. Press gently onto face and neck. Use jojoba, argan, or rosehip oil."
                )
            ],
            benefits: [
                "Deep hydration",
                "Restores moisture barrier",
                "Soothes dryness",
                "Long-lasting moisture"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-dry"
        ),
        RoutineTemplate(
            id: combinationId,
            title: "Combination Skin Balance",
            description: "Address different needs across your face - oily T-zone and dry cheeks.",
            category: .combination,
            duration: "8-10 min",
            difficulty: .intermediate,
            tags: ["Balanced", "Multi-zone", "Adaptive", "Versatile"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Balancing Cleanser",
                    why: "Cleanses oily T-zone without over-drying cheeks. The key is finding middle-ground formulas",
                    how: "Use gel-cream hybrid cleanser. Spend extra time on oily areas, be gentle on dry zones. Lukewarm water only."
                ),
                TemplateRoutineStep(
                    title: "Toner",
                    why: "Balances pH across different zones and prepares skin for targeted treatments",
                    how: "Apply all over. Can layer extra on dry areas or use hydrating toner on cheeks, mattifying on T-zone for multi-masking approach."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Serum",
                    why: "Provides treatment benefits without overloading oily zones or leaving dry areas thirsty",
                    how: "Apply evenly across face. Niacinamide works great for combination skin as it balances oil and hydrates simultaneously."
                ),
                TemplateRoutineStep(
                    title: "Adaptive Moisturizer",
                    why: "Modern formulas adapt to different moisture levels across your face, providing what each zone needs",
                    how: "Apply thin layer on T-zone, more generous on cheeks. Or use two products: gel on oily areas, cream on dry areas."
                ),
                TemplateRoutineStep(
                    title: "Broad Spectrum Sunscreen",
                    why: "All zones need equal UV protection. Choose formula that works for both oily and dry areas",
                    how: "Use lightweight, non-greasy SPF 30+. Gel or fluid formulas work best. Apply evenly across all zones."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Balancing Cleanser",
                    why: "Removes the day's varied buildup - excess oil from T-zone, environmental stress from dry areas",
                    how: "Double cleanse if needed. Oil cleanser removes sunscreen, then balancing cleanser. Focus on needs of each zone."
                ),
                TemplateRoutineStep(
                    title: "Toner",
                    why: "Evening toner can be more targeted - use different ones for different zones if needed",
                    how: "Apply with hands or cotton pad. This is great time to multi-mask: hydrating toner on cheeks, BHA on T-zone."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Serum",
                    why: "Nighttime serum addresses concerns across all zones without overwhelming any particular area",
                    how: "Apply to entire face. Retinol or niacinamide work well for combination skin's varied needs."
                ),
                TemplateRoutineStep(
                    title: "Zone-specific Treatment",
                    why: "This is where you customize - address oily T-zone concerns AND dry cheek needs separately",
                    how: "Apply BHA or spot treatment to oily/acne-prone areas. Use hydrating serum or oil on dry patches. Customize to your needs."
                ),
                TemplateRoutineStep(
                    title: "Adaptive Moisturizer",
                    why: "Locks in treatments while providing balanced hydration that won't cause excess oil or dryness",
                    how: "Apply according to each zone's needs. Thin layer on T-zone, richer on cheeks. Listen to your skin's feedback."
                )
            ],
            benefits: [
                "Balances different zones",
                "Addresses multiple concerns",
                "Versatile approach",
                "Customizable application"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-combination"
        ),
        RoutineTemplate(
            id: advancedKoreanId,
            title: "Advanced Korean 12-Step",
            description: "The complete Korean skincare ritual for ultimate skin transformation.",
            category: .korean,
            duration: "25-30 min",
            difficulty: .advanced,
            tags: ["Complete", "Luxury", "Comprehensive", "Advanced"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Water Cleanser",
                    why: "Morning second cleanse removes overnight oils and prepares skin for multiple treatment layers",
                    how: "Use gentle, low-pH cleanser. Massage for 60 seconds. The foundation of successful layering starts with clean canvas."
                ),
                TemplateRoutineStep(
                    title: "Toner",
                    why: "Balances pH and creates optimal environment for the many treatment layers to follow",
                    how: "Pat toner into skin with hands, using 7-skin method if desired. First layer of hydration in this multi-step ritual."
                ),
                TemplateRoutineStep(
                    title: "Essence",
                    why: "Core of K-beauty: delivers lightweight hydration that enhances absorption of subsequent products",
                    how: "Pour into palms and press gently into skin. This watery layer is key to that glass skin glow."
                ),
                TemplateRoutineStep(
                    title: "Treatment Essence",
                    why: "Contains fermented ingredients and active components for skin renewal and brightening",
                    how: "Pat 2-3 drops across face. Treatment essences are more concentrated than regular essence. Premium K-beauty secret."
                ),
                TemplateRoutineStep(
                    title: "Serum",
                    why: "Targeted treatment for specific concerns - brightening, anti-aging, or hydration",
                    how: "Apply 2-3 drops. Press and pat to absorb. Can use multiple serums for different concerns."
                ),
                TemplateRoutineStep(
                    title: "Ampoule",
                    why: "Most concentrated treatment product with highest active ingredient levels for maximum results",
                    how: "Use 1-2 drops only - very potent. Pat gently. Reserve for key concerns. Often used for special occasions or treatments."
                ),
                TemplateRoutineStep(
                    title: "Eye Cream",
                    why: "Delicate eye area needs specialized treatment before facial moisturizer",
                    how: "Use ring finger to tap tiny amount around orbital bone. Never pull or tug the delicate skin."
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Seals in all the treatment layers and provides lasting hydration throughout the day",
                    how: "Apply to lock in all previous steps. Korean moisturizers are often gel-based for lightweight finish."
                ),
                TemplateRoutineStep(
                    title: "Sunscreen",
                    why: "Final step protects all that investment in skincare. K-beauty has world's best cosmetically elegant sunscreens",
                    how: "Apply generously as final step. Korean sunscreens are famous for elegant, non-greasy finishes that work under makeup."
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Oil Cleanser",
                    why: "First cleanse dissolves makeup, sunscreen, and oil-based impurities. Foundation of double cleanse method",
                    how: "Massage onto dry skin for 1-2 minutes. Add water to emulsify into milky texture, then rinse thoroughly."
                ),
                TemplateRoutineStep(
                    title: "Water Cleanser",
                    why: "Second cleanse removes remaining water-based impurities for perfectly clean skin",
                    how: "Massage onto wet skin. The double cleanse is non-negotiable in K-beauty for truly clean, product-ready skin."
                ),
                TemplateRoutineStep(
                    title: "Exfoliant",
                    why: "Removes dead skin cells so all the treatment products can penetrate effectively",
                    how: "Apply chemical exfoliant (AHA/BHA). Leave on 10-15 minutes, rinse. Use 2-3x per week, not daily."
                ),
                TemplateRoutineStep(
                    title: "Toner",
                    why: "Rebalances pH after exfoliation and preps for the treatment layers",
                    how: "Pat generously into skin. Can do multiple layers. Evening routine has even more layers than morning."
                ),
                TemplateRoutineStep(
                    title: "Essence",
                    why: "Delivers first wave of hydration and treatment ingredients into freshly exfoliated skin",
                    how: "Press into skin gently. Freshly exfoliated skin absorbs essence more effectively for enhanced results."
                ),
                TemplateRoutineStep(
                    title: "Treatment Essence",
                    why: "Night is optimal time for treatment essences to work their renewal magic during skin's repair cycle",
                    how: "Pat 2-3 drops across face. These work while you sleep for that morning glow."
                ),
                TemplateRoutineStep(
                    title: "Serum",
                    why: "Evening serums can be more intensive - retinol, peptides, or intensive hydration for overnight repair",
                    how: "Apply targeted serum. Can use different one than morning. Night is for anti-aging actives."
                ),
                TemplateRoutineStep(
                    title: "Ampoule",
                    why: "Concentrated treatment works overnight when skin is in peak repair mode",
                    how: "Use 1-2 drops of your most powerful treatment. This is your premium step for special skin needs."
                ),
                TemplateRoutineStep(
                    title: "Sheet Mask",
                    why: "Weekly intensive hydration and treatment in a relaxing ritual. K-beauty's signature step",
                    how: "Apply after essences/serums, before moisturizer. Relax for 15-20 minutes. Pat in remaining essence. Use 2-3x per week."
                ),
                TemplateRoutineStep(
                    title: "Eye Cream",
                    why: "Nighttime eye cream can be richer with intensive ingredients for overnight renewal",
                    how: "Tap gently around eye area. Can use more generous amount than morning. Focus on concerns like fine lines."
                ),
                TemplateRoutineStep(
                    title: "Moisturizer",
                    why: "Final occlusive layer seals in all treatments and provides overnight hydration",
                    how: "Apply generously. Can use sleeping mask 2-3x per week for extra overnight boost. Wake up to glowing skin."
                )
            ],
            benefits: [
                "Complete skin transformation",
                "Maximum hydration",
                "Advanced anti-aging",
                "Luxury experience"
            ],
            isFeatured: false,
            isPremium: true,
            imageName: "routine-advanced-korean"
        ),
        RoutineTemplate(
            id: teenAcneId,
            title: "Teen Acne Fighter",
            description: "Gentle yet effective routine designed specifically for teenage skin and hormonal acne.",
            category: .acne,
            duration: "6-8 min",
            difficulty: .beginner,
            tags: ["Teen", "Hormonal", "Gentle", "Preventive"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Foaming Cleanser",
                    why: "Removes morning oil without harsh ingredients that can irritate young skin and trigger more breakouts",
                    how: "Wet face with lukewarm water. Apply cleanser, massage for 30-60 seconds. Rinse well and pat dry. Do this EVERY morning!"
                ),
                TemplateRoutineStep(
                    title: "Salicylic Acid Toner",
                    why: "Keeps pores clear and prevents the blackheads and whiteheads that turn into pimples",
                    how: "Apply with cotton pad or hands. Start every other day to let skin adjust. Can use daily once skin tolerates it."
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Yes, even oily teen skin needs moisture! Skipping it makes skin produce MORE oil to compensate",
                    how: "Use gel or water-based moisturizer. Apply thin layer. Won't make you break out if oil-free and non-comedogenic."
                ),
                TemplateRoutineStep(
                    title: "Oil-free Sunscreen",
                    why: "Protects skin and prevents dark spots from healing pimples. Many acne products make sun sensitivity worse",
                    how: "Apply SPF 30+ every morning. Choose oil-free formulas. This prevents acne scars from getting darker!"
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Foaming Cleanser",
                    why: "Removes the day's oil, sweat, dirt, and sunscreen that clog pores overnight",
                    how: "Wash for full 60 seconds in evening - you need to remove sunscreen! Use lukewarm water and gentle circular motions."
                ),
                TemplateRoutineStep(
                    title: "Salicylic Acid Toner",
                    why: "Works overnight to unclog pores and prevent tomorrow's breakouts while you sleep",
                    how: "Apply after cleansing. Let it dry for a minute before moisturizer. This is your pimple prevention step!"
                ),
                TemplateRoutineStep(
                    title: "Lightweight Moisturizer",
                    why: "Nighttime hydration prevents your skin from overproducing oil in the morning",
                    how: "Apply to slightly damp skin for better absorption. Don't skip this even if you have oily skin!"
                ),
                TemplateRoutineStep(
                    title: "Spot Treatment",
                    why: "Targets active pimples with concentrated ingredients to make them go away faster",
                    how: "Apply ONLY to active pimples, not all over your face. Use clean hands or cotton swab. Let it dry before touching your face."
                )
            ],
            benefits: [
                "Prevents teen acne",
                "Gentle on young skin",
                "Builds good habits",
                "Easy to follow"
            ],
            isFeatured: false,
            isPremium: false,
            imageName: "routine-acne"
        ),
        RoutineTemplate(
            id: matureSkinId,
            title: "Mature Skin Revival",
            description: "Comprehensive routine targeting multiple signs of aging for mature skin.",
            category: .antiAging,
            duration: "15-18 min",
            difficulty: .advanced,
            tags: ["Mature", "Comprehensive", "Luxury", "Advanced"],
            morningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Mature skin requires gentle cleansing that doesn't strip the natural oils that decline with age",
                    how: "Use rich cream or oil-based cleanser. Massage gently with lukewarm water for 60 seconds. Mature skin is more delicate."
                ),
                TemplateRoutineStep(
                    title: "Vitamin C Serum",
                    why: "Antioxidant powerhouse that brightens age spots, boosts collagen, and protects against environmental damage",
                    how: "Apply 4-5 drops to clean skin each morning. Use L-ascorbic acid formula for maximum efficacy. Store in cool, dark place."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Mature skin produces less hyaluronic acid naturally. Supplementing plumps fine lines and restores youthful moisture",
                    how: "Apply to damp skin for maximum water-binding. Use 3-4 drops. Follow immediately with moisturizer to lock in hydration."
                ),
                TemplateRoutineStep(
                    title: "Rich Eye Cream",
                    why: "Eye area shows aging first and needs specialized rich treatment for crow's feet, hollowing, and crepiness",
                    how: "Use ring finger to gently tap generous amount around entire eye area. Don't skimp - mature eyes need more product."
                ),
                TemplateRoutineStep(
                    title: "Luxury Moisturizer",
                    why: "Rich moisturizer with ceramides and peptides rebuilds barrier that weakens with age, providing essential nourishment",
                    how: "Apply generously to face, neck, and chest. These areas show aging too! Mature skin needs richer formulas than younger skin."
                ),
                TemplateRoutineStep(
                    title: "Anti-aging Sunscreen",
                    why: "SPF is THE most important anti-aging step. Prevents further damage and protects against skin cancer risk",
                    how: "Apply SPF 50 broad-spectrum. Use three finger-lengths for face and neck. Reapply every 2 hours outdoors. Non-negotiable!"
                )
            ],
            eveningSteps: [
                TemplateRoutineStep(
                    title: "Gentle Cleanser",
                    why: "Evening cleanse removes the day's environmental damage and prepares skin for powerful overnight treatments",
                    how: "Double cleanse: oil cleanser first for sunscreen, then cream cleanser. Be extra gentle - mature skin bruises more easily."
                ),
                TemplateRoutineStep(
                    title: "Retinol Treatment",
                    why: "Gold standard anti-aging ingredient. Increases cell turnover, boosts collagen, improves texture and tone",
                    how: "Start with 0.25% if new to retinol. Apply pea-sized amount to dry skin. Wait 20 minutes before moisturizer. Use 3-4x per week initially."
                ),
                TemplateRoutineStep(
                    title: "Peptide Complex",
                    why: "Peptides signal skin to produce more collagen and elastin, directly addressing loss of firmness and structure",
                    how: "Apply 2-3 drops after retinol. Peptides work synergistically with retinol for enhanced anti-aging benefits."
                ),
                TemplateRoutineStep(
                    title: "Hyaluronic Acid",
                    why: "Overnight hydration while skin is in repair mode. Plumps lines and restores bounce that mature skin loses",
                    how: "Apply to slightly damp skin. Can use more at night than morning. Essential for mature skin's hydration needs."
                ),
                TemplateRoutineStep(
                    title: "Rich Eye Cream",
                    why: "Nighttime eye cream with retinol or peptides works during sleep to reduce crow's feet and firm delicate area",
                    how: "Apply generously around entire eye area including upper lid. Night is when these ingredients work their magic."
                ),
                TemplateRoutineStep(
                    title: "Luxury Moisturizer",
                    why: "Rich night cream supports overnight repair with ceramides, peptides, and nourishing oils mature skin craves",
                    how: "Apply thick layer to face, neck, and chest. Can use facial oil on top for extra nourishment. Wake up to renewed skin."
                )
            ],
            benefits: [
                "Targets multiple aging signs",
                "Improves skin texture",
                "Restores firmness",
                "Comprehensive care"
            ],
            isFeatured: false,
            isPremium: true,
            imageName: "routine-mature"
        )
    ]
}
