//
//  Preview.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import Foundation
import SwiftData

struct Preview {
    
let modelContainer: ModelContainer
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: PackingList.self, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    func addExamples(_ examples: PackingList) {
        Task {
            @MainActor in
                modelContainer.mainContext.insert(examples)
            }
    }
    
}
