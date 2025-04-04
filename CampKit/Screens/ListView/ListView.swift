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
        
    @State private var scrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 1
    
    let packingListsCount: Int
    
    //Initialize ListView with its corresponding ViewModel
    init(viewModel: ListViewModel, packingListsCount: Int) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.packingListsCount = packingListsCount
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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
                HStack {
                    Spacer()
                    addCategoryButton
                }//:HSTACK
                .padding()
                
            }//:ZSTACK
            .background(Color.colorTan)
            .navigationTitle(viewModel.packingList.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .animation(.easeOut(duration: 0.3), value: viewModel.isShowingDuplicationConfirmation)
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
            .photosPicker(isPresented: $isPhotoPickerPresented, selection: $bannerImageItem, matching: .images)
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
            .sheet(isPresented: $isEditingTitle) {
                EditListDetailsModal(packingList: viewModel.packingList)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.isRearranging) {
                RearrangeCategoriesView(viewModel: viewModel)
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
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
            .alert(isPresented: $viewModel.isShowingDuplicationConfirmation) {
                Alert(title: Text("Duplicate List"), message: Text("Your list has been successfully duplicated."), dismissButton: .default(Text("OK")))
            }
            .confirmationDialog(
                "Are you sure you want to delete this list?",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteList(dismiss: dismiss) // Perform delete
                }
                Button("Cancel", role: .cancel) { }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }//:NAVIGATION STACK
    }//:BODY
    
    //MARK: - ADD CATEGORY BUTTON
    
    private var addCategoryButton: some View {
        
        Button {
            viewModel.addNewCategory()
        } label: {
            BigButtonLabel(label: "Add Category")
        }
        .buttonStyle(BigButton())
    }
    
    
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
            //MARK: - MENU BUTTON
            Menu {
                // Edit Title
                Button(action: {
                    isEditingTitle.toggle()
                }) {
                    Label("Edit List Details", systemImage: "pencil")
                }
                
                // Change banner image
                Button(action: { isPhotoPickerPresented = true }) {
                    Label("Edit Photo", systemImage: "camera")
                }
                
                // Rearrange option
                Button(action: {
                    viewModel.isRearranging = true
                }) {
                    Label("Rearrange", systemImage: "arrow.up.arrow.down")
                }
                
                // Expand All
                Button(action: {
                    withAnimation {
                        viewModel.expandAll()
                    }
                }) {
                    Label("Expand All", systemImage: "rectangle.expand.vertical")
                }
                
                // Collapse All
                Button(action: {
                    withAnimation {
                        viewModel.collapseAll()
                    }
                }) {
                    Label("Collapse All", systemImage: "rectangle.compress.vertical")
                }
                
                // Duplicate List
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < Constants.proVersionListCount {
                        isShowingDuplicationConfirmation = true
                    } else {
                        storeKitManager.isUpgradeToProShowing = true
                    }
                    
                } label: {
                    Label("Duplicate List", systemImage: "doc.on.doc")
                }
                
                // Delete List
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
                
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
        }
    }
}

//MARK: - PREVIEWS

#Preview("Sample Data") {
    NavigationStack {
        let storeKitManager = StoreKitManager()
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory container
        )
        
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
        let placeholderPackingList = PackingList(title: "Sample Packing List")
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: placeholderPackingList)
        
        ListView(viewModel: viewModel, packingListsCount: 3)
            .modelContainer(container)
            .environment(storeKitManager)
            .environment(\.modelContext, container.mainContext)
        
    }
}
