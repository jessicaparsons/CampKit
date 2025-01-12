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
        [
            Category(name: "Bed 0", position: 0, items: [
                Item(title: "Pillows", isPacked: false),
                Item(title: "Sleeping bag", isPacked: false),
                Item(title: "Sleeping pad", isPacked: false),
            ]),
            Category(name: "Clothes 1", position: 1, items: [
                Item(title: "Jackets", isPacked: false),
                Item(title: "Shoes", isPacked: false),
                Item(title: "Toiletries", isPacked: false),
            ]),
            Category(name: "Food 2", position: 2, items: [
                Item(title: "Propane", isPacked: false),
                Item(title: "Stove", isPacked: false),
                Item(title: "Cooler", isPacked: false),
            ]),
            Category(name: "Lounge 3", position: 3, items: [
                Item(title: "Chair", isPacked: false),
                Item(title: "Books", isPacked: false),
                Item(title: "Cards/Games", isPacked: false),
            ]),
            Category(name: "Hike 4", position: 4, items: [
                Item(title: "Backpack", isPacked: false),
                Item(title: "Camera", isPacked: false),
                Item(title: "Trail snacks", isPacked: false),
            ]),
        ]
    }
}


extension PackingList {
    
    static var samplePackingList: PackingList {
        let photo = UIImage(named: "placeholder")?.pngData()
        let packingList = PackingList(
            title: "Sample Camping Trip",
            photo: photo,
            dateCreated: Date(),
            locationName: "Joshua Tree National Park"
        )
        packingList.categories = Category.sampleCategories
        return packingList
    }
}

