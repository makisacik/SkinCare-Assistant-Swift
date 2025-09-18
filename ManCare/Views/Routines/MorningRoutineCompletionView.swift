//
//  MorningRoutineCompletionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MorningRoutineCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routineManager: RoutineManager

    @ObservedObject private var productService = ProductService.shared
    
    @State private var routineSteps: [RoutineStepDetail]
    let onComplete: () -> Void
    let originalRoutine: RoutineResponse?
    
    init(routineSteps: [RoutineStepDetail], onComplete: @escaping () -> Void, originalRoutine: RoutineResponse?) {
        self._routineSteps = State(initialValue: routineSteps)
        self.onComplete = onComplete
        self.originalRoutine = originalRoutine
    }
    
    @State private var completedSteps: Set<String> = []
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingProductSelection: RoutineStepDetail?
    @State private var showingEditRoutine = false
    
    private var completedStepsCount: Int {
        // Filter completed steps to only include morning routine steps
        let morningStepIds = Set(routineSteps.map { $0.id })
        return completedSteps.intersection(morningStepIds).count
    }
    
    private var totalSteps: Int {
        routineSteps.count
    }
    
    private var isRoutineComplete: Bool {
        completedStepsCount == totalSteps
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Steps Section
                            stepsSection
                            
                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                    .background(ThemeManager.shared.theme.palette.background.ignoresSafeArea(.all, edges: .bottom))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton, trailing: editButton)
            .onAppear {
                setupNavigationBarAppearance()
                // Load completion state from RoutineManager
                completedSteps = routineManager.getCompletedSteps(for: Date())
            }
            .onChange(of: routineManager.completedSteps) { newValue in
                completedSteps = newValue
            }
        }
        .overlay(
            Group {
                if let step = showingProductSelection {
                    HalfScreenSheet(
                        isPresented: .constant(true),
                        onDismiss: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showingProductSelection = nil 
                            }
                        }
                    ) {
                        StepProductSelectionSheet(
                            step: step,
                            onDismiss: { 
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showingProductSelection = nil 
                                }
                            }
                        )
                    }
                }
            }
            .allowsHitTesting(showingProductSelection != nil)
        )
        .sheet(item: $showingStepDetail) { stepDetail in
            RoutineStepDetailView(stepDetail: stepDetail)
        }
        .sheet(isPresented: $showingEditRoutine) {
            if let routine = originalRoutine {
                EditRoutineView(
                    originalRoutine: routine,
                    routineManager: routineManager
                ) { updatedRoutine in
                    // Update the routine steps when the routine is edited
                    updateRoutineSteps(from: updatedRoutine)
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        ThemeManager.shared.theme.palette.background
            .ignoresSafeArea()
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 0) {
            // Pink header background - extends into safe area
            ZStack {
                // Deep accent gradient background for header
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.shared.theme.palette.primaryLight,     // Lighter primary
                        ThemeManager.shared.theme.palette.primary,          // Base primary
                        ThemeManager.shared.theme.palette.primaryLight      // Lighter primary
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all, edges: .top) // Extend into safe area
                
                VStack(spacing: 16) {
                    // Title and decorations
                    HStack {
                        Text("MORNING ROUTINE")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                            .shadow(color: ThemeManager.shared.theme.palette.textPrimary.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Spacer()
                        
                        // Decorative elements
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Progress indicator
                    progressIndicator
                }
            }
            .frame(height: 120)
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 12) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index < completedStepsCount ? ThemeManager.shared.theme.palette.background : ThemeManager.shared.theme.palette.border)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index < completedStepsCount ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: completedStepsCount)
                }
            }
            
            Spacer()
            
            // Completion percentage
            Text("\(totalSteps > 0 ? Int((Double(completedStepsCount) / Double(totalSteps)) * 100) : 0)%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    
    // MARK: - Steps Section
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Steps")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                    
                    Text("\(totalSteps) products")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                }
                
                Spacer()
                
                Button {
                    // Edit steps action
                } label: {
                    Text("Edit steps >")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ThemeManager.shared.theme.palette.primary.opacity(0.3))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Steps list
            VStack(spacing: 20) {
                ForEach(Array(routineSteps.enumerated()), id: \.element.id) { index, step in
                    DetailedStepRow(
                        step: step,
                        stepNumber: index + 1,
                        isCompleted: completedSteps.contains(step.id),
                        onToggle: {
                            toggleStepCompletion(step.id)
                        },
                        onAddProduct: {
                            showingProductSelection = step
                        },
                        onTap: {
                            showingStepDetail = step
                        }
                    )
                }
            }
        }
    }
    
    
    // MARK: - Navigation Buttons
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
    
    private var editButton: some View {
        Button {
            showingEditRoutine = true
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // Create the same pink gradient as the header
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1.0).cgColor,
            UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        // Create a background image from the gradient
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let backgroundImage = renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }

        appearance.backgroundImage = backgroundImage
        appearance.shadowImage = UIImage() // Remove shadow

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private func toggleStepCompletion(_ stepId: String) {
        // Find the step to get its details
        guard let step = routineSteps.first(where: { $0.id == stepId }) else { return }
        
        // Use the RoutineManager to persist the completion
        routineManager.toggleStepCompletion(
            stepId: stepId,
            stepTitle: step.title,
            stepType: step.stepType,
            timeOfDay: step.timeOfDay
        )
        
        // Add haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func updateRoutineSteps(from routine: RoutineResponse) {
        // Store the current state before updating
        let oldCompletedSteps = routineManager.getCompletedSteps(for: Date())
        let oldRoutineSteps = routineSteps
        
        // Convert the updated routine to RoutineStepDetail array
        routineSteps = routine.routine.morning.map { apiStep in
            RoutineStepDetail(
                id: UUID().uuidString, // Generate unique ID for each step
                title: apiStep.name,
                description: "\(apiStep.why) - \(apiStep.how)",
                stepType: apiStep.step,
                timeOfDay: .morning,
                why: apiStep.why,
                how: apiStep.how
            )
        }
        
        // Preserve completion state by mapping old step IDs to new ones
        var newCompletedSteps: Set<String> = []
        
        // Try to match completed steps by title (since IDs might change)
        for completedStepId in oldCompletedSteps {
            // First try to find the old step to get its title
            if let oldStep = oldRoutineSteps.first(where: { $0.id == completedStepId }) {
                // If the step still exists with the same ID, keep it completed
                if routineSteps.contains(where: { $0.id == completedStepId }) {
                    newCompletedSteps.insert(completedStepId)
                } else {
                    // Try to find a matching step by title
                    if let matchingStep = routineSteps.first(where: { $0.title == oldStep.title }) {
                        newCompletedSteps.insert(matchingStep.id)
                    }
                }
            }
        }
        
        completedSteps = newCompletedSteps
    }
    
    
}

