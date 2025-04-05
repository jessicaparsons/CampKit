//
//  RestockModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftData
import Foundation

@Model
class RestockItem: Identifiable {
    var id: UUID = UUID()
    var title: String
    var dateCreated: Date = Date()
    var isPacked: Bool
    
    init(id: UUID, title: String, dateCreated: Date, isPacked: Bool) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
        self.isPacked = isPacked
    }
}
