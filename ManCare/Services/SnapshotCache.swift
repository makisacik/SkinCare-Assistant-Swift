//
//  SnapshotCache.swift
//  ManCare
//
//  In-memory cache for routine snapshots
//

import Foundation

// MARK: - Snapshot Cache

class SnapshotCache {
    
    // MARK: - Cache Key
    
    private struct CacheKey: Hashable {
        let routineId: UUID
        let date: Date
        
        init(routineId: UUID, date: Date) {
            // Normalize to start of day for consistent caching
            let calendar = Calendar.current
            self.routineId = routineId
            self.date = calendar.startOfDay(for: date)
        }
    }
    
    // MARK: - Properties
    
    private var cache: [CacheKey: RoutineSnapshot] = [:]
    private let lock = NSLock()
    
    // MARK: - Cache Operations
    
    /// Get snapshot from cache
    func get(routineId: UUID, date: Date) -> RoutineSnapshot? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = CacheKey(routineId: routineId, date: date)
        let snapshot = cache[key]
        
        if snapshot != nil {
            print("✅ SnapshotCache: Hit for routine \(routineId) on \(date)")
        } else {
            print("⚠️ SnapshotCache: Miss for routine \(routineId) on \(date)")
        }
        
        return snapshot
    }
    
    /// Set snapshot in cache
    func set(_ snapshot: RoutineSnapshot, for routineId: UUID, date: Date) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = CacheKey(routineId: routineId, date: date)
        cache[key] = snapshot
        
        print("✅ SnapshotCache: Cached snapshot for routine \(routineId) on \(date)")
    }
    
    /// Invalidate cache for a specific routine
    func invalidate(routineId: UUID) {
        lock.lock()
        defer { lock.unlock() }
        
        let keysToRemove = cache.keys.filter { $0.routineId == routineId }
        keysToRemove.forEach { cache.removeValue(forKey: $0) }
        
        print("✅ SnapshotCache: Invalidated \(keysToRemove.count) entries for routine \(routineId)")
    }
    
    /// Invalidate cache for a specific date
    func invalidate(date: Date) {
        lock.lock()
        defer { lock.unlock() }
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        let keysToRemove = cache.keys.filter { $0.date == normalizedDate }
        keysToRemove.forEach { cache.removeValue(forKey: $0) }
        
        print("✅ SnapshotCache: Invalidated \(keysToRemove.count) entries for date \(date)")
    }
    
    /// Clear all cache
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        let count = cache.count
        cache.removeAll()
        
        print("✅ SnapshotCache: Cleared \(count) entries")
    }
    
    /// Invalidate past dates (cleanup)
    func invalidatePastDates() {
        lock.lock()
        defer { lock.unlock() }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let keysToRemove = cache.keys.filter { $0.date < today }
        keysToRemove.forEach { cache.removeValue(forKey: $0) }
        
        print("✅ SnapshotCache: Cleaned up \(keysToRemove.count) past entries")
    }
    
    // MARK: - Cache Stats
    
    var cacheSize: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }
}

