//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import PhotosUI
import ConfettiSwiftUI
import CoreData

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    @StateObject var viewModel: ListViewModel
    
    @State private var isPhotoPickerPresented: Bool = false
    @State private var bannerImageItem: PhotosPickerItem?
    @State private var bannerImage: UIImage?
    @State private var isEditing: Bool = false
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isToggleAllItemsConfirmationPresented: Bool = false
    @State private var fireScale: CGFloat = 0.1
    @State private var isEditingTitle: Bool = false
    @State private var isDuplicationConfirmationPresented: Bool = false
    @State private var isAddNewCategoryPresented: Bool = false
    @State private var newCategoryTitle: String = ""
    @State private var isRearranging: Bool = false
    @State private var trigger: Int = 0
    
    @State private var isConfettiVisible: Bool = false
    
    @State private var scrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 1
    
    let packingListsCount: Int
    
    private var isFormValid: Bool {
        !newCategoryTitle.isEmptyOrWhiteSpace
    }
    
    //Initialize ListView with its corresponding ViewModel
    init(
        context: NSManagedObjectContext,
        packingList: PackingList,
        packingListsCount: Int
    ) {
        _viewModel = StateObject(wrappedValue: ListViewModel(viewContext: context, packingList: packingList))
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
                                
                                CategoriesListView(
                                    viewModel: viewModel,
                                    isRearranging: $isRearranging
                                )
                                
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
                    
                        if viewModel.isConfettiVisible {
                            ZStack {
                                Text("🔥")
                                    .font(.system(size: 50))
                                    .scaleEffect(fireScale)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 2)
                                
                                    .onAppear {
                                        fireScale = 0.1
                                        withAnimation(.interpolatingSpring(stiffness: 200, damping: 8)) {
                                            fireScale = 1.0
                                        }
                                        trigger += 1
                                    }
                                    .confettiCannon(
                                        trigger: $trigger,
                                        num:1,
                                        confettis: [.text("🔥")],
                                        confettiSize: 8,
                                        rainHeight: 0,
                                        radius: 150,
                                        repetitions: 10,
                                        repetitionInterval: 0.1,
                                        hapticFeedback: true)
                            }//:ZSTACK
                            .animation(.easeOut(duration: 0.5), value: isConfettiVisible)
                        }//:CONDITION
                }//:ZSTACK
            }//:GROUP
            .background(Color.colorTan)
            .navigationTitle(viewModel.packingList.title ?? Constants.newPackingListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .animation(.easeOut(duration: 0.3), value: viewModel.isSuccessfulDuplicationPresented)
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
                    Text(viewModel.packingList.title ?? Constants.newPackingListTitle)
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
                        save(viewContext)
                        
                    } else {
                        print("Failed to load image")
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
                isToggleAllItemsConfirmationPresented = true
            }) {
                Label(
                    viewModel.areAllItemsChecked ? "Check All" : "Uncheck All",
                    systemImage: viewModel.areAllItemsChecked ? "checkmark.circle.fill" : "checkmark.circle"
                )
                .dynamicForegroundStyle(trigger: scrollOffset)
            }
            .confirmationDialog(
                viewModel.areAllItemsChecked ? "Are you sure you want to uncheck all items?" : "Are you sure you want to check all items?",
                isPresented: $isToggleAllItemsConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(viewModel.areAllItemsChecked ? "Uncheck All" : "Check All") {
                    viewModel.toggleAllItems()
                    isToggleAllItemsConfirmationPresented = false
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
                    isRearranging = true
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
                        isDuplicationConfirmationPresented = true
                    } else {
                        storeKitManager.isUpgradeToProPresented = true
                    }
                    
                } label: {
                    Label("Duplicate List", systemImage: "doc.on.doc")
                }
                
                
                // DELETE LIST
                Button(role: .destructive) {
                    isDeleteConfirmationPresented = true
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
                
                
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
            
            //ADD NEW CATEGORY
            Button {
                isAddNewCategoryPresented = true
            } label: {
                Image(systemName: "plus")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
            .alert("Add New Category", isPresented: $isAddNewCategoryPresented) {
                TextField("New category", text: $newCategoryTitle)
                Button("Done", action: {
                    if isFormValid {
                        viewModel.addNewCategory(title: newCategoryTitle)
                        newCategoryTitle = ""
                    }
                    isAddNewCategoryPresented = false
                }).disabled(!isFormValid)
                Button("Cancel", role: .cancel) { }
            }
        }//:HSTACK
        .sheet(isPresented: $isEditingTitle) {
            EditListDetailsModal(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $bannerImageItem, matching: .images)
        .sheet(isPresented: $isRearranging) {
            RearrangeCategoriesView(viewModel: viewModel)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            "Are you sure you want to duplicate the list?",
            isPresented: $isDuplicationConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Duplicate") {
                viewModel.duplicateList()
                isDuplicationConfirmationPresented = false
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Duplicate List", isPresented: Binding(
            get: { viewModel.isSuccessfulDuplicationPresented },
            set: { viewModel.isSuccessfulDuplicationPresented = $0 }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your list has been successfully duplicated.")
        }
        .confirmationDialog(
            "Are you sure you want to delete this list?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                // Step 1: Exit the view
                dismiss()
                // Step 2: After a short delay, safely delete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    let listToDelete = viewModel.packingList
                    viewContext.delete(listToDelete)
                    save(viewContext)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

//MARK: - PREVIEWS

#Preview("Sample Data") {
   
        let storeKitManager = StoreKitManager()
        let context = PersistenceController.preview.container.viewContext
        
        let samplePackingList = PackingList.samplePackingList(context: context)
        
    NavigationStack {
        ListView(
            context: context,
            packingList: samplePackingList,
            packingListsCount: 3
        )
        .environment(storeKitManager)
        .environment(\.managedObjectContext, context)
    }
}

#Preview("Basic Preview") {
    let storeKitManager = StoreKitManager()
    let context = PersistenceController.preview.container.viewContext
    
    let emptySamplePackingList = PackingList(context: context, title: "Empty List", position: 0)
    
    NavigationStack {
        ListView(
            context: context,
            packingList: emptySamplePackingList,
            packingListsCount: 3
        )
        .environment(storeKitManager)
        .environment(\.managedObjectContext, context)
        
    }
}
