//
//  CategoriesListView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isRearranging: Bool
    
    var body: some View {
            LazyVStack(spacing: 10) {
                if viewModel.packingList.isDeleted {
                    EmptyView()
                        .onAppear {
                            dismiss() // Trigger dismissal as a side effect
                        }
                } else if viewModel.packingList.categories.isEmpty {
                    ContentUnavailableView(
                        "Fresh Start",
                        systemImage: "tent",
                        description: Text("Hit the \"+\" to add a new category and get started")
                    )
                    .padding(.top, Constants.emptyContentSpacing)
                } else {
                    ForEach(viewModel.packingList.categories.sorted(by: { $0.position > $1.position })) { category in
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(Color.customWhite)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            CategorySectionView(
                                viewModel: viewModel,
                                category: category,
                                isRearranging: $isRearranging,
                                deleteCategory: { viewModel.deleteCategory(category) }
                            )
                        }//:ZSTACK

                    }//:LOOP
                }
            }//:LAZY VSTACK
            .offset(y: -30)    }
}

#Preview("Empty") {
    
    @Previewable @State var isRearranging: Bool = false
    
    // Create an in-memory ModelContainer
    let container = PreviewContainer.shared
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample PackingList
    let samplePackingList = PackingList.samplePackingList
    
    // Create a mock ListViewModel
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    // Return the preview
    return ScrollView {
        LazyVStack {
            CategoriesListView(viewModel: viewModel, isRearranging: $isRearranging)
                .modelContainer(container)
        }
    }
}

#Preview {
    @Previewable @State var isRearranging: Bool = false

    // Create an in-memory ModelContainer
    let container = PreviewContainer.shared
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample PackingList
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    // Create a mock ListViewModel
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    // Return the preview
    return ScrollView {
        LazyVStack {
            CategoriesListView(viewModel: viewModel, isRearranging: $isRearranging)
                .modelContainer(container)
        }
    }
}
