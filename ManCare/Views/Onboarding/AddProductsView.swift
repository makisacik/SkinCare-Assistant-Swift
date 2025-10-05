//
//  AddProductsView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct AddProductsView: View {
    @Environment(\.colorScheme) private var cs
    
    var onNext: () -> Void
    var onPrevious: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 120)
                    
                    // Main headline
                    Text("Add or Scan Products")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Descriptive text
                    Text("Upload or photograph your skincare products — Glowie identifies them and explains what's inside.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Single image section - same size as combined images from first page
                Image("onboarding-left")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 336, height: 336) // Same size as combined three images (160+16+160 = 336 width, 336 height)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 60)
                
                // Next Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onNext()
                } label: {
                    HStack(spacing: 8) {
                        Text("Next")
                            .font(ThemeManager.shared.theme.typo.title.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ThemeManager.shared.theme.palette.secondary)
                    .cornerRadius(ThemeManager.shared.theme.cardRadius)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.94).ignoresSafeArea()) // Light beige background
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
    }
}

#Preview("AddProductsView - Light") {
    AddProductsView(
        onNext: {},
        onPrevious: {}
    )
    .preferredColorScheme(.light)
}

#Preview("AddProductsView - Dark") {
    AddProductsView(
        onNext: {},
        onPrevious: {}
    )
    .preferredColorScheme(.dark)
}
