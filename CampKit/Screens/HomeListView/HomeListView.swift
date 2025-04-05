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
    @Environment(StoreKitManager.self) private var storeKitManager
    @State private var viewModel: HomeListViewModel
    @Query(sort: \PackingList.dateCreated, order: .reverse) private var packingLists: [PackingList]
    
    @State private var location: String = ""
    
    @Binding var isNewListQuizShowing: Bool
    
    init(modelContext: ModelContext, isNewListQuizShowing: Binding<Bool>) {
        let viewModel = HomeListViewModel(modelContext: modelContext)
        _viewModel = State(wrappedValue: viewModel)
        _isNewListQuizShowing = isNewListQuizShowing
    }
    
    var body: some View {
        NavigationStack {
            
            //MARK: - HEADER
            VStack {
                ZStack(alignment: .bottom) {
                    LinearGradient(colors: [.customGold, .customSage, .customSky, .customLilac], startPoint: .bottomLeading, endPoint: .topTrailing)
                        .ignoresSafeArea()
                    VStack {
                        Text("Howdy, Camper!")
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .padding(.bottom, 30)
                    }//:VSTACK
                }//:ZSTACK
                .frame(height: 150)
                
                //MARK: - PACKING LISTS
                
                if packingLists.isEmpty {
                    VStack(spacing: Constants.verticalSpacing) {
                        LazyVStack {
                            ContentUnavailableView("Empty List", systemImage: "tent", description: Text("You haven't created any lists yet. Get started!"))
                                .padding(.top, Constants.emptyContentSpacing)
                        }//:LAZYVSTACK
                        addNewListButton
                        Spacer()
                    }//:VSTACK
                } else {
                    List {
                        ForEach(packingLists) { packingList in
                            
                            NavigationLink(
                                destination: ListView(
                                    viewModel: ListViewModel(modelContext: modelContext, packingList: packingList),
                                    packingListsCount: packingLists.count
                                ),
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
                                                .lineLimit(1)
                                                .truncationMode(.tail)
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
                        addNewListButton
                    }//:LIST
                    .sheet(isPresented: Binding(
                        get: { storeKitManager.isUpgradeToProShowing },
                        set: { storeKitManager.isUpgradeToProShowing = $0 })
                    ) {
                        UpgradeToProView()
                    }
                }//:ELSE
                
                
                
            }//:VSTACK
            .navigationTitle("Packing Lists")
            .navigationBarHidden(true)
            .scrollContentBackground(.hidden)
            .background(Color.customTan)
            .offset(y: -10)
            .ignoresSafeArea()
        }//:NAVIGATION STACK
    }//:BODY
    
    //MARK: - ADD NEW LIST BUTTON
    
    private var addNewListButton: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < Constants.proVersionListCount {
                        isNewListQuizShowing = true
                    } else {
                        storeKitManager.isUpgradeToProShowing = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add New List")
                            .padding(5)
                    }
                }//:BUTTON
                .buttonStyle(BigButton())
                Spacer()
            }//:HSTACK
        }//:SECTION
        .listRowBackground(Color.customTan)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }//:ADDNEWLISTBUTTON
}//:STRUCT

#Preview("Sample Data") {
    
    @Previewable @State var isNewListQuizShowing: Bool = false
    @Previewable @State var isUpgradeToProShowing: Bool = false
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    preloadPackingListData(context: container.mainContext)
    
    return HomeListView(modelContext: container.mainContext, isNewListQuizShowing: $isNewListQuizShowing)
        .modelContainer(container)
        .environment(\.modelContext, container.mainContext)
        .environment(storeKitManager)
}


#Preview("Empty List") {
    
    @Previewable @State var isNewListQuizShowing: Bool = false
    @Previewable @State var isUpgradeToProShowing: Bool = false
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return HomeListView(modelContext: container.mainContext, isNewListQuizShowing: $isNewListQuizShowing)
        .modelContainer(container)
        .environment(\.modelContext, container.mainContext)
        .environment(storeKitManager)
}
