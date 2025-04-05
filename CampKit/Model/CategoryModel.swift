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
    var id: UUID = UUID()
    @Attribute var name: String
    @Attribute var position: Int
    @Relationship(deleteRule: .cascade) var items: [Item]
    var packingList: PackingList?
    var isExpanded: Bool

    init(id: UUID = UUID(), name: String, position: Int, items: [Item] = [], isExpanded: Bool = false) {
        self.id = id
        self.name = name
        self.position = position
        self.items = []
        self.isExpanded = isExpanded
    }
    
}


extension Category {
    var sortedItems: [Item] {
        items
            .filter { $0.modelContext != nil && $0.position != nil }
            .sorted { $0.position ?? 0 < $1.position ?? 0 }
    }
}
