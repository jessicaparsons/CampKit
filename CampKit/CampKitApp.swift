//
//  CampKitApp.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

@main
struct CampKitApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self, PackingList.self, Category.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
            preloadDataIfNeeded()
        }

    var body: some Scene {
        WindowGroup {
            HomeListView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func preloadDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<PackingList>()
        
        do {
            let existingLists = try context.fetch(fetchDescriptor)
            if existingLists.isEmpty {
                print("Preloading data...")
                preloadPackingListData(context: context)
            } else {
                print("Data already exists. Skipping preload.")
            }
        } catch {
            print("Error checking existing data: \(error)")
        }
    }
}
