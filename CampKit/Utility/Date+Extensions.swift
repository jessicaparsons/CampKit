//
//  Date+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/16/25.
//

import Foundation

extension Date {
    
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        let calendar = Calendar.current
        return calendar.isDateInTomorrow(self)
    }
    
    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    }
}


extension Array where Element == Date {
    func formattedRange(format: String = "MMM d") -> String {
        let sorted = self.sorted()
        guard let first = sorted.first, let last = sorted.last else {
            return "Select Dates"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return "\(formatter.string(from: first)) – \(formatter.string(from: last))"
    }
}

extension Date {
    static func formattedRange(from start: Date?, to end: Date?) -> String {
        guard let start = start, let end = end else {
            return "Select Dates"
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MMM d"

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"

        return "\(dayFormatter.string(from: start)) – \(dayFormatter.string(from: end)), \(yearFormatter.string(from: end))"
    }
}

