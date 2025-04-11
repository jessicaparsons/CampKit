//
//  RestockModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftData
import Foundation

@Model
class RestockItem: Identifiable, EditablePackableItem {
    
    var id: UUID = UUID()
    @Attribute var position: Int
    var title: String
    var dateCreated: Date = Date()
    var isPacked: Bool
    
    init(position: Int, title: String, isPacked: Bool) {
        self.position = position
        self.title = title
        self.isPacked = isPacked
    }
}
