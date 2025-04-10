//
//  ReminderItem.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import Foundation
import SwiftData

@Model
class ReminderItem: Identifiable {
    
    var id: UUID = UUID()
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
