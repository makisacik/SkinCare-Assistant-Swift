//
//  CycleSetupView.swift
//  ManCare
//
//  Onboarding page for menstruation cycle setup
//

import SwiftUI

struct CycleSetupView: View {
    @Environment(\.colorScheme) private var cs
    
    var onNext: (CycleData?) -> Void
    var onPrevious: () -> Void
    
    @State private var lastPeriodDate: Date = Date()
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    @State private var showDatePicker = false
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Fixed header section
                    VStack(spacing: 12) {
                        // Title
                        Text("Track Your Cycle")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Subtitle
                        Text("Get personalized skincare tips that adapt to your menstrual cycle")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .frame(minHeight: 120)
                    .padding(.top, 20)
                    
                    // Visual Element - Cycle Phases Illustration
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            CyclePhaseIcon(
                                phase: .menstrual,
                                icon: "drop.fill",
                                color: ThemeManager.shared.theme.palette.error
                            )
                            CyclePhaseIcon(
                                phase: .follicular,
                                icon: "sparkles",
                                color: ThemeManager.shared.theme.palette.success
                            )
                            CyclePhaseIcon(
                                phase: .ovulation,
                                icon: "sun.max.fill",
                                color: ThemeManager.shared.theme.palette.warning
                            )
                            CyclePhaseIcon(
                                phase: .luteal,
                                icon: "moon.fill",
                                color: ThemeManager.shared.theme.palette.primary
                            )
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 20)
                    
                    // Input Section
                    VStack(spacing: 16) {
                        // Last Period Start Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("When did your last period start?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.primary)
                                    
                                    Text(lastPeriodDate, style: .date)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ThemeManager.shared.theme.palette.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                        )
                                )
                            }
                            
                            if showDatePicker {
                                DatePicker(
                                    "Select Date",
                                    selection: $lastPeriodDate,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .accentColor(ThemeManager.shared.theme.palette.primary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ThemeManager.shared.theme.palette.surface)
                                )
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        
                        // Cycle Length
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Average cycle length")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Text("\(Int(cycleLength)) days")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }
                            
                            Slider(value: $cycleLength, in: 21...35, step: 1)
                                .accentColor(ThemeManager.shared.theme.palette.primary)
                            
                            Text("Typical range: 21-35 days")
                                .font(.system(size: 11))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                )
                        )
                        
                        // Period Length
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Period length")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Text("\(Int(periodLength)) days")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }
                            
                            Slider(value: $periodLength, in: 3...7, step: 1)
                                .accentColor(ThemeManager.shared.theme.palette.primary)
                            
                            Text("Typical range: 3-7 days")
                                .font(.system(size: 11))
                                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Info Box
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.info)
                        
                        Text("Your cycle data stays private on your device")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ThemeManager.shared.theme.palette.info.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 40)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Continue Button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            // Show paywall for premium feature
                            showPaywall = true
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
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
                        
                        // Skip Button
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onNext(nil)
                        } label: {
                            Text("Skip for now")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onChange(of: cs) { ThemeManager.shared.refreshForSystemChange($0) }
        .animation(.easeInOut, value: showDatePicker)
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onSubscribe: {
                    // Handle subscription - for now just save the cycle data
                    let cycleData = CycleData(
                        lastPeriodStartDate: lastPeriodDate,
                        averageCycleLength: Int(cycleLength),
                        periodLength: Int(periodLength)
                    )
                    showPaywall = false
                    onNext(cycleData)
                },
                onClose: {
                    // Close paywall without subscribing
                    showPaywall = false
                }
            )
        }
    }
}

// MARK: - Cycle Phase Icon

private struct CyclePhaseIcon: View {
    let phase: CyclePhase
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(phase.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("CycleSetupView - Light") {
    CycleSetupView(
        onNext: { _ in },
        onPrevious: {}
    )
    .preferredColorScheme(.light)
}

#Preview("CycleSetupView - Dark") {
    CycleSetupView(
        onNext: { _ in },
        onPrevious: {}
    )
    .preferredColorScheme(.dark)
}
