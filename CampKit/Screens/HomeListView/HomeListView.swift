//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct HomeListView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: HomeListViewModel
    @Query(sort: \PackingList.dateCreated, order: .reverse) private var packingLists: [PackingList]
    @StateObject private var storeKitManager = StoreKitManager()
    @State private var isNewListQuizShowing: Bool = false
    @State private var isStepOne: Bool = true
    @State private var location: String = ""
    @State private var isUpgradeToProShowing: Bool = false
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    
    init(modelContext: ModelContext) {
        let viewModel = HomeListViewModel(modelContext: modelContext)
        _viewModel = State(wrappedValue: viewModel)
        
    }
    
    var body: some View {
        NavigationStack {
            
            //MARK: - HEADER
            
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
                        .padding(.bottom)
                    Spacer()
                }//:VSTACK
            }//:ZSTACK
            .frame(height: 80)
            
            //MARK: - PACKING LISTS
            
            ZStack {
                
                List {
                    ForEach(packingLists) { packingList in
                        
                        NavigationLink(
                            destination: ListView(viewModel: ListViewModel(modelContext: modelContext, packingList: packingList)),
                            label: {
                                HStack {
                                    // Optional photo thumbnail
                                    if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(Constants.cornerRadius)
                                            .padding(.trailing, 8)
                                    } else {
                                        Image("TopographyDesign")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(Constants.cornerRadius)
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
                        )//:NAVIGATION LINK
                    } //:FOR EACH
                    .onDelete { indexSet in
                        for index in indexSet {
                            let packingListToDelete = packingLists[index]
                            modelContext.delete(packingListToDelete)
                            
                            do {
                                try modelContext.save() // Save changes
                                print("Packing list deleted successfully.")
                            } catch {
                                print("Failed to delete packing list: \(error)")
                            }
                        }
                    }
                    
                    //MARK: - ADD NEW LIST BUTTON
                    Section {
                        Button {
                            if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < 3 {
                                isNewListQuizShowing = true
                            } else {
                                isUpgradeToProShowing = true
                            }
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
                .sheet(isPresented: $isNewListQuizShowing) {
                    NavigationStack {
                        QuizView(
                            viewModel: QuizViewModel(modelContext: modelContext),
                            isNewListQuizShowing: $isNewListQuizShowing,
                            isStepOne: $isStepOne,
                            navigateToListView: $navigateToListView,
                            currentPackingList: $currentPackingList
                        )
                    }
                }
                .navigationDestination(isPresented: $navigateToListView) {
                    if let packingList = currentPackingList {
                        ListView(viewModel: ListViewModel(modelContext: modelContext, packingList: packingList))
                    } else {
                        Text("No packing list available.")
                    }
                }
                .sheet(isPresented: $isUpgradeToProShowing) {
                    UpgradeToProView(isUpgradeToProShowing: $isUpgradeToProShowing, storeKitManager: storeKitManager)
                }
            }//:ZSTACK
            .navigationTitle("Packing Lists")
            .navigationBarHidden(true)
            .scrollContentBackground(.hidden)
            .background(Color.customTan)
            .offset(y: -10)
            .ignoresSafeArea()
            .overlay {
                if packingLists.isEmpty {
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
    
    return HomeListView(modelContext: container.mainContext)
        .modelContainer(container)
        .environment(\.modelContext, container.mainContext)
}


#Preview("Empty List") {
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return HomeListView(modelContext: container.mainContext)
        .modelContainer(container)
        .environment(\.modelContext, container.mainContext)
}
