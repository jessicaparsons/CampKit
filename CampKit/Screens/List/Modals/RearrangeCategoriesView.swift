//
//  RearrangeCategoriesView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//

import SwiftUI

struct RearrangeCategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var categories: [Category]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories.sorted(by: { $0.position < $1.position }), id: \.id) { category in
                    Text(category.name)
                        .font(.headline)
                }
                .onMove(perform: moveCategory)
            }
            .navigationTitle("Rearrange Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .environment(\.editMode, .constant(.active)) // Enable edit mode for reordering
        }
    }
    
    private func moveCategory(from source: IndexSet, to destination: Int) {
            // Sort categories by position before reordering
            var sortedCategories = categories.sorted(by: { $0.position < $1.position })
            
            // Perform the move operation
            sortedCategories.move(fromOffsets: source, toOffset: destination)
            
            // Update the original categories array to reflect the new order
            for (index, category) in sortedCategories.enumerated() {
                category.position = index
            }
            categories = sortedCategories // Update the binding
            
            // Save the changes to SwiftData
            do {
                try modelContext.save()
                print("Categories reordered successfully.")
            } catch {
                print("Failed to save reordered categories: \(error.localizedDescription)")
            }
        }
}

#Preview {
    // Sample categories for the preview
    @Previewable @State var sampleCategories: [Category] = [
        Category(name: "Clothes", position: 0),
        Category(name: "Food", position: 1),
        Category(name: "Camping Gear", position: 2),
        Category(name: "Electronics", position: 3)
    ]
    
    return NavigationStack {
        RearrangeCategoriesView(categories: $sampleCategories)
    }
}
