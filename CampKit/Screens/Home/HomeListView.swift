//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct HomeListView: View {
    private let modelContext: ModelContext
    @StateObject private var viewModel: HomeListViewModel
    @State private var isNewListQuizShowing: Bool = false
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    init(modelContext: ModelContext, viewModel: HomeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.modelContext = modelContext
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
                        .foregroundColor(.black)
                        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 2, x: 1, y: 1)
                        .padding(.bottom)
                    Spacer()
                }//:VSTACK
            }//:ZSTACK
            .frame(height: 80)
            
            
            List {
                ForEach(viewModel.packingLists) { packingList in
                    NavigationLink(destination: {
                        let listViewModel = ListViewModel(packingList: packingList, modelContext: modelContext)
                        ListView(viewModel: listViewModel)
                    }, label: {
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
                    })//:NAVIGATION LINK
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
            .navigationBarTitle("Packing Lists")
            .navigationBarHidden(true)
            .scrollContentBackground(.hidden)
            .background(Color.customTan)
            .offset(y: -10)
            .ignoresSafeArea()
            .overlay {
                if viewModel.packingLists.isEmpty {
                    ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("You haven't created any lists yet. Get started!"))
                }
            }
            

        }//:NAVIGATION STACK
        
        
    }//:BODY

}//:STRUCT


#Preview("Sample Data") {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    preloadPackingListData(context: container.mainContext)
    
    let viewModel = HomeListViewModel(modelContext: container.mainContext)

    return HomeListView(modelContext: container.mainContext, viewModel: viewModel)
        .modelContainer(container)
}


#Preview("Empty List") {
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let viewModel = HomeListViewModel(modelContext: container.mainContext)
    
    // Return the HomeListView and pass the `modelContext`
    return HomeListView(modelContext: container.mainContext, viewModel: viewModel)
        .modelContainer(container) // Attach the mock container for previews
}
