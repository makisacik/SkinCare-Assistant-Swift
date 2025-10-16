//
//  DateUtils.swift
//  ManCare
//
//  Created by AI Assistant
//

import Foundation

/// Centralized date utilities to ensure consistent timezone handling across the app
enum DateUtils {
    /// Get a calendar instance configured with the local timezone
    static var localCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }

    /// Get the start of day for a given date in the local timezone
    static func startOfDay(for date: Date) -> Date {
        return localCalendar.startOfDay(for: date)
    }

    /// Check if two dates are on the same day in the local timezone
    static func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        return localCalendar.isDate(date1, inSameDayAs: date2)
    }

    /// Get the current date normalized to start of day in local timezone
    static var todayStartOfDay: Date {
        return startOfDay(for: Date())
    }

    /// Format a date for logging
    static func formatForLog(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