// MARK: - Detailed Step Row

private struct DetailedStepRow: View {

    let step: RoutineStepDetail
    let stepNumber: Int
    let isCompleted: Bool
    let onToggle: () -> Void
    let onAddProduct: () -> Void
    let onTap: () -> Void
    
    @State private var showCheckmarkAnimation = false
    
    private var stepColor: Color {
        switch step.stepType.color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "orange": return ThemeManager.shared.theme.palette.warning
        case "purple": return ThemeManager.shared.theme.palette.primary
        case "red": return ThemeManager.shared.theme.palette.error
        case "pink": return ThemeManager.shared.theme.palette.primary
        case "teal": return ThemeManager.shared.theme.palette.info
        case "indigo": return ThemeManager.shared.theme.palette.info
        case "brown": return ThemeManager.shared.theme.palette.textMuted
        case "gray": return ThemeManager.shared.theme.palette.textMuted
        default: return ThemeManager.shared.theme.palette.primary
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left content area
            VStack(alignment: .leading, spacing: 16) {
                // Horizontal row with step number, icon, and name
                HStack(spacing: 12) {
                    // Step number
                    Text("\(stepNumber)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(stepColor)
                        .frame(width: 40)
                    
                    // Product image
                    Image(step.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                    
                    // Step title (smaller font) - allow it to expand and wrap
                    Text(step.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.theme.palette.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 8)
                }

                // Add product button below the horizontal row
                Button {
                    onAddProduct()
                } label: {
                    Text("+ Add your own product")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(stepColor.opacity(0.3))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 56) // Align with the content above

                // Step description
                Text(step.description)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.theme.palette.textSecondary)
                    .lineLimit(nil)
                    .padding(.leading, 56) // Align with the content above
            }
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }

            // Right completion area
            completionArea
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
    }

    private var completionArea: some View {
        VStack {
            Spacer()

            // Completion indicator
            ZStack {
                Circle()
                    .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 2)
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Circle()
                        .fill(ThemeManager.shared.theme.palette.primary)
                        .frame(width: 40, height: 40)
                        .scaleEffect(showCheckmarkAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)

                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .scaleEffect(showCheckmarkAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCheckmarkAnimation)
                }
            }

            // Completion text
            Text(isCompleted ? "Done" : "Tap to complete")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeManager.shared.theme.palette.textMuted)
                .padding(.top, 4)

            Spacer()
        }
        .frame(width: 70)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.theme.palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.theme.palette.border, lineWidth: 1)
                )
        )
        .opacity(0.6) // Decreased opacity for visual distinction
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()

            if !isCompleted {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCheckmarkAnimation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCheckmarkAnimation = false
                }
            }
        }
    }
}

