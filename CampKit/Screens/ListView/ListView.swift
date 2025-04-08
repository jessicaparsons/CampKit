//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import ConfettiSwiftUI

struct ListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    @StateObject private var viewModel: ListViewModel
    
    @State private var isPhotoPickerPresented: Bool = false
    @State private var bannerImageItem: PhotosPickerItem?
    @State private var bannerImage: UIImage?
    @State private var isEditing: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var isShowingToggleAllItemsConfirmation: Bool = false
    @State private var fireScale: CGFloat = 0.1
    @State private var isEditingTitle: Bool = false
    @State private var isShowingDuplicationConfirmation: Bool = false
    @State private var isAddNewCategoryShowing: Bool = false
    @State private var newCategoryTitle: String = ""
    
    @State private var scrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 1
    
    let packingListsCount: Int
    
    
    
    //Initialize ListView with its corresponding ViewModel
    init(viewModel: ListViewModel, packingListsCount: Int) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.packingListsCount = packingListsCount
    }
    
    var body: some View {
        if viewModel.packingList.isDeleted {
           EmptyView()
        }
        else {
            Group {
                ZStack(alignment: .center) {
                    ScrollView {
                        VStack {
                            
                            //MARK: - BANNER IMAGE
                            BannerImageView(viewModel: viewModel, bannerImage: $bannerImage)
                                .frame(maxWidth: .infinity) // Ensure full width
                                .listRowInsets(EdgeInsets()) // Remove extra padding
                            
                            //MARK: - LIST DETAILS HEADER
                            VStack {
                                ListDetailCardView(viewModel: viewModel)
                                    .offset(y: -40)
                                
                                
                                //MARK: - LIST CATEGORIES
                                
                                CategoriesListView(viewModel: viewModel)
                                
                            }//:VSTACK
                            .padding(.horizontal)
                        }//:VSTACK
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .frame(height: 0)
                                    .onChange(of: geo.frame(in: .global).minY) {
                                        scrollOffset = geo.frame(in: .global).minY
                                    }
                            }
                        )//NAV BAR UI CHANGES ON SCROLL
                    }//:SCROLLVIEW
                    .background(Color.colorTan)
                    .ignoresSafeArea(edges: .top)
                    
                    //MARK: - CONFETTI ANIMATION
                    VStack {
                        Spacer()
                        if viewModel.isConfettiVisible {
                            Text("🔥")
                                .font(.system(size: 50))
                                .scaleEffect(fireScale)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 2)
                                .opacity(viewModel.isConfettiVisible ? 1 : 0)
                                .onAppear {
                                    fireScale = 0.1
                                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 8)) {
                                        fireScale = 1.0
                                    }
                                }
                                .confettiCannon(
                                    trigger: $viewModel.trigger,
                                    num:1,
                                    confettis: [.text("🔥")],
                                    confettiSize: 8,
                                    rainHeight: 0,
                                    radius: 150,
                                    repetitions: 10,
                                    repetitionInterval: 0.1,
                                    hapticFeedback: true)
                        }//:CONDITION
                        Spacer()
                    }//:VSTACK
                    
                }//:ZSTACK
            }//:GROUP
            .background(Color.colorTan)
            .navigationTitle(viewModel.packingList.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .animation(.easeOut(duration: 0.3), value: viewModel.isShowingSuccessfulDuplication)
            .toolbar {
                //CUSTOM BACK BUTTON
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .dynamicForegroundStyle(trigger: scrollOffset)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    optionsMenu
                }
                // This makes the title invisible until scrolled
                ToolbarItem(placement: .principal) {
                    Text(viewModel.packingList.title)
                        .opacity(scrollOffset < -scrollThreshold ? 1 : 0)
                }
            }
            .onChange(of: bannerImageItem) {
                Task {
                    if let data = try? await bannerImageItem?.loadTransferable(type: Data.self),
                       let loadedImage = UIImage(data: data)
                    {
                        bannerImage = loadedImage
                        viewModel.packingList.photo = data  // Save to SwiftData PackingList Model
                        viewModel.saveContext()
                        
                    } else {
                        print("Failed to load image")
                    }
                }
            }
            .onChange(of: viewModel.trigger) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation {
                        viewModel.isConfettiVisible = false
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }//:CONDITION
    }//:BODY
    
    
    //MARK: - OPTIONS MENU
    
    private var optionsMenu: some View {
        HStack {
            //MARK: - CHECK ALL ITEMS BUTTON
            Button(action: {
                isShowingToggleAllItemsConfirmation = true
            }) {
                Label(
                    viewModel.areAllItemsChecked ? "Check All" : "Uncheck All",
                    systemImage: viewModel.areAllItemsChecked ? "checkmark.circle.fill" : "checkmark.circle"
                )
                .dynamicForegroundStyle(trigger: scrollOffset)
            }
            .confirmationDialog(
                viewModel.areAllItemsChecked ? "Are you sure you want to uncheck all items?" : "Are you sure you want to check all items?",
                isPresented: $isShowingToggleAllItemsConfirmation,
                titleVisibility: .visible
            ) {
                Button(viewModel.areAllItemsChecked ? "Uncheck All" : "Check All") {
                    viewModel.toggleAllItems()
                    isShowingToggleAllItemsConfirmation = false
                }
                
                Button("Cancel", role: .cancel) { }
            }
            //MARK: - MENU BUTTON
            Menu {
                // EDIT TITLE
                Button(action: {
                    isEditingTitle = true
                }) {
                    Label("Edit List Details", systemImage: "pencil")
                }
                
                
                // CHANGE BANNER IMAGE
                Button(action: {
                    isPhotoPickerPresented = true
                }) {
                    Label("Edit Photo", systemImage: "camera")
                }
                
                
                // REARRANGE
                Button(action: {
                    viewModel.isRearranging = true
                }) {
                    Label("Rearrange", systemImage: "arrow.up.arrow.down")
                }
                
                
                // EXPAND ALL
                Button(action: {
                    withAnimation {
                        viewModel.expandAll()
                    }
                }) {
                    Label("Expand All", systemImage: "rectangle.expand.vertical")
                }
                
                // COLLAPSE ALL
                Button(action: {
                    withAnimation {
                        viewModel.collapseAll()
                    }
                }) {
                    Label("Collapse All", systemImage: "rectangle.compress.vertical")
                }
                
                // DUPLICATE LIST
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < Constants.proVersionListCount {
                        isShowingDuplicationConfirmation = true
                    } else {
                        storeKitManager.isUpgradeToProShowing = true
                    }
                    
                } label: {
                    Label("Duplicate List", systemImage: "doc.on.doc")
                }
                
                
                // DELETE LIST
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
                
                
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
            
            //ADD NEW CATEGORY
            Button {
                isAddNewCategoryShowing = true
            } label: {
                Image(systemName: "plus")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
            .alert("Add New Category", isPresented: $isAddNewCategoryShowing) {
                TextField("New category", text: $newCategoryTitle)
                Button("Add", action: {
                    if newCategoryTitle != "" {
                        viewModel.addNewCategory(title: newCategoryTitle)
                        newCategoryTitle = ""
                    }
                    isAddNewCategoryShowing = false
                })
                Button("Cancel", role: .cancel) { }
            }
        }//:HSTACK
        .sheet(isPresented: $isEditingTitle) {
            EditListDetailsModal(packingList: viewModel.packingList)
                .presentationDetents([.medium, .large])
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $bannerImageItem, matching: .images)
        .sheet(isPresented: $viewModel.isRearranging) {
            RearrangeCategoriesView(viewModel: viewModel)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            "Are you sure you want to duplicate the list?",
            isPresented: $isShowingDuplicationConfirmation,
            titleVisibility: .visible
        ) {
            Button("Duplicate") {
                viewModel.duplicateList()
                isShowingDuplicationConfirmation = false
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Duplicate List", isPresented: $viewModel.isShowingSuccessfulDuplication) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your list has been successfully duplicated.")
        }
        .confirmationDialog(
            "Are you sure you want to delete this list?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                    // Step 1: Exit the view
                    dismiss()
                    // Step 2: After a short delay, safely delete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        let listToDelete = viewModel.packingList
                        viewModel.modelContext.delete(listToDelete)
                        viewModel.saveContext()
                    }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

//MARK: - PREVIEWS

#Preview("Sample Data") {
    NavigationStack {
        let storeKitManager = StoreKitManager()
        let container = PreviewContainer.shared
        
        // Populate the container with sample data
        preloadPackingListData(context: container.mainContext)
        
        // Fetch a sample packing list from the container
        let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
        
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
        
        // Return the ListView with the in-memory container
        return ListView(viewModel: viewModel, packingListsCount: 3)
            .modelContainer(container)
            .environment(storeKitManager)
            .environment(\.modelContext, container.mainContext)
        
    }
}

#Preview("Basic Preview") {
    NavigationStack {
        let storeKitManager = StoreKitManager()
        let placeholderPackingList = PackingList(position: 0, title: "Empty Camping List", locationName: "Ojai")
        let container = PreviewContainer.shared
        
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: placeholderPackingList)
        
        ListView(viewModel: viewModel, packingListsCount: 3)
            .modelContainer(container)
            .environment(storeKitManager)
            .environment(\.modelContext, container.mainContext)
        
    }
}
