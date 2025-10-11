//
//  BadgePulseModifier.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct BadgePulseModifier: ViewModifier {
    @State private var isPulsing = false
    let shouldPulse: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .onAppear {
                if shouldPulse {
                    startPulsing()
                }
            }
    }
    
    private func startPulsing() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                isPulsing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isPulsing = false
                }
            }
        }
    }
}

extension View {
    func badgePulse(enabled: Bool = true) -> some View {
        modifier(BadgePulseModifier(shouldPulse: enabled))
    }
}

