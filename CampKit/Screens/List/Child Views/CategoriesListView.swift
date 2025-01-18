//
//  CategoriesListView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    @EnvironmentObject var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            LazyVStack(spacing: 10) {
                if viewModel.packingList.isDeleted {
                    EmptyView()
                        .onAppear {
                            dismiss() // Trigger dismissal as a side effect
                        }
                } else if viewModel.packingList.categories.isEmpty {
                    ContentUnavailableView(
                        "No Lists Available",
                        systemImage: "plus.circle",
                        description: Text("Add a new list to get started")
                    )
                } else {
                    ForEach(viewModel.packingList.categories.sorted(by: { $0.position < $1.position })) { category in
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customWhite)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            CategorySectionView(
                                category: category,
                                isRearranging: $viewModel.isRearranging,
                                addItem: { itemTitle in viewModel.addItem(to: category, itemTitle: itemTitle) }, // Pass the title and category
                                deleteItem: { item in viewModel.deleteItem(item) }, // Pass the item to delete
                                deleteCategory: { viewModel.deleteCategory(category) }, // Delete the category
                                globalIsExpanded: viewModel.globalIsExpanded,
                                globalExpandCollapseAction: viewModel.globalExpandCollapseAction
                            )
                        }//:ZSTACK

                    }//:LOOP
                }
            }//:LAZY VSTACK
            .offset(y: -30)    }
}

#Preview {
    
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample PackingList
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    // Create a mock ListViewModel
    let viewModel = ListViewModel(packingList: samplePackingList, modelContext: container.mainContext)
    
    // Return the preview
    return CategoriesListView()
        .modelContainer(container) // Provide the ModelContainer
        .environmentObject(viewModel) // Inject the mock ListViewModel
    
}
