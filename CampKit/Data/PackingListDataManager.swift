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
    
    let categoryNames = [
            "Bed 0", "Clothes 1", "Food 2", "Lounge 3", "Hike 4"
        ]
    
    print("Created Categories: \([categoryNames])")
    
    let items = [
        "Bed 0": ["Pillows", "Sleeping bag", "Sleeping pad"],
        "Clothes 1": ["Jackets", "Hats", "Shoes", "Toiletries", "Supplements"],
        "Food 2": ["Propane", "Stove", "Cooler", "Ice", "Dry bag", "Water", "Water bottles"],
        "Lounge 3": ["Chair", "Electronics", "Shade pop up", "Books", "Cards/games", "Instruments"],
        "Hike 4": ["Backpack", "Chargers", "Drugs", "Camera", "Trail snacks"]
    ]
    print("Created Items: \([items])")
    
    
    // Create and populate categories with items
    for (index, categoryName) in categoryNames.enumerated() {
        let category = Category(name: categoryName, position: index)

        // Add items to category
        if let itemNames = items[categoryName] {
            for (itemIndex, itemName) in itemNames.enumerated() {
                let item = Item(title: itemName, isPacked: false, position: itemIndex, category: category)
                category.items.append(item)
            }
        }

        print("Assigning \(category.name) position: \(category.position)")
        sampleList.categories.append(category)
    }

    
    // Insert the sample list into the context
    context.insert(sampleList)
    print("Inserted PackingList: \(sampleList)")

    
}
