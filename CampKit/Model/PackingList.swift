//
//  ListModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import Foundation
import SwiftData

@Model
class PackingList {
    var title: String
    var photo: Data? // Optional photo for thumbnail
    var dateCreated: Date
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(title: String, photo: Data? = nil, dateCreated: Date = Date()) {
        self.title = "Your Packing List"
        self.photo = photo
        self.dateCreated = dateCreated
        self.categories = []
    }
}
