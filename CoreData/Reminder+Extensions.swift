//
//  Reminder+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/14/25.
//

import CoreData

extension Reminder {
    convenience init(
        context: NSManagedObjectContext,
        title: String,
        isCompleted: Bool = false,
        notes: String? = nil,
        reminderDate: Date? = nil,
        reminderTime: Date? = nil,
        id: UUID? = nil
    ) {
        self.init(context: context)
        self.title = title
        self.isCompleted = isCompleted
        self.notes = notes
        self.reminderDate = reminderDate ?? Date()
        self.reminderTime = reminderTime ?? Date()
        self.id = id ?? UUID()
    }
    
}
