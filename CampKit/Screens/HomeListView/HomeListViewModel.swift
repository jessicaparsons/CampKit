//
//  HomeListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/13/25.
//

import SwiftUI
import SwiftData

final class HomeListViewModel: ObservableObject {
    
    private let modelContext: ModelContext
    
    @Published var packingLists: [PackingList] = [] {
        didSet {
            print("Packing lists updated: \(packingLists.map { $0.title })")
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchPackingLists()
    }
    
    func fetchPackingLists() {
        let fetchDescriptor = FetchDescriptor<PackingList>()
        do {
            packingLists = try modelContext.fetch(fetchDescriptor)
            print("Fetched packing lists: \(packingLists.map { $0.title })")
        } catch {
            print("Error fetching packing lists: \(error)")
            packingLists = []
        }
    }
    
    func addNewList() {
        withAnimation {
            let newPackingList = PackingList(title: "New List")
            modelContext.insert(newPackingList)
            saveContext()
            fetchPackingLists()
        }
    }
    
    func deleteLists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(packingLists[index])
                saveContext()
                fetchPackingLists()
            }
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
            print("Context saved successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
