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
    @StateObject private var viewModel: HomeListViewModel
    
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: HomeListViewModel(modelContext: modelContext))
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
                ForEach(viewModel.packingLists) { packingList in
                    NavigationLink {
                        let listViewModel = ListViewModel(packingList: packingList, modelContext: modelContext)
                        ListView(viewModel: listViewModel)
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
                .onDelete(perform: viewModel.deleteLists)
                
                Section {
                    Button {
                        viewModel.addNewList()
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
            if viewModel.packingLists.isEmpty {
                ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("You haven't created any lists yet. Get started!"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.addNewList()
                } label: {
                    Label("Add List", systemImage: "plus")
                }
            }
        }
    }//:BODY

}//:STRUCT


#Preview("Sample Data") {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    preloadPackingListData(context: container.mainContext)

    return HomeListView(modelContext: container.mainContext)
        .modelContainer(container)
}


#Preview("Empty List") {
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Return the HomeListView and pass the `modelContext`
    return HomeListView(modelContext: container.mainContext)
        .modelContainer(container) // Attach the mock container for previews
}
