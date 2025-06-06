//
//  SampleRestockItems.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//
#if DEBUG
import SwiftUI
import CoreData


extension RestockItem {
    static func generateSampleItems(context: NSManagedObjectContext) {
        let titles = ["Toothpaste and a long item goes here to see wrap", "Fuel Canister", "Trail Mix", "Boots", "Water Bottle", "Snacks", "Sunscreen", "Map", "Whistle", "First Aid Kit", "Matches", "Knife", "Whistle", "Emergency Blanket", "Flashlight", "Whistle", "Emergency Blanket", "Flashlight"]
        for (index, title) in titles.enumerated() {
            let item = RestockItem(context: context)
            item.id = UUID()
            item.title = title
            item.position = Int64(index)
            item.isPacked = false
        }
    }
}
#endif
