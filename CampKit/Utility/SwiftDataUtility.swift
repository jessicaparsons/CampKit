//
//  SwiftDataUtility.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import SwiftData


func save(_ context: ModelContext) {
    do {
        try context.save()
        print("SwiftData context saved.")
    } catch {
        print("SwiftData save failed: \(error.localizedDescription)")
    }
}

