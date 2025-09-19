//
//  ViewExtensions.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 19.09.2025.
//

import SwiftUI

// MARK: - View Extensions for State Management

extension View {
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
