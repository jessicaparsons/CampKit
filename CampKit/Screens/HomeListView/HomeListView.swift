//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import CoreData

struct HomeListView: View {
    //Live Data
    @FetchRequest(
        entity: CampKit.PackingList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PackingList.position, ascending: true)]) private var packingLists: FetchedResults<PackingList>
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(StoreKitManager.self) private var storeKitManager
    
    @State private var location: String = ""
    @State private var editMode: EditMode = .inactive
    @Binding var isNewListQuizPresented: Bool
    
    init(context: NSManagedObjectContext, isNewListQuizPresented: Binding<Bool>) {
        _isNewListQuizPresented = isNewListQuizPresented
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
                                        context: viewContext,
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
                                                Text(packingList.title ?? Constants.newPackingListTitle)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                Text(packingList.dateCreated, style: .date)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }//:VSTACK
                                        }//:HSTACK
                                    }
                                )//:NAVIGATION LINK
                            } //:FOR EACH
                            .onMove { indices, newOffset in
                                var reorderedLists = packingLists.map { $0 }

                                reorderedLists.move(fromOffsets: indices, toOffset: newOffset)

                                for (index, item) in reorderedLists.enumerated() {
                                    item.position = Int64(index)
                                }

                                save(viewContext)
                            }


                            .onDelete { offsets in
                                for index in offsets {
                                    viewContext.delete(packingLists[index])
                                }
                                save(viewContext)
                            }

                        }
                    }//:LIST
                    .sheet(isPresented: Binding(
                        get: { storeKitManager.isUpgradeToProPresented },
                        set: { storeKitManager.isUpgradeToProPresented = $0 })
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
        
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if editMode == .inactive {
                        // REARRANGE BUTTON
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                        // ADD BUTTON
                        Button {
                            if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < Constants.proVersionListCount {
                                isNewListQuizPresented = true
                            } else {
                                storeKitManager.isUpgradeToProPresented = true
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

#Preview() {
    
    @Previewable @State var isNewListQuizPresented: Bool = false
    @Previewable @State var isUpgradeToProPresented: Bool = false
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    let context = PersistenceController.preview.container.viewContext

    NavigationStack {
        HomeListView(context: context, isNewListQuizPresented: $isNewListQuizPresented)
            .environment(\.managedObjectContext, context)
            .environment(storeKitManager)
    }
}
