//
//  AddNewRestockItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/4/25.
//

import SwiftUI

struct AddNewRestockItemView: View {
    
    @Bindable var viewModel: RestockViewModel
    @State private var newItemTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundColor(.gray)
                .font(.system(size: 22))
                .onTapGesture {
                    isFocused = true
                }
            TextField("", text: $newItemTitle, prompt: Text("Add new item").foregroundStyle(Color.secondary))
                .focused($isFocused)
                .textFieldStyle(.plain)
                .fontWeight(.light)
                .onSubmit {
                    viewModel.addNewItem(title: newItemTitle)
                    newItemTitle = ""
                    isFocused = false
                }
            if isFocused {
                Button {
                    viewModel.addNewItem(title: newItemTitle)
                    newItemTitle = ""
                    isFocused = false
                } label: {
                    Text("Done")
                        .foregroundStyle(.primary)
                }
               
            }
            
        }//:HSTACK
        .padding(.horizontal)
        .padding(.top, 12)
    }
}
#if DEBUG
#Preview {
    let previewStack = CoreDataStack.preview
    
    AddNewRestockItemView(viewModel: RestockViewModel(context: previewStack.context))
}
#endif
