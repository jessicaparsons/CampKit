//
//  CoreDataStack.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import CoreData
import CloudKit

final class CoreDataStack: ObservableObject {

    #if DEBUG
    let shouldInitializeCloudKitSchema = true
    #else
    let shouldInitializeCloudKitSchema = false
    #endif
    
    
    
    @MainActor static let shared = CoreDataStack()
    
    var ckContainer: CKContainer {
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        guard let identifier = storeDescription?
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get container identifier")
        }
        return CKContainer(identifier: identifier)
    }
    
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var privatePersistentStore: NSPersistentStore {
        guard let privateStore = _privatePersistentStore else {
            fatalError("Private store is not set")
        }
        return privateStore
    }
    
    var sharedPersistentStore: NSPersistentStore {
        guard let sharedStore = _sharedPersistentStore else {
            fatalError("Shared store is not set")
        }
        return sharedStore
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "CampKitModel")
        
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
        
        // TODO: 1
        let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription
            .copy() as? NSPersistentStoreDescription else {
            fatalError(
                "Copying the private store description returned an unexpected value."
            )
        }
        sharedStoreDescription.url = sharedStoreURL
        
        
        // TODO: 2
        
        guard let containerIdentifier = privateStoreDescription
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get containerIdentifier")
        }
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: containerIdentifier
        )
        sharedStoreOptions.databaseScope = .shared
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        
        // TODO: 3
        
        container.persistentStoreDescriptions.append(sharedStoreDescription)
        
        
        // TODO: 4
        
        container.loadPersistentStores { loadedStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            }

            // Assign the store references
            if let cloudKitContainerOptions = loadedStoreDescription.cloudKitContainerOptions {
                guard let loadedStoreDescriptionURL = loadedStoreDescription.url else { return }

                if cloudKitContainerOptions.databaseScope == .private {
                    self._privatePersistentStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescriptionURL)
                } else if cloudKitContainerOptions.databaseScope == .shared {
                    self._sharedPersistentStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescriptionURL)
                }
            }

//            // SCHEMA INIT (development only)
//            #if DEBUG
//            if self.shouldInitializeCloudKitSchema {
//                do {
//                    try container.initializeCloudKitSchema(options: [])
//                    print("CloudKit schema initialized")
//                } catch {
//                    print("Failed to initialize CloudKit schema: \(error)")
//                }
//            }
//            #endif
        }
        
//        container.loadPersistentStores { loadedStoreDescription, error in
//            if let error = error as NSError? {
//                fatalError("Failed to load persistent stores: \(error)")
//            } else if let cloudKitContainerOptions = loadedStoreDescription
//                .cloudKitContainerOptions {
//                guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
//                    return
//                }
//                if cloudKitContainerOptions.databaseScope == .private {
//                    let privateStore = container.persistentStoreCoordinator
//                        .persistentStore(for: loadedStoreDescritionURL)
//                    self._privatePersistentStore = privateStore
//                } else if cloudKitContainerOptions.databaseScope == .shared {
//                    let sharedStore = container.persistentStoreCoordinator
//                        .persistentStore(for: loadedStoreDescritionURL)
//                    self._sharedPersistentStore = sharedStore
//                }
//            }
//        }
        
        for entity in container.managedObjectModel.entities {
            print("Entity loaded: \(entity.name ?? "Unnamed")")
        }
        
        
        //container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    
    
    //private init() {}
    
    
    private init(inMemory: Bool = false) {
        if inMemory {
            let container = NSPersistentCloudKitContainer(name: "CampKitModel")
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null") // in-memory
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load in-memory store: \(error)")
                }
            }
            
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            container.viewContext.automaticallyMergesChangesFromParent = true
            self.persistentContainer = container
        }
    }
    
}

// MARK: Save or delete from Core Data
extension CoreDataStack {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ViewContext save error: \(error)")
            }
        }
    }
    
    func delete(_ list: PackingList) {
        context.perform {
            self.context.delete(list)
            self.save()
        }
    }
}


extension CoreDataStack {
    func isShared(object: NSManagedObject) -> Bool {
        isShared(objectID: object.objectID)
    }
    
    func canEdit(object: NSManagedObject) -> Bool {
      return persistentContainer.canUpdateRecord(
        forManagedObjectWith: object.objectID
      )
    }
    func canDelete(object: NSManagedObject) -> Bool {
      return persistentContainer.canDeleteRecord(
        forManagedObjectWith: object.objectID
      )
    }
    
    func isOwner(object: NSManagedObject) -> Bool {
      guard isShared(object: object) else { return false }
        
      guard let share = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
        print("Get ckshare error")
        return false
      }
        
        guard let currentUser = share.currentUserParticipant else { return false }
        
        return currentUser.userIdentity.userRecordID == share.owner.userIdentity.userRecordID
        
    }


    
    //get information about the people participating in the share.
    func getShare(_ list: PackingList) -> CKShare? {
      guard isShared(object: list) else { return nil }
      guard let shareDictionary = try? persistentContainer.fetchShares(matching: [list.objectID]),
        let share = shareDictionary[list.objectID] else {
        print("Unable to get CKShare")
        return nil
      }
        share[CKShare.SystemFieldKey.title] = list.title
      return share
    }

    //determine if an object isShared
    
    private func isShared(objectID: NSManagedObjectID) -> Bool {
        var isShared = false
        if let persistentStore = objectID.persistentStore {
            if persistentStore == sharedPersistentStore {
                isShared = true
            } else {
                let container = persistentContainer
                do {
                    let shares = try container.fetchShares(matching: [objectID])
                    if shares.first != nil {
                        isShared = true
                    }
                } catch {
                    print("Failed to fetch share for \(objectID): \(error)")
                }
            }
        }
        return isShared
    }
}


#if DEBUG
extension CoreDataStack {
    @MainActor static var preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)
        let context = stack.context


        do {
            try context.save()
        } catch {
            fatalError("❌ Failed to save preview context: \(error)")
        }

        return stack
    }()
}
#endif
