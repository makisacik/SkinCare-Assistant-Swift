//
//  INCIDisplayView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

// MARK: - INCI Display View

/// View for displaying enriched INCI ingredient data
struct INCIDisplayView: View {
    let inciEntries: [INCIEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients (INCI)")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(Array(inciEntries.enumerated()), id: \.offset) { index, entry in
                HStack(alignment: .top, spacing: 12) {
                    // Ingredient number
                    Text("\(index + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 20, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // INCI name
                        Text(entry.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        // Function
                        if let function = entry.function {
                            Text(function)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        // Concerns
                        if let concerns = entry.concerns, !concerns.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(concerns, id: \.self) { concern in
                                    Text("• \(concern)")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview

#Preview {
    INCIDisplayView(inciEntries: [
        INCIEntry(
            name: "Aqua",
            function: "solvent",
            concerns: nil
        ),
        INCIEntry(
            name: "Niacinamide",
            function: "skin conditioning agent",
            concerns: ["May cause irritation in sensitive skin"]
        ),
        INCIEntry(
            name: "Zinc PCA",
            function: "antimicrobial, astringent",
            concerns: nil
        ),
        INCIEntry(
            name: "Hyaluronic Acid",
            function: "humectant, skin conditioning agent",
            concerns: nil
        )
    ])
    .padding()
}
