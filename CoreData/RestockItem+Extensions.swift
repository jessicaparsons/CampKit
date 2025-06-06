//
//  RestockItem+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/14/25.
//

import Foundation
import CoreData

extension RestockItem: EditablePackableItem {
    convenience init(
        context: NSManagedObjectContext,
        title: String? = nil,
        position: Int,
        isPacked: Bool = false,
        dateCreated: Date? = nil,
        id: UUID = UUID(),
        quantity: Int64? = nil
    ) {
        self.init(context: context)
        self.title = title
        self.position = Int64(position)
        self.isPacked = isPacked
        self.dateCreated = dateCreated ?? Date()
        self.id = id
        self.quantity = quantity ?? 0
    }
    
    var positionInt: Int {
        get { Int(position) }
        set { position = Int64(newValue) }
    }
}
