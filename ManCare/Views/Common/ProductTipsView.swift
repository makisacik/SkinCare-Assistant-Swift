//
//  ProductTipsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ProductTipsView: View {
    @StateObject private var tipsService = ProductTipsService.shared
    @State private var currentTip: ProductTip?
    @State private var isAnimating = false
    @State private var tipOpacity: Double = 0.0
    @State private var tipOffset: CGFloat = 50
    
    let productType: ProductType
    
    var body: some View {
        VStack(spacing: 0) {
            if let tip = currentTip {
                tipCard(tip)
                    .opacity(tipOpacity)
                    .offset(y: tipOffset)
                    .animation(.easeInOut(duration: 0.6), value: tipOpacity)
                    .animation(.easeInOut(duration: 0.6), value: tipOffset)
            } else {
                emptyStateView
            }
        }
        .onAppear {
            startTips()
        }
        .onDisappear {
            tipsService.stopTips()
        }
        .onChange(of: tipsService.currentTip) { newTip in
            animateTipChange(to: newTip)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 24))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text("No tips available")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .frame(height: 120)
    }
    
    private func tipCard(_ tip: ProductTip) -> some View {
        VStack(spacing: 16) {
            // Category badge
            HStack {
                Image(systemName: tip.category.systemIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(categoryColor(tip.category))
                
                Text(tip.category.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(categoryColor(tip.category))
                
                Spacer()
                
                // Rotation indicator
                if tipsService.isRotating {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(ThemeManager.shared.theme.palette.primary)
                                .frame(width: 4, height: 4)
                                .opacity(isAnimating ? (index == 0 ? 1.0 : 0.3) : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                }
            }
            
            // Tip content
            VStack(spacing: 8) {
                Text(tip.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(tip.content)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
            
            // Manual navigation buttons (only show if there are multiple tips)
            if tipsService.getTipsCount(for: productType) > 1 {
                HStack(spacing: 16) {
                    Button {
                        tipsService.previousTip()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Tip counter
                    Text("\(tipsService.currentTipIndex + 1) of \(tipsService.getTipsCount(for: productType))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    
                    Spacer()
                    
                    Button {
                        tipsService.nextTip()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
        .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func categoryColor(_ category: TipCategory) -> Color {
        switch category.colorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return ThemeManager.shared.theme.palette.primary
        }
    }
    
    private func startTips() {
        tipsService.startTips(for: productType)
        currentTip = tipsService.currentTip
        animateTipAppearance()
    }
    
    private func animateTipAppearance() {
        tipOpacity = 1.0
        tipOffset = 0
        isAnimating = true
    }
    
    private func animateTipChange(to newTip: ProductTip?) {
        // Fade out current tip
        withAnimation(.easeInOut(duration: 0.3)) {
            tipOpacity = 0.0
            tipOffset = -30
        }
        
        // Update tip and fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentTip = newTip
            withAnimation(.easeInOut(duration: 0.3)) {
                tipOpacity = 1.0
                tipOffset = 0
            }
        }
    }
}

// MARK: - Compact Tips View for Timer

struct CompactProductTipsView: View {
    @StateObject private var tipsService = ProductTipsService.shared
    @State private var currentTip: ProductTip?
    @State private var isAnimating = false
    @State private var tipOpacity: Double = 0.0
    @State private var tipOffset: CGFloat = 20
    
    let productType: ProductType
    
    var body: some View {
        VStack(spacing: 0) {
            if let tip = currentTip {
                compactTipCard(tip)
                    .opacity(tipOpacity)
                    .offset(y: tipOffset)
                    .animation(.easeInOut(duration: 0.5), value: tipOpacity)
                    .animation(.easeInOut(duration: 0.5), value: tipOffset)
            }
        }
        .onAppear {
            startTips()
        }
        .onChange(of: tipsService.currentTip) { newTip in
            animateTipChange(to: newTip)
        }
    }
    
    private func compactTipCard(_ tip: ProductTip) -> some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: tip.category.systemIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(categoryColor(tip.category))
                .frame(width: 24, height: 24)
            
            // Tip content
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(tip.content)
                    .font(.system(size: 12))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Rotation indicator
            if tipsService.isRotating && !tipsService.isPaused {
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(ThemeManager.shared.theme.palette.primary)
                            .frame(width: 3, height: 3)
                            .opacity(isAnimating ? (index == 0 ? 1.0 : 0.3) : 0.3)
                            .animation(
                                .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                                value: isAnimating
                            )
                    }
                }
            } else if tipsService.isPaused {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
        .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private func categoryColor(_ category: TipCategory) -> Color {
        switch category.colorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return ThemeManager.shared.theme.palette.primary
        }
    }
    
    private func startTips() {
        tipsService.startTips(for: productType)
        currentTip = tipsService.currentTip
        animateTipAppearance()
    }
    
    private func animateTipAppearance() {
        tipOpacity = 1.0
        tipOffset = 0
        isAnimating = true
    }
    
    private func animateTipChange(to newTip: ProductTip?) {
        // Fade out current tip
        withAnimation(.easeInOut(duration: 0.25)) {
            tipOpacity = 0.0
            tipOffset = -15
        }
        
        // Update tip and fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentTip = newTip
            withAnimation(.easeInOut(duration: 0.25)) {
                tipOpacity = 1.0
                tipOffset = 0
            }
        }
    }
}

// MARK: - Preview

#Preview("ProductTipsView") {
    VStack(spacing: 20) {
        ProductTipsView(productType: .cleanser)
            .frame(height: 200)
        
        CompactProductTipsView(productType: .faceSerum)
            .frame(height: 80)
    }
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}
