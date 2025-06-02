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
    @Binding var isPickerFocused: Bool
    
    var body: some View {
        LazyVStack(spacing: 10) {
            if viewModel.packingList.isDeleted {
                EmptyView()
                    .onAppear {
                        dismiss() // Trigger dismissal as a side effect
                    }
            } else if viewModel.packingList.sortedCategories.isEmpty {
                EmptyContentView(
                    icon: "tent",
                    description: "You haven't created any categories yet")
            } else {
                ForEach(viewModel.packingList.sortedCategories, id: \.objectID) { category in
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Color.colorWhite)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        CategorySectionView(
                            viewModel: viewModel,
                            category: category,
                            isRearranging: $isRearranging,
                            deleteCategory: { viewModel.deleteCategory(category) },
                            isPickerFocused: $isPickerFocused
                        )
                    }//:ZSTACK
                    
                }//:LOOP
            }
        }//:LAZY VSTACK
        
    }
}
#if DEBUG
#Preview() {
    
    @Previewable @State var isRearranging: Bool = false
    @Previewable @State var isPickerFocused: Bool = false
    
    let context = CoreDataStack.shared.context
    
    let list = PackingList.samplePackingList(context: context)
        
    // Return the preview
    ScrollView {
        LazyVStack {
            CategoriesListView(viewModel: ListViewModel(viewContext: context, packingList: list), isRearranging: $isRearranging,
            isPickerFocused: $isPickerFocused)
        }
    }
}

#endif
