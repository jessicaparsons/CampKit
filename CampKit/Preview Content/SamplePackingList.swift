//
//  SamplePackingList.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import Foundation
import UIKit
import CoreData



extension PackingList {
    
    static func samplePackingList(context: NSManagedObjectContext) -> PackingList {
        
        let packingList = PackingList(context: context)
        packingList.position = 0
        packingList.title = "Preview Camping Trip"
        packingList.dateCreated = Date()
        packingList.photo = UIImage(named: "test")?.pngData()
        packingList.startDate = Date()
        packingList.endDate = Date()
        packingList.locationName = "Angeles National Forest"
        
        let categories = Category.sampleCategories(context: context)
        categories.forEach { $0.packingList = packingList }
        packingList.categories = NSSet(array: categories)
        
        return packingList
    }
}

extension Category {
    static func sampleCategories(context: NSManagedObjectContext) -> [Category] {
        let categoriesWithItems: [(name: String, position: Int, items: [String], isExpanded: Bool)] = [
            ("Bed 4", 4, ["Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad"], true),
            ("Clothes 3", 3, ["Jackets", "Shoes", "Toiletries","Jackets", "Shoes", "Toiletries","Jackets", "Shoes", "Toiletries"], true),
            ("Food 2", 2, ["Propane", "Stove", "Cooler","Propane", "Stove", "Cooler","Propane", "Stove", "Cooler","Propane", "Stove", "Cooler"], true),
            ("Lounge 1", 1, ["Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games"], true),
//            ("Hike 4", 4, ["Backpack", "Camera", "Trail snacks","Backpack", "Camera", "Trail snacks","Backpack", "Camera", "Trail snacks"], true),
//            ("Kids 5", 0, ["Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad","Pillows", "Sleeping bag", "Sleeping pad"], true),
//            ("Pets 6", 1, ["Jackets", "Shoes", "Toiletries","Jackets", "Shoes", "Toiletries","Jackets", "Shoes", "Toiletries"], true),
//            ("Hot 7", 2, ["Propane", "Stove", "Cooler","Propane", "Stove", "Cooler","Propane", "Stove", "Cooler","Propane", "Stove", "Cooler"], true),
//            ("Cold 8", 3, ["Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games","Chair", "Books", "Cards/Games"], true),
            ("Water Sports 0", 0, ["Backpack", "Camera", "Trail snacks","Backpack", "Camera", "Trail snacks","Backpack", "Camera", "Trail snacks"], true)
        ]

        return categoriesWithItems.map { categoryData in
            let category = Category(context: context)
            category.id = UUID()
            category.name = categoryData.name
            category.position = Int64(categoryData.position)
            category.isExpanded = categoryData.isExpanded

            let items: Set<Item> = Set(categoryData.items.enumerated().map { index, itemTitle in
                let item = Item(context: context)
                item.id = UUID()
                item.title = itemTitle
                item.isPacked = false
                item.position = Int64(index)
                item.category = category
                return item
            })

            category.items = items as NSSet

            return category
        }
    }
}



