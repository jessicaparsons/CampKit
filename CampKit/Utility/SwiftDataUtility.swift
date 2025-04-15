//
//  SwiftDataUtility.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import CoreData


func save(_ context: NSManagedObjectContext) {
    do {
        try context.save()
        print("SwiftData context saved.")
    } catch {
        print("SwiftData save failed: \(error.localizedDescription)")
    }
}

