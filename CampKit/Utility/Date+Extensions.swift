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
}
