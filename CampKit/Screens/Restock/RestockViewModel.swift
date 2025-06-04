//
//  RestockViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import CoreData

@Observable
@MainActor
final class RestockViewModel {
    
    private let viewContext: NSManagedObjectContext
    var restockItems: [RestockItem] = []
    
    var sortedItems: [RestockItem] {
        restockItems.sorted(by: { $0.position < $1.position })
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func togglePacked(for item: RestockItem) {
        
        item.isPacked.toggle()
        save(viewContext)
        restockItems = restockItems.map { $0 }
            
    }
    
    func addNewItem(title: String) {
        
        guard !title.isEmptyOrWhiteSpace else { return }
        
        withAnimation {
            let newPosition = (restockItems.map(\.positionInt).max() ?? -1) + 1
            let newItem = RestockItem(context: viewContext, title: title, position: newPosition, isPacked: false)
            save(viewContext)
            restockItems = try! fetchRestockItems(using: viewContext)
        }
    }


    
    
    func onMove(source: IndexSet, destination: Int) {
        let sorted = sortedItems
        var mutable = sorted
        mutable.move(fromOffsets: source, toOffset: destination)

        for (i, item) in mutable.enumerated() {
            item.positionInt = mutable.count - i // Highest position = top
        }

        save(viewContext)
        restockItems = mutable
    }

    func deleteItem(_ item: RestockItem) {
        
        viewContext.delete(item)
        
        //Update positions in the main list
        restockItems.removeAll { $0.id == item.id }
        
        for (index, item) in restockItems.enumerated() {
            item.position = Int64(index)
        }
        
        save(viewContext)
    }
    
    func loadItems() async {
        do {
            restockItems = try fetchRestockItems(using: viewContext)
        } catch {
            
        }
    }
    
    
    func fetchRestockItems(using context: NSManagedObjectContext) throws -> [RestockItem] {
        let request = NSFetchRequest<RestockItem>(entityName: "RestockItem")
        request.sortDescriptors = []
        
        return try context.fetch(request)
    }

    
}
