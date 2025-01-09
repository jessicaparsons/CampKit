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
    var locationName: String? // For display
    var latitude: Double?    // For weather API
    var longitude: Double?   // For weather API
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(title: String, photo: Data? = nil, dateCreated: Date = Date(), locationName: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.title = title
        self.photo = photo
        self.dateCreated = dateCreated
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.categories = []
    }
}
