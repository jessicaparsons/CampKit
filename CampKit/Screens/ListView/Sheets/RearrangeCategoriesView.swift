//
//  RearrangeCategoriesView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//

import SwiftUI

struct RearrangeCategoriesView: View {
    @ObservedObject var viewModel: ListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {

                List {
                    // Access categories from the ViewModel
                    ForEach(viewModel.packingList.sortedCategories) { category in
                        Text(category.name)
                            .font(.headline)
                    }
                    .onMove(perform: moveCategory)
                }//:LIST
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .environment(\.editMode, .constant(.active)) // Enable edit mode for reordering
            }//:VSTACK
            .navigationTitle("Rearrange")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.colorWhiteSands)
        }//:NAVIGATION STACK
        
    }
    
    private func moveCategory(from source: IndexSet, to destination: Int) {
        withAnimation {
            viewModel.moveCategory(from: source, to: destination) // Use ViewModel's method
        }
    }
}
#if DEBUG
#Preview {
    
    let previewStack = CoreDataStack.preview
    
    let samplePackingList = PackingList.samplePackingList(context: previewStack.context)
    

    NavigationStack {
        RearrangeCategoriesView(viewModel: ListViewModel(viewContext: previewStack.context, packingList: samplePackingList)
        )
       
    }
    
}
#endif
