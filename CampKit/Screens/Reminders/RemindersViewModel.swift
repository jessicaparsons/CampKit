//
//  RemindersViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import SwiftUI
import SwiftData

class RemindersViewModel: ObservableObject {
    
    
    private let modelContext: ModelContext
    //@Published var restockItems: [RestockItem] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}
