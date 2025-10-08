//
//  ViewExtensions.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import SwiftUI

// MARK: - String Extensions for Proper Capitalization

extension String {
    /// Capitalize brand and product names properly
    /// Examples: "mia klinika" -> "Mia Klinika", "CERA VE" -> "Cera Ve"
    var properCapitalized: String {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        return words.map { word in
            // Handle special cases for common brand patterns
            let lowercaseWord = word.lowercased()

            // Keep certain words in all caps if they appear to be acronyms
            if lowercaseWord.count <= 3 && word.allSatisfy({ $0.isLetter }) {
                return word.uppercased()
            }

            // Capitalize first letter of each word
            return word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }

    /// Capitalize brand names with special handling for common patterns
    var brandCapitalized: String {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        return words.map { word in
            let lowercaseWord = word.lowercased()

            // Handle common brand name patterns
            switch lowercaseWord {
            case "co", "corp", "inc", "ltd", "llc":
                return word.uppercased()
            case "of", "the", "and", "or", "in", "on", "at", "to", "for", "with", "by":
                return word.lowercased()
            default:
                // For short words (likely acronyms), keep uppercase
                if word.count <= 3 && word.allSatisfy({ $0.isLetter }) {
                    return word.uppercased()
                }
                // Otherwise capitalize first letter
                return word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }
        }.joined(separator: " ")
    }
}

// MARK: - View Extensions for State Management

extension View {
    /// Conditionally apply a view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func handleRoutineError(_ error: Error?) -> some View {
        self.alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
    }
    
    func withRoutineLoading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 5)
                                    .frame(width: 80, height: 80)
                            )
                    }
                }
            }
        )
    }
}

// MARK: - ViewState Enum

enum ViewState {
    case loading
    case loaded
    case empty
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
