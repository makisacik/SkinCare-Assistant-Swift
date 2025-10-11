//
//  GuideContentService.swift
//  ManCare
//
//  Service to convert MiniGuide to full Guide with flexible content structure
//

import Foundation

class GuideContentService {
    
    /// Convert a MiniGuide to a full Guide with content
    func getGuide(for miniGuide: MiniGuide) -> Guide {
        let content = getContent(for: miniGuide)
        
        return Guide(
            id: miniGuide.id.uuidString,
            title: miniGuide.title,
            subtitle: miniGuide.subtitle,
            readMinutes: miniGuide.minutes,
            updatedAt: Date(),
            imageName: miniGuide.imageName,
            content: content
        )
    }
    
    private func getContent(for miniGuide: MiniGuide) -> [GuideContent] {
        switch miniGuide.title {
        case "Skincare 101: Build a basic routine":
            return skincare101Content
        case "How your cycle affects skin":
            return cycleSkinContent
        case "AM vs PM Routine":
            return ampmRoutineContent
        case "Acids, Explained":
            return acidsExplainedContent
        case "Retinoids 101":
            return retinoids101Content
        default:
            return defaultContent(for: miniGuide)
        }
    }
    
    private var skincare101Content: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Building a solid skincare routine doesn't have to be complicated. Start with these four essential steps and adjust as you learn what your skin needs."),
            GuideContent(type: .h2, text: "The 4-Step Foundation"),
            GuideContent(type: .list, items: [
                "Cleanse: Remove dirt, oil, and makeup twice daily",
                "Treat: Target specific concerns with serums or treatments",
                "Moisturize: Lock in hydration and protect your barrier",
                "Protect: Shield from UV damage with SPF during the day"
            ]),
            GuideContent(type: .h3, text: "Morning Routine"),
            GuideContent(type: .paragraph, text: "Cleanser → Treatment (if needed) → Moisturizer → SPF 30+"),
            GuideContent(type: .paragraph, text: "Keep morning treatments gentle to avoid irritation under makeup"),
            GuideContent(type: .h3, text: "Evening Routine"),
            GuideContent(type: .paragraph, text: "Cleanser → Treatment (actives work best at night) → Moisturizer"),
            GuideContent(type: .paragraph, text: "Don't mix strong actives without patch testing first"),
            GuideContent(type: .disclaimer, text: "Individual results may vary. Consult a dermatologist for persistent skin concerns.")
        ]
    }
    
    private var cycleSkinContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Hormonal shifts throughout your cycle can significantly impact your skin. Understanding these changes helps you adjust your routine for optimal results."),
            GuideContent(type: .h2, text: "The 4 Phases at a Glance"),
            GuideContent(type: .image, imageName: "placeholder", caption: "Visual guide showing how hormones affect skin throughout your cycle"),
            GuideContent(type: .list, items: [
                "Menstruation (Days 1–5): Skin may be sensitive and dry",
                "Follicular (Days 6–13): Usually calmer, good for introducing new products",
                "Ovulation (≈Day 14): Peak glow but potential oiliness",
                "Luteal (Days 15–28): Increased breakouts and sensitivity"
            ]),
            GuideContent(type: .h3, text: "Menstruation: Gentle Care"),
            GuideContent(type: .image, imageName: "placeholder", caption: "Gentle, hydrating products perfect for sensitive days"),
            GuideContent(type: .paragraph, text: "Use gentle, hydrating products. Focus on barrier repair."),
            GuideContent(type: .paragraph, text: "Avoid harsh exfoliants or strong actives if skin feels sensitive."),
            GuideContent(type: .h3, text: "Luteal Phase: Breakout Prevention"),
            GuideContent(type: .paragraph, text: "Spot treat with salicylic acid or benzoyl peroxide."),
            GuideContent(type: .paragraph, text: "Maintain consistent routine to prevent flare-ups."),
            GuideContent(type: .disclaimer, text: "Educational content only. Consult healthcare provider for medical advice.")
        ]
    }
    
    private var ampmRoutineContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Your skin has different needs throughout the day. Morning routines focus on protection, while evening routines emphasize repair and renewal."),
            GuideContent(type: .image, imageName: "placeholder", caption: "Morning vs evening routine comparison"),
            GuideContent(type: .h2, text: "Morning: Protection Mode"),
            GuideContent(type: .list, items: [
                "Gentle cleanser or water rinse",
                "Hydrating toner or essence",
                "Light moisturizer or serum",
                "SPF 30+ sunscreen (essential!)"
            ]),
            GuideContent(type: .h3, text: "Evening: Repair Mode"),
            GuideContent(type: .list, items: [
                "Thorough cleansing to remove sunscreen and makeup",
                "Treatment products (retinoids, acids, serums)",
                "Rich moisturizer or night cream",
                "Optional: face oil for extra hydration"
            ]),
            GuideContent(type: .paragraph, text: "Layer products from thinnest to thickest consistency"),
            GuideContent(type: .paragraph, text: "Don't skip SPF in the morning, even if staying indoors"),
            GuideContent(type: .paragraph, text: "Your evening routine is where actives work best"),
            GuideContent(type: .disclaimer, text: "Adjust routine based on your skin type and concerns.")
        ]
    }
    
    private var acidsExplainedContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Chemical exfoliants (acids) can transform your skin, but understanding which ones work for your skin type is key to success."),
            GuideContent(type: .h2, text: "Types of Acids"),
            GuideContent(type: .h3, text: "AHA (Alpha Hydroxy Acids)"),
            GuideContent(type: .list, items: [
                "Glycolic acid: Most potent, great for texture and fine lines",
                "Lactic acid: Gentler option, good for sensitive skin",
                "Mandelic acid: Largest molecule, least irritating"
            ]),
            GuideContent(type: .h3, text: "BHA (Beta Hydroxy Acid)"),
            GuideContent(type: .list, items: [
                "Salicylic acid: Oil-soluble, penetrates pores deeply",
                "Best for acne-prone and oily skin",
                "Can be used daily in lower concentrations"
            ]),
            GuideContent(type: .h3, text: "PHA (Polyhydroxy Acids)"),
            GuideContent(type: .list, items: [
                "Gentlest exfoliating acids",
                "Great for sensitive or barrier-compromised skin",
                "Provide hydration along with exfoliation"
            ]),
            GuideContent(type: .paragraph, text: "Start with low concentrations (2-5%) and use 2-3 times per week"),
            GuideContent(type: .paragraph, text: "Don't mix multiple acids or use with retinoids initially"),
            GuideContent(type: .paragraph, text: "Always use SPF when using acids, as they increase sun sensitivity"),
            GuideContent(type: .disclaimer, text: "Introduce acids gradually and patch test before full use.")
        ]
    }
    
    private var retinoids101Content: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Retinoids are the gold standard for anti-aging and acne treatment, but they require careful introduction and consistent use."),
            GuideContent(type: .h2, text: "Types of Retinoids"),
            GuideContent(type: .list, items: [
                "Retinol: Over-the-counter, good for beginners",
                "Retinaldehyde: More potent than retinol, less irritating than tretinoin",
                "Tretinoin: Prescription strength, most effective but can be harsh"
            ]),
            GuideContent(type: .h3, text: "Getting Started"),
            GuideContent(type: .list, items: [
                "Start with 0.1-0.25% retinol, 2-3 times per week",
                "Use the sandwich method: moisturizer → retinol → moisturizer",
                "Apply only at night and always use SPF during the day"
            ]),
            GuideContent(type: .h3, text: "The Purging Phase"),
            GuideContent(type: .list, items: [
                "Initial breakout period lasting 2-6 weeks",
                "Skin may become dry, flaky, or irritated",
                "This is normal and temporary"
            ]),
            GuideContent(type: .paragraph, text: "Be patient and consistent - results take 3-6 months"),
            GuideContent(type: .paragraph, text: "Don't give up during the purging phase"),
            GuideContent(type: .paragraph, text: "Buffer with moisturizer if irritation occurs"),
            GuideContent(type: .disclaimer, text: "Consult a dermatologist for prescription-strength retinoids.")
        ]
    }
    
    private func defaultContent(for miniGuide: MiniGuide) -> [GuideContent] {
        [
            GuideContent(type: .intro, text: "Learn more about \(miniGuide.category.lowercased()) and how it relates to your skincare routine."),
            GuideContent(type: .paragraph, text: "This guide will help you understand the fundamentals and make informed decisions about your skincare routine."),
            GuideContent(type: .h2, text: "Key Takeaways"),
            GuideContent(type: .list, items: [
                "Start with the basics and build gradually",
                "Listen to your skin and adjust as needed",
                "Consistency is more important than complexity"
            ]),
            GuideContent(type: .disclaimer, text: "Individual results may vary. Consult a professional for personalized advice.")
        ]
    }
}