//
//  InspirationalQuotesSection.swift
//  ManCare
//
//  Created for Discover Page Inspirational Quotes Feature
//

import SwiftUI

struct InspirationalQuotesSection: View {
    let quotes: [InspirationalQuote]
    @State private var currentQuoteIndex = 0
    @State private var showingShareSheet = false
    @State private var rotationTimer: Timer?
    
    var body: some View {
        VStack(spacing: 24) {
            // Section Header
            VStack(spacing: 8) {
                Text(L10n.Discover.Quotes.title)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .tracking(1.2)
                
                Text(currentQuote.displayText)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                
                Text(currentQuote.displayAuthor)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .padding(.top, 8)
            }
            
            // Share Button
            Button(action: {
                showingShareSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quote Navigation Dots
            if quotes.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<quotes.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentQuoteIndex ? 
                                  ThemeManager.shared.theme.palette.primary : 
                                  ThemeManager.shared.theme.palette.textSecondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentQuoteIndex)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .onAppear {
            // Start auto-rotation of quotes every 10 seconds
            startQuoteRotation()
        }
        .onDisappear {
            // Clean up timer when view disappears
            stopQuoteRotation()
        }
        .onTapGesture {
            // Tap to cycle through quotes
            cycleToNextQuote()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [
                "\(currentQuote.displayText)\n\(currentQuote.displayAuthor)\n\n\(L10n.Discover.Quotes.shareFooter)"
            ])
        }
    }
    
    private var currentQuote: InspirationalQuote {
        guard !quotes.isEmpty else {
            return InspirationalQuote(
                id: UUID(),
                text: L10n.Discover.Quotes.Fallback.text,
                author: L10n.Discover.Quotes.Fallback.author,
                category: L10n.Discover.Quotes.Fallback.category,
                localizationKey: nil
            )
        }
        return quotes[currentQuoteIndex]
    }
    
    private func cycleToNextQuote() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
        }
    }
    
    private func startQuoteRotation() {
        guard quotes.count > 1 else { return }
        
        // Invalidate existing timer to prevent duplicates
        stopQuoteRotation()
        
        // Create new timer and store it
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
            }
        }
    }
    
    private func stopQuoteRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    InspirationalQuotesSection(quotes: [
        InspirationalQuote(
            id: UUID(),
            text: nil,
            author: nil,
            category: nil,
            localizationKey: "quote1"
        ),
        InspirationalQuote(
            id: UUID(),
            text: nil,
            author: nil,
            category: nil,
            localizationKey: "quote2"
        )
    ])
    .background(ThemeManager.shared.theme.palette.background)
}
