//
//  HomeListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/9/25.
//

import SwiftUI
import CoreData
import CloudKit

@MainActor
class HomeListViewModel: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    private let sortKey = "selectedHomeSort"

    @Published var packingLists: [PackingList] = []
    @Published var draggedItem: PackingList?
    
    var selectedSort: String {
        get {
            UserDefaults.standard.string(forKey: sortKey) ?? "Date"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sortKey)
            fetchPackingLists()
        }
    }

    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        setupCloudKitObserver()
        fetchPackingLists()
    }
    
    ///Sort by title or date, but set nil dates to distant future so they are sorted at the bottom of the list
    func fetchPackingLists() {
        let request: NSFetchRequest<PackingList> = PackingList.fetchRequest()
        request.sortDescriptors = [] //Sort manually

        do {
            var lists = try viewContext.fetch(request)

            if selectedSort == "Date" {
                lists.sort {
                    ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture)
                }
            } else {
                lists.sort {
                    ($0.title ?? "") < ($1.title ?? "")
                }
            }

            self.packingLists = lists
        } catch {
            self.packingLists = []
        }
    }

    
    
    private func setupCloudKitObserver() {
        NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event {
                #if DEBUG
                print("CloudKit sync finished: \(event)")
                #endif
                Task { @MainActor in
                    self.fetchPackingLists() 
                }
            }
        }
    }
    
    func reassignAllListPositions() {
        let lists = packingLists.filter { !$0.isDeleted } // skip deleted objects
        
        for (index, list) in lists.enumerated() {
            list.position = Int64(index)
        }

        save(viewContext)
    }
    
    
    
    func delete(_ packingList: PackingList) {
        withAnimation {
            viewContext.delete(packingList)
            save(viewContext)
            
            // Delete associated CKShare if exists
                Task {
                    await deleteCKShareIfNeeded(for: packingList)
                }
            
            fetchPackingLists()
        }
    }
    
    func deleteCKShareIfNeeded(for list: PackingList) async {
        guard CoreDataStack.shared.isOwner(object: list),
              let share = CoreDataStack.shared.getShare(list) else {
            return
        }

        let container = CKContainer.default()
        let database = container.privateCloudDatabase

        do {
            let (_, deleted) = try await database.modifyRecords(saving: [], deleting: [share.recordID])
            
            #if DEBUG
            print("CKShare deleted: \(deleted)")
            #endif
            
        } catch {
            
            #if DEBUG
            print("Failed to delete CKShare: \(error)")
            #endif
        }
    }

    
    //LOOK UP BY ID
    
    func packingList(for uri: URL) -> PackingList? {
        guard let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else {
            return nil
        }
        return try? viewContext.existingObject(with: objectID) as? PackingList
    }

    
}
    
