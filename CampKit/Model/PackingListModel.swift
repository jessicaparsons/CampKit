//
//  ListModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import Foundation
import SwiftData

@Model
class PackingList: Identifiable {
    var title: String
    var photo: Data? // Optional photo for thumbnail
    var dateCreated: Date = Date()
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(title: String, photo: Data? = nil, dateCreated: Date = Date(), locationName: String? = nil) {
        self.title = title
        self.categories = []
    }
}
