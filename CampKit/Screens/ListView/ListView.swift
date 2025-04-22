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
import CloudKit
import os

struct ListView: View {
    
    @AppStorage("successEmoji") private var successEmoji: String = "🔥"
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    @StateObject var viewModel: ListViewModel
    
    //CHANGING PHOTO
    @State private var bannerImageItem: PhotosPickerItem?
    @State private var bannerImage: UIImage?
    @State private var isPhotoPickerPresented: Bool = false
    
    //EDITING STATES
    @State private var isEditing: Bool = false
    @State private var isEditingTitle: Bool = false
    @State private var isRearranging: Bool = false
    
    //CONFIRMATIONS
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isToggleAllItemsConfirmationPresented: Bool = false
    @State private var isDuplicationConfirmationPresented: Bool = false
    
    //ADD NEW CATEGORY
    @State private var isAddNewCategoryPresented: Bool = false
    @State private var newCategoryTitle: String = ""
    
    //FIRE ANIMATION
    @State private var trigger: Int = 0
    @State private var isConfettiVisible: Bool = false
    @State private var fireScale: CGFloat = 0.1
    
    //NAVIGATION
    @State private var scrollOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 1
    
    //SHARING OPTIONS
    @State private var isSharingSheetPresented: Bool = false
    @State private var container: CKContainer?
    @State private var share: CKShare?
    @State private var isCloudShareSheetPresented = false
    @State private var sharingController: UICloudSharingController?
    @State private var participants: [CKShare.Participant] = []
    @State private var showParticipantsMenu = false
    
    //PRO
    @State private var isUpgradeToProPresented: Bool = false
    
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
                .refreshable {
                    await refresh(context: viewContext)
                }
                
                
                //MARK: - CONFETTI ANIMATION
                
                if viewModel.isConfettiVisible {
                    ZStack {
                        Text(successEmoji)
                            .font(.system(size: 100))
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
                                confettis: [.text(successEmoji)],
                                confettiSize: 18,
                                rainHeight: 0,
                                radius: 150,
                                repetitions: 10,
                                repetitionInterval: 0.1,
                                hapticFeedback: true)
                    }//:ZSTACK
                    .animation(.easeOut(duration: 0.5), value: isConfettiVisible)
                }//:CONDITION
            }//:ZSTACK
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
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
                viewModel.refresh()
            }
        }//:CONDITION
    }//:BODY
    
    
    //MARK: - OPTIONS MENU
    
    private var optionsMenu: some View {
        HStack {
            //MARK: - LIST IS SHARED OPTIONS
            if share != nil {
                Menu {
                    Section {
                        ForEach(participants, id: \.self) { participant in
                            let name = participant.userIdentity.nameComponents?.formatted() ?? "Unknown"
                            let permission = participant.permission == .readOnly ? "View Only" : "Can Edit"
                            Label(name.isEmpty ? "Unknown" : "\(name) • \(permission)", systemImage: "person.circle")
                        }
                    } header: {
                        Text("Current Participants")
                    }
                    
                    
                    Group {
                        Divider()
                        
                        Button {
                            Task {
                                await prepareCloudSharingSheet()
                            }
                        } label: {
                            Label("Manage Shared List", systemImage: "person.crop.circle.badge.questionmark")
                        }
                    }//:GROUP
                } label: {
                    Label("Shared", systemImage: "person.crop.circle.badge.checkmark")
                        .dynamicForegroundStyle(trigger: scrollOffset)
                    
                }
                .onTapGesture {
                    if let existingShare = share {
                        participants = viewModel.loadParticipants(from: existingShare)
                    }
                }
            }
            
            //MARK: - ADD NEW CATEGORY
            Button {
                isAddNewCategoryPresented = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .dynamicForegroundStyle(trigger: scrollOffset)
            }
            
            //MARK: - MENU BUTTON
            Menu {
                
                //MARK: - CHECK ALL ITEMS BUTTON
                Button(action: {
                    isToggleAllItemsConfirmationPresented = true
                }) {
                    Label(
                        viewModel.areAllItemsChecked ? "Uncheck All" : "Check All",
                        systemImage: viewModel.areAllItemsChecked ? "circle" : "checkmark.circle"
                    )
                }
                Divider()
                
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
                
                Divider()
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
                
                Divider()
                
                
                // INVITE CAMPER
                
                Button {
                    Task {
                        do {
                            let controller = try await sharePackingList(viewModel.packingList.objectID)
                            await MainActor.run {
                                self.sharingController = controller
                                self.isCloudShareSheetPresented = true
                            }
                        } catch {
                            print("Failed to share: \(error)")
                        }
                    }
                } label: {
                    Label("Invite Collaborator", systemImage: "person.crop.circle.badge.plus")
                }
                
                // SHARE LIST
                
                Button {
                    isSharingSheetPresented.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                // DUPLICATE LIST
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < Constants.proVersionListCount {
                        isDuplicationConfirmationPresented = true
                    } else {
                        isUpgradeToProPresented.toggle()
                    }
                    
                } label: {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
                
                
                Divider()
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
        .sheet(isPresented: $isSharingSheetPresented) {
            let text = viewModel.exportAsPlainText(packingList: viewModel.packingList)
            let pdf = viewModel.generatePDF(from: text)
            SharingOptionsSheet(items: [text, pdf])
        }
        .sheet(isPresented: $isCloudShareSheetPresented) {
            if let sharingController = sharingController {
                CloudSharingSheet(controller: sharingController)
            }
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
    
    private func prepareCloudSharingSheet() async {
        guard let existingShare = share else { return }

        do {
            let refreshedShare = try await viewModel.fetchLatestShare(for: existingShare.recordID)

            if let share = refreshedShare {
                self.participants = share.participants
                self.sharingController = UICloudSharingController(share: share, container: CKContainer.default())
                self.isCloudShareSheetPresented = true
            } else {
                print("Could not find updated share")
            }
        } catch {
            print("Error fetching updated share: \(error)")
        }
    }

    
    @MainActor
    func sharePackingList(_ packingListID: NSManagedObjectID) async throws -> UICloudSharingController {
        let controller = UICloudSharingController { sharingController, preparationHandler in
            Task {
                do {
                    let context = PersistenceController.shared.container.viewContext
                    let packingList = context.object(with: packingListID) as! PackingList

                    // ✅ Generate share
                    let (objectIDs, share, container) = try await PersistenceController.shared.container.share([packingList], to: nil)

                    log.info("✅ Shared PackingList with objectIDs: \(objectIDs)")
                    log.info("✅ Share created with ID: \(share.recordID.recordName)")
                    log.info("✅ Share URL: \(String(describing: share.url))")

                    share[CKShare.SystemFieldKey.title] = packingList.title as? CKRecordValue
                    try context.save()

                    // Call the handler to complete setup
                    preparationHandler(share, container, nil)

                } catch {
                    log.info("❌ Share preparation failed: \(error)")
                    preparationHandler(nil, nil, error)
                }
            }
        }

        controller.availablePermissions = [.allowReadWrite, .allowReadOnly, .allowPrivate]
        return controller
    }

}

//MARK: - PREVIEWS
#if DEBUG
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
#endif
