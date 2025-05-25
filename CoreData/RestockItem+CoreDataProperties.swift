//
//  RestockItem+CoreDataProperties.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/13/25.
//
//

import Foundation
import CoreData


extension RestockItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RestockItem> {
        return NSFetchRequest<RestockItem>(entityName: "RestockItem")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isPacked: Bool
    @NSManaged public var position: Int64
    @NSManaged public var title: String?
    @NSManaged public var quantity: Int64

}

extension RestockItem : Identifiable {

}
