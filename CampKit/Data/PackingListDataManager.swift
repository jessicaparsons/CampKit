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
        dateCreated: Date(),
        locationName: "Joshua Tree National Park"
    )
    print("Created PackingList: \(sampleList.title)")
    
    let categories = [
        Category(name: "Bed 0", position: 0),
        Category(name: "Clothes 1", position: 1),
        Category(name: "Food 2", position: 2),
        Category(name: "Lounge 3", position: 3),
        Category(name: "Hike 4", position: 4)
    ]
    print("Created Categories: \([categories])")
    
    let items = [
        "Bed 0": ["Pillows", "Sleeping bag", "Sleeping pad"],
        "Clothes 1": ["Jackets", "Hats", "Shoes", "Toiletries", "Supplements"],
        "Food 2": ["Propane", "Stove", "Cooler", "Ice", "Dry bag", "Water", "Water bottles"],
        "Lounge 3": ["Chair", "Electronics", "Shade pop up", "Books", "Cards/games", "Instruments"],
        "Hike 4": ["Backpack", "Chargers", "Drugs", "Camera", "Trail snacks"]
    ]
    print("Created Items: \([items])")
    
    
    
    
    
    // Populate categories and their items
    for category in categories {
        if let itemNames = items[category.name] {
            let categoryItems = itemNames.map { Item(title: $0) }
            category.items.append(contentsOf: categoryItems)
        }
        print("Assigning \(category.name) position: \(category.position)")
        sampleList.categories.append(category)
        
        for category in sampleList.categories {
            print("Category '\(category.name)' has position \(category.position)")
        }
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
