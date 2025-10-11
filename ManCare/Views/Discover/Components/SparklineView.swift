//
//  SparklineView.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct SparklineView: View {
    let percentage: Int
    @State private var animatedWidth: CGFloat = 0
    
    private let maxWidth: CGFloat = 60
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background bar
            RoundedRectangle(cornerRadius: 4)
                .fill(ThemeManager.shared.theme.palette.border.opacity(0.3))
                .frame(width: maxWidth, height: 8)
            
            // Animated progress bar
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.theme.palette.success,
                            ThemeManager.shared.theme.palette.success.opacity(0.7)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: animatedWidth, height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animatedWidth = CGFloat(percentage) / 100 * maxWidth
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            Text("42%")
            SparklineView(percentage: 42)
        }
        
        HStack {
            Text("31%")
            SparklineView(percentage: 31)
        }
        
        HStack {
            Text("24%")
            SparklineView(percentage: 24)
        }
    }
    .padding()
}

