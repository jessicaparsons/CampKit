//
//  PackingListDataManager.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import Foundation
import SwiftData
import UIKit

func preloadPackingListData(context: ModelContext) {
    
    // Add debug statement to confirm function execution
    print("populateSampleData called")
    let fetchDescriptor = FetchDescriptor<PackingList>()
    let existingPackingLists = try? context.fetch(fetchDescriptor)
    print("Fetched Packing Lists Before Insert: \(existingPackingLists ?? [])")
    
    // Check if there are already packing lists to avoid duplication
    guard existingPackingLists?.isEmpty == true else {
        print("Data already exists. Skipping preload.")
        return
    }
    
    // Load the placeholder image as Data
    let placeholderImage = UIImage(named: "SequoiaPlaceholder")
    let placeholderImageData = placeholderImage?.jpegData(compressionQuality: 0.8)

    // Create a sample PackingList
    let sampleList = PackingList(
        title: "Sample Camping Trip",
        photo: placeholderImageData,
        dateCreated: Date()
    )
    print("Created PackingList: \(sampleList.title)")
    
    let categories = [
        Category(name: "Bed"),
        Category(name: "Clothes"),
        Category(name: "Food"),
        Category(name: "Lounge"),
        Category(name: "Hike")
    ]
    print("Created Categories: \([categories])")
    
    let items = [
        "Bed": ["Pillows", "Sleeping bag", "Sleeping pad"],
        "Clothes": ["Jackets", "Hats", "Shoes", "Toiletries", "Supplements"],
        "Food": ["Propane", "Stove", "Cooler", "Ice", "Dry bag", "Water", "Water bottles"],
        "Lounge": ["Chair", "Electronics", "Shade pop up", "Books", "Cards/games", "Instruments"],
        "Hike": ["Backpack", "Chargers", "Drugs", "Camera", "Trail snacks"]
    ]
    print("Created Items: \([items])")
    
    
    
    // Populate categories and their items
    for category in categories {
        if let itemNames = items[category.name] {
            let categoryItems = itemNames.map { Item(title: $0) }
            category.items.append(contentsOf: categoryItems)
        }
        sampleList.categories.append(category)
    }
    
    // Insert the sample list into the context
    context.insert(sampleList)
    print("Inserted PackingList: \(sampleList)")

    
    
//    // Debug inserted data
//    print("Inserted PackingList: \(sampleList.title)")
//    print("Categories in '\(sampleList.title)':")
//    for category in sampleList.categories {
//        print("  - \(category.name)")
//        for item in category.items {
//            print("    - \(item.title), Packed: \(item.isPacked)")
//        }
//    }

}
