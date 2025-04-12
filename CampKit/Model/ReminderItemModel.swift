//
//  ReminderItem.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import Foundation
import SwiftData

@Model
class ReminderItem: Identifiable {
    
    var id: UUID = UUID()
    var title: String
    var notes: String?
    var isCompleted: Bool
    var reminderDate: Date?
    var reminderTime: Date?
    
    init(title: String, notes: String = "", isCompleted: Bool = false, reminderDate: Date? = nil, reminderTime: Date? = nil) {
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.reminderTime = reminderTime
    }
}
