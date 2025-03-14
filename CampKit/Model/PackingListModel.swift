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
    @Relationship(deleteRule: .cascade) var participants: [Participant]
    @Relationship(deleteRule: .cascade) var activities: [Activity]
    @Relationship(deleteRule: .cascade) var weatherConditions: [WeatherCondition]
    @Relationship(deleteRule: .cascade) var categories: [Category]

    init(
        title: String,
        photo: Data? = nil,
        dateCreated: Date = Date(),
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        elevation: Double? = nil,
        participants: [Participant] = [],
        activities: [Activity] = [],
        weatherConditions: [WeatherCondition] = []
    ) {
        self.title = title
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        
        self.participants = participants
        self.activities = activities
        self.weatherConditions = weatherConditions
        
        self.categories = []
    }
}
