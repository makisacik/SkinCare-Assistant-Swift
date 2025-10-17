//
//  FreshDropsSection.swift
//  ManCare
//
//  Created for Discover Page Feature
//

import SwiftUI

struct FreshDropsSection: View {
    let freshRoutines: [FreshRoutine]
    let getRoutineTemplate: (FreshRoutine) -> RoutineTemplate?
    let onRoutineTap: (RoutineTemplate) -> Void
    let onSaveTap: (RoutineTemplate) -> Void
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(L10n.Discover.FreshDrops.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                    }
                    
                    Text(L10n.Discover.FreshDrops.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
                
                Spacer()
                
                Button(L10n.Discover.viewAll) {
                    onViewAll()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll of cards
            if freshRoutines.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(freshRoutines) { freshRoutine in
                            if let template = getRoutineTemplate(freshRoutine) {
                                FreshRoutineCard(
                                    routine: template,
                                    badge: freshRoutine.badge,
                                    onTap: {
                                        onRoutineTap(template)
                                    },
                                    onSave: {
                                        onSaveTap(template)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            
            Text(L10n.Discover.FreshDrops.empty)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    FreshDropsSection(
        freshRoutines: [],
        getRoutineTemplate: { _ in nil },
        onRoutineTap: { _ in },
        onSaveTap: { _ in },
        onViewAll: {}
    )
}

