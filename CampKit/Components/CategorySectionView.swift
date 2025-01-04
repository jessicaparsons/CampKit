//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

struct CategorySectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var category: Category
    @State private var item: String = ""
    
    @State private var isExpanded: Bool = true
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            
            //Iterate through items in the category
            ForEach(category.items) { item in
                
                EditableItemView(item: item)
                
            }//:FOREACH
            .onDelete { indexSet in
                deleteItems(in: category, at: indexSet)
            }
            
            // Add new item to the category
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.gray)
                    .font(.title3)
                TextField("Add new item", text: $item)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addItem(to: category)
                    }
            }//:HSTACK
            
        } label: {
            HStack {
                TextField("Category Name", text: $category.name)
                    .textFieldStyle(.plain)
                    .font(.headline)
            }
        } //:DISCLOSURE GROUP
        .animation(.easeInOut, value: isExpanded)
        
    }//:BODY

    
    private func addItem(to category: Category) {
        if !item.isEmpty {
            let newItem = Item(title: item, isPacked: false)
            category.items.append(newItem)
            modelContext.insert(newItem)
            item = ""
        }
    }
    
    private func deleteItems(in category: Category, at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(category.items[index])
        }
    }
}

#Preview {
    CategorySectionView(category: Category(name: "Sleeping"))
}
