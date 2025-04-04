//
//  RearrangeCategoriesView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//

import SwiftUI
import SwiftData

struct RearrangeCategoriesView: View {
    @ObservedObject var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Rearrange Categories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, -Constants.verticalSpacing)
                List {
                    // Access categories from the ViewModel
                    ForEach(viewModel.packingList.categories.sorted(by: { $0.position < $1.position }), id: \.id) { category in
                        Text(category.name)
                            .font(.headline)
                    }
                    .onMove(perform: moveCategory)
                }//:LIST
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .environment(\.editMode, .constant(.active)) // Enable edit mode for reordering
            }//:VSTACK
            .background(Color.colorTan)
        }//:NAVIGATION STACK
        
    }
    
    private func moveCategory(from source: IndexSet, to destination: Int) {
        withAnimation {
            viewModel.moveCategory(from: source, to: destination) // Use ViewModel's method
        }
    }
}

#Preview {
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Create a mock PackingList and populate it with sample categories
    let samplePackingList = PackingList(title: "Sample Trip")
    let sampleCategories = [
        Category(name: "Clothes", position: 0),
        Category(name: "Food", position: 1),
        Category(name: "Camping Gear", position: 2),
        Category(name: "Electronics", position: 3)
    ]
    samplePackingList.categories.append(contentsOf: sampleCategories)
    container.mainContext.insert(samplePackingList)

    // Create a mock ListViewModel with the PackingList
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)

    // Return the view with the mock ModelContainer and ViewModel
    return NavigationStack {
        RearrangeCategoriesView(viewModel: viewModel)
    }
    .modelContainer(container) // Attach the mock ModelContainer for SwiftData support
}
