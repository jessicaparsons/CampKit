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
        packingList.photo = UIImage(named: "placeholder")?.pngData()
        
        let categories = Category.sampleCategories(context: context)
        categories.forEach { $0.packingList = packingList }
        packingList.categories = NSSet(array: categories)
        
        return packingList
    }
}

extension Category {
    static func sampleCategories(context: NSManagedObjectContext) -> [Category] {
        let categoriesWithItems: [(name: String, position: Int, items: [String], isExpanded: Bool)] = [
            ("Bed 0", 0, ["Pillows", "Sleeping bag", "Sleeping pad"], true),
            ("Clothes 1", 1, ["Jackets", "Shoes", "Toiletries"], true),
            ("Food 2", 2, ["Propane", "Stove", "Cooler"], true),
            ("Lounge 3", 3, ["Chair", "Books", "Cards/Games"], true),
            ("Hike 4", 4, ["Backpack", "Camera", "Trail snacks"], true)
        ]

        return categoriesWithItems.map { categoryData in
            let category = Category(context: context)
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



