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
    @Attribute var position: Int
    var title: String
    var photo: Data?
    var dateCreated: Date = Date()
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?
    var elevation: Double?

    
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(
        position: Int,
        title: String,
        photo: Data? = nil,
        dateCreated: Date = Date(),
        locationName: String? = nil,
        locationAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        elevation: Double? = nil
    ) {
        self.position = position
        self.title = title
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
            
        self.categories = []
    }
}
