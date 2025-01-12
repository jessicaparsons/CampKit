//
//  SamplePackingList.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import Foundation
import UIKit

extension PackingList {
    
    
    static var sample: PackingList {
        let photo = UIImage(named: "placeholder")?.pngData()
        let packingList = PackingList(
            title: "Sample Camping Trip",
            photo: photo,
            dateCreated: Date(),
            locationName: "Joshua Tree National Park"
        )
        
        packingList.categories = Category.sample
        return packingList
    }
}


extension Category {
    
    static var sample: [Category] {
        let categories =
        
        [
            Category(name: "Bed 0", position: 0),
            Category(name: "Clothes 1", position: 1),
            Category(name: "Food 2", position: 2),
            Category(name: "Lounge 3", position: 3),
            Category(name: "Hike 4", position: 4)
        ]
        
        // Map items to categories
        let itemsByCategory = Item.sample
        for category in categories {
            if let items = itemsByCategory[category.name] {
                category.items = items
                items.forEach { $0.category = category }
            }
        }

        return categories
        
    }
}

extension Item {
    static var sample: [String: [Item]] {
        [
            "Bed 0": ["Pillows", "Sleeping bag", "Sleeping pad"].map { Item(title: $0) },
            "Clothes 1": ["Jackets", "Hats", "Shoes", "Toiletries", "Supplements"].map { Item(title: $0) },
            "Food 2": ["Propane", "Stove", "Cooler", "Ice", "Dry bag", "Water", "Water bottles"].map { Item(title: $0) },
            "Lounge 3": ["Chair", "Electronics", "Shade pop up", "Books", "Cards/games", "Instruments"].map { Item(title: $0) },
            "Hike 4": ["Backpack", "Chargers", "Drugs", "Camera", "Trail snacks"].map { Item(title: $0) }
        ]
    }
}

