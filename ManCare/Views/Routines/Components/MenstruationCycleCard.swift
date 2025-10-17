//
//  MenstruationCycleCard.swift
//  ManCare
//
//  Menstruation cycle tracking card with cycle wheel
//

import SwiftUI

struct MenstruationCycleCard: View {
    @StateObject private var cycleStore = CycleStore()
    @State private var showingSettings = false
    
    private var currentDay: Int {
        cycleStore.cycleData.currentDayInCycle()
    }
    
    private var currentPhase: CyclePhase {
        cycleStore.cycleData.currentPhase()
    }
    
    private var totalDays: Int {
        cycleStore.cycleData.averageCycleLength
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Settings Button
            HStack(alignment: .center, spacing: 12) {
                // Cycle Wheel - Smaller and more compact
                CycleWheelView(
                    currentDay: currentDay,
                    totalDays: totalDays,
                    phase: currentPhase
                )
                .frame(width: 60, height: 60)
                
                // Phase Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: currentPhase.iconName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(currentPhase.mainColor)
                        
                        Text(currentPhase.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Text("\(L10n.Common.bullet) \(currentPhase.description)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text(L10n.Routines.CycleCard.dayNumber(currentDay))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(currentPhase.mainColor)
                        
                        Text(L10n.Routines.CycleCard.ofTotal(totalDays))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                    }
                }
                
                Spacer()
                
                // Settings Button
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(ThemeManager.shared.theme.palette.surface.opacity(0.5))
                        )
                }
            }
            
            // Skincare Tip - More compact
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(currentPhase.mainColor)
                    .padding(.top, 1)
                
                Text(currentPhase.skincareTip)
                    .font(.system(size: 12))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(currentPhase.mainColor.opacity(0.08))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface,
                            ThemeManager.shared.theme.palette.surface.opacity(0.8),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(currentPhase.mainColor.opacity(0.3), lineWidth: 1.5)
                )
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingSettings) {
            CycleSettingsView(cycleStore: cycleStore)
        }
    }
}

// MARK: - Cycle Wheel View

struct CycleWheelView: View {
    let currentDay: Int
    let totalDays: Int
    let phase: CyclePhase
    
    private var progress: Double {
        Double(currentDay) / Double(totalDays)
    }
    
    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: phase.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(phase.mainColor.opacity(0.3), lineWidth: 2)
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    phase.mainColor,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
            
            // Inner circle with day number
            VStack(spacing: 0) {
                Text("\(currentDay)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(phase.mainColor)
                
                Text(L10n.Routines.CycleCard.day)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
            }
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ThemeManager.shared.theme.palette.background
            .ignoresSafeArea()
        
        VStack {
            MenstruationCycleCard()
            Spacer()
        }
        .padding(.top, 40)
    }
}
