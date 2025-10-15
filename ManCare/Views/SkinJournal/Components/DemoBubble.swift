//
//  DemoBubble.swift
//  ManCare
//
//  Floating bubble prompt for the comparison demo
//

import SwiftUI

struct DemoBubble: View {
    let text: String
    @Binding var isVisible: Bool
    @State private var animateIn = false
    
    var body: some View {
        HStack(spacing: 8) {
            Text("✨")
                .font(.system(size: 16))
            
            Text(text)
                .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.85),
                            Color(red: 0.95, green: 0.92, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: ThemeManager.shared.theme.palette.primary.opacity(0.2),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        )
        .scaleEffect(animateIn ? 1.0 : 0.8)
        .opacity(animateIn ? 1.0 : 0.0)
        .offset(y: animateIn ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateIn = true
            }
            
            // Auto-dismiss after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = false
                }
            }
        }
    }
}

