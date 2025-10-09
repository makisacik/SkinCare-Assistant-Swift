//
//  StepAdaptationBadge.swift
//  ManCare
//
//  Badge showing step adaptation level
//

import SwiftUI

struct StepAdaptationBadge: View {
    let emphasis: StepEmphasis
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(emphasis.color.opacity(0.15))
                .frame(width: 32, height: 32)
            
            Circle()
                .stroke(emphasis.color.opacity(0.3), lineWidth: 1.5)
                .frame(width: 32, height: 32)
            
            Image(systemName: emphasis.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(emphasis.color)
        }
        .scaleEffect(isPulsing && emphasis == .emphasize ? 1.1 : 1.0)
        .animation(
            emphasis == .emphasize 
                ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                : .default,
            value: isPulsing
        )
        .onAppear {
            if emphasis == .emphasize {
                isPulsing = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            VStack {
                StepAdaptationBadge(emphasis: .skip)
                Text("Skip")
                    .font(.caption)
            }
            
            VStack {
                StepAdaptationBadge(emphasis: .reduce)
                Text("Reduce")
                    .font(.caption)
            }
            
            VStack {
                StepAdaptationBadge(emphasis: .normal)
                Text("Normal")
                    .font(.caption)
            }
            
            VStack {
                StepAdaptationBadge(emphasis: .emphasize)
                Text("Emphasize")
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(ThemeManager.shared.theme.palette.background)
}


