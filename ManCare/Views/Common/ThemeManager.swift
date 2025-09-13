//  ThemeManager.swift
//  ManCare
//
//  Option A: Non-isolated type + MainActor APIs
//  Blue-centric palette (no green accents)

import SwiftUI

// MARK: - AppTheme

public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system, light, dark
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

// MARK: - Color Helpers

extension Color {
    /// Hex like "#1C2A44" or "1C2A44"
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (r, g, b) = (17, 26, 46) // fallback deep navy
        }
        self = Color(.sRGB,
                     red: Double(r) / 255,
                     green: Double(g) / 255,
                     blue: Double(b) / 255,
                     opacity: alpha)
    }
}

// MARK: - Palette

public struct ThemePalette: Equatable {
    // Core brand
    public let primary: Color      // Deep Navy
    public let secondary: Color    // Action Blue
    public let accent: Color       // Electric/Royal Blue

    // Text
    public let textPrimary: Color
    public let textSecondary: Color
    public let textMuted: Color

    // Backgrounds
    public let bg: Color
    public let card: Color
    public let separator: Color

    // States
    public let success: Color
    public let warning: Color
    public let error: Color

    // Shadows
    public let shadow: Color
}

// MARK: - Typography

public struct ThemeTypography: Equatable {
    public let h1: Font
    public let h2: Font
    public let h3: Font
    public let title: Font
    public let body: Font
    public let sub: Font
    public let caption: Font

    public static let `default` = ThemeTypography(
        h1: .system(size: 32, weight: .bold, design: .rounded),
        h2: .system(size: 24, weight: .semibold, design: .rounded),
        h3: .system(size: 20, weight: .semibold, design: .rounded),
        title: .system(size: 18, weight: .semibold, design: .default),
        body: .system(size: 16, weight: .regular, design: .default),
        sub: .system(size: 14, weight: .regular, design: .default),
        caption: .system(size: 12, weight: .medium, design: .rounded)
    )
}

// MARK: - Theme

public struct Theme: Equatable {
    public let palette: ThemePalette
    public let typo: ThemeTypography
    public let cornerRadius: CGFloat = 16
    public let cardRadius: CGFloat = 20
    public let padding: CGFloat = 16

    // Prebuilt themes (Blue-centric)
    public static let light = Theme(
        palette: ThemePalette(
            primary:      Color(hex: "#111A2E"),  // deep navy
            secondary:    Color(hex: "#2F6FED"),  // action blue
            accent:       Color(hex: "#6AA9FF"),  // electric highlight
            textPrimary:   Color(hex: "#0B1120"),
            textSecondary: Color(hex: "#334155"),
            textMuted:     Color(hex: "#64748B"),
            bg:            Color(hex: "#F6F8FB"),  // light blue-gray
            card:          Color.white,
            separator:     Color(hex: "#E5E7EB"),
            success:       Color(hex: "#16A34A"),
            warning:       Color(hex: "#F59E0B"),
            error:         Color(hex: "#EF4444"),
            shadow:        Color.black.opacity(0.08)
        ),
        typo: .default
    )

    public static let dark = Theme(
        palette: ThemePalette(
            primary:      Color(hex: "#111A2E"),
            secondary:    Color(hex: "#2F6FED"),
            accent:       Color(hex: "#6AA9FF"),
            textPrimary:   Color(hex: "#E2E8F0"),
            textSecondary: Color(hex: "#C7D2FE"), // subtle bluish secondary
            textMuted:     Color(hex: "#9AA5B1"),
            bg:            Color(hex: "#0B1220"),  // deep blue-black
            card:          Color(hex: "#111827"),  // near-black with blue tint
            separator:     Color.white.opacity(0.07),
            success:       Color(hex: "#16A34A"),
            warning:       Color(hex: "#F59E0B"),
            error:         Color(hex: "#F43F5E"),
            shadow:        Color.black.opacity(0.6)
        ),
        typo: .default
    )
}

// MARK: - ThemeManager (non-isolated type; UI APIs are MainActor)

public final class ThemeManager: ObservableObject {
    @AppStorage("app.theme.selection") private var storedSelection: String = AppTheme.system.rawValue
    @Published public private(set) var selection: AppTheme
    @Published public private(set) var theme: Theme

    // Shared instance
    public static let shared = ThemeManager()

    private init(colorScheme: ColorScheme? = nil) {
        let storedValue = UserDefaults.standard.string(forKey: "app.theme.selection") ?? AppTheme.system.rawValue
        let initial = AppTheme(rawValue: storedValue) ?? .system
        self.selection = initial
        self.theme = ThemeManager.resolveTheme(for: initial, colorScheme: colorScheme)
    }

    @MainActor
    public func apply(_ selection: AppTheme, colorScheme: ColorScheme? = nil) {
        self.selection = selection
        self.storedSelection = selection.rawValue
        self.theme = Self.resolveTheme(for: selection, colorScheme: colorScheme)
    }

    @MainActor
    public func refreshForSystemChange(_ colorScheme: ColorScheme?) {
        guard selection == .system else { return }
        self.theme = Self.resolveTheme(for: .system, colorScheme: colorScheme)
    }

    private static func resolveTheme(for selection: AppTheme, colorScheme: ColorScheme?) -> Theme {
        switch selection {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return (colorScheme == .dark) ? .dark : .light
        }
    }
}

// MARK: - Environment Injection

private struct ThemeManagerKey: EnvironmentKey {
    // Use shared instance by default
    static var defaultValue: ThemeManager { ThemeManager.shared }
}

public extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Sugar

public extension View {
    func themed(_ manager: ThemeManager) -> some View {
        environment(\.themeManager, manager)
    }
}

// MARK: - Reusable Modifiers

struct HeadlineStyle: ViewModifier {
    @Environment(\.themeManager) private var tm
    func body(content: Content) -> some View {
        content
            .font(tm.theme.typo.h2)
            .foregroundColor(tm.theme.palette.textPrimary)
    }
}

struct CardStyle: ViewModifier {
    @Environment(\.themeManager) private var tm
    func body(content: Content) -> some View {
        content
            .padding(tm.theme.padding)
            .background(tm.theme.palette.card)
            .cornerRadius(tm.theme.cardRadius)
            .shadow(color: tm.theme.palette.shadow, radius: 12, x: 0, y: 6)
    }
}

public extension View {
    func headline() -> some View { modifier(HeadlineStyle()) }
    func themedCard() -> some View { modifier(CardStyle()) }
}

// MARK: - Buttons

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.themeManager) private var tm
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(tm.theme.typo.title)
            .foregroundColor(Color.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(tm.theme.palette.secondary)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .cornerRadius(tm.theme.cornerRadius)
            .shadow(color: tm.theme.palette.shadow, radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

public struct GhostButtonStyle: ButtonStyle {
    @Environment(\.themeManager) private var tm
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(tm.theme.typo.body.weight(.semibold))
            .foregroundColor(tm.theme.palette.textPrimary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(tm.theme.palette.separator.opacity(0.35))
            .cornerRadius(tm.theme.cornerRadius)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
