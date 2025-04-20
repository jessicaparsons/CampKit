//
//  NotificationManager.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/19/25.
//

import Foundation
import UserNotifications

struct UserData {
    let title: String?
    let body: String?
    let date: Date?
    let time: Date?
    
}

struct NotificationManager {
    
    static func scheduleNotification(userData: UserData) {
        //SET UP COMPONENTS
        
        let content = UNMutableNotificationContent()
        content.title = userData.title ?? "Reminder"
        content.body = userData.body ?? ""
        content.sound = UNNotificationSound.default
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: userData.date ?? Date())
        
        if let reminderTime = userData.time {
            let reminderTimeDateComponents = reminderTime.dateComponents
            dateComponents.hour = reminderTimeDateComponents.hour
            dateComponents.minute = reminderTimeDateComponents.minute
        }
        
        //SET UP CALENDAR NOTIFICATION TRIGGER
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "Reminder Notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
