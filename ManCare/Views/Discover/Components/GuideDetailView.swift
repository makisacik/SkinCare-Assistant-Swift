//
//  GuideDetailView.swift
//  ManCare
//
//  Discover / Mini Guides — Parallax Header + Scroll Animation
//  iOS 16+
//
//  Drop this file in your project and present `GuideDetailView(sampleGuide)`
//  Make sure you have an image asset named "placeholder".
//
//  Highlights
//  - Full-bleed header image with parallax + stretchy pull-down
//  - Collapsing title into a compact top bar after a threshold
//  - Bottom gradient for legibility
//  - Smooth fade + scale transitions
//  - Simple renderer for common guide blocks (intro/h2/h3/paragraph/list/do/don't/tip/disclaimer/cta)

import SwiftUI

// MARK: - Model

struct Guide: Identifiable {
    let id: String
    var title: String
    var subtitle: String?
    var readMinutes: Int
    var updatedAt: Date
    var imageName: String // "placeholder"
    var content: [GuideContent]
}

struct GuideContent: Identifiable {
    let id = UUID()
    let type: ContentType
    let text: String?
    let items: [String]?
    let imageName: String?
    let caption: String?
    
    enum ContentType {
        case intro
        case h2
        case h3
        case paragraph
        case list
        case image
        case tip
        case disclaimer
    }
    
    init(type: ContentType, text: String? = nil, items: [String]? = nil, imageName: String? = nil, caption: String? = nil) {
        self.type = type
        self.text = text
        self.items = items
        self.imageName = imageName
        self.caption = caption
    }
}

// MARK: - Scroll Offset Preference

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View

struct GuideDetailView: View {
    // Config
    var guide: Guide
    var headerMaxHeight: CGFloat = 320
    var headerMinHeight: CGFloat = 84
    var collapseThreshold: CGFloat = 160 // when compact nav appears

