//
//  Item+CoreDataProperties.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/13/25.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isPacked: Bool
    @NSManaged public var position: Int64
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension Item : Identifiable {

}
