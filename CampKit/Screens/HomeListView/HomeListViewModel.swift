//
//  HomeListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/9/25.
//

import SwiftUI
import CoreData


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
        fetchPackingLists()
    }
    
    func fetchPackingLists() {
        let request: NSFetchRequest<PackingList> = PackingList.fetchRequest()
        
        request.sortDescriptors = selectedSort == "Date"
        ? [NSSortDescriptor(keyPath: \PackingList.startDate, ascending: true)]
        : [NSSortDescriptor(keyPath: \PackingList.title, ascending: true)]

        do {
            packingLists = try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
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
            if let index = packingLists.firstIndex(of: packingList) {
                packingLists.remove(at: index) 
            }
            viewContext.delete(packingList)
            reassignAllListPositions()
        }

        save(viewContext)
    }

    func moveItem(from: PackingList, to: PackingList) {
        guard let fromIndex = packingLists.firstIndex(of: from),
              let toIndex = packingLists.firstIndex(of: to),
              fromIndex != toIndex else { return }

        withAnimation {
            let movedItem = packingLists.remove(at: fromIndex)
            packingLists.insert(movedItem, at: toIndex)
            
            reassignAllListPositions()
        }
        
        save(viewContext)
    }

    
    //LOOK UP BY ID
    
    func packingList(for uri: URL) -> PackingList? {
        guard let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else {
            return nil
        }
        return try? viewContext.existingObject(with: objectID) as? PackingList
    }

    
}
    
