//
//  MorningRoutineCompletionView.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct MorningRoutineCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeManager) private var tm
    @ObservedObject private var productService = ProductService.shared
    @StateObject private var routineTrackingService = RoutineTrackingService()
    
    let routineSteps: [RoutineStepDetail]
    let onComplete: () -> Void
    
    @State private var completedSteps: Set<String> = []
    @State private var showingStepDetail: RoutineStepDetail?
    @State private var showingProductSelection: RoutineStepDetail?
    
    private var completedStepsCount: Int {
        completedSteps.count
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
                    .background(
                        // Extend the background gradient to cover bottom safe area
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.05, green: 0.1, blue: 0.2),
                                Color(red: 0.08, green: 0.15, blue: 0.3),
                                Color(red: 0.12, green: 0.2, blue: 0.35)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(.all, edges: .bottom)
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    editButton
                }
            }
            .onAppear {
                setupNavigationBarAppearance()
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
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.1, blue: 0.2),
                Color(red: 0.08, green: 0.15, blue: 0.3),
                Color(red: 0.12, green: 0.2, blue: 0.35)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 0) {
            // Pink header background - extends into safe area
            ZStack {
                // Pink gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.3, blue: 0.6),
                        Color(red: 0.8, green: 0.2, blue: 0.5)
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
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Spacer()
                        
                        // Decorative elements
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.orange)
                                .shadow(color: .yellow.opacity(0.5), radius: 2)
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
                        .fill(index < completedStepsCount ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index < completedStepsCount ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: completedStepsCount)
                }
            }
            
            Spacer()
            
            // Completion percentage
            Text("\(Int((Double(completedStepsCount) / Double(totalSteps)) * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
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
                        .foregroundColor(.white)
                    
                    Text("\(totalSteps) products")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    // Edit steps action
                } label: {
                    Text("Edit steps >")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.3))
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
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    private var editButton: some View {
        Button {
            // Edit routine action
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
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
        if completedSteps.contains(stepId) {
            completedSteps.remove(stepId)
        } else {
            completedSteps.insert(stepId)
            
            // Add haptic feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
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
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "brown": return .brown
        case "gray": return .gray
        default: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left content area
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Step number
                    Text("\(stepNumber)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(stepColor)
                        .frame(width: 40)
                    
                    // Product image placeholder
                    RoundedRectangle(cornerRadius: 8)
                        .fill(stepColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: step.iconName)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(stepColor)
                        )
                    
                    // Step title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(step.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Button {
                            onAddProduct()
                        } label: {
                            Text("+ Add your own product")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(stepColor.opacity(0.3))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Spacer()
                }

                // Step description
                Text(step.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
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
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var completionArea: some View {
        VStack {
            Spacer()

            // Completion indicator
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Circle()
                        .fill(Color.white)
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
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 4)

            Spacer()
        }
        .frame(width: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
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
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
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
                        Image(systemName: productIcon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(productColor)
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
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "brown": return .brown
        case "gray": return .gray
        default: return .gray
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
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "brown": return .brown
        case "gray": return .gray
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(productColor.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: productType.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(productColor)
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
                                .foregroundColor(Color.white)

                            VStack(spacing: 2) {
                                Text("Scan Product")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color.white)

                                Text("Take a photo to automatically extract product information")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color.white)
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
                                .foregroundColor(Color.white)

                            VStack(spacing: 2) {
                                Text("Add Manually")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color.white)

                                Text("Enter product details manually")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }

                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color.white)
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

// MARK: - Half Screen Sheet

struct HalfScreenSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let content: Content
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var sheetOffset: CGFloat = 1000 // Start off-screen
    
    init(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay - covers entire screen including safe areas
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .ignoresSafeArea(.all)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onTapGesture {
                        dismissSheet()
                    }
                    .animation(.easeInOut(duration: 0.3), value: isPresented)
                
                // Sheet content
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Drag handle
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                        
                        // Content
                        content
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .frame(maxHeight: geometry.size.height * 0.6)
                    .offset(y: sheetOffset + dragOffset)
                    .background(
                        // Extended background to cover safe area
                        Color(.systemBackground)
                            .frame(height: geometry.size.height)
                            .offset(y: geometry.size.height * 0.4) // Extend below the sheet
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                // Only allow downward dragging
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                // Dismiss if dragged down more than 100 points
                                if value.translation.height > 100 {
                                    dismissSheet()
                                } else {
                                    // Snap back to original position
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
            }
        }
        .onAppear {
            if isPresented {
                showSheet()
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                showSheet()
            } else {
                hideSheet()
            }
        }
    }
    
    private func showSheet() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            sheetOffset = 0
        }
    }
    
    private func hideSheet() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            sheetOffset = 1000 // Move off-screen
            dragOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
    
    private func dismissSheet() {
        isPresented = false
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview("MorningRoutineCompletionView") {
    MorningRoutineCompletionView(
        routineSteps: [
            RoutineStepDetail(
                id: "morning_cleanser",
                title: "Gentle Cleanser",
                description: "Oil-free gel cleanser – reduces shine, clears pores",
                iconName: "drop.fill",
                stepType: .cleanser,
                timeOfDay: .morning,
                why: "Removes overnight oil buildup and prepares skin for treatments",
                how: "Apply to damp skin, massage gently for 30 seconds, rinse with lukewarm water"
            ),
            RoutineStepDetail(
                id: "morning_moisturizer",
                title: "Water-based Moisturizer",
                description: "Lightweight gel moisturizer – hydrates without greasiness",
                iconName: "drop.circle.fill",
                stepType: .moisturizer,
                timeOfDay: .morning,
                why: "Provides essential hydration and creates a protective barrier",
                how: "Apply a pea-sized amount, massage in upward circular motions"
            ),
            RoutineStepDetail(
                id: "morning_sunscreen",
                title: "Sunscreen SPF 30+",
                description: "SPF 30+ broad spectrum – protects against sun damage",
                iconName: "sun.max.fill",
                stepType: .sunscreen,
                timeOfDay: .morning,
                why: "Prevents UV damage, premature aging, and skin cancer",
                how: "Apply generously 15 minutes before sun exposure, reapply every 2 hours"
            )
        ],
        onComplete: { print("Routine completed!") }
    )
}
