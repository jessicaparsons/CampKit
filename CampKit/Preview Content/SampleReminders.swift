//
//  SampleReminders.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/15/25.
//
#if DEBUG

import Foundation
import CoreData


extension Reminder {
    
    static func generateSampleReminders(context: NSManagedObjectContext) {
        let reminders = [
            Reminder(context: context, title: "Charge Batteries", notes: "Ollie's collar", reminderDate: Date(), reminderTime: Date()),
            Reminder(context: context, title: "Check propane"),
            Reminder(context: context, title: "Fill up water bottles")
        ]
    }
}

#endif
