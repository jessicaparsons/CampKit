//
//  Item+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/14/25.
//

import Foundation
import CoreData

extension Item: EditablePackableItem {
    convenience init(
        context: NSManagedObjectContext,
        id: UUID = UUID(),
        title: String? = nil,
        isPacked: Bool = false
    )
    {
        self.init(context: context)
        self.id = id
        self.title = title
        self.isPacked = isPacked
    }
}

