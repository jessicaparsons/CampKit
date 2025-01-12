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
    @Query private var packingLists: [PackingList] // Fetch all PackingList objects
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @State private var item: String = ""
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.customGold, .customSage, .customSky, .customLilac], startPoint: .bottomLeading, endPoint: .topTrailing)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Spacer()
                    Text("Howdy, Camper!")
                        .font(.title)
                        .fontWeight(.light)
                        .padding(.bottom)
                    Spacer()
                }//:VSTACK
            }//:ZSTACK
            .frame(height: 80)
            
            
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
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .padding(.trailing, 8)
                            } else {
                                Image("TopographyDesign")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                        .padding(.trailing, 8)
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
                
                Section {
                    Button {
                        addNewList()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add New List")
                                .padding(5)
                        }
                    }
                    .buttonStyle(BigButton())
                }//:SECTION
                .listRowBackground(Color.customTan)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }//:LIST
            .scrollContentBackground(.hidden)
            .background(Color.customTan)
            .offset(y: -10)
            .ignoresSafeArea()
            
            
            
            
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
    
    let container = try! ModelContainer(for: PackingList.self, Category.self, Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    // Populate the container with sample data
    preloadPackingListData(context: container.mainContext)
    
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    
    return HomeListView()
        .modelContainer(container)
}

#Preview("Empty List") {
    HomeListView()
        .modelContainer(for: [PackingList.self, Category.self, Item.self], inMemory: true)
}
