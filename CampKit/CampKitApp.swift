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
    
    var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    let storeKitManager = StoreKitManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self, PackingList.self, Category.self, RestockItem.self, ReminderItem.self
        ])
        
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        let modelConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isPreview)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfig])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
            preloadDataIfNeeded()
        }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(weatherViewModel)
                .environment(storeKitManager)
                .modelContainer(sharedModelContainer)
        }
        
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
