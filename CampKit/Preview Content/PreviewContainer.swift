//
//  PreviewContainer.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import Foundation


import SwiftUI
import SwiftData

@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            PackingList.self, Category.self, Item.self, RestockItem.self
        ])
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            preloadPackingListData(context: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
