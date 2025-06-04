//
//  RefreshContextHelper.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import Foundation
import CoreData
    
@MainActor
func refresh(context: NSManagedObjectContext) async {
    do {
        try context.setQueryGenerationFrom(.current)
    } catch {
    }
}
