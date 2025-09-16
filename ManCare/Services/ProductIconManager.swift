//
//  ProductIconManager.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Product Icon Manager

/// Manages custom product icons for different product types
class ProductIconManager {
    
    // MARK: - Available Custom Icons
    
    /// Available custom product icon assets
    enum CustomIcon: String, CaseIterable {
        case bottleCleanserBlue = "bottle-cleanser-blue"
        case exfoliatorOrange = "exfoliator-orange"
        case jarMoisturizerGreen = "jar-moisturizer-green"
        case serumIndigo = "serum-indigo"
        case sunScreenYellow = "sun-screen-yellow"
        case tonerBottlePurple = "toner-buttle-purple" // Note: keeping original typo in asset name
        
        var displayName: String {
            switch self {
            case .bottleCleanserBlue: return "Cleanser Bottle"
            case .exfoliatorOrange: return "Exfoliator"
            case .jarMoisturizerGreen: return "Moisturizer Jar"
            case .serumIndigo: return "Serum Bottle"
            case .sunScreenYellow: return "Sunscreen"
            case .tonerBottlePurple: return "Toner Bottle"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Get a consistent icon name for any product type or step name
    /// Uses deterministic hashing to ensure the same input always gets the same icon
    static func getIconName(for input: String) -> String {
        let icons = CustomIcon.allCases
        let hash = input.hashValue
        let index = abs(hash) % icons.count
        return icons[index].rawValue
    }
    
    /// Get icon name for a ProductType
    static func getIconName(for productType: ProductType) -> String {
        return getIconName(for: productType.rawValue)
    }
    
    /// Get icon name for a step name
    static func getIconNameForStepName(_ stepName: String) -> String {
        return getIconName(for: stepName)
    }
    
    /// Get icon name for routine step based on step content
    static func getStepIconName(for step: String) -> String {
        return getIconName(for: step)
    }
    
    /// Get all available custom icons
    static func getAllCustomIcons() -> [CustomIcon] {
        return CustomIcon.allCases
    }
    
    /// Get the fallback icon (exfoliator-orange)
    static func getFallbackIcon() -> String {
        return CustomIcon.exfoliatorOrange.rawValue
    }
    
}

// MARK: - SwiftUI Image Extension

extension Image {
    /// Create an Image from a ProductType using custom icons
    init(productType: ProductType) {
        let iconName = ProductIconManager.getIconName(for: productType)
        self.init(iconName)
    }
    
    /// Create an Image from a step name using custom icons
    init(stepName: String) {
        let iconName = ProductIconManager.getIconNameForStepName(stepName)
        self.init(iconName)
    }
    
    /// Create an Image for product/step icons - always uses one of the 6 available assets
    /// For system UI icons, use Image(systemName:) directly
    static func productIcon(for input: String) -> Image {
        // System icons that should stay as system icons
        let systemIcons = [
            "sun.max.fill", "moon.fill", "moon.circle.fill", "moon.stars.fill",
            "calendar", "chevron.right", "chevron.left", "chevron.up", "chevron.down",
            "checkmark", "checkmark.circle.fill", "xmark.circle.fill", "plus.circle.fill",
            "minus.circle.fill", "play.circle.fill", "pause.circle.fill", "arrow.right",
            "arrow.left", "arrow.clockwise", "camera.viewfinder", "text.viewfinder",
            "magnifyingglass", "slider.horizontal.3", "timer", "forward.fill",
            "pause.fill", "play.fill", "lightbulb.fill", "party.popper.fill",
            "bookmark", "clock", "list.bullet", "bell.fill", "pencil",
            "line.3.horizontal", "link.badge.minus", "link.badge.plus", "plus",
            "brain.head.profile", "text.badge.checkmark", "camera.badge.ellipsis",
            "text.magnifyingglass", "photo.on.rectangle", "flashlight.on.fill", "flashlight.off.fill",
            "trash"
        ]
        
        if systemIcons.contains(input) {
            return Image(systemName: input)
        } else {
            // For products/steps, use one of the 6 available assets
            let iconName = ProductIconManager.getIconName(for: input)
            return Image(iconName)
        }
    }
    
    /// Create an Image for product/step icons from ProductType
    static func productIcon(for productType: ProductType) -> Image {
        let iconName = ProductIconManager.getIconName(for: productType)
        return Image(iconName)
    }
    
}

// MARK: - ProductType Extension

extension ProductType {
    /// Get custom icon name for this product type
    var customIconName: String {
        return ProductIconManager.getIconName(for: self)
    }
}
