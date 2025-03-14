//
//  SamplePackingList.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import Foundation
import UIKit

extension Category {
    static var sampleCategories: [Category] {
        // Define category names and associated items
        let categoriesWithItems: [(name: String, position: Int, items: [String], isExpanded: Bool)] = [
            ("Bed 0", 0, ["Pillows", "Sleeping bag", "Sleeping pad"], true),
            ("Clothes 1", 1, ["Jackets", "Shoes", "Toiletries"], true),
            ("Food 2", 2, ["Propane", "Stove", "Cooler"], true),
            ("Lounge 3", 3, ["Chair", "Books", "Cards/Games"], true),
            ("Hike 4", 4, ["Backpack", "Camera", "Trail snacks"], true)
        ]

        // Create categories with items
        return categoriesWithItems.map { categoryData in
            let category = Category(name: categoryData.name, position: categoryData.position)
            category.items = categoryData.items.enumerated().map { index, itemTitle in
                let item = Item(title: itemTitle, isPacked: false)
                item.position = index
                item.category = category
                return item
            }
            return category
        }
    }
}


extension PackingList {
    
    static var samplePackingList: PackingList {
        let photo = UIImage(named: "placeholder")?.pngData()
        let packingList = PackingList(
            title: "Sample Camping Trip"
        )
        packingList.categories = Category.sampleCategories
        return packingList
    }
}

