//
//  PackingList+CoreDataProperties.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/13/25.
//
//

import Foundation
import CoreData


extension PackingList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PackingList> {
        return NSFetchRequest<PackingList>(entityName: "PackingList")
    }

    @NSManaged public var dateCreated: Date
    @NSManaged public var elevation: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var locationAddress: String?
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var photo: Data?
    @NSManaged public var position: Int64
    @NSManaged public var title: String?
    @NSManaged public var categories: NSSet?

}

// MARK: Generated accessors for categories
extension PackingList {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

extension PackingList : Identifiable {

}
