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
            title: miniGuide.localizedTitle,
            subtitle: miniGuide.localizedSubtitle,
            readMinutes: miniGuide.minutes,
            updatedAt: Date(),
            imageName: headerImage,
            content: content
        )
    }
    
    private func getHeaderImage(for miniGuide: MiniGuide) -> String {
        // Use guideKey to determine header image
        switch miniGuide.guideKey {
        case "cycleSkin":
            return "guide-cycle-1"
        case "ampmRoutine":
            return "guide-ampm-1"
        case "acidsExplained":
            return "guide-acids-1"
        case "retinoids101":
            return "guide-retinol-1"
        case "skinimalism":
            return "guide-minimalist-1"
        default:
            return miniGuide.imageName
        }
    }

    private func getContent(for miniGuide: MiniGuide) -> [GuideContent] {
        // Use guideKey to determine content
        switch miniGuide.guideKey {
        case "cycleSkin":
            return cycleSkinContent
        case "ampmRoutine":
            return ampmRoutineContent
        case "acidsExplained":
            return acidsExplainedContent
        case "retinoids101":
            return retinoids101Content
        case "skinimalism":
            return skinimalismGuideContent
        default:
            return defaultContent(for: miniGuide)
        }
    }
    
    private var cycleSkinContent: [GuideContent] {
        let key = "cycleSkin"
        return [
            GuideContent(type: .intro, text: L10n.Guides.intro(key)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 1)),
            GuideContent(type: .image, imageName: "content-cycle-1", caption: nil),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 4)
            ]),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 1)),
            GuideContent(type: .image, imageName: "content-cycle-2", caption: nil),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 1)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 3)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 3)
            ]),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 5)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 6)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 7)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 8)),
        ]
    }


    
    private var ampmRoutineContent: [GuideContent] {
        let key = "ampmRoutine"
        return [
            GuideContent(type: .intro, text: L10n.Guides.intro(key)),
            GuideContent(type: .image, imageName: "content-ampm-1", caption: nil),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 1)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 3)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 1)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 4)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 5)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 6)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 5)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 7)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 6)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 8)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 7)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 9)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 10)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 11)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 4)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 4)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 12))
        ]
    }


    
    private var acidsExplainedContent: [GuideContent] {
        let key = "acidsExplained"
        return [
            GuideContent(type: .intro, text: L10n.Guides.intro(key)),
            GuideContent(type: .image, imageName: "content-acids-1", caption: nil),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 1)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 3)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 3)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 1)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 4)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 3)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 5)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 6)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 3, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 3, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 3, itemIndex: 3)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 7)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 8)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 4, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 4, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 4, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 4, itemIndex: 4),
                L10n.Guides.listItem(key, listIndex: 4, itemIndex: 5)
            ]),
            GuideContent(type: .tip, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 9)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 10)),
            GuideContent(type: .image, imageName: "content-acids-2", caption: nil),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 11))
        ]
    }

    
    private var retinoids101Content: [GuideContent] {
        let key = "retinoids101"
        return [
            GuideContent(type: .intro, text: L10n.Guides.intro(key)),
            GuideContent(type: .image, imageName: "content-retinol-1", caption: nil),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 1)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 2)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 3)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 4)),
            GuideContent(type: .image, imageName: "content-retinol-2", caption: nil),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 5)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 4)
            ]),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 1)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 6)),
            GuideContent(type: .h3, text: L10n.Guides.heading(key, level: "h3", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 7)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 2)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 5)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 8)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 6)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 4)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 9))
        ]
    }

    private var skinimalismGuideContent: [GuideContent] {
        let key = "skinimalism"
        return [
            GuideContent(type: .intro, text: L10n.Guides.intro(key)),
            GuideContent(type: .image, imageName: "content-minimalist-1", caption: nil),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 1)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 2)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 1)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 2)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 1, itemIndex: 3)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 3)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 3)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 5)),
            GuideContent(type: .tip, text: L10n.Guides.tip(key, index: 2)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 4)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 6)),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 7)),
            GuideContent(type: .h2, text: L10n.Guides.heading(key, level: "h2", index: 5)),
            GuideContent(type: .list, items: [
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 1),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 2),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 3),
                L10n.Guides.listItem(key, listIndex: 2, itemIndex: 4)
            ]),
            GuideContent(type: .paragraph, text: L10n.Guides.paragraph(key, index: 8))
        ]
    }
    
    private func defaultContent(for miniGuide: MiniGuide) -> [GuideContent] {
        let category = miniGuide.localizedCategory.lowercased()
        return [
            GuideContent(type: .intro, text: L10n.Guides.defaultIntro(category)),
            GuideContent(type: .paragraph, text: L10n.Guides.defaultParagraph(1)),
            GuideContent(type: .h2, text: L10n.Guides.defaultHeading("h2", index: 1)),
            GuideContent(type: .list, items: [
                L10n.Guides.defaultListItem(1, itemIndex: 1),
                L10n.Guides.defaultListItem(1, itemIndex: 2),
                L10n.Guides.defaultListItem(1, itemIndex: 3)
            ]),
            GuideContent(type: .disclaimer, text: L10n.Guides.defaultDisclaimer)
        ]
    }
}
