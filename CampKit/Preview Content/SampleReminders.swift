//
//  SampleReminders.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/15/25.
//

import Foundation
import CoreData

struct SampleReminders {
    
    
    static var reminders: [Reminder] {
        
        let context = PersistenceController.shared.container.viewContext
        return [
            Reminder(context: context, title: "Charge Batteries", notes: "Ollie's collar", reminderDate: Date(), reminderTime: Date()),
            Reminder(context: context, title: "Check propane"),
            Reminder(context: context, title: "Fill up water bottles")
        ]
    }
}
