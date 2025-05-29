//
//  AddNewItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/18/25.
//

import SwiftUI

struct AddNewItemView: View {
    @ObservedObject var viewModel: ListViewModel
    
    @FocusState var isFocused : Bool
    @State private var newItemText: String = ""
    @ObservedObject var category: Category
    @Binding var isPickerFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundColor(.gray)
                .font(.system(size: 22))
                .onTapGesture {
                    isFocused = true
                }
            TextField("", text: $newItemText, prompt: Text("Add new item").foregroundStyle(Color.secondary))
                .focused($isFocused)
                .fontWeight(.light)
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
        .simultaneousGesture(
            TapGesture().onEnded {
                isPickerFocused = false
            }
        )
    }
}
#if DEBUG
#Preview {
    @Previewable @State var isPickerFocused = false
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    
    let categories = Category.sampleCategories(context: previewStack.context)
    
    return AddNewItemView(viewModel: ListViewModel(viewContext: previewStack.context, packingList: list), category: categories.first!, isPickerFocused: $isPickerFocused)
        .background(Color.colorSecondaryGrey)
    
}
#endif
