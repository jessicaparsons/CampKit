//
//  RemindersViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import SwiftUI
import SwiftData

@Observable
final class RemindersViewModel {
    
    
    private let modelContext: ModelContext
    //var reminderItems: [ReminderItem] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
 
    func fetchReminderItems() async throws -> [ReminderItem] {
        return try modelContext.fetch(FetchDescriptor<ReminderItem>())
    }
}
