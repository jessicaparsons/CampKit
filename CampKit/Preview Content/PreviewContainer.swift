//
//  PreviewContainer.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import Foundation


import SwiftUI
import SwiftData

@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            PackingList.self, Category.self, Item.self, RestockItem.self, ReminderItem.self
        ])
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            preloadPackingListData(context: container.mainContext)
            for reminder in SampleReminders.reminders {
                container.mainContext.insert(reminder)
            }
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
        
    }()
}



struct SampleReminders {
    
    static var reminders: [ReminderItem] {
        return [
            ReminderItem(title: "Charge Batteries", notes: "Ollie's collar", reminderDate: Date(), reminderTime: Date()),
            ReminderItem(title: "Check propane"),
            ReminderItem(title: "Fill up water bottles")
        ]
    }
}
