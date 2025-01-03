//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct HomeListView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var packingLists: [PackingList] // Fetch all UserList objects
    
    let packingLists: [PackingList] = [
            PackingList(title: "Sequoia")
        ]
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @State private var item: String = ""
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(packingLists) { packingList in
                    NavigationLink {
                        ListView(packingList: packingList)
                    } label: {
                        HStack {
                            // Optional photo thumbnail
                            if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(packingList.title)
                                    .font(.headline)
                                Text(packingList.dateCreated, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } //:FOR EACH
                .onDelete(perform: deleteItems)
            }//:LIST
            
        }//:NAVIGATION STACK
        .navigationTitle("My Lists")
        .overlay {
            if packingLists.isEmpty {
                ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("You haven't created any lists yet. Get started!"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addNewList()
                } label: {
                    Label("Add List", systemImage: "plus")
                }
            }
        }
    }//:BODY
    
    
    private func addNewList() {
        withAnimation {
            let newPackingList = PackingList(title: "New List")
            // Save to SwiftData
            modelContext.insert(newPackingList)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(packingLists[index])
            }
        }
    }
    
}//:STRUCT



#Preview("Sample Data") {
    
    HomeListView()
    
//    let container = try! ModelContainer(for: [PackingList.self, Category.self, Item.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//    let sampleList = PackingList(title: "Sequoia")
//        container.mainContext.insert(sampleList)
//    
//    return HomeListView()
//        .modelContainer(container)
}

#Preview("Empty List") {
    HomeListView()
        .modelContainer(for: [PackingList.self, Category.self, Item.self], inMemory: true)
}
