//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var packingList: PackingList // Property to accept a PackingList instance
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @State private var item: String = ""
    
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        NavigationSplitView {
            
            //:BANNER IMAGE
            VStack {
                if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                }
                //:DETAIL CARD
                VStack {
                    ListDetailView(packingList: packingList)
                        .offset(y: -20)
                    
                    //:LISTS
                    
                    List {
                        ForEach(packingList.categories) { category in
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
                            
                        }//:FOREACH
                    }//:LIST
                        .overlay {
                            if packingList.categories.isEmpty {
                                ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("Add some items to your list"))
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .secondaryAction) {
                                EditButton()
                            }
                            ToolbarItem {
                                Button(action: addItem) {
                                    Label("Add Item", systemImage: "plus")
                                }
                            }
                        }
                } //:VSTACK
                .background(Color(red: 0.949, green: 0.949, blue: 0.967))
            }//:VSTACK
        } detail: {
            Text("Select an item")
        }
    }//:BODY
    
    private func addItem(to category: Category) {
        withAnimation {
            if !item.isEmpty {
                let newItem = Item(title: item, isPacked: false)
                category.items.append(newItem) // Add item to category
                modelContext.insert(newItem)   // Insert into SwiftData
                item = ""
            }
        }
    }
    
    private func deleteItems(in category: Category, at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(category.items[index])
            }
        }
    }
}

#Preview("Basic Preview") {
    ListView(packingList: PackingList(title: "Sample List"))
}

//#Preview("Sample Data") {
//    
//    let sampleList = PackingList(title: "Sample List")
//    sampleList.categories.append(Category(name: "Category 1"))
//    
//    let container = try! ModelContainer(for: PackingList.self, Category.self, Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//        container.mainContext.insert(sampleList)
//        
//    ListView(packingList: sampleList)
//            .modelContainer(container)
//}

//#Preview("Empty List") {
//    let container = try! ModelContainer(for: PackingList.self, Category.self, Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//        
//        ListView(packingList: PackingList(title: "Empty List"))
//            .modelContainer(container)
//}
