//
//  InsightsViewModel.swift
//  ManCare
//
//  Created for Insights Tab Feature
//

import Foundation
import SwiftUI
import Combine

@MainActor
class InsightsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStreak: Int = 0
    @Published var weeklyCompletionRate: Double = 0
    @Published var monthlyCompletionRate: Double = 0
    @Published var morningCompletionCount: Int = 0
    @Published var eveningCompletionCount: Int = 0
    @Published var morningTotal: Int = 7
    @Published var eveningTotal: Int = 7
    @Published var mostUsedProducts: [(product: String, productType: ProductType, count: Int)] = []
    @Published var tagFrequencies: [(tag: SkinFeelTag, percentage: Double)] = []
    @Published var adaptationImpact: Double? = nil
    @Published var mostConsistentPeriod: String = ""
    @Published var isLoading = true
    
    // MARK: - Dependencies
    private let completionViewModel: RoutineCompletionViewModel
    private let skinJournalStore = SkinJournalStore.shared
    
    // MARK: - Initialization
    init(completionViewModel: RoutineCompletionViewModel) {
        self.completionViewModel = completionViewModel
    }
    
    // MARK: - Public Methods
    
    func loadAllInsights() async {
        await MainActor.run {
            isLoading = true
        }
        
        await calculateCurrentStreak()
        await calculateCompletionRates()
        await getMostUsedProducts()
        await getTagFrequencies()
        await calculateAdaptationImpact()
        await findMostConsistentPeriod()
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    // MARK: - Calculation Methods
    
    /// Calculate current streak of consecutive days with at least 1 completed step
    func calculateCurrentStreak() async {
        guard let routine = completionViewModel.activeRoutine else {
            await MainActor.run { currentStreak = 0 }
            return
        }
        
        let calendar = DateUtils.localCalendar
        let today = DateUtils.todayStartOfDay
        var streak = 0
        
        for dayOffset in 0..<365 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { break }
            
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            
            if completedSteps.isEmpty {
                break
            } else {
                streak += 1
            }
        }
        
        await MainActor.run {
            self.currentStreak = streak
        }
    }
    
    /// Calculate completion rates for last 7 and 30 days
    func calculateCompletionRates() async {
        guard let routine = completionViewModel.activeRoutine else {
            await MainActor.run {
                weeklyCompletionRate = 0
                monthlyCompletionRate = 0
            }
            return
        }
        
        let calendar = DateUtils.localCalendar
        let today = DateUtils.todayStartOfDay
        
        // Weekly (last 7 days)
        var weeklyCompleted = 0
        var weeklyTotal = 0
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            weeklyCompleted += completedSteps.count
            weeklyTotal += routine.stepDetails.count
        }
        
        // Monthly (last 30 days)
        var monthlyCompleted = 0
        var monthlyTotal = 0
        
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            monthlyCompleted += completedSteps.count
            monthlyTotal += routine.stepDetails.count
        }
        
        let weeklyRate = weeklyTotal > 0 ? Double(weeklyCompleted) / Double(weeklyTotal) : 0
        let monthlyRate = monthlyTotal > 0 ? Double(monthlyCompleted) / Double(monthlyTotal) : 0
        
        await MainActor.run {
            self.weeklyCompletionRate = weeklyRate
            self.monthlyCompletionRate = monthlyRate
        }
    }
    
    /// Get top 5 most used products from last 30 days
    func getMostUsedProducts() async {
        guard let routine = completionViewModel.activeRoutine else {
            await MainActor.run { mostUsedProducts = [] }
            return
        }
        
        let calendar = DateUtils.localCalendar
        let today = DateUtils.todayStartOfDay
        
        var productCounts: [String: Int] = [:]
        
        // Collect all completed steps from last 30 days
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            
            for stepId in completedSteps {
                if let step = routine.stepDetails.first(where: { $0.id.uuidString == stepId }) {
                    productCounts[step.stepType, default: 0] += 1
                }
            }
        }
        
        // Sort by count and take top 5
        let sorted = productCounts.sorted { $0.value > $1.value }.prefix(5)
        let products = sorted.compactMap { (stepType, count) -> (String, ProductType, Int)? in
            guard let productType = ProductType(rawValue: stepType) else { return nil }
            return (productType.displayName, productType, count)
        }
        
        await MainActor.run {
            self.mostUsedProducts = products
        }
    }
    
    /// Get tag frequencies from skin journal (last 30 days)
    func getTagFrequencies() async {
        let calendar = DateUtils.localCalendar
        let today = Date()
        guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) else {
            await MainActor.run { tagFrequencies = [] }
            return
        }
        
        let recentEntries = skinJournalStore.getEntries(from: thirtyDaysAgo, to: today)
        
        var tagCounts: [SkinFeelTag: Int] = [:]
        var totalTags = 0
        
        for entry in recentEntries {
            for tag in entry.skinFeelTags {
                tagCounts[tag, default: 0] += 1
                totalTags += 1
            }
        }
        
        guard totalTags > 0 else {
            await MainActor.run { tagFrequencies = [] }
            return
        }
        
        // Calculate percentages and take top 6
        let frequencies = tagCounts.map { (tag, count) in
            (tag: tag, percentage: Double(count) / Double(totalTags) * 100)
        }.sorted { $0.percentage > $1.percentage }.prefix(6)
        
        await MainActor.run {
            self.tagFrequencies = Array(frequencies)
        }
    }
    
    /// Compare completion rate this week vs last week (if adaptation enabled)
    func calculateAdaptationImpact() async {
        guard let routine = completionViewModel.activeRoutine,
              routine.adaptationEnabled else {
            await MainActor.run { adaptationImpact = nil }
            return
        }
        
        let calendar = DateUtils.localCalendar
        let today = DateUtils.todayStartOfDay
        
        // This week (last 7 days)
        var thisWeekCompleted = 0
        var thisWeekTotal = 0
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            thisWeekCompleted += completedSteps.count
            thisWeekTotal += routine.stepDetails.count
        }
        
        // Last week (days 7-13 ago)
        var lastWeekCompleted = 0
        var lastWeekTotal = 0
        
        for dayOffset in 7..<14 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            lastWeekCompleted += completedSteps.count
            lastWeekTotal += routine.stepDetails.count
        }
        
        guard thisWeekTotal > 0 && lastWeekTotal > 0 else {
            await MainActor.run { adaptationImpact = nil }
            return
        }
        
        let thisWeekRate = Double(thisWeekCompleted) / Double(thisWeekTotal)
        let lastWeekRate = Double(lastWeekCompleted) / Double(lastWeekTotal)
        
        let percentageDifference = ((thisWeekRate - lastWeekRate) / lastWeekRate) * 100
        
        await MainActor.run {
            self.adaptationImpact = percentageDifference
        }
    }
    
    /// Determine if morning or evening is more consistent
    func findMostConsistentPeriod() async {
        guard let routine = completionViewModel.activeRoutine else {
            await MainActor.run { mostConsistentPeriod = "" }
            return
        }
        
        let calendar = DateUtils.localCalendar
        let today = DateUtils.todayStartOfDay
        
        var morningDaysCompleted = 0
        var eveningDaysCompleted = 0
        
        let morningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .morning }
        let eveningSteps = routine.stepDetails.filter { $0.timeOfDayEnum == .evening }
        
        // Check last 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let completedSteps = await completionViewModel.getCompletedSteps(for: date)
            
            let completedMorningSteps = morningSteps.filter { completedSteps.contains($0.id.uuidString) }
            let completedEveningSteps = eveningSteps.filter { completedSteps.contains($0.id.uuidString) }
            
            if !completedMorningSteps.isEmpty {
                morningDaysCompleted += 1
            }
            if !completedEveningSteps.isEmpty {
                eveningDaysCompleted += 1
            }
        }
        
        let morningRate = !morningSteps.isEmpty ? Double(morningDaysCompleted) / 7.0 : 0
        let eveningRate = !eveningSteps.isEmpty ? Double(eveningDaysCompleted) / 7.0 : 0
        
        let insight: String
        if morningRate > eveningRate && morningRate > 0 {
            let percentage = Int(morningRate * 100)
            insight = "You're most consistent in the mornings! 🌅 (\(percentage)% completion rate)"
        } else if eveningRate > morningRate && eveningRate > 0 {
            let percentage = Int(eveningRate * 100)
            insight = "Your evening routine shines! 🌙 (\(percentage)% completion rate)"
        } else if morningRate == eveningRate && morningRate > 0 {
            let percentage = Int(morningRate * 100)
            insight = "You're equally consistent! Both routines at \(percentage)%"
        } else {
            insight = "Start building consistency with your routine!"
        }
        
        await MainActor.run {
            self.morningCompletionCount = morningDaysCompleted
            self.eveningCompletionCount = eveningDaysCompleted
            self.mostConsistentPeriod = insight
        }
    }
}

