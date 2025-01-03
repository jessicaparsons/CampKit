//
//  Category.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import Foundation
import SwiftData

@Model
class Category {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [Item] // Relationship with items
    var packingList: PackingList? // Backlink to the parent PackingList

    init(name: String) {
        self.name = name
        self.items = []
    }
}
