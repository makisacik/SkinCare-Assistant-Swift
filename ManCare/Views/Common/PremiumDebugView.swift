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
                            Text("Premium Status")
                                .font(.headline)
                            Text(premiumManager.isPremium ? "Active" : "Inactive")
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
                    Text("Current Status")
                }
                
                // Actions Section
                Section {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Show Paywall")
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
                            Text("Grant Premium (Test)")
                        }
                    }
                    .disabled(premiumManager.isPremium)
                    
                    Button {
                        premiumManager.revokePremium()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Revoke Premium (Test)")
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
                            Text("Restore Purchases")
                        }
                    }
                } header: {
                    Text("Actions")
                }
                
                // Features Section
                Section {
                    FeatureStatusRow(
                        icon: "list.bullet",
                        title: "Create Routines",
                        status: premiumManager.isPremium ? "Unlimited" : "2 max"
                    )
                    
                    FeatureStatusRow(
                        icon: "drop.fill",
                        title: "Cycle Adaptation",
                        status: premiumManager.canUseCycleAdaptation() ? "Available" : "Premium Only"
                    )
                    
                    FeatureStatusRow(
                        icon: "camera.on.rectangle.fill",
                        title: "Skin Journal",
                        status: premiumManager.canUseSkinJournal() ? "Available" : "Premium Only"
                    )
                    
                    FeatureStatusRow(
                        icon: "sun.max.fill",
                        title: "Weather Adaptation",
                        status: premiumManager.canUseWeatherAdaptation() ? "Available" : "Locked"
                    )
                } header: {
                    Text("Feature Access")
                } footer: {
                    Text("Test premium features by toggling the premium status above. In production, features will be locked behind real StoreKit purchases.")
                }
            }
            .navigationTitle("Premium Debug")
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

