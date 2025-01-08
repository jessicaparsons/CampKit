//
//  Category.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import Foundation
import SwiftData

@Model
class Category: Identifiable {
    var id: UUID = UUID() // Unique identifier
    @Attribute var name: String
    @Relationship(deleteRule: .cascade) var items: [Item] // Relationship with items
    var packingList: PackingList? // Backlink to the parent PackingList
    @Attribute var position: Int

    init(name: String, position: Int) {
        self.name = name
        self.items = []
        self.position = position
    }
    
}
