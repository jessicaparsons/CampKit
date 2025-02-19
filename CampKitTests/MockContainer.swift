//
//  MockContainer.swift
//  CampKitTests
//
//  Created by Jessica Parsons on 2/9/25.
//

import Foundation
import SwiftData
@testable import CampKit

@MainActor
let mockContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: PackingList.self, Category.self, Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
