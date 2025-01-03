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
    @State private var isExpanded: Bool = true
    
    @State private var item: String = ""
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    
    var body: some View {
        Section(header: Text(category.name).font(.headline)) {
            
            //Iterate through items in the category
            ForEach(category.items) { item in
                HStack {
                    Button(action: {
                        // Toggle completion state
                        if let index = category.items.firstIndex(where: { $0.id == item.id }) {
                            category.items[index].isPacked.toggle()
                            hapticFeedback.notificationOccurred(.success)
                        }
                    }) {
                        Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isPacked ? .green : .gray)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                    
                    Text(item.title)
                        .foregroundColor(textColor(for: item))
                        .strikethrough(item.isPacked)
                        .italic(item.isPacked)
                }//:HSTACK
            }//:FOREACH
            .onDelete { indexSet in
                deleteItems(in: category, at: indexSet)
            }
            
            // Add new item to the category
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.gray)
                    .font(.title2)
                TextField("Add new item", text: $item)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addItem(to: category)
                    }
            }//:HSTACK
            
        } //:SECTION
        
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
