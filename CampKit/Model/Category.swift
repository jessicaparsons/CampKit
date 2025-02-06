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
    var myID: UUID = UUID() // Unique identifier
    @Attribute var name: String
    @Attribute var position: Int
    @Relationship(deleteRule: .cascade) var items: [Item] = []
    var packingList: PackingList?
    
    var isExpanded: Bool

    init(name: String, position: Int, items: [Item] = [], isExpanded: Bool = true) {
        self.name = name
        self.position = position
        self.items = []
        self.isExpanded = isExpanded
    }
    
}
