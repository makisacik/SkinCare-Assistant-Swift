//
//  ProductTipsService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import Combine

@MainActor
class ProductTipsService: ObservableObject {
    static let shared = ProductTipsService()
    
    @Published var currentTip: ProductTip?
    @Published var isRotating = false
    @Published var isPaused = false
    
    private var tips: [ProductTip] = []
    private var currentIndex = 0
    
    var currentTipIndex: Int {
        return currentIndex
    }
    private var rotationTimer: Timer?
    private let rotationInterval: TimeInterval = 8.0 // Change tip every 8 seconds
    private var tipStartTime: Date?
    private var remainingTime: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Public Methods
    
    func startTips(for productType: ProductType) {
        stopTips()
        
        tips = ProductTipsData.getTips(for: productType)
        currentIndex = 0
        
        guard !tips.isEmpty else {
            currentTip = nil
            return
        }
        
        currentTip = tips[currentIndex]
        tipStartTime = Date()
        remainingTime = rotationInterval
        startRotation()
    }
    
    func stopTips() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        isRotating = false
        isPaused = false
        currentTip = nil
        tipStartTime = nil
        remainingTime = 0
    }
    
    func pauseTips() {
        guard !isPaused else { return }
        
        isPaused = true
        rotationTimer?.invalidate()
        rotationTimer = nil
        
        // Calculate remaining time
        if let startTime = tipStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            remainingTime = max(0, rotationInterval - elapsed)
        }
    }
    
    func resumeTips() {
        guard !tips.isEmpty && isPaused else { return }
        
        isPaused = false
        if tips.count > 1 && remainingTime > 0 {
            tipStartTime = Date()
            startRotationWithRemainingTime()
        }
    }
    
    func nextTip() {
        guard !tips.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % tips.count
        currentTip = tips[currentIndex]
        tipStartTime = Date()
        remainingTime = rotationInterval
    }
    
    func previousTip() {
        guard !tips.isEmpty else { return }
        
        currentIndex = currentIndex > 0 ? currentIndex - 1 : tips.count - 1
        currentTip = tips[currentIndex]
    }
    
    func getRandomTip(for productType: ProductType) -> ProductTip? {
        return ProductTipsData.getRandomTip(for: productType)
    }
    
    func getTipsCount(for productType: ProductType) -> Int {
        return ProductTipsData.getTips(for: productType).count
    }
    
    // MARK: - Private Methods
    
    private func startRotation() {
        guard tips.count > 1 && !isPaused else { return }
        
        isRotating = true
        rotationTimer = Timer.scheduledTimer(withTimeInterval: rotationInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                self.nextTip()
            }
        }
    }
    
    private func startRotationWithRemainingTime() {
        guard tips.count > 1 && !isPaused && remainingTime > 0 else { return }
        
        isRotating = true
        rotationTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isPaused else { return }
                self.nextTip()
                // After the first timer with remaining time, start normal rotation
                if self.tips.count > 1 {
                    self.startRotation()
                }
            }
        }
    }
    
    deinit {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
}

// MARK: - Tip Category Extensions

extension TipCategory {
    var systemIcon: String {
        switch self {
        case .application:
            return "hand.point.up"
        case .technique:
            return "hand.draw"
        case .timing:
            return "clock"
        case .benefits:
            return "star.fill"
        case .commonMistakes:
            return "exclamationmark.triangle"
        case .proTips:
            return "lightbulb.fill"
        }
    }
    
    var colorName: String {
        switch self {
        case .application:
            return "blue"
        case .technique:
            return "green"
        case .timing:
            return "orange"
        case .benefits:
            return "purple"
        case .commonMistakes:
            return "red"
        case .proTips:
            return "yellow"
        }
    }
}
