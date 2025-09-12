//
//  PresentationModifier.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct PresentationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
