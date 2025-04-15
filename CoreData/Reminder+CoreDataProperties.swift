//
//  Reminder+CoreDataProperties.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/13/25.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notes: String?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var reminderTime: Date?
    @NSManaged public var title: String?

}

extension Reminder : Identifiable {

}
