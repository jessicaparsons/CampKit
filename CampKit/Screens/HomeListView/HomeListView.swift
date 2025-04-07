//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct HomeListView: View {
    //Live Data
    @Query(sort: \PackingList.position) var fetchedLists: [PackingList]
    // Editable state for drag/delete
    @State private var packingLists: [PackingList] = []
    
    @Environment(\.modelContext) var modelContext
    @Environment(StoreKitManager.self) private var storeKitManager
    @StateObject private var viewModel: HomeListViewModel
    
    @State private var location: String = ""
    @State private var editMode: EditMode = .inactive
    @Binding var isNewListQuizShowing: Bool
    
    init(modelContext: ModelContext, isNewListQuizShowing: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: HomeListViewModel(modelContext: modelContext))
        _isNewListQuizShowing = isNewListQuizShowing
    }
    
    var body: some View {
            //MARK: - HEADER
        ZStack(alignment: .top) {
                
                gradientHeaderView
                
                VStack {
                    //MARK: - PACKING LISTS
                  
                    if packingLists.isEmpty {
                        VStack(spacing: Constants.verticalSpacing) {
                                ContentUnavailableView("Let's Get Packing", systemImage: "tent", description: Text("You haven't created any lists yet. Hit the \"+\" to get started!"))
                                    .padding(.top, Constants.emptyContentSpacing)
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
                            .onMove { source, destination in
                                packingLists.move(fromOffsets: source, toOffset: destination)

                                for (index, list) in packingLists.enumerated() {
                                    list.position = index
                                }

                                viewModel.saveContext()
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    modelContext.delete(packingLists[index])
                                }

                                packingLists.remove(atOffsets: offsets)

                                for (index, list) in packingLists.enumerated() {
                                    list.position = index
                                }

                                viewModel.saveContext()
                            }
                        
                            
                        }//:LIST
                        .sheet(isPresented: Binding(
                            get: { storeKitManager.isUpgradeToProShowing },
                            set: { storeKitManager.isUpgradeToProShowing = $0 })
                        ) {
                            UpgradeToProView()
                        }
                    }//:ELSE
                }//:VSTACK
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.customTan)
                        .ignoresSafeArea(.container, edges: [.bottom])
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: -2)
                )
                .padding(.top, 60)
            }//:ZSTACK
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
            .onAppear {
                packingLists = fetchedLists
            }
            .onChange(of: fetchedLists) {
                packingLists = fetchedLists
            }
        
    }//:BODY
        
    //MARK: - GRADIENT HEADER
        
   private var gradientHeaderView: some View {
       ZStack(alignment: .center) {
            LinearGradient(colors: [.customGold, .customSage, .customSky, .customLilac], startPoint: .topLeading, endPoint: .topTrailing)
                
            HStack{
                Text("Howdy, Camper!")
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                Spacer()
                HStack(spacing: Constants.horizontalPadding) {
                    if editMode == .inactive {
                        // REARRANGE BUTTON
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                            
                        }
                        // ADD BUTTON
                        Button {
                            if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < Constants.proVersionListCount {
                                isNewListQuizShowing = true
                            } else {
                                storeKitManager.isUpgradeToProShowing = true
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Text("Done")
                                .font(.body)
                        }
                    }
                }//:HSTACK
                .foregroundStyle(.black)
                .font(.title3)
            }//:HSTACK
            .padding(.vertical)
            .padding(.horizontal, Constants.horizontalPadding)
        }//:ZSTACK
        .ignoresSafeArea()
        .frame(height: Constants.gradientBannerHeight)
    }
  
    
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
    
    return NavigationStack {
        HomeListView(modelContext: container.mainContext, isNewListQuizShowing: $isNewListQuizShowing)
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
            .environment(storeKitManager)
    }
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