    // State
    @State private var scrollY: CGFloat = 0 // negative when scrolled up
    @State private var showCompactBar: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: true) {
                // Track scroll in named coordinate space
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("GuideScroll")) .minY)
                    }
                    .frame(height: 0)

                    header

                    content
                }
            }
            .coordinateSpace(name: "GuideScroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollY = value
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCompactBar = (-value) > collapseThreshold
                }
            }

            // Compact top bar overlays as you scroll
            compactNavBar
                .opacity(showCompactBar ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: showCompactBar)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(red: 0.98, green: 0.96, blue: 0.94))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header
    private var header: some View {
        // Compute dynamic height
        let stretch = max(0, scrollY) // positive when pulling down
        let collapse = max(0, -scrollY) // positive when scrolling up
        let height = max(headerMinHeight, headerMaxHeight + stretch - collapse)

        return ZStack(alignment: .bottomLeading) {
            // Parallax image
            GeometryReader { geometry in
                Image(guide.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                            startPoint: .center, endPoint: .bottom
                        )
                    )
                    .offset(y: parallaxOffset(for: scrollY))
                    .scaleEffect(headerScale(for: scrollY))
                    .animation(.smooth(duration: 0.25), value: scrollY)
            }
        }
        .frame(height: headerMaxHeight) // layout baseline; actual image height animates
        .background(Color.clear)
    }

    // MARK: Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title area at top of content
            VStack(alignment: .leading, spacing: 8) {
                Text(guide.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .lineLimit(3)
                
                if let subtitle = guide.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .padding(.top, 4)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        Text("\(guide.readMinutes) min read")
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        Text(formatDate(from: guide.updatedAt))
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 24)
            
            ForEach(guide.content) { content in
                contentView(content)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .background(
            // Rounded top for the content area that sits under the image
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color(red: 0.98, green: 0.96, blue: 0.94))
                .offset(y: -24)
        )
        .padding(.top, -24) // pull content up to overlap header bottom
    }

    // MARK: Compact Nav Bar
    private var compactNavBar: some View {
        ZStack {
            // Blur background for readability
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(height: 56)
                .overlay(Divider(), alignment: .bottom)

            HStack(spacing: 12) {
                // Back button
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
                .buttonStyle(.plain)

                Text(guide.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    // MARK: - Content Renderer
    @ViewBuilder private func contentView(_ content: GuideContent) -> some View {
        switch content.type {
        case .intro:
            if let text = content.text {
                Text(text)
                    .font(.title3)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 16)
            }
        case .h2:
            if let text = content.text {
                Text(text)
                    .font(.title2.bold())
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .padding(.top, 32)
                    .padding(.bottom, 12)
            }
        case .h3:
            if let text = content.text {
                Text(text)
                    .font(.title3.bold())
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
            }
        case .paragraph:
            if let text = content.text {
                Text(text)
                    .font(.body)
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                    .padding(.bottom, 12)
            }
        case .list:
            if let items = content.items {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("•")
                                .font(.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            Text(LocalizedStringKey(item))
                                .font(.body)
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        case .image:
            if let imageName = content.imageName {
                VStack(alignment: .center, spacing: 8) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .cornerRadius(12)
                        .clipped()
                    
                    if let caption = content.caption {
                        Text(caption)
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 16)
            }
        case .tip:
            if let text = content.text {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#F59E0B"))

                    Text(text)
                        .font(.callout)
                        .foregroundColor(Color(hex: "#92400E"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FEF3C7"))
                )
                .padding(.vertical, 12)
            }
        case .disclaimer:
            if let text = content.text {
                Text(text)
                    .font(.footnote)
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
            }
        }
    }


    // MARK: Helpers
    private func parallaxOffset(for y: CGFloat) -> CGFloat {
        // Pull-down stretches (positive y), scroll-up parallax (negative y)
        if y > 0 { return -y * 0.4 }        // resist pull-down
        return y * 0.25                      // subtle parallax when scrolling up
    }

    private func headerScale(for y: CGFloat) -> CGFloat {
        // Slight scale on pull-down for a springy feel
        if y > 0 { return 1 + (min(y, 120) / 600) }
        return 1
    }

    private func formatDate(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df.string(from: date)
    }
}


// MARK: - Preview with sample data
struct GuideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GuideDetailView(guide: sampleGuide)
        }
        .environment(\.colorScheme, .light)
    }
}

// Sample guide for immediate testing
private let sampleGuide = Guide(
    id: "guide_cycle_skin_v1",
    title: "How Your Cycle Affects Skin",
    subtitle: "Adjust gently through each phase",
    readMinutes: 3,
    updatedAt: .now,
    imageName: "placeholder",
    content: [
        GuideContent(type: .intro, text: "Hormonal shifts can change oiliness, sensitivity, and hydration. Use this quick map to adjust without overhauling everything."),
        GuideContent(type: .h2, text: "The 4 Phases at a Glance"),
        GuideContent(type: .image, imageName: "placeholder", caption: "Visual guide to cycle phases and their effects on skin"),
        GuideContent(type: .list, items: [
            "Menstruation (Days 1–5): barrier may feel fragile; keep it gentle.",
            "Follicular (Days 6–13): often calmer; reintroduce light actives.",
            "Ovulation (≈Day 14): glow + potential T‑zone shine; balance sebum.",
            "Luteal (Days 15–28): increased congestion; avoid brand‑new harsh actives."
        ]),
        GuideContent(type: .h3, text: "Menstruation: Soothe & Protect"),
        GuideContent(type: .image, imageName: "placeholder", caption: "Gentle skincare products for sensitive days"),
        GuideContent(type: .paragraph, text: "Gentle cleanse, hydrating toner/essence, ceramide moisturizer; SPF AM."),
        GuideContent(type: .paragraph, text: "Don't introduce brand‑new strong acids/retinoids if extra sensitive."),
        GuideContent(type: .paragraph, text: "Humectants + a thin occlusive at night can reduce tightness."),
        GuideContent(type: .h3, text: "Luteal: Pre‑Period Breakouts"),
        GuideContent(type: .paragraph, text: "Spot treatment (BHA or benzoyl peroxide). Keep routine consistent."),
        GuideContent(type: .paragraph, text: "Avoid aggressive new peels while irritation is high."),
        GuideContent(type: .disclaimer, text: "Educational, not medical advice. Consult a professional for persistent concerns.")
    ]
)
