//  ThemeManager.swift
//  ManCare
//
//  Simplified theme system with #7D5A5A color palette

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
    /// Hex like "#7D5A5A" or "7D5A5A"
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (r, g, b) = (125, 90, 90) // fallback to base color
        }
        self = Color(.sRGB,
                     red: Double(r) / 255,
                     green: Double(g) / 255,
                     blue: Double(b) / 255,
                     opacity: alpha)
    }
}

// MARK: - Simplified Palette

public struct ThemePalette: Equatable {
    // Primary Colors (based on #7D5A5A)
    public let primary: Color              // #7D5A5A (main brand color)
    public let primaryLight: Color         // #9A6B6B (lighter variant)
    public let onPrimary: Color            // #FFFFFF

    // Secondary Colors (calendar background)
    public let secondary: Color            // #B5828C (calendar background)
    public let secondaryLight: Color       // #C896A0 (lighter calendar background)
    public let onSecondary: Color          // #FFFFFF (white text)

    // Background Colors (neutral grays)
    public let background: Color           // #F8F6F6 (very light neutral gray)
    public let surface: Color              // #F0F0F0 (light neutral gray)
    public let surfaceAlt: Color           // #E8E8E8 (medium neutral gray)
    public let onBackground: Color         // #2C1E1E (dark text)
    public let onSurface: Color            // #2C1E1E (dark text)

    // Border and Separator
    public let border: Color               // #C0B8B8 (neutral gray border)
    public let separator: Color            // #C0B8B8 (same as border)

    // Text Colors
    public let textPrimary: Color          // #2C1E1E (dark brown)
    public let textSecondary: Color        // #5A4A4A (medium brown)
    public let textMuted: Color            // #8A7A7A (light brown)
    public let textInverse: Color          // #FFFFFF

    // Feedback Colors
    public let success: Color              // #4A7D5A (green)
    public let warning: Color              // #7D7D4A (yellow-brown)
    public let error: Color                // #7D4A4A (red-brown)
    public let info: Color                 // #4A5A7D (blue-brown)
    public let onSuccess: Color            // #FFFFFF
    public let onWarning: Color            // #2C1E1E<<<
    public let onError: Color              // #FFFFFF
    public let onInfo: Color               // #FFFFFF

    // Utility Colors
    public let shadow: Color               // #0000003D (24% opacity)
    public let disabledBg: Color           // #E0D8D8 (disabled background)
    public let disabledText: Color         // #A8A19A (disabled text)

    // Card and Component Colors
    public let cardBackground: Color       // #F2F0F0 (card background)
    public let accentBackground: Color     // #F5F3F3 (accent background)
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

    // Simplified theme with #7D5A5A color palette
    public static let light = Theme(
        palette: ThemePalette(
            // Primary Colors
            primary: Color(hex: "#B5828C"),
            primaryLight: Color(hex: "#B5828C"),
            onPrimary: Color(hex: "#FFFFFF"),

            // Secondary Colors
            secondary: Color(hex: "#B5828C"),
            secondaryLight: Color(hex: "#C896A0"),
            onSecondary: Color(hex: "#FFFFFF"),

            // Background Colors
            background: Color(hex: "#F3E1E1"),
            surface: Color(hex: "#F6EDF7"),
            surfaceAlt: Color(hex: "#FDF3EF"),
            onBackground: Color(hex: "#2C1E1E"),
            onSurface: Color(hex: "#2C1E1E"),

            // Border and Separator
            border: Color(hex: "#C0B8B8"),
            separator: Color(hex: "#C0B8B8"),

            // Text Colors
            textPrimary: Color(hex: "#2C1E1E"),
            textSecondary: Color(hex: "#5A4A4A"),
            textMuted: Color(hex: "#8A7A7A"),
            textInverse: Color(hex: "#FFFFFF"),

            // Feedback Colors
            success: Color(hex: "#4A7D5A"),
            warning: Color(hex: "#7D7D4A"),
            error: Color(hex: "#7D4A4A"),
            info: Color(hex: "#4A5A7D"),
            onSuccess: Color(hex: "#FFFFFF"),
            onWarning: Color(hex: "#2C1E1E"),
            onError: Color(hex: "#FFFFFF"),
            onInfo: Color(hex: "#FFFFFF"),

            // Utility Colors
            shadow: Color(hex: "#0000003D"),
            disabledBg: Color(hex: "#E0D8D8"),
            disabledText: Color(hex: "#A8A19A"),

            // Card and Component Colors
            cardBackground: Color(hex: "#F2F0F0"),
            accentBackground: Color(hex: "#F5F3F3")
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
        // Always use light theme with #7D5A5A color palette
        return .light
    }
}

// MARK: - Direct Access (Singleton Pattern)

// ThemeManager is now accessed directly via ThemeManager.shared
// No need for environment injection or themed() modifier

// MARK: - Reusable Modifiers

struct HeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ThemeManager.shared.theme.typo.h2)
            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ThemeManager.shared.theme.padding)
            .background(ThemeManager.shared.theme.palette.cardBackground)
            .cornerRadius(ThemeManager.shared.theme.cardRadius)
            .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 12, x: 0, y: 6)
    }
}

