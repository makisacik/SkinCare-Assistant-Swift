//
//  ShimmerText.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 5.10.2025.
//

import SwiftUI

struct ShimmerText: View {
    let text: String
    let baseColor: Color
    
    @State private var phase: CGFloat = -1.0
    @State private var isAnimating = false

    var body: some View {
        Text(text)
            .foregroundColor(baseColor)
            .overlay {
                LinearGradient(
                    colors: [.white.opacity(0.0), .white.opacity(0.9), .white.opacity(0.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 140)
                .offset(x: phase * 240)
                .blendMode(.screen)
                .mask(Text(text))
            }
            .onAppear {
                startAnimationLoop()
            }
    }
    
    private func startAnimationLoop() {
        guard !isAnimating else { return }
        isAnimating = true
        
        Task {
            while true {
                // Move the shimmer slowly (3.5s duration)
                withAnimation(.linear(duration: 2)) {
                    phase = 1.2
                }
                // Wait for animation to finish
                try? await Task.sleep(nanoseconds: 3_500_000_000)
                
                // Pause for 1.5s before restarting
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Reset shimmer to start
                phase = -1.0
            }
        }
    }
}

