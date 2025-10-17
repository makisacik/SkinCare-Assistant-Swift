//
//  PremiumDebugView.swift
//  ManCare
//
//  Debug view for testing premium features
//

import SwiftUI

struct PremiumDebugView: View {
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                // Premium Status Section
                Section {
                    HStack {
                        Image(systemName: premiumManager.isPremium ? "crown.fill" : "crown")
                            .foregroundColor(premiumManager.isPremium ? .yellow : .gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Debug.premiumStatus)
                                .font(.headline)
                            Text(premiumManager.isPremium ? L10n.Debug.active : L10n.Debug.inactive)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Status indicator
                        Circle()
                            .fill(premiumManager.isPremium ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                    }
                } header: {
                    Text(L10n.Debug.currentStatus)
                }
                
                // Actions Section
                Section {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text(L10n.Debug.showPaywall)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        premiumManager.grantPremium()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(L10n.Debug.grantPremium)
                        }
                    }
                    .disabled(premiumManager.isPremium)
                    
                    Button {
                        premiumManager.revokePremium()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(L10n.Debug.revokePremium)
                        }
                    }
                    .disabled(!premiumManager.isPremium)
                    
                    Button {
                        Task {
                            try? await premiumManager.restorePurchases()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(L10n.Debug.restorePurchases)
                        }
                    }
                } header: {
                    Text(L10n.Debug.actions)
                }
                
                // Features Section
                Section {
                    FeatureStatusRow(
                        icon: "list.bullet",
                        title: L10n.Debug.featureCreateRoutines,
                        status: premiumManager.isPremium ? L10n.Debug.statusUnlimited : L10n.Debug.statusMaxTwo
                    )
                    
                    FeatureStatusRow(
                        icon: "drop.fill",
                        title: L10n.Debug.featureCycleAdaptation,
                        status: premiumManager.canUseCycleAdaptation() ? L10n.Debug.statusAvailable : L10n.Debug.statusPremiumOnly
                    )
                    
                    FeatureStatusRow(
                        icon: "camera.on.rectangle.fill",
                        title: L10n.Debug.featureSkinJournal,
                        status: premiumManager.canUseSkinJournal() ? L10n.Debug.statusAvailable : L10n.Debug.statusPremiumOnly
                    )
                    
                    FeatureStatusRow(
                        icon: "sun.max.fill",
                        title: L10n.Debug.featureWeatherAdaptation,
                        status: premiumManager.canUseWeatherAdaptation() ? L10n.Debug.statusAvailable : L10n.Debug.statusLocked
                    )
                } header: {
                    Text(L10n.Debug.featureAccess)
                } footer: {
                    Text(L10n.Debug.testPremiumFooter)
                }
            }
            .navigationTitle(L10n.Debug.premiumTitle)
            .sheet(isPresented: $showingPaywall) {
                PaywallView(
                    onSubscribe: {
                        print("✅ Premium granted via paywall")
                    },
                    onClose: {
                        print("ℹ️ Paywall closed")
                    }
                )
            }
        }
    }
}

// MARK: - Feature Status Row

private struct FeatureStatusRow: View {
    let icon: String
    let title: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ThemeManager.shared.theme.palette.primary)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    PremiumDebugView()
}

