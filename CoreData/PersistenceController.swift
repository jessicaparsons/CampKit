//
//  PersistenceController.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/13/25.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CampKitModel")
        

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data store failed: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

#if DEBUG
extension PersistenceController {
    @MainActor static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create a sample PackingList
        let sampleList = PackingList.samplePackingList(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save preview context: \(error)")
        }

        return controller
    }()
}
#endif
