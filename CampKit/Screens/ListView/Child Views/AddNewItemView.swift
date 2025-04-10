//
//  AddNewItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI
import SwiftData

struct AddNewItemView: View {
    var viewModel: ListViewModel
    
    @FocusState var isFocused : Bool
    @State private var newItemText: String = ""
    @Bindable var category: Category
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundColor(.gray)
                .font(.system(size: 22))
                .onTapGesture {
                    isFocused = true
                }
            TextField("Add new item", text: $newItemText)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .onSubmit {
                    viewModel.addItem(to: category, itemTitle: newItemText)
                    newItemText = ""
                    isFocused = false
                }
            if isFocused {
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
        .padding(.vertical, 12)
    }
}

#Preview {
    
    let container = PreviewContainer.shared
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample PackingList
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    let sampleCategory = samplePackingList.categories.first!
    
    let sampleViewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    return AddNewItemView(viewModel: sampleViewModel, category: sampleCategory)
        .modelContainer(container)
        .background(Color.customTan)
    
}
