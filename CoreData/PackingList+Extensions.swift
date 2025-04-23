//
//  PackingList+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/14/25.
//

import Foundation
import CoreData
import SwiftData
import CloudKit
import UniformTypeIdentifiers
import CoreTransferable

extension PackingList: @unchecked Sendable {
    convenience init(
        context: NSManagedObjectContext,
        title: String? = nil,
        position: Int,
        photo: Data? = nil,
        dateCreated: Date = Date(),
        locationName: String? = nil,
        locationAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        elevation: Double? = nil
    ) {
        self.init(context: context)
        self.title = title
        self.position = Int64(position)
        self.photo = photo
        self.dateCreated = dateCreated
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude.map(NSNumber.init(value:))
        self.longitude = longitude.map(NSNumber.init(value:))
        self.elevation = elevation.map(NSNumber.init(value:))
    }
    
    var sortedCategories: [Category] {
        (categories as? Set<Category>)?.sorted(by: { ($0.position) > ($1.position) }) ?? []
    }

}
