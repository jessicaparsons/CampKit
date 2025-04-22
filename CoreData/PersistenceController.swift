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

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Missing persistent store description")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions?.databaseScope = .private // Optional, default is private

        container.loadPersistentStores { storeDescription, error in
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
