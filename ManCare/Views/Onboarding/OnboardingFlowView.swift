//
//  OnboardingFlowView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    var onComplete: () -> Void
    var onSkipToHome: (() -> Void)? = nil
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            // Page content with smooth transitions
            TabView(selection: $currentPage) {
                // Page 0: Welcome
                WelcomeView(
                    onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 1
                        }
                    },
                    onSkipToHome: onSkipToHome
                )
                .tag(0)
                
                // Page 1: Create Routine
                CreateRoutineView(
                    onNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 2
                        }
                    },
                    onPrevious: {}
                )
                .tag(1)
                
                // Page 2: Add Products
                AddProductsView(
                    onNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 3
                        }
                    },
                    onPrevious: {}
                )
                .tag(2)
                
                // Page 3: Discover & Track Progress
                DiscoverProgressView(
                    onGetStarted: {
                        onComplete()
                    },
                    onPrevious: {}
                )
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Custom page indicator overlay at top
            VStack {
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        if index == currentPage {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ThemeManager.shared.theme.palette.primary)
                                .frame(width: 24, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        } else {
                            Circle()
                                .fill(ThemeManager.shared.theme.palette.separator)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                Spacer()
            }
        }
        .onAppear {
            // Reset to first page when view appears
            currentPage = 0
        }
    }
}

#Preview("OnboardingFlowView - Light") {
    OnboardingFlowView(
        onComplete: {},
        onSkipToHome: {}
    )
    .preferredColorScheme(.light)
}

#Preview("OnboardingFlowView - Dark") {
    OnboardingFlowView(
        onComplete: {},
        onSkipToHome: {}
    )
    .preferredColorScheme(.dark)
}
