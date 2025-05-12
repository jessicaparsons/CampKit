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
        elevation: Double? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.init(context: context)
        self.title = title ?? Constants.newPackingListTitle
        self.position = Int64(position)
        self.photo = photo
        self.dateCreated = dateCreated
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude ?? 0.0
        self.longitude = longitude ?? 0.0
        self.elevation = elevation ?? 0.0
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var sortedCategories: [Category] {
        (categories as? Set<Category>)?.sorted(by: { ($0.position) > ($1.position) }) ?? []
    }

}


extension PackingList: Identifiable {}

