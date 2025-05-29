//
//  HomeListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/9/25.
//

import SwiftUI
import CoreData

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
    
    func fetchPackingLists() {
        let request: NSFetchRequest<PackingList> = PackingList.fetchRequest()
        
        request.sortDescriptors = selectedSort == "Date"
        ? [NSSortDescriptor(keyPath: \PackingList.startDate, ascending: true)]
        : [NSSortDescriptor(keyPath: \PackingList.title, ascending: true)]

        do {
            self.packingLists = try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    
    private func setupCloudKitObserver() {
        NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event {
                print("CloudKit sync finished: \(event)")
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
            fetchPackingLists()
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
    
