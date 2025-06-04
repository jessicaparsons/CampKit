//
//  CoreDataStack.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import CoreData
import CloudKit

final class CoreDataStack: ObservableObject {


//    #if DEBUG
//    let shouldInitializeCloudKitSchema = true
//    #else
//    let shouldInitializeCloudKitSchema = false
//    #endif
    
    @MainActor static let shared = CoreDataStack()
    
    ///Create a CKContainer property using persistent container store description.
    
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
                
        /// Configures the shared database to store records shared with you.
        /// Makes a copy of your privateStoreDescription and update its URL to sharedStoreURL
        
        let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription
            .copy() as? NSPersistentStoreDescription else {
            fatalError(
                "Copying the private store description returned an unexpected value."
            )
        }
        sharedStoreDescription.url = sharedStoreURL
        
        
        /// Creates NSPersistentContainerCloudKitContainerOptions, using the identifier from your private store description.
        
        guard let containerIdentifier = privateStoreDescription
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get containerIdentifier")
        }
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: containerIdentifier
        )
        
        /// Set databaseScope to .shared
        sharedStoreOptions.databaseScope = .shared
        
        /// Set the cloudKitContainerOptions property for the sharedStoreDescription created.
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        
        /// Adds shared NSPersistentStoreDescription to the container.
        
        container.persistentStoreDescriptions.append(sharedStoreDescription)
        
        
        /// Stores a reference to each store when it’s loaded.
        
        
        container.loadPersistentStores { loadedStoreDescription, error in
          if let error = error as NSError? {
            fatalError("Failed to load persistent stores: \(error)")
          } else if let cloudKitContainerOptions = loadedStoreDescription
            .cloudKitContainerOptions {
            guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
              return
            }
        
          /// Checks databaseScope and determines whether it’s private or shared.
          /// Sets the persistent store based on the scope.
              
            if cloudKitContainerOptions.databaseScope == .private {
              let privateStore = container.persistentStoreCoordinator
                .persistentStore(for: loadedStoreDescritionURL)
              self._privatePersistentStore = privateStore
                
            } else if cloudKitContainerOptions.databaseScope == .shared {
              let sharedStore = container.persistentStoreCoordinator
                .persistentStore(for: loadedStoreDescritionURL)
              self._sharedPersistentStore = sharedStore
            }
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
        
        
        for entity in container.managedObjectModel.entities {
            print("Entity loaded: \(entity.name ?? "Unnamed")")
        }
        
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
    
    ///Determine if the destination is already shared and then take the proper action.
    
    func isShared(object: NSManagedObject) -> Bool {
      isShared(objectID: object.objectID)
    }
    
    /// Checks the persistentStore of the NSManagedObjectID that was passed in to see if it’s the sharedPersistentStore.
    /// If it is, then this object is already shared.
    /// Otherwise, use fetchShares(matching:) to see if you have objects matching the objectID in question.
    /// If a match returns, this object is already shared.
    
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


extension CoreDataStack {
    
    
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
        
        print("I am the current user/owner: \(currentUser.userIdentity.userRecordID == share.owner.userIdentity.userRecordID)")
        
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
