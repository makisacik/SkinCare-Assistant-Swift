//
//  CycleSettingsView.swift
//  ManCare
//
//  Settings view for menstruation cycle tracking
//

import SwiftUI

struct CycleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var cycleStore: CycleStore
    
    @State private var lastPeriodDate: Date
    @State private var cycleLength: Double
    @State private var periodLength: Double
    @State private var showPaywall = false
    
    init(cycleStore: CycleStore) {
        self.cycleStore = cycleStore
        _lastPeriodDate = State(initialValue: cycleStore.cycleData.lastPeriodStartDate)
        _cycleLength = State(initialValue: Double(cycleStore.cycleData.averageCycleLength))
        _periodLength = State(initialValue: Double(cycleStore.cycleData.periodLength))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(ThemeManager.shared.theme.palette.primary)
                        
                        Text(L10n.Myself.Cycle.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        Text(L10n.Myself.Cycle.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Last Period Start Date
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.Myself.Cycle.lastPeriodStart)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                            
                            DatePicker(
                                L10n.Myself.Cycle.selectDate,
                                selection: $lastPeriodDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .accentColor(ThemeManager.shared.theme.palette.primary)
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
                        
                        // Cycle Length
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(L10n.Myself.Cycle.averageCycleLength)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Text(L10n.Myself.Cycle.cycleLengthValue(Int(cycleLength)))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }
                            
                            Slider(value: $cycleLength, in: 21...35, step: 1)
                                .accentColor(ThemeManager.shared.theme.palette.primary)
                            
                            Text(L10n.Myself.Cycle.cycleLengthRange)
                                .font(.system(size: 12))
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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(L10n.Myself.Cycle.periodLength)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                
                                Spacer()
                                
                                Text(L10n.Myself.Cycle.periodLengthValue(Int(periodLength)))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.primary)
                            }
                            
                            Slider(value: $periodLength, in: 3...7, step: 1)
                                .accentColor(ThemeManager.shared.theme.palette.primary)
                            
                            Text(L10n.Myself.Cycle.periodLengthRange)
                                .font(.system(size: 12))
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
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(ThemeManager.shared.theme.palette.info)
                            
                            Text(L10n.Myself.Cycle.privacyInfo)
                                .font(.system(size: 13))
                                .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                                .lineLimit(nil)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.info.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Save Button
                    Button {
                        showPaywall = true
                    } label: {
                        Text(L10n.Myself.Cycle.saveSettings)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ThemeManager.shared.theme.palette.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(ThemeManager.shared.theme.palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Myself.Cycle.cancel) {
                        dismiss()
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    onSubscribe: {
                        // Handle subscription - for now just save the settings
                        showPaywall = false
                        saveSettings()
                        dismiss()
                    },
                    onClose: {
                        // Close paywall without saving
                        showPaywall = false
                    }
                )
            }
        }
    }
    
    private func saveSettings() {
        let newCycleData = CycleData(
            lastPeriodStartDate: lastPeriodDate,
            averageCycleLength: Int(cycleLength),
            periodLength: Int(periodLength)
        )
        cycleStore.updateCycleData(newCycleData)
    }
}

// MARK: - Preview

#Preview {
    CycleSettingsView(cycleStore: CycleStore())
}
