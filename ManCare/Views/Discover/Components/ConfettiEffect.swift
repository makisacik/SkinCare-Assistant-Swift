//
//  ConfettiEffect.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct ConfettiEffect: View {
    @State private var animate = false
    let trigger: Bool
    
    private let colors: [Color] = [
        Color(hex: "#FFE6D1"),
        Color(hex: "#FFE6F0"),
        Color(hex: "#E6F3FF"),
        Color(hex: "#F5DEB3"),
        ThemeManager.shared.theme.palette.primary,
        ThemeManager.shared.theme.palette.success
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    delay: Double(index) * 0.05,
                    animate: animate
                )
            }
        }
        .onChange(of: trigger) { newValue in
            if newValue {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    animate = false
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    let animate: Bool
    
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .onChange(of: animate) { shouldAnimate in
                if shouldAnimate {
                    withAnimation(.easeOut(duration: 1).delay(delay)) {
                        opacity = 1
                        yOffset = CGFloat.random(in: -100...(-50))
                        xOffset = CGFloat.random(in: -50...50)
                        rotation = Double.random(in: 0...360)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + delay) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            opacity = 0
                            yOffset = yOffset + 50
                        }
                    }
                } else {
                    opacity = 0
                    yOffset = 0
                    xOffset = 0
                    rotation = 0
                }
            }
    }
}

#Preview {
    ConfettiEffect(trigger: true)
}

