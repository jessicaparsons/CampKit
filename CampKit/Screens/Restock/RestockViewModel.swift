//
//  RestockViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import SwiftData

@Observable
@MainActor
final class RestockViewModel {
    
    private let modelContext: ModelContext
    var restockItems: [RestockItem] = []
    
    var sortedItems: [RestockItem] {
        restockItems.sorted(by: { $0.position > $1.position })
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func togglePacked(for item: RestockItem) {
        
        item.isPacked.toggle()
        save(modelContext)
        restockItems = restockItems.map { $0 }
            
    }
    
    func addNewItem(title: String) {
        withAnimation {
            let newPosition = (restockItems.map(\.position).max() ?? -1) + 1
            let newItem = RestockItem(position: newPosition, title: title, isPacked: false)
            modelContext.insert(newItem)
            save(modelContext)
            restockItems = try! fetchRestockItems()
        }
    }
    
    func onMove(source: IndexSet, destination: Int) {
        let sorted = sortedItems
        var mutable = sorted
        mutable.move(fromOffsets: source, toOffset: destination)

        for (i, item) in mutable.enumerated() {
            item.position = mutable.count - i // Highest position = top
        }

        save(modelContext)
        restockItems = mutable
    }

    func deleteItem(at offsets: IndexSet) {
        let sorted = sortedItems
        var mutable = sorted

        for index in offsets {
            let item = mutable[index]
            modelContext.delete(item)
        }

        mutable.remove(atOffsets: offsets)

        for (index, item) in mutable.enumerated() {
            item.position = mutable.count - index
        }

        save(modelContext)
        restockItems = mutable
    }
    
    func loadItems() async {
        do {
            restockItems = try fetchRestockItems()
        } catch {
            print("Failed to fetch restock items: \(error)")
            
        }
    }
    
    
    func fetchRestockItems() throws -> [RestockItem] {
        try modelContext.fetch(FetchDescriptor<RestockItem>())
    }

    
    
}
