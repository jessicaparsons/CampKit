//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import PhotosUI
internal import ConfettiSwiftUI
import CoreData
import os


struct ListView: View {
    
    @AppStorage("successEmoji") private var successEmoji: String = "🔥"
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject var viewModel: ListViewModel
    @ObservedObject var homeViewModel: HomeListViewModel
    
    //CHANGING PHOTO
    @State private var bannerImageItem: PhotosPickerItem?
    @State private var bannerImage: UIImage?
    @State private var isPhotoPickerPresented: Bool = false
    @State private var isGalleryPhotoPickerPresented: Bool = false
    
    //EDITING STATES
    @State private var isEditing: Bool = false
    @State private var isRearranging: Bool = false
    @State private var isPickerFocused: Bool = false
    
    //CONFIRMATIONS
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isToggleAllItemsConfirmationPresented: Bool = false
    @State private var isDuplicationConfirmationPresented: Bool = false
    
    //ADD NEW CATEGORY
    @State private var isAddNewCategoryPresented: Bool = false
    @State private var isAddNewPresetCategoryPresented: Bool = false
    @State private var newCategoryTitle: String = ""
    
    //FIRE ANIMATION
    @State private var trigger: Int = 0
    @State private var isConfettiVisible: Bool = false
    @State private var fireScale: CGFloat = 0.1
    @State private var confettiOpacity: Double = 1.0
    
    //NAVIGATION
    @State private var scrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 1
    @State private var isMenuOpen = false
    
    //SHARING OPTIONS
    @State private var isSharingSheetPresented: Bool = false
    
    //PRO
    @State private var isUpgradeToProPresented: Bool = false
    
    //LAYOUT
    @State private var scrollPosition: CGFloat = 0
    @State private var statusBarStyle: UIStatusBarStyle = .lightContent
    
    let packingListsCount: Int
    
    private var isFormValid: Bool {
        !newCategoryTitle.isEmptyOrWhiteSpace
    }
    
    init(
        context: NSManagedObjectContext,
        packingList: PackingList,
        packingListsCount: Int
    ) {
        _viewModel = StateObject(wrappedValue: ListViewModel(viewContext: context, packingList: packingList))
        _homeViewModel = .init(wrappedValue: .init(viewContext: context))
        self.packingListsCount = packingListsCount
        
    }
    
    var body: some View {
        if viewModel.packingList.isDeleted {
            EmptyView()
        }
        else {
            ZStack(alignment: .center) {
                //MARK: - BANNER IMAGE
                VStack {
                    BannerImageView(viewModel: viewModel)
                        .frame(maxWidth: .infinity) // Ensure full width
                        .listRowInsets(EdgeInsets()) // Remove extra padding
                        .onTapGesture {
                            isPickerFocused = false
                        }
                    Spacer()
                    
                }//:VSTACK
                .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    
                        //MARK: - LIST DETAILS HEADER
                        VStack {
                            
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        scrollOffset = geo.frame(in: .named("scroll")).minY
                                    }
                                    .onChange(of: geo.frame(in: .named("scroll")).minY) {
                                        scrollOffset = geo.frame(in: .named("scroll")).minY
                                    }
                                    .frame(height: 0) // Keeps layout unaffected
                            }
                            
                            ListDetailCardView(viewModel: viewModel)
                                .padding(.top, 68)
                                .onTapGesture {
                                    isPickerFocused = false
                                }
                            
                            //MARK: - LIST CATEGORIES
                            
                            CategoriesListView(
                                viewModel: viewModel,
                                isRearranging: $isRearranging,
                                isPickerFocused: $isPickerFocused
                            )
                            .padding(.bottom, Constants.bodyPadding)
                            
                        }//:VSTACK
                        .padding(.horizontal, sizeClass == .regular ? Constants.ipadPadding : Constants.defaultPadding)
                }//:SCROLLVIEW
                .coordinateSpace(name: "scroll")
                .scrollIndicators(.hidden)
                
                //MARK: - FLOATING MENU
                
