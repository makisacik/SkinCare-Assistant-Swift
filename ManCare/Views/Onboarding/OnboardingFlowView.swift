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
    @State private var showRoutineCreator = false
    @State private var skipToHome = false
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            if skipToHome {
                MainTabView(generatedRoutine: nil)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .zIndex(3)
            } else if showRoutineCreator {
                RoutineCreatorFlow()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .zIndex(2)
            } else {
                mainOnboardingView
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .zIndex(1)
            }
        }
    }
    
    private var mainOnboardingView: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator integrated into layout (not overlay)
                PageIndicator(
                    total: totalPages,
                    index: $currentPage,
                    activeColor: ThemeManager.shared.theme.palette.primary,
                    inactiveColor: ThemeManager.shared.theme.palette.separator
                )
                .padding(.top, 50)
                
                // Page content with smooth transitions
                TabView(selection: $currentPage) {
                    // Page 0: Welcome
                    WelcomeView(
                        onGetStarted: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage = 1
                            }
                        },
                        onSkipToHome: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                skipToHome = true
                            }
                        }
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
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showRoutineCreator = true
                            }
                        },
                        onPrevious: {}
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .onAppear {
            currentPage = 0
        }
    }
}

#Preview("OnboardingFlowView - Light") {
    OnboardingFlowView()
        .preferredColorScheme(.light)
}

#Preview("OnboardingFlowView - Dark") {
    OnboardingFlowView()
        .preferredColorScheme(.dark)
}
