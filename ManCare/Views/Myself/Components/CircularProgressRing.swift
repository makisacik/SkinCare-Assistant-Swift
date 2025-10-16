//
//  CircularProgressRing.swift
//  ManCare
//
//  Created for Insights Tab Feature
//

import SwiftUI

struct CircularProgressRing: View {
    let percentage: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedPercentage: Double = 0
    
    init(percentage: Double, color: Color, lineWidth: CGFloat = 8, size: CGFloat = 80) {
        self.percentage = min(max(percentage, 0), 100)
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    ThemeManager.shared.theme.palette.border.opacity(0.3),
                    lineWidth: lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedPercentage / 100)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            Text("\(Int(animatedPercentage))%")
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                animatedPercentage = percentage
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularProgressRing(percentage: 75, color: .blue)
        CircularProgressRing(percentage: 45, color: .green, size: 60)
        CircularProgressRing(percentage: 90, color: .orange, size: 100)
    }
    .padding()
}

