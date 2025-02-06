//
//  AddNewItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI
import SwiftData

struct AddNewItemView: View {
    @ObservedObject var viewModel: ListViewModel
    
    @FocusState var isFocused : Bool
    @State private var newItemText: String = ""
    @Bindable var category: Category
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundColor(.gray)
                .font(.title3)
            TextField("Add new item", text: $newItemText)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .onSubmit {
                    viewModel.addItem(to: category, itemTitle: newItemText)
                    newItemText = ""
                    isFocused = false
                }
            if !newItemText.isEmpty {
                Button {
                    viewModel.addItem(to: category, itemTitle: newItemText)
                    newItemText = ""
                    isFocused = false
                } label: {
                    Text("Done")
                }
            }
            
        }//:HSTACK
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample PackingList
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    let sampleCategory = samplePackingList.categories.first!
    
    let sampleViewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    // Return the preview
    return AddNewItemView(viewModel: sampleViewModel, category: sampleCategory)
        .modelContainer(container)
    
}
