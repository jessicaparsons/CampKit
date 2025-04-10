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
    
    @State private var location: String = ""
    @State private var editMode: EditMode = .inactive
    @Binding var isNewListQuizShowing: Bool
    
    init(modelContext: ModelContext, isNewListQuizShowing: Binding<Bool>) {
        _isNewListQuizShowing = isNewListQuizShowing
    }
    
    var body: some View {
        //MARK: - HEADER
        ZStack(alignment: .top) {
            
            
            //MARK: - BACKGROUND STYLES
            GradientTanBackgroundView()
            
            
            VStack {
                //MARK: - PACKING LISTS
                
                if packingLists.isEmpty {
                    ScrollView {
                        ContentUnavailableView("Let's Get Packing", systemImage: "tent", description: Text("""
You haven't created any lists yet. 
Hit the \"+\" to get started!
"""))
                        .padding(.top, Constants.emptyContentSpacing)
                    }
                } else {
                    
                    List {
                        Section(header:
                                    Color.clear
                            .frame(height: 1)//For top spacing
                        ) {
                            ForEach(packingLists) { packingList in
                                
                                NavigationLink(
                                    destination: ListView(
                                        modelContext: modelContext,
                                        packingList: packingList,
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
                                
                                save(modelContext)
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    modelContext.delete(packingLists[index])
                                }
                                
                                packingLists.remove(atOffsets: offsets)
                                
                                for (index, list) in packingLists.enumerated() {
                                    list.position = index
                                }
                                
                                save(modelContext)
                            }
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
        }//:ZSTACK
        .navigationTitle("Howdy, Camper")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
        .onAppear {
            packingLists = fetchedLists
        }
        .onChange(of: fetchedLists) {
            packingLists = fetchedLists
        }
        
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if editMode == .inactive {
                        // REARRANGE BUTTON
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.body)
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
                        }
                    }
                }//:HSTACK
                .foregroundStyle(Color.primary)
            }//:TOOL BAR ITEM
        }//:TOOLBAR
        
    }//:BODY
    
    
}//:STRUCT

#Preview("Sample Data") {
    
    @Previewable @State var isNewListQuizShowing: Bool = false
    @Previewable @State var isUpgradeToProShowing: Bool = false
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    let container = PreviewContainer.shared
    
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
    
    let container = PreviewContainer.shared
    
    return NavigationStack {
        HomeListView(modelContext: container.mainContext, isNewListQuizShowing: $isNewListQuizShowing)
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
            .environment(storeKitManager)
    }
}
