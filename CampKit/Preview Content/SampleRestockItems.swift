//
//  SampleRestockItems.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import CoreData


extension RestockItem {
    static func generateSampleItems(context: NSManagedObjectContext) {
        let titles = ["Toothpaste", "Fuel Canister", "Trail Mix"]
        for (index, title) in titles.enumerated() {
            let item = RestockItem(context: context)
            item.id = UUID()
            item.title = title
            item.position = Int64(index)
            item.isPacked = false
        }
    }
}
