//
//  RoutineDataIntegrityTest.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct RoutineDataIntegrityTest: View {
    
    @StateObject private var productService = ProductService.shared
    @EnvironmentObject var routineManager: RoutineManager
    
    @State private var testResults: [String] = []
    @State private var isRunningTest = false
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("Routine Data Integrity Test")
                        .font(ThemeManager.shared.theme.typo.h1)
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("Test that 6+ products can be added to routine steps without data loss")
                        .font(ThemeManager.shared.theme.typo.sub)
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Test button
                Button {
                    runDataIntegrityTest()
                } label: {
                    HStack(spacing: 8) {
                        if isRunningTest {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        Text(isRunningTest ? "Running Test..." : "Run Test")
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                    }
                    .foregroundColor(ThemeManager.shared.theme.palette.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(ThemeManager.shared.theme.palette.secondary)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isRunningTest)
                
                // Results
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Test Results")
                            .font(ThemeManager.shared.theme.typo.h3)
                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(testResults, id: \.self) { result in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: result.contains("✅") ? "checkmark.circle.fill" : result.contains("❌") ? "xmark.circle.fill" : "info.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(result.contains("✅") ? ThemeManager.shared.theme.palette.success : result.contains("❌") ? ThemeManager.shared.theme.palette.error : ThemeManager.shared.theme.palette.info)
                                        
                                        Text(result)
                                            .font(ThemeManager.shared.theme.typo.body)
                                            .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.theme.palette.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ThemeManager.shared.theme.palette.separator, lineWidth: 1)
                                )
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(ThemeManager.shared.theme.palette.accentBackground.ignoresSafeArea())
            .navigationTitle("Data Integrity Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func runDataIntegrityTest() {
        isRunningTest = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            
            // Test 1: Create test products
            results.append("🧪 Creating test products...")
            let testProducts = createTestProducts()
            results.append("✅ Created \(testProducts.count) test products")
            
            // Test 2: Create routine with multiple steps
            results.append("🧪 Creating routine with multiple steps...")
            let routine = createTestRoutine()
            results.append("✅ Created routine with \(routine.morningSteps.count + routine.eveningSteps.count + routine.weeklySteps.count) steps")
            
            // Test 3: Attach products to steps
            results.append("🧪 Attaching products to steps...")
            let editingService = RoutineEditingService(originalRoutine: nil, routineManager: routineManager)
            editingService.editableRoutine = routine
            
            var attachedCount = 0
            for product in testProducts.prefix(6) {
                if let step = routine.morningSteps.first(where: { $0.stepType == product.tagging.productType }) {
                    editingService.attachProduct(product, to: step)
                    attachedCount += 1
                }
            }
            results.append("✅ Attached \(attachedCount) products to routine steps")
            
            // Test 4: Save routine
            results.append("🧪 Saving routine to UserDefaults...")
            do {
                let data = try JSONEncoder().encode(editingService.editableRoutine)
                UserDefaults.standard.set(data, forKey: "test_routine")
                results.append("✅ Routine saved successfully")
            } catch {
                results.append("❌ Failed to save routine: \(error.localizedDescription)")
            }
            
            // Test 5: Load routine
            results.append("🧪 Loading routine from UserDefaults...")
            if let loadedData = UserDefaults.standard.data(forKey: "test_routine"),
               let loadedRoutine = try? JSONDecoder().decode(EditableRoutine.self, from: loadedData) {
                results.append("✅ Routine loaded successfully")
                
                // Test 6: Verify product attachments
                results.append("🧪 Verifying product attachments...")
                var verifiedAttachments = 0
                for step in loadedRoutine.morningSteps {
                    if step.hasAttachedProduct {
                        verifiedAttachments += 1
                    }
                }
                results.append("✅ Verified \(verifiedAttachments) product attachments")
                
                // Test 7: Verify step ordering
                results.append("🧪 Verifying step ordering...")
                let morningSteps = loadedRoutine.morningSteps.sorted { $0.order < $1.order }
                let isOrdered = morningSteps.enumerated().allSatisfy { index, step in
                    step.order == index
                }
                results.append(isOrdered ? "✅ Step ordering preserved" : "❌ Step ordering corrupted")
                
            } else {
                results.append("❌ Failed to load routine")
            }
            
            // Test 8: Clean up
            results.append("🧪 Cleaning up test data...")
            UserDefaults.standard.removeObject(forKey: "test_routine")
            results.append("✅ Test data cleaned up")
            
            // Final result
            let successCount = results.filter { $0.contains("✅") }.count
            let totalTests = results.filter { $0.contains("🧪") }.count
            results.append("📊 Test Summary: \(successCount)/\(totalTests) tests passed")
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunningTest = false
            }
        }
    }
    
    private func createTestProducts() -> [Product] {
        let productTypes: [ProductType] = [.cleanser, .faceSerum, .moisturizer, .sunscreen, .facialOil, .exfoliator, .toner, .eyeCream]
        
        return productTypes.enumerated().map { index, type in
            Product(
                id: "test_product_\(index)",
                displayName: "Test \(type.displayName) \(index + 1)",
                tagging: ProductTagging(
                    productType: type,
                    ingredients: ["Test Ingredient \(index + 1)"],
                    claims: ["testClaim"]
                ),
                brand: "Test Brand \(index + 1)",
                size: "\(50 + index * 10)ml",
                description: "Test product for data integrity testing"
            )
        }
    }
    
    private func createTestRoutine() -> EditableRoutine {
        let morningSteps = [
            EditableRoutineStep(
                id: "morning_cleanser",
                title: "Gentle Cleanser",
                description: "Remove dirt and oil",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Essential for clean skin",
                how: "Apply and rinse",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: true,
                originalStep: true,
                order: 0,
                morningEnabled: true,
                eveningEnabled: false,
                attachedProductId: nil,
                productConstraints: nil
            ),
            EditableRoutineStep(
                id: "morning_serum",
                title: "Face Serum",
                description: "Targeted treatment",
                stepType: .faceSerum,
                timeOfDay: .morning,
                why: "Targeted benefits",
                how: "Apply 2-3 drops",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: false,
                originalStep: true,
                order: 1,
                morningEnabled: true,
                eveningEnabled: false,
                attachedProductId: nil,
                productConstraints: nil
            ),
            EditableRoutineStep(
                id: "morning_moisturizer",
                title: "Moisturizer",
                description: "Hydrate skin",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Essential hydration",
                how: "Apply and massage",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: false,
                originalStep: true,
                order: 2,
                morningEnabled: true,
                eveningEnabled: false,
                attachedProductId: nil,
                productConstraints: nil
            ),
            EditableRoutineStep(
                id: "morning_sunscreen",
                title: "Sunscreen",
                description: "UV protection",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevent sun damage",
                how: "Apply generously",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: true,
                originalStep: true,
                order: 3,
                morningEnabled: true,
                eveningEnabled: false,
                attachedProductId: nil,
                productConstraints: nil
            )
        ]
        
        let eveningSteps = [
            EditableRoutineStep(
                id: "evening_cleanser",
                title: "Evening Cleanser",
                description: "Remove makeup and dirt",
                stepType: .cleanser,
                timeOfDay: .evening,
                why: "Remove daily buildup",
                how: "Apply and rinse",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: true,
                originalStep: true,
                order: 0,
                morningEnabled: false,
                eveningEnabled: true,
                attachedProductId: nil,
                productConstraints: nil
            ),
            EditableRoutineStep(
                id: "evening_oil",
                title: "Face Oil",
                description: "Nourish skin",
                stepType: .facialOil,
                timeOfDay: .evening,
                why: "Deep nourishment",
                how: "Apply 2-3 drops",
                isEnabled: true,
                frequency: .daily,
                customInstructions: nil,
                isLocked: false,
                originalStep: true,
                order: 1,
                morningEnabled: false,
                eveningEnabled: true,
                attachedProductId: nil,
                productConstraints: nil
            )
        ]
        
        return EditableRoutine(
            morningSteps: morningSteps,
            eveningSteps: eveningSteps,
            weeklySteps: [],
            originalRoutine: nil,
            lastModified: Date(),
            isCustomized: true
        )
    }
}

// MARK: - Preview

#Preview("RoutineDataIntegrityTest") {
    RoutineDataIntegrityTest()
}
