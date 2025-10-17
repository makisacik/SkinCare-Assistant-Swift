//
//  LoadingView.swift
//  ManCare
//
//  A simple, general-purpose loading indicator
//

import SwiftUI

struct LoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Loading content
            VStack(spacing: 20) {
                // Spinning circle
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.theme.palette.primary,
                                ThemeManager.shared.theme.palette.primaryLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

                // Loading text
                Text(L10n.Common.loading)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.shared.theme.palette.surface)
                    .shadow(color: ThemeManager.shared.theme.palette.shadow.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
    }
}

#Preview {
    LoadingView()
}
