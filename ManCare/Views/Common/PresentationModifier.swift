//
//  PresentationModifier.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import SwiftUI

struct PresentationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
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
                ThemeManager.shared.theme.palette.textPrimary.opacity(isPresented ? 0.3 : 0)
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
                            .fill(ThemeManager.shared.theme.palette.textMuted.opacity(0.4))
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        // Content
                        content
                    }
                    .background(ThemeManager.shared.theme.palette.fieldBackground)
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
