//
//  Preview.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import Foundation
import SwiftData
import SwiftUI

struct Preview: PreviewModifier {
    
    static func makeSharedContext() async throws -> Context {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PackingList.self, Category.self, configurations: config)
        
        
        for category in Category.sampleCategories {
            container.mainContext.insert(category)
            
        }
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

//extension PreviewTrait where T == Preview.ViewTraits {
//    @MainActor static var sampleData: Self = .modifier(SampleDataReminders())
//}
