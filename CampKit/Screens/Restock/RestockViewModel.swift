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
            let newItem = RestockItem(
                position: restockItems.count,
                title: title,
                isPacked: false)
                modelContext.insert(newItem)
        }
        saveContext()
        do {
            restockItems = try fetchRestockItems()
        } catch {
            print("could not fetch restock items: \(error)")
        }
    }
    
    func onMove(source: IndexSet, destination: Int) {
        restockItems.move(fromOffsets: source, toOffset: destination)

        // Reassign position to match array order (ascending)
        for (index, item) in restockItems.enumerated() {
            item.position = index
        }

        saveContext()
    }

    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let item = restockItems[index]
            modelContext.delete(item)
        }

        restockItems.remove(atOffsets: offsets)

        // Reassign positions in ascending order
        for (index, item) in restockItems.enumerated() {
            item.position = index
        }

        saveContext()
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