                FloatingMenuView(
                    isMenuOpen: $isMenuOpen,
                    buttonOneImage: "square.and.pencil",
                    buttonOneLabel: "Blank Category",
                    buttonOneAction: {
                        isAddNewCategoryPresented = true
                        isMenuOpen = false
                    },
                    buttonTwoImage: "sparkles.square.filled.on.square",
                    buttonTwoLabel: "Preset Category",
                    buttonTwoAction: {
                        isAddNewPresetCategoryPresented = true
                        isMenuOpen = false
                    }
                )
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isPickerFocused = false
                    }
                )
                .ignoresSafeArea(.keyboard)
                
                //MARK: - CONFETTI ANIMATION
                
                if viewModel.isConfettiVisible {
                    ZStack {
                        Text(successEmoji)
                            .font(.system(size: 100))
                            .scaleEffect(fireScale)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 2)
                            .onAppear {
                                fireScale = 0.1
                                confettiOpacity = 1.0
                                withAnimation(.interpolatingSpring(stiffness: 200, damping: 8)) {
                                    fireScale = 1.0
                                }
                                trigger += 1
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        confettiOpacity = 0
                                    }
                                }
                            }
                            .confettiCannon(
                                trigger: $trigger,
                                num:1,
                                confettis: [.text(successEmoji)],
                                confettiSize: 18,
                                rainHeight: 0,
                                radius: 150,
                                repetitions: 10,
                                repetitionInterval: 0.1,
                                hapticFeedback: true)
                    }//:ZSTACK
                    .opacity(confettiOpacity)
                }//:CONDITION
                
            }//:ZSTACK
            .background(Color.colorWhiteSands)
            .navigationTitle(viewModel.packingList.title ?? Constants.newPackingListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .animation(.easeOut(duration: 0.3), value: viewModel.isSuccessfulDuplicationPresented)
            .photosPicker(isPresented: $isGalleryPhotoPickerPresented, selection: $bannerImageItem, matching: .images)
            .toolbar {
                //CUSTOM BACK BUTTON
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .accessibilityLabel("Back")
                            Text("Back")
                        }
                        .dynamicForegroundStyle(trigger: scrollOffset)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    optionsMenu
                }
                
                // This makes the title invisible until scrolled
                ToolbarItem(placement: .principal) {
                    Text(viewModel.packingList.title ?? Constants.newPackingListTitle)
                        .opacity(scrollOffset < -scrollThreshold ? 1 : 0)
                }
            }
            .onChange(of: bannerImageItem) {
                Task { @MainActor in
                    if let data = try? await bannerImageItem?.loadTransferable(type: Data.self),
                       let loadedImage = UIImage(data: data)
                    {
                        bannerImage = loadedImage
                        viewModel.updatePhoto(with: loadedImage)
                        
                    } else {
                        
                    }
                }
            }
            
            
        }//:CONDITION
    }//:BODY
    
    
    //MARK: - OPTIONS MENU
    
    private var optionsMenu: some View {
        HStack {
            
            //MARK: - CHANGE BANNER PHOTO
            Button(action: {
                isPhotoPickerPresented = true
            }) {
                Label("Edit Photo", systemImage: "photo")
            }
            .dynamicForegroundStyle(trigger: scrollOffset)
            .accessibilityHint("Edit the photo used as the background")
            .sheet(isPresented: $isPhotoPickerPresented) {
                NavigationStack {
                    BackgroundPickerView { image in
                        bannerImage = image
                        viewModel.updatePhoto(with: image)
                        isPhotoPickerPresented.toggle()
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                isPhotoPickerPresented.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .tint(Color.primary)
                                    .accessibilityLabel("Exit")
                            }
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button {
                                isGalleryPhotoPickerPresented = true
                            } label: {
                                Image(systemName: "camera")
                                .foregroundStyle(Color.primary)
                                .accessibilityLabel("Open phone gallery")
                            }
                            
                        }
                    }
                }
                
            }
            
            
            //MARK: - MENU BUTTON
            Menu {
                
                //MARK: - CHECK ALL ITEMS BUTTON
                Button(action: {
                    isToggleAllItemsConfirmationPresented = true
                }) {
                    Label(
                        viewModel.allItemsAreChecked ? "Uncheck All" : "Check All",
                        systemImage: viewModel.allItemsAreChecked ? "circle" : "checkmark.circle"
                    )
                }
                .accessibilityHint("Check or uncheck all items")
                
                Divider()
                // REARRANGE
                Button(action: {
                    isRearranging = true
                }) {
                    Label("Reorder Categories", systemImage: "text.line.magnify")
                }
                .accessibilityHint("Reorder the categories in the list")
                
                
                // EXPAND ALL
                Button(action: {
                    viewModel.expandAll()
                }) {
                    Label("Expand All", systemImage: "rectangle.expand.vertical")
                }
                .accessibilityHint("Expand all categories")
                
                // COLLAPSE ALL
                Button(action: {
                    viewModel.collapseAll()
                }) {
                    Label("Collapse All", systemImage: "rectangle.compress.vertical")
                }
                .accessibilityHint("Collapse all categories")
                
                Divider()
                
                // SHARE LIST
                
                Button {
                    isSharingSheetPresented.toggle()
                } label: {
                    Label("Share/Export", systemImage: "square.and.arrow.up")
                }
                .accessibilityHint("Share or export your list")
                
                // DUPLICATE LIST
                Button {
                    if storeKitManager.isProUnlocked || packingListsCount < Constants.proVersionListCount {
                        isDuplicationConfirmationPresented = true
                    } else {
                        isUpgradeToProPresented.toggle()
                    }
                } label: {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
                .accessibilityHint("Duplicate your list")
                
                Divider()
                // DELETE LIST
                Button(role: .destructive) {
                    isDeleteConfirmationPresented = true
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
                .accessibilityHint("Delete your list")
                
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .dynamicForegroundStyle(trigger: scrollOffset)
                    .accessibilityLabel("Menu")
            }
            .confirmationDialog(
                viewModel.allItemsAreChecked ? "Are you sure you want to uncheck all items?" : "Are you sure you want to check all items?",
                isPresented: $isToggleAllItemsConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(viewModel.allItemsAreChecked ? "Uncheck All" : "Check All") {
                    viewModel.toggleAllItems()
                    isToggleAllItemsConfirmationPresented = false
                }
                .accessibilityHint("Check or uncheck all items")
                
                Button("Cancel", role: .cancel) { }
                    .accessibilityHint("Cancel")
            }
            
        }//:HSTACK
        .sheet(isPresented: $isRearranging) {
            RearrangeListView(
                items: viewModel.packingList.sortedCategories,
                label: { $0.name },
                moveAction: { source, destination in
                    viewModel.moveCategory(from: source, to: destination)
                }
            )
        }
        .alert("Add New Category", isPresented: $isAddNewCategoryPresented) {
            TextField("New category", text: $newCategoryTitle)
            Button("Done", action: {
                if isFormValid {
                    viewModel.addNewCategory(title: newCategoryTitle)
                    newCategoryTitle = ""
                }
                isAddNewCategoryPresented = false
            })
            .disabled(!isFormValid)
            .accessibilityHint("Done adding new category")
            
            Button("Cancel", role: .cancel) { }
                .accessibilityHint("Cancel")
        }
        //MARK: - SHARE SHEET
        .sheet(isPresented: $isSharingSheetPresented) {
            let text = viewModel.exportAsPlainText(packingList: viewModel.packingList)
            let pdf = viewModel.generatePDF(from: text)
            SharingOptionsSheet(items: [text, pdf])
        }
        
        //MARK: - ADD NEW PRESET CATEGORY
        .sheet(isPresented: $isAddNewPresetCategoryPresented) {
            AddNewCategoriesView(viewModel: viewModel)
        }
        .confirmationDialog(
            "Are you sure you want to duplicate the list?",
            isPresented: $isDuplicationConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Duplicate") {
                viewModel.duplicateList()
                HapticsManager.shared.triggerSuccess()
                isDuplicationConfirmationPresented = false
            }
            .accessibilityHint("Duplicate the list")
            
            Button("Cancel", role: .cancel) { }
                .accessibilityHint("Cancel")
        }
        .alert("Duplicate List", isPresented: Binding(
            get: { viewModel.isSuccessfulDuplicationPresented },
            set: { viewModel.isSuccessfulDuplicationPresented = $0 }
        )) {
            Button("OK", role: .cancel) { }
                .accessibilityHint("Close")
        } message: {
            Text("Your list has been successfully duplicated.")
        }
        .confirmationDialog(
            "Are you sure you want to delete this list?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                homeViewModel.delete(viewModel.packingList)
                dismiss()
                HapticsManager.shared.triggerSuccess()
                
            }
            .accessibilityHint("Delete the list")
            Button("Cancel", role: .cancel) { }
                .accessibilityHint("Cancel")
        }
        .sheet(isPresented: $isUpgradeToProPresented) {
            UpgradeToProView()
        }
    }//:OPTIONS MENU
    
    
}


//MARK: - PREVIEWS
#if DEBUG
#Preview("Sample Data") {
    
    let storeKitManager = StoreKitManager()
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    
    NavigationStack {
        ListView(
            context: previewStack.context,
            packingList: list,
            packingListsCount: 3
        )
        .environment(storeKitManager)
        .environment(\.managedObjectContext, previewStack.context)
    }
}
#Preview("Basic Preview") {
    let storeKitManager = StoreKitManager()
    let previewStack = CoreDataStack.preview
    
    let list = PackingList(context: previewStack.context, position: 1)
    
    NavigationStack {
        ListView(
            context: previewStack.context,
            packingList: list,
            packingListsCount: 3
        )
        .environment(storeKitManager)
        .environment(\.managedObjectContext, previewStack.context)
        
    }
}
#endif
