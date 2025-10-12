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

// MARK: - Routine Template

struct RoutineTemplate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: RoutineCategory
    let stepCount: Int
    let duration: String
    let difficulty: Difficulty
    let tags: [String]
    let morningSteps: [String]
    let eveningSteps: [String]
    let benefits: [String]
    let isFeatured: Bool
    let isPremium: Bool
    let imageName: String
    
    // Computed property for backward compatibility
    var steps: [String] {
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
            stepCount: 10,
            duration: "15-20 min",
            difficulty: .intermediate,
            tags: ["Hydration", "Glow", "Multi-step", "Popular"],
            morningSteps: [
                "Water-based Cleanser - Deep clean pores",
                "Toner - Balance pH and prep skin",
                "Essence - Lightweight hydration layer",
                "Serum - Targeted treatment",
                "Moisturizer - Lock in hydration",
                "Sunscreen - Daily protection"
            ],
            eveningSteps: [
                "Oil Cleanser - Remove makeup and sunscreen",
                "Water-based Cleanser - Deep clean pores",
                "Exfoliant - Gentle chemical exfoliation",
                "Sheet Mask - Intensive treatment (2-3x/week)",
                "Eye Cream - Delicate eye area care",
                "Moisturizer - Lock in hydration"
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
            stepCount: 6,
            duration: "8-12 min",
            difficulty: .beginner,
            tags: ["Acne", "Salicylic Acid", "Gentle", "Effective"],
            morningSteps: [
                "Gentle Cleanser - Remove dirt and oil",
                "Salicylic Acid Toner - Unclog pores",
                "Niacinamide Serum - Reduce inflammation",
                "Lightweight Moisturizer - Hydrate without clogging",
                "Sunscreen - Protect healing skin"
            ],
            eveningSteps: [
                "Gentle Cleanser - Remove dirt and oil",
                "Salicylic Acid Toner - Unclog pores",
                "Niacinamide Serum - Reduce inflammation",
                "Spot Treatment - Target active breakouts",
                "Lightweight Moisturizer - Hydrate without clogging"
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
            stepCount: 7,
            duration: "12-15 min",
            difficulty: .intermediate,
            tags: ["Retinol", "Vitamin C", "Anti-aging", "Firming"],
            morningSteps: [
                "Gentle Cleanser - Remove daily buildup",
                "Vitamin C Serum - Brighten and protect",
                "Hyaluronic Acid - Plump and hydrate",
                "Rich Moisturizer - Nourish and protect",
                "Sunscreen - Protect from UV damage"
            ],
            eveningSteps: [
                "Gentle Cleanser - Remove daily buildup",
                "Retinol Treatment - Stimulate collagen",
                "Peptide Serum - Support skin structure",
                "Eye Cream - Target fine lines",
                "Rich Moisturizer - Nourish and protect"
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
            stepCount: 3,
            duration: "3-5 min",
            difficulty: .beginner,
            tags: ["Quick", "Simple", "Essential", "Beginner"],
            morningSteps: [
                "Gentle Cleanser - Clean skin",
                "Moisturizer - Hydrate and protect",
                "Sunscreen - Daily protection"
            ],
            eveningSteps: [
                "Gentle Cleanser - Clean skin",
                "Moisturizer - Hydrate and protect"
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
            stepCount: 5,
            duration: "6-8 min",
            difficulty: .beginner,
            tags: ["Gentle", "Calming", "Fragrance-free", "Sensitive"],
            morningSteps: [
                "Cream Cleanser - Gentle cleansing",
                "Soothing Toner - Calm irritation",
                "Hyaluronic Acid - Gentle hydration",
                "Barrier Repair Cream - Strengthen skin",
                "Mineral Sunscreen - Gentle protection"
            ],
            eveningSteps: [
                "Cream Cleanser - Gentle cleansing",
                "Soothing Toner - Calm irritation",
                "Hyaluronic Acid - Gentle hydration",
                "Barrier Repair Cream - Strengthen skin"
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
            stepCount: 6,
            duration: "8-10 min",
            difficulty: .beginner,
            tags: ["Oil Control", "Mattifying", "Pore Care", "Lightweight"],
            morningSteps: [
                "Gel Cleanser - Remove excess oil",
                "BHA Toner - Unclog pores",
                "Niacinamide Serum - Control oil production",
                "Lightweight Moisturizer - Hydrate without greasiness",
                "Oil-free Sunscreen - Protect without shine"
            ],
            eveningSteps: [
                "Gel Cleanser - Remove excess oil",
                "BHA Toner - Unclog pores",
                "Niacinamide Serum - Control oil production",
                "Lightweight Moisturizer - Hydrate without greasiness",
                "Clay Mask - Weekly deep clean"
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
            stepCount: 7,
            duration: "10-12 min",
            difficulty: .beginner,
            tags: ["Hydration", "Moisture", "Rich", "Nourishing"],
            morningSteps: [
                "Cream Cleanser - Gentle, hydrating cleanse",
                "Hydrating Toner - Prep for moisture",
                "Hyaluronic Acid - Attract moisture",
                "Rich Serum - Nourish deeply",
                "Heavy Moisturizer - Lock in hydration",
                "Sunscreen - Protect and moisturize"
            ],
            eveningSteps: [
                "Cream Cleanser - Gentle, hydrating cleanse",
                "Hydrating Toner - Prep for moisture",
                "Hyaluronic Acid - Attract moisture",
                "Rich Serum - Nourish deeply",
                "Heavy Moisturizer - Lock in hydration",
                "Facial Oil - Extra nourishment"
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
            stepCount: 6,
            duration: "8-10 min",
            difficulty: .intermediate,
            tags: ["Balanced", "Multi-zone", "Adaptive", "Versatile"],
            morningSteps: [
                "Balancing Cleanser - Clean without stripping",
                "Toner - Balance different zones",
                "Lightweight Serum - Even application",
                "Adaptive Moisturizer - Light to medium weight",
                "Broad Spectrum Sunscreen - All-over protection"
            ],
            eveningSteps: [
                "Balancing Cleanser - Clean without stripping",
                "Toner - Balance different zones",
                "Lightweight Serum - Even application",
                "Zone-specific Treatment - Different areas",
                "Adaptive Moisturizer - Light to medium weight"
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
            stepCount: 12,
            duration: "25-30 min",
            difficulty: .advanced,
            tags: ["Complete", "Luxury", "Comprehensive", "Advanced"],
            morningSteps: [
                "Water Cleanser - Second cleanse",
                "Toner - Balance and prep",
                "Essence - Lightweight hydration",
                "Treatment Essence - Advanced treatment",
                "Serum - Targeted care",
                "Ampoule - Concentrated treatment",
                "Eye Cream - Delicate area",
                "Moisturizer - Lock in everything",
                "Sunscreen - Final protection"
            ],
            eveningSteps: [
                "Oil Cleanser - First cleanse",
                "Water Cleanser - Second cleanse",
                "Exfoliant - Remove dead skin",
                "Toner - Balance and prep",
                "Essence - Lightweight hydration",
                "Treatment Essence - Advanced treatment",
                "Serum - Targeted care",
                "Ampoule - Concentrated treatment",
                "Sheet Mask - Intensive treatment",
                "Eye Cream - Delicate area",
                "Moisturizer - Lock in everything"
            ],
            benefits: [
                "Complete skin transformation",
                "Maximum hydration",
                "Advanced anti-aging",
                "Luxury experience"
            ],
            isFeatured: false,
            isPremium: true,
            imageName: "routine-korean"
        ),
        RoutineTemplate(
            id: teenAcneId,
            title: "Teen Acne Fighter",
            description: "Gentle yet effective routine designed specifically for teenage skin and hormonal acne.",
            category: .acne,
            stepCount: 5,
            duration: "6-8 min",
            difficulty: .beginner,
            tags: ["Teen", "Hormonal", "Gentle", "Preventive"],
            morningSteps: [
                "Gentle Foaming Cleanser - Clean without irritation",
                "Salicylic Acid Toner - Prevent breakouts",
                "Lightweight Moisturizer - Hydrate without clogging",
                "Oil-free Sunscreen - Daily protection"
            ],
            eveningSteps: [
                "Gentle Foaming Cleanser - Clean without irritation",
                "Salicylic Acid Toner - Prevent breakouts",
                "Lightweight Moisturizer - Hydrate without clogging",
                "Spot Treatment - Target active pimples"
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
            stepCount: 8,
            duration: "15-18 min",
            difficulty: .advanced,
            tags: ["Mature", "Comprehensive", "Luxury", "Advanced"],
            morningSteps: [
                "Gentle Cleanser - Respect mature skin",
                "Vitamin C Serum - Brighten and protect",
                "Hyaluronic Acid - Plump and hydrate",
                "Rich Eye Cream - Target eye area",
                "Luxury Moisturizer - Nourish deeply",
                "Anti-aging Sunscreen - Complete protection"
            ],
            eveningSteps: [
                "Gentle Cleanser - Respect mature skin",
                "Retinol Treatment - Stimulate renewal",
                "Peptide Complex - Support structure",
                "Hyaluronic Acid - Plump and hydrate",
                "Rich Eye Cream - Target eye area",
                "Luxury Moisturizer - Nourish deeply"
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
