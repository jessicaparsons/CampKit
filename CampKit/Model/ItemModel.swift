//
//  Item.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable, EditablePackableItem {
    var id: UUID = UUID()
    var title: String
    var isPacked: Bool
    var position: Int?
    var category: Category? // Backlink to the parent category
    
    init(id: UUID = UUID(), title: String, isPacked: Bool = false) {
        self.id = id
        self.title = title
        self.isPacked = isPacked
    }
}

