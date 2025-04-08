//
//  RestockViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import SwiftData

class RestockViewModel: ObservableObject {
    
    private let modelContext: ModelContext
    @Published var restockItems: [RestockItem] = []
    var sortedItems: [RestockItem] {
        restockItems.sorted(by: { $0.position > $1.position })
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func togglePacked(for item: RestockItem) {
        withAnimation {
            item.isPacked.toggle()
            saveContext()
        }
            
    }
    
    @MainActor
    func addNewItem(title: String) {
        withAnimation {
            let newPosition = (restockItems.map(\.position).max() ?? -1) + 1
            let newItem = RestockItem(position: newPosition, title: title, isPacked: false)
            modelContext.insert(newItem)
            saveContext()
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

        saveContext()
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

        saveContext()
        restockItems = mutable
    }
    
    func fetchRestockItems() throws -> [RestockItem] {
        try modelContext.fetch(FetchDescriptor<RestockItem>())
    }
    
    func saveContext() {
        do {
            try modelContext.save()
            print("Packing list and categories saved successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    
}