public extension View {
    func headline() -> some View { modifier(HeadlineStyle()) }
    func themedCard() -> some View { modifier(CardStyle()) }
}

// MARK: - Buttons

public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeManager.shared.theme.typo.title)
            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? ThemeManager.shared.theme.palette.primaryLight : ThemeManager.shared.theme.palette.primary)
            .cornerRadius(ThemeManager.shared.theme.cornerRadius)
            .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

public struct GhostButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
            .foregroundColor(ThemeManager.shared.theme.palette.primary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? ThemeManager.shared.theme.palette.surface : Color.clear)
            .cornerRadius(ThemeManager.shared.theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cornerRadius)
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeManager.shared.theme.typo.title)
            .foregroundColor(ThemeManager.shared.theme.palette.onSecondary)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? ThemeManager.shared.theme.palette.secondaryLight : ThemeManager.shared.theme.palette.secondary)
            .cornerRadius(ThemeManager.shared.theme.cornerRadius)
            .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

public struct DestructiveButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeManager.shared.theme.typo.title)
            .foregroundColor(ThemeManager.shared.theme.palette.onError)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(ThemeManager.shared.theme.palette.error)
            .cornerRadius(ThemeManager.shared.theme.cornerRadius)
            .shadow(color: ThemeManager.shared.theme.palette.shadow, radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Component Color Extensions

public extension ThemePalette {
    // Navigation & Shell
    var topAppBarBackground: Color { primary }
    var topAppBarText: Color { onPrimary }
    var tabBarBackground: Color { background }
    var tabBarActiveIcon: Color { primary }
    var tabBarInactiveIcon: Color { textSecondary }
    var tabBarIndicator: Color { primary }

    // Cards & Surfaces
    var cardSurface: Color { surface }
    var cardTitle: Color { textPrimary }
    var cardBody: Color { textSecondary }
    var cardBorder: Color { border }
    var highlightedPanelBackground: Color { surfaceAlt }
    var highlightedPanelText: Color { textPrimary }

    // Input Fields
    var fieldBackground: Color { textInverse }
    var fieldText: Color { textPrimary }
    var fieldPlaceholder: Color { textMuted }
    var fieldStrokeDefault: Color { border }
    var fieldStrokeFocus: Color { primary }
    var fieldHelperError: Color { error }

    // Lists & Rows
    var rowBackground: Color { textInverse }
    var rowSeparator: Color { border }
    var swipeSelectionTint: Color { primary }

    // Feedback & Overlays
    var toastInfoBackground: Color { info }
    var toastInfoText: Color { onInfo }
    var toastSuccessBackground: Color { success }
    var toastSuccessText: Color { onSuccess }
    var toastWarningBackground: Color { warning }
    var toastWarningText: Color { onWarning }
    var toastErrorBackground: Color { error }
    var toastErrorText: Color { onError }
    var modalOverlay: Color { shadow }

    // Progress & Charts
    var progressActive: Color { secondary }
    var progressTrack: Color { border }
    var chartPrimary: Color { primary }
    var chartSecondary: Color { primaryLight }
    var chartPositive: Color { success }
    var chartNegative: Color { error }

    // Badges & Highlights
    var badgeBackground: Color { primary }
    var badgeText: Color { onPrimary }
    var highlightPillBackground: Color { accentBackground }
    var highlightPillText: Color { textPrimary }
}

// MARK: - Additional View Modifiers

public struct InputFieldStyle: ViewModifier {
    @FocusState private var isFocused: Bool

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ThemeManager.shared.theme.palette.fieldBackground)
            .foregroundColor(ThemeManager.shared.theme.palette.fieldText)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeManager.shared.theme.cornerRadius)
                    .stroke(isFocused ? ThemeManager.shared.theme.palette.fieldStrokeFocus : ThemeManager.shared.theme.palette.fieldStrokeDefault, lineWidth: 1)
            )
            .cornerRadius(ThemeManager.shared.theme.cornerRadius)
            .focused($isFocused)
    }
}

public struct BadgeStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(ThemeManager.shared.theme.typo.caption)
            .foregroundColor(ThemeManager.shared.theme.palette.badgeText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ThemeManager.shared.theme.palette.badgeBackground)
            .cornerRadius(12)
    }
}

public struct HighlightPillStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(ThemeManager.shared.theme.typo.caption)
            .foregroundColor(ThemeManager.shared.theme.palette.highlightPillText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(ThemeManager.shared.theme.palette.highlightPillBackground)
            .cornerRadius(16)
    }
}

public extension View {
    func inputFieldStyle() -> some View { modifier(InputFieldStyle()) }
    func badgeStyle() -> some View { modifier(BadgeStyle()) }
    func highlightPillStyle() -> some View { modifier(HighlightPillStyle()) }
}
