//
//  PageIndicator.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 6.10.2025.
//

import SwiftUI

struct PageIndicator: View {
    let total: Int
    @Binding var index: Int
    let activeColor: Color
    let inactiveColor: Color
    
    // Tweakables
    private let dot: CGFloat = 8
    private let activeWidth: CGFloat = 24
    private let spacing: CGFloat = 2
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<total, id: \.self) { i in
                // Fixed container prevents layout jumps
                ZStack {
                    Capsule(style: .continuous)
                        .fill(i == index ? activeColor : inactiveColor)
                        .frame(width: i == index ? activeWidth : dot, height: dot)
                        .animation(
                            reduceMotion ? nil :
                            .spring(response: 0.32, dampingFraction: 0.85, blendDuration: 0.1),
                            value: index
                        )
                        .accessibilityHidden(true)
                }
                .frame(width: activeWidth, height: dot) // <-- fixed slot width
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        index = i
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(index + 1) of \(total)")
    }
}
