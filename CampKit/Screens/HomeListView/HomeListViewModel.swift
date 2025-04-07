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
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    func saveContext() {
        do {
            try modelContext.save()
            print("Context saved successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
}

