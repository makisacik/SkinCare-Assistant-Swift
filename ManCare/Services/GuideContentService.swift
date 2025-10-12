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
        let headerImage = getHeaderImage(for: miniGuide)
        
        return Guide(
            id: miniGuide.id.uuidString,
            title: miniGuide.title,
            subtitle: miniGuide.subtitle,
            readMinutes: miniGuide.minutes,
            updatedAt: Date(),
            imageName: headerImage,
            content: content
        )
    }
    
    private func getHeaderImage(for miniGuide: MiniGuide) -> String {
        switch miniGuide.title {
        case "How your cycle affects skin":
            return "guide-cycle-1"
        case "AM vs PM Routine":
            return "guide-ampm-1"
        case "Acids, Explained":
            return "guide-acids-1"
        case "Retinoids":
            return "guide-retinol-1"
        case "Skinimalism & Minimal Routines":
            return "guide-minimalist-1"
        default:
            return miniGuide.imageName
        }
    }

    private func getContent(for miniGuide: MiniGuide) -> [GuideContent] {
        switch miniGuide.title {
        case "How your cycle affects skin":
            return cycleSkinContent
        case "AM vs PM Routine":
            return ampmRoutineContent
        case "Acids, Explained":
            return acidsExplainedContent
        case "Retinoids":
            return retinoids101Content
        case "Skinimalism & Minimal Routines":
            return skinimalismGuideContent
        default:
            return defaultContent(for: miniGuide)
        }
    }
    
    private var cycleSkinContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Hormonal shifts across your menstrual cycle influence hydration, oiliness, sensitivity, and glow. Knowing what to expect helps you tailor your routine each phase."),

            GuideContent(type: .h2, text: "Cycle Phases & Skin at a Glance"),
            GuideContent(type: .image, imageName: "content-cycle-1", caption: "Hormonal changes and skin responses through the cycle"),
            GuideContent(type: .list, items: [
                "Menstruation (Days 1–5): Skin feels dry, tight, fragile",
                "Follicular (Days 6–13): Skin calms and becomes more resilient",
                "Ovulation (≈ Day 14): Natural glow, possible shine in T-zone",
                "Luteal (Days 15–28): Oiliness, breakouts, sensitivity may rise"
            ]),

            GuideContent(type: .h3, text: "Menstruation – Repair & Hydrate"),
            GuideContent(type: .image, imageName: "content-cycle-2", caption: "Soothing care for your barrier during your period"),
            GuideContent(type: .paragraph, text: "With estrogen and progesterone low, skin is more vulnerable. Use mild, hydrating cleansers and barrier-repair moisturizers."),
            GuideContent(type: .paragraph, text: "Skip actives like retinoids or strong acids — your skin needs calm, not stress."),
            GuideContent(type: .tip, text: "Tip: Use a calming mask or compress to reduce inflammation."),

            GuideContent(type: .h3, text: "Follicular – Rebalance & Brighten"),
            GuideContent(type: .paragraph, text: "As estrogen rises, skin becomes clearer and more responsive. This is a good window to reintroduce gentle actives like vitamin C or mild exfoliants."),
            GuideContent(type: .list, items: [
                "Use mild exfoliation (AHA/BHA) 1–2× per week",
                "Apply brightening serums",
                "Keep consistent hydration"
            ]),

            GuideContent(type: .h3, text: "Ovulation – Glow & Maintain"),
            GuideContent(type: .paragraph, text: "At peak hormone levels, skin often looks radiant. But excess oil in the T-zone may appear."),
            GuideContent(type: .paragraph, text: "Switch to lighter moisturizers, double-cleanse if wearing makeup, and use a clay mask if needed."),
            GuideContent(type: .tip, text: "Pro Tip: It's a great time for photos or events — your skin tends to look its best."),

            GuideContent(type: .h3, text: "Luteal – Soothe & Prevent"),
            GuideContent(type: .paragraph, text: "Rising progesterone increases oil and inflammation, which can trigger breakouts."),
            GuideContent(type: .paragraph, text: "Focus on calming ingredients (niacinamide, zinc), spot treatments (salicylic acid, benzoyl peroxide), and avoid introducing anything new."),

            GuideContent(type: .h2, text: "Adaptive Routine Tips"),
            GuideContent(type: .paragraph, text: "Consider rotating a few formulas (hydrating, brightening, clarifying) depending on phase. This helps keep your skin balanced all month."),
        ]
    }


    
    private var ampmRoutineContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Your skin isn't the same all day — it behaves differently in **daylight** and **darkness**. By understanding those shifts, you can match your routine to support what your skin is trying to do."),

            GuideContent(type: .image, imageName: "content-ampm-1", caption: "Skin functions across day & night"),

            // — Morning Logic —
            GuideContent(type: .h2, text: "Morning: Defense & Stabilization"),
            GuideContent(type: .paragraph, text: "When the sun is up, your skin's job is **protection**. It faces UV rays, pollution, blue light, and environmental stressors. Using antioxidant ingredients and a good barrier helps it resist damage."),

            GuideContent(type: .h3, text: "Why Cleansing First Matters"),
            GuideContent(type: .paragraph, text: "Overnight, your skin secretes oils and sheds tiny debris. A **gentle cleanse** or even a splash of water clears that buildup without stripping — prepping your skin to absorb protective products."),

            GuideContent(type: .h3, text: "Antioxidants & Lightweight Serums"),
            GuideContent(type: .paragraph, text: "**Antioxidants** (like vitamin C or niacinamide) act like shields against free radicals from UV and pollution. Using them in the morning gives them maximum exposure time to neutralize stressors."),

            GuideContent(type: .tip, text: "**Pro Tip**: Apply vitamin C serum on slightly damp skin for better absorption. Wait 1-2 minutes before layering moisturizer."),

            GuideContent(type: .h3, text: "Moisturize to Reinforce the Barrier"),
            GuideContent(type: .paragraph, text: "A good moisturizer helps your skin **lock in hydration** and maintain barrier integrity — essential when outer stress is trying to pull moisture out."),

            GuideContent(type: .h3, text: "Sunscreen: The Non-Negotiable Step"),
            GuideContent(type: .paragraph, text: "Everything else sets the stage — but **sunscreen is your direct defense**. A broad-spectrum SPF shields skin from UV damage, which accelerates aging and pigmentation."),

            // — Evening Logic —
            GuideContent(type: .h2, text: "Evening: Repair & Renewal"),
            GuideContent(type: .paragraph, text: "At night, your skin shifts into **recovery mode**. Blood flow increases, repair enzymes activate, and your barrier becomes more permeable — this is your window for treatments."),

            GuideContent(type: .h3, text: "Double Cleanse When Needed"),
            GuideContent(type: .paragraph, text: "If you wore makeup, sunscreen, or encountered heavy pollution, start with an **oil or balm cleanser**, then follow with a gentle cleanser. You want a clean canvas so actives work better."),

            GuideContent(type: .h3, text: "Apply Actives When Skin Is More Receptive"),
            GuideContent(type: .paragraph, text: "In the evening, your skin more readily absorbs **actives** like retinoids, acids, peptides, or growth factors. Because protective demands are low, it's safer to use stronger ingredients."),

            GuideContent(type: .tip, text: "**Timing Tip**: Apply actives like retinoids on completely dry skin. Wait 20-30 minutes after cleansing to minimize irritation."),

            GuideContent(type: .h3, text: "Lock in with Richer Moisturizers"),
            GuideContent(type: .paragraph, text: "As barrier permeability is higher at night, applying a **richer moisturizer** or cream helps prevent excessive water loss and supports repair processes."),

            // — Examples to Illustrate —
            GuideContent(type: .h2, text: "Example Day vs Night Scenarios"),
            GuideContent(type: .paragraph, text: "Say you use a **vitamin C serum**: in the morning, it works to neutralize UV-induced free radicals all day. If you used that same vitamin C at night instead of something more reparative, you'd miss that daily protective window."),

            GuideContent(type: .paragraph, text: "Or consider **retinol**: it degrades in UV light. If used in the morning, it's less effective and more likely to irritate. At night, it can stimulate collagen repair with less risk."),

            GuideContent(type: .h2, text: "Key Principles to Remember"),
            GuideContent(type: .list, items: [
                "**Match ingredient to skin's priority**: protect in the day, repair at night.",
                "Go from **lightweight → heavier textures** (serum → cream) so absorption works.",
                "Avoid **layering too many actives** in one session; let skin rest.",
                "If your skin feels irritated, revert to **basics** (cleanse + hydrate) and reintroduce actives slowly."
            ]),

            GuideContent(type: .paragraph, text: "When you see morning and evening routines as **support systems** — not just checklists — you give each product the right time and purpose. Your skin will respond better when it feels respected and understood.")
        ]
    }


    
    private var acidsExplainedContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "Chemical exfoliants — or **\"acids\"** in skincare — gently dissolve the bonds between dead skin cells. Used well, they can help refine texture, brighten, and unclog pores. But to use them effectively, it helps to understand how they work and when to use each kind."),

            GuideContent(type: .image, imageName: "content-acids-1", caption: "Overview: how different acids work (AHA, BHA, PHA)"),

            GuideContent(type: .h2, text: "What Happens When You Use an Exfoliating Acid?"),
            GuideContent(type: .paragraph, text: "Your skin naturally sheds dead cells over time — but sometimes that process slows, leading to **dullness, roughness, and clogged pores**. Acids act like gentle unlockers, breaking down the glue (desmosomes) between those cells so they can slough off more smoothly. When used properly, this supports renewal without harsh scrubbing."),

            GuideContent(type: .h2, text: "Major Categories & When They Shine"),


            GuideContent(type: .h3, text: "AHAs — Alpha Hydroxy Acids"),
            GuideContent(type: .paragraph, text: "AHAs are **water-soluble**, working mostly on the skin's surface. They're great for smoothing texture, fading discoloration, and improving radiance. But because they penetrate relatively deeply, they may cause sensitivity — especially on thinner or drier skin."),
            GuideContent(type: .list, items: [
                "**Glycolic acid** — smallest molecule, most potent; good for texture, dullness, fine lines",
                "**Lactic acid** — gentler and hydrating; better for sensitive or dry skin",
                "**Mandelic acid** — larger molecule, slower penetration; often better tolerated by reactive skin"
            ]),
            GuideContent(type: .paragraph, text: "**Example**: If your skin feels rough or uneven, you might use a 5–10% glycolic or lactic product a few nights a week to help resurface gradually."),

            GuideContent(type: .tip, text: "**Starter Tip**: Begin with lactic acid (5-8%) instead of glycolic if you have sensitive or dry skin — it's gentler and more hydrating."),

            GuideContent(type: .h3, text: "BHAs — Beta Hydroxy Acids"),
            GuideContent(type: .paragraph, text: "BHAs (mainly salicylic acid) are **oil-soluble**, which means they can penetrate into sebum within the pores. This makes them especially useful for oily, acne-prone, or congested skin types."),
            GuideContent(type: .list, items: [
                "**Salicylic acid**: dissolves oil, can reduce inflammation, unclogs pores",
                "Used for **blackheads**, clogged pores, and blemishes",
                "Lower concentrations (0.5–2%) can be used more regularly if tolerated"
            ]),
            GuideContent(type: .paragraph, text: "**Example**: If you often get clogged pores or breakouts, a BHA toner or serum (e.g. ~1%) can help smooth and purify your skin without over-exfoliating."),

            GuideContent(type: .h3, text: "PHAs — Polyhydroxy Acids"),
            GuideContent(type: .paragraph, text: "PHAs are the **gentlest** of the exfoliating acids. Their larger molecular size means they penetrate less deeply, making them good options for sensitive, barrier-weakened, or reactive skin."),
            GuideContent(type: .list, items: [
                "**Gluconolactone, lactobionic acid, galactose** — common PHA types",
                "Provide mild exfoliation while also attracting **moisture** or acting as antioxidants",
                "Lower irritation risk, even for delicate or sensitized skin"
            ]),
            GuideContent(type: .paragraph, text: "**Example**: If your skin flares easily, starting with a 2–5% PHA a few times a week gives you gentler exfoliation with reduced risk."),

            GuideContent(type: .h2, text: "Smart Strategies & Safety Tips"),
            GuideContent(type: .paragraph, text: "To enjoy the benefits while keeping irritation low, follow these guiding principles:"),
            GuideContent(type: .list, items: [
                "**Start low**: low concentration, fewer nights a week (e.g. 2–3×) before increasing frequency or strength",
                "Introduce **only one acid** or active at a time so your skin can adjust",
                "Avoid layering **strong actives** (like retinoids or multiple acids) on the same night initially",
                "**Always use broad-spectrum SPF** — acids increase sun sensitivity",
                "Watch your skin's signals — **tingling is normal**, burning or persistent redness is not"
            ]),

            GuideContent(type: .tip, text: "**Recovery Tip**: If you experience irritation, skip acids for 3-5 days and focus on gentle cleansing + barrier repair (ceramides, hyaluronic acid). Your skin needs recovery, not more exfoliation."),

            GuideContent(type: .h2, text: "How to Fit Acids Into Your Routine"),
            GuideContent(type: .paragraph, text: "Here are a few example patterns to help you slot in acids without disrupting your core care:"),
            GuideContent(type: .paragraph, text: "• **Night Routine (3×/week)**: Cleanse → apply acid → wait a few minutes → hydrating serum → moisturizer\n\n• **Alternate Nights**: Use BHA one night, AHA another, and keep some nights for barrier recovery (no actives)\n\n• **Separation**: If you use an acid and a retinoid, consider using them on different nights until your skin adjusts."),

            GuideContent(type: .image, imageName: "content-acids-2", caption: "Example skin-friendly layering: acid → hydrating → barrier support"),

            GuideContent(type: .paragraph, text: "Over time, your skin may tolerate stronger formulas or more frequent use — but always move **slowly**. Let the skin adapt. **Exfoliation is a tool, not a race**.")
        ]
    }

    
    private var retinoids101Content: [GuideContent] {
        [
            GuideContent(type: .intro, text: "**Retinoids** — derivatives of vitamin A — are among the most studied and effective tools for smoothing texture, fading discoloration, and managing breakouts. But the benefits come with nuance: you need to introduce them **thoughtfully** and let them work over time."),

            GuideContent(type: .image, imageName: "content-retinol-1", caption: "How retinoids work at a cellular level"),

            GuideContent(type: .h2, text: "What Retinoids Do & Why They're Powerful"),
            GuideContent(type: .paragraph, text: "Retinoids improve skin by **accelerating cellular turnover** (encouraging older cells to shed), **stimulating collagen production**, and helping regulate pigmentation. Over weeks and months, this can translate to smoother skin, fewer clogged pores, and a more even tone."),

            GuideContent(type: .h2, text: "Types of Retinoids & Potency"),
            GuideContent(type: .h3, text: "Retinol"),
            GuideContent(type: .paragraph, text: "Available over the counter, **retinol** is milder and must convert in your skin to retinoic acid to become active. Because of this conversion step, it's **gentler** and better tolerated by beginners."),

            GuideContent(type: .h3, text: "Retinaldehyde (Retinal)"),
            GuideContent(type: .paragraph, text: "A **mid-strength option**. It requires fewer conversion steps than retinol, so it tends to act faster with moderate irritation risk."),

            GuideContent(type: .h3, text: "Prescription Retinoids (e.g. Tretinoin)"),
            GuideContent(type: .paragraph, text: "These are already in the **active form** (retinoic acid), so they are the **strongest**. They often deliver faster results, but also higher risk of irritation, especially in early phases."),

            GuideContent(type: .image, imageName: "content-retinol-2", caption: "Comparative strength: retinol vs retinal vs tretinoin"),

            GuideContent(type: .h2, text: "How to Start & Build Tolerance"),
            GuideContent(type: .paragraph, text: "Because retinoids can cause **dryness, flaking, or sensitivity** initially, the key is to start slow and build over time."),

            GuideContent(type: .list, items: [
                "Begin with a low-strength formulation (e.g. 0.1 % retinol) 2–3 nights per week",
                "Use the **\"sandwich\" method**: apply a thin layer of moisturizer → retinoid → another thin layer of moisturizer to buffer",
                "**Always apply at night** (retinoids are photosensitive and can degrade in daylight)",
                "Use **broad-spectrum SPF** the next day — retinoids make your skin more sensitive to UV"
            ]),

            GuideContent(type: .tip, text: "**Beginner's Tip**: If you're completely new to retinoids, start with retinol 0.1% only once a week for the first 2 weeks. This helps your skin build tolerance without overwhelming it."),

            GuideContent(type: .h2, text: "The Purging Phase & What to Expect"),
            GuideContent(type: .paragraph, text: "In the first few weeks, your skin may flare with **breakouts, peeling, or dryness** as the retinoid accelerates cell turnover. This is often called the **\"purging\" period**. It usually lasts 2–6 weeks, depending on skin sensitivity and the formulation strength."),

            GuideContent(type: .h3, text: "Tips During Purging"),
            GuideContent(type: .paragraph, text: "**Stick with your routine** (unless there's severe irritation). Use **gentle, comforting products** (hydrating, barrier support). Don't layer too many actives (e.g. strong acids + retinoids on same night) until your skin adjusts."),

            GuideContent(type: .tip, text: "**Purging vs. Reaction**: Purging happens in areas where you usually break out and subsides in 4-6 weeks. If new areas break out or irritation persists beyond 8 weeks, it's likely a reaction — reduce frequency or stop."),

            GuideContent(type: .h2, text: "Examples & Scenarios"),
            GuideContent(type: .paragraph, text: "• If you're new: start with 0.1 % retinol 3 nights/week, moisturize before and after.\n• After 2 months of tolerance, you might increase to 4 nights or try a slightly higher strength.\n• If your skin becomes flaky or sensitive, reduce frequency or use buffers (moisturizers or hydrating serums)."),

            GuideContent(type: .h2, text: "Helpful Principles to Remember"),
            GuideContent(type: .list, items: [
                "**Progress slowly** — consistency trumps aggression",
                "**Less can be more** — a small amount is enough (pea-sized for face)",
                "If irritation is **intense or persistent**, scale back and regroup",
                "**Patience is key** — visible results often begin after 8–12 weeks"
            ]),

            GuideContent(type: .paragraph, text: "When you understand not just **what** to use but **why** and **how**, you give your skin a better chance to adapt, respond, and improve — without undue stress or setbacks.")
        ]
    }

    private var skinimalismGuideContent: [GuideContent] {
        [
            GuideContent(type: .intro, text: "**Skinimalism** encourages a shift from product overload to **deliberate simplicity** — using fewer, smarter choices to support your skin's natural rhythm."),

            GuideContent(type: .image, imageName: "content-minimalist-1", caption: "Skinimalism: fewer products, more skin health"),

            GuideContent(type: .h2, text: "Why Minimal Works Better Sometimes"),
            GuideContent(type: .paragraph, text: "Your skin is already doing a lot: **protecting, repairing, renewing**. Too many actives or layers can stress its barrier, confuse signals, or cause ingredient conflicts. Minimal routines reduce these stress hits."),
            GuideContent(type: .paragraph, text: "Plus, when you use **fewer products**, you can see how your skin reacts to each one — this makes diagnosing issues easier."),

            GuideContent(type: .tip, text: "**Simplification Tip**: If you're overwhelmed by a 10-step routine, strip it down to cleanse + moisturize + SPF for 2 weeks. Watch how your skin responds, then reintroduce one product at a time."),

            GuideContent(type: .h2, text: "The Foundation Trio"),
            GuideContent(type: .list, items: [
                "**Cleanse gently** — remove dirt, oil, and pollution without stripping",
                "**Moisturize** — supply lipids, water, and barrier support",
                "**Sun protection (daytime)** — shield from UV, which accelerates aging"
            ]),
            GuideContent(type: .paragraph, text: "Even these **three steps** can do a lot if you choose well-formulated, skin-friendly versions."),

            GuideContent(type: .h2, text: "When & How to Add a \"Hero\" Product"),
            GuideContent(type: .paragraph, text: "If your skin needs something extra (brightening, mild exfoliation, hydration boost), pick **one product that can do multiple jobs**. For example, a niacinamide + antioxidant serum or a gentle exfoliant with hydrating support."),
            GuideContent(type: .paragraph, text: "Introduce new products **one at a time**, and give your skin **4–8 weeks to adapt**."),

            GuideContent(type: .tip, text: "**Multi-Tasker Pick**: Look for products that combine benefits — like a moisturizer with SPF, or a serum with niacinamide + vitamin C. This reduces steps without sacrificing results."),

            GuideContent(type: .h2, text: "Example Minimal Routine"),
            GuideContent(type: .paragraph, text: "• **Morning**: Gentle cleanser → lightweight moisturizer → SPF\n• **Evening**: Mild cleanser → (optional) hero serum → richer moisturizer or barrier support cream"),
            GuideContent(type: .paragraph, text: "If your skin tolerates it, you can **alternate nights** for actives (e.g. exfoliant night, recovery night) — but keep layering light."),

            GuideContent(type: .h2, text: "Common Challenges & Solutions"),
            GuideContent(type: .list, items: [
                "**My skin is reactive** → go slower, buffer with extra moisturizer",
                "**I want more glow** → choose antioxidants or brightening ingredients rather than layering many serums",
                "**Skipping steps feels risky** → remember: your foundation trio already covers the essentials",
                "**I still want to treat acne / pigmentation** → use spot treatments or alternate nights rather than daily layering"
            ]),

            GuideContent(type: .paragraph, text: "**Minimal doesn't mean underpowered** — it means intentional. When each product has a purpose, your skin can **breathe, adapt, and thrive**.")
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
