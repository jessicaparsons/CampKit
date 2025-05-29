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
    
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
 
    func fetchReminderItems() async throws -> [Reminder] {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return try viewContext.fetch(request)
    }
    
    func deleteCompletedReminders() {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        
        do {
            let completedReminders = try viewContext.fetch(request)
            
            for reminder in completedReminders {
                viewContext.delete(reminder)
            }
            try viewContext.save()
        } catch {
            print("Failed to delete completed remiders: \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - CREATE OR UPDATE THE REMINDER
    @MainActor
    func updateReminder(isNew: Bool, currentReminder: Reminder, title: String, notes: String, showCalendar: Bool, showTime: Bool, reminderDate: Date? = nil, reminderTime: Date? = nil) {
        
        currentReminder.id = currentReminder.id ?? UUID()
        currentReminder.title = title
        currentReminder.notes = notes.isEmpty ? nil : notes
        currentReminder.reminderDate = showCalendar ? reminderDate : nil
        currentReminder.reminderTime = showTime ? reminderTime : nil
        currentReminder.isCompleted = currentReminder.isCompleted
        
        //SCHEDULE A LOCAL NOTIFICATION
        if let existingReminderTime = currentReminder.reminderTime {
            NotificationManager.scheduleNotification(userData: UserData(
                title: currentReminder.title,
                body: currentReminder.notes ?? "",
                date: currentReminder.reminderDate ?? Date(),
                time: existingReminderTime
            ))
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Could not save or update reminder: \(error.localizedDescription)")
            if isNew {
                viewContext.delete(currentReminder)
            }
        }
    }
    
}
