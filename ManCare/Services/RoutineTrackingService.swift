//
//  RoutineTrackingService.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class RoutineTrackingService: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var completedSteps: Set<String> = []
    
    // MARK: - Public Methods
    
    /// Toggle completion status for a routine step on a specific date
    func toggleStepCompletion(stepId: String, stepTitle: String, stepType: ProductType, timeOfDay: TimeOfDay, date: Date = Date()) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Check if completion already exists for this step on this date
        if let existingCompletion = getCompletion(stepId: stepId, date: startOfDay) {
            // Toggle existing completion
            existingCompletion.isCompleted.toggle()
            existingCompletion.createdAt = Date()
        } else {
            // Create new completion
            let completion = RoutineCompletion(context: viewContext)
            completion.stepId = stepId
            completion.stepTitle = stepTitle
            completion.stepType = stepType.rawValue
            completion.timeOfDay = timeOfDay.rawValue
            completion.completionDate = startOfDay
            completion.isCompleted = true
            completion.createdAt = Date()
        }
        
        saveContext()
        updateCompletedSteps(for: startOfDay)
    }
    
    /// Get completion status for a specific step on a specific date
    func isStepCompleted(stepId: String, date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if let completion = getCompletion(stepId: stepId, date: startOfDay) {
            return completion.isCompleted
        }
        return false
    }
    
    /// Get all completed steps for a specific date
    func getCompletedSteps(for date: Date = Date()) -> Set<String> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "completionDate == %@ AND isCompleted == YES", startOfDay as NSDate)
        
        do {
            let completions = try viewContext.fetch(request)
            return Set(completions.compactMap { completion in
                guard let stepId = completion.stepId, !stepId.isEmpty else {
                    return nil
                }
                return stepId
            })
        } catch {
            print("Error fetching completed steps: \(error)")
            return []
        }
    }
    
    /// Get completion statistics for a date range
    func getCompletionStats(from startDate: Date, to endDate: Date) -> [Date: CompletionStats] {
        let calendar = Calendar.current
        var stats: [Date: CompletionStats] = [:]
        
        let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "completionDate >= %@ AND completionDate <= %@", 
                                      calendar.startOfDay(for: startDate) as NSDate,
                                      calendar.startOfDay(for: endDate) as NSDate)
        
        do {
            let completions = try viewContext.fetch(request)
            
            // Group by date
            let groupedCompletions = Dictionary(grouping: completions) { completion in
                guard let completionDate = completion.completionDate else {
                    return Date()
                }
                return calendar.startOfDay(for: completionDate)
            }
            
            // Calculate stats for each date
            for (date, dateCompletions) in groupedCompletions {
                let completedCount = dateCompletions.filter { $0.isCompleted }.count
                let totalCount = dateCompletions.count
                
                stats[date] = CompletionStats(
                    date: date,
                    completedSteps: completedCount,
                    totalSteps: totalCount,
                    completionRate: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
                )
            }
        } catch {
            print("Error fetching completion stats: \(error)")
        }
        
        return stats
    }
    
    /// Get streak information
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while true {
            let completedSteps = getCompletedSteps(for: currentDate)
            if completedSteps.isEmpty {
                break
            }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    /// Clear all completions (for testing/reset purposes)
    func clearAllCompletions() {
        let request: NSFetchRequest<NSFetchRequestResult> = RoutineCompletion.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try viewContext.execute(deleteRequest)
            saveContext()
            completedSteps.removeAll()
        } catch {
            print("Error clearing completions: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func getCompletion(stepId: String, date: Date) -> RoutineCompletion? {
        let request: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "stepId == %@ AND completionDate == %@", stepId, date as NSDate)
        request.fetchLimit = 1
        
        do {
            let completions = try viewContext.fetch(request)
            return completions.first
        } catch {
            print("Error fetching completion: \(error)")
            return nil
        }
    }
    
    private func updateCompletedSteps(for date: Date) {
        completedSteps = getCompletedSteps(for: date)
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Supporting Types

struct CompletionStats {
    let date: Date
    let completedSteps: Int
    let totalSteps: Int
    let completionRate: Double
    
    var isComplete: Bool {
        return completionRate >= 1.0
    }
    
    var progressPercentage: Double {
        return completionRate * 100
    }
}

// MARK: - Extensions
