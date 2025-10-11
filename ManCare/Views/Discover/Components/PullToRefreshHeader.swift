//
//  PullToRefreshHeader.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct PullToRefreshHeader: View {
    let refreshText: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
            
            Text(refreshText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
            
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .rotationEffect(.degrees(isAnimating ? -360 : 0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.6))
        )
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            isAnimating = true
        }
    }
}

#Preview {
    VStack {
        PullToRefreshHeader(refreshText: "Refreshed just now • new tips every morning ☀️")
        PullToRefreshHeader(refreshText: "Refreshed 5 min ago • new tips every morning ☀️")
        PullToRefreshHeader(refreshText: "Refreshed 2 hours ago")
    }
    .padding()
}

