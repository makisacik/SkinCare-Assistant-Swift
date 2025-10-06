//
//  ContentView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RoutineCreatorFlow(onComplete: { _ in })
    }
}

#Preview {
    ContentView()
}
