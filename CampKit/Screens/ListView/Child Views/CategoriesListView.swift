//
//  CategoriesListView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI

struct CategoriesListView: View {
    @ObservedObject var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isRearranging: Bool
    
    var body: some View {
            LazyVStack(spacing: 10) {
                if viewModel.packingList.isDeleted {
                    EmptyView()
                        .onAppear {
                            dismiss() // Trigger dismissal as a side effect
                        }
                } else if viewModel.packingList.sortedCategories.isEmpty {
                    ContentUnavailableView(
                        "Fresh Start",
                        systemImage: "tent",
                        description: Text("Hit the \"+\" to add a new category and get started")
                    )
                    .padding(.top, Constants.emptyContentSpacing)
                } else {
                    ForEach(viewModel.packingList.sortedCategories, id: \.objectID) { category in
                        
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
#if DEBUG
#Preview() {
    
    @Previewable @State var isRearranging: Bool = false
    
    let context = PersistenceController.preview.container.viewContext
    
    let samplePackingList = PackingList.samplePackingList(context: context)
        
    // Return the preview
    ScrollView {
        LazyVStack {
            CategoriesListView(viewModel: ListViewModel(viewContext: context, packingList: samplePackingList), isRearranging: $isRearranging)
        }
    }
}

#endif
