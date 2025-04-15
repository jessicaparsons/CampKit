//
//  Category+Extensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/14/25.
//

import Foundation
import CoreData

extension Category {
    
    convenience init(
        context: NSManagedObjectContext,
        id: UUID = UUID(),
        isExpanded: Bool = false,
        name: String,
        position: Int,
        items: NSSet? = nil,
        packingList: PackingList? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.isExpanded = isExpanded
        self.name = name
        self.position = Int64(position)
        self.items = items
        self.packingList = packingList
        
    }
    
    var sortedItems: [Item] {
        (items as? Set<Item>)?.sorted(by: { $0.position < $1.position }) ?? []
    }
}

