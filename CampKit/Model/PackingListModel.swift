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
    var elevation: Double?
    
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(
        title: String,
        photo: Data? = nil,
        dateCreated: Date = Date(),
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        elevation: Double? = nil
    ) {
        self.title = title
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
            
        self.categories = []
    }
}
