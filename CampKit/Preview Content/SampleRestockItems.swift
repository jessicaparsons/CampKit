//
//  SampleRestockItems.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import Foundation

extension RestockItem {
    
    static var restockItems: [RestockItem] {
        return [
            RestockItem(position: 0, title: "Propane", isPacked: false),
            RestockItem(position: 1, title: "Paper Towels", isPacked: false),
            RestockItem(position: 2, title: "Fire Starter", isPacked: false),
            RestockItem(position: 3, title: "Gloves", isPacked: false),
            RestockItem(position: 4, title: "Propane", isPacked: false),
            RestockItem(position: 5, title: "Paper Towels", isPacked: false),
            RestockItem(position: 6, title: "Fire Starter", isPacked: false),
            RestockItem(position: 7, title: "Gloves", isPacked: false),
            RestockItem(position: 8, title: "Propane", isPacked: false),
            RestockItem(position: 9, title: "Paper Towels", isPacked: false),
            RestockItem(position: 10, title: "Fire Starter", isPacked: false),
            RestockItem(position: 11, title: "Gloves", isPacked: false),
        ]
    }
}