// MARK: - Step Product Selection Sheet

private struct StepProductSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var productService = ProductService.shared
    let step: RoutineStepDetail
    let onDismiss: () -> Void
    
    @State private var showingAddProduct = false
    @State private var selectedProductType: ProductType?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("Add Product to \(step.title)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Text("Choose from your products or add a new one")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Content
            if getMatchingProducts().isEmpty {
                // Empty state - show add product options
                EmptyProductTypeView(
                    productType: step.stepType,
                    onAddProduct: {
                        selectedProductType = step.stepType
                        showingAddProduct = true
                    }
                )
            } else {
                // Show existing products
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(getMatchingProducts(), id: \.id) { product in
                            StepProductRow(
                                product: product,
                                step: step,
                                onSelect: {
                                    // Here you would attach the product to the step
                                    // For now, just dismiss
                                    onDismiss()
                                }
                            )
                        }
                        
                        // Add new product option
                        Button {
                            selectedProductType = step.stepType
                            showingAddProduct = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Text("Add New \(step.stepType.displayName)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ThemeManager.shared.theme.palette.info.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ThemeManager.shared.theme.palette.info.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            if let productType = selectedProductType {
                AddProductView(
                    productService: productService,
                    initialProductType: productType
                ) { newProduct in
                    // Product was added successfully
                    // The product list will be updated automatically via ProductService
                    showingAddProduct = false
                }
            }
        }
    }
    
    private func getMatchingProducts() -> [Product] {
        return productService.userProducts.filter { product in
            product.tagging.productType == step.stepType
        }
    }
}

// MARK: - Step Product Row

private struct StepProductRow: View {

    let product: Product
    let step: RoutineStepDetail
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // Product image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(productColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(productIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    )
                
                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let brand = product.brand {
                        Text(brand)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productColor: Color {
        switch product.tagging.productType.color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "orange": return ThemeManager.shared.theme.palette.warning
        case "purple": return ThemeManager.shared.theme.palette.primary
        case "red": return ThemeManager.shared.theme.palette.error
        case "pink": return ThemeManager.shared.theme.palette.primary
        case "teal": return ThemeManager.shared.theme.palette.info
        case "indigo": return ThemeManager.shared.theme.palette.info
        case "brown": return ThemeManager.shared.theme.palette.textMuted
        case "gray": return ThemeManager.shared.theme.palette.textMuted
        default: return ThemeManager.shared.theme.palette.textMuted
        }
    }
    
    private var productIcon: String {
        product.tagging.productType.iconName
    }
}

// MARK: - Empty Product Type View

private struct EmptyProductTypeView: View {

    let productType: ProductType
    let onAddProduct: () -> Void
    
    private var productColor: Color {
        switch productType.color {
        case "blue": return ThemeManager.shared.theme.palette.info
        case "green": return ThemeManager.shared.theme.palette.success
        case "yellow": return ThemeManager.shared.theme.palette.warning
        case "orange": return ThemeManager.shared.theme.palette.warning
        case "purple": return ThemeManager.shared.theme.palette.primary
        case "red": return ThemeManager.shared.theme.palette.error
        case "pink": return ThemeManager.shared.theme.palette.primary
        case "teal": return ThemeManager.shared.theme.palette.info
        case "indigo": return ThemeManager.shared.theme.palette.info
        case "brown": return ThemeManager.shared.theme.palette.textMuted
        case "gray": return ThemeManager.shared.theme.palette.textMuted
        default: return ThemeManager.shared.theme.palette.textMuted
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(productColor.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(productType.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            // Text
            VStack(spacing: 6) {
                Text("No \(productType.displayName) Added")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("You don't have any \(productType.displayName.lowercased()) products yet. Add one to get started!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Add Product Options
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Scan Product Card
                    Button {
                        // TODO: Implement scan functionality
                        onAddProduct()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                            VStack(spacing: 2) {
                                Text("Scan Product")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                                Text("Take a photo to automatically extract product information")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(productColor)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Or Text
                    VStack {
                        Text("Or")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 6)
                    }

                    // Add Manually Card
                    Button {
                        onAddProduct()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                            VStack(spacing: 2) {
                                Text("Add Manually")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse)

                                Text("Enter product details manually")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeManager.shared.theme.palette.textInverse.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeManager.shared.theme.palette.textInverse)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(productColor)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
}


// MARK: - Preview

#Preview("MorningRoutineCompletionView") {
    MorningRoutineCompletionView(
        routineSteps: [
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Water-based Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: UUID().uuidString,
                title: "Sunscreen SPF 30+",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevents UV damage, premature aging, and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
            )
        ],
        onComplete: { print("Routine completed!") },
        originalRoutine: nil
    )
    .environmentObject(RoutineManager())
}
