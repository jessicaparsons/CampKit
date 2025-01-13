//
//  Item.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable {
    var myID: UUID = UUID()
    var title: String
    var isPacked: Bool
    var position: Int // Custom order property
    var category: Category? // Backlink to the parent category
    
    init(title: String, isPacked: Bool = false, position: Int, category: Category?) {
        self.title = title
        self.isPacked = isPacked
        self.position = position
        self.category = category
    }
}

//@Model
//final class Item {
//    var title: String
//    var isComplete: Bool
//    var timestamp: Date
//    
//    init(title: String, isComplete: Bool, timestamp: Date) {
//        self.title = title
//        self.isComplete = isComplete
//        self.timestamp = timestamp
//    }
//}
