//
//  RemindersViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import SwiftUI
import CoreData

@Observable
final class RemindersViewModel {
    
    
    private let viewContext: NSManagedObjectContext
    //var reminderItems: [ReminderItem] = []
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
 
    func fetchReminderItems() async throws -> [Reminder] {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return try viewContext.fetch(request)
    }
}
