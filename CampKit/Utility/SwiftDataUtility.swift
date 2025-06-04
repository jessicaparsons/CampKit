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
    } catch {
        
    }
}

