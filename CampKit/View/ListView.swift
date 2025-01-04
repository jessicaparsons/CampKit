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
                            CategorySectionView(category: category)
                            
                        }//:FOREACH
                    }//:LIST
                    .scrollContentBackground(.hidden)
                    .background(Color("ColorTan"))
                    .overlay {
                        if packingList.categories.isEmpty {
                            ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("Add some items to your list"))
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


#Preview("Sample Data") {
    
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Populate the container with sample data
    preloadPackingListData(context: container.mainContext)
    
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    // Return the view with the mock ModelContainer
    return ListView(packingList: samplePackingList)
        .modelContainer(container)
}

#Preview("Basic Preview") {
    ListView(packingList: PackingList(title: "Sample List"))
}
