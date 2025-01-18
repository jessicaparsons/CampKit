//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ListViewModel
    
    //Initialize ListView with its corresponding ViewModel
    init(viewModel: ListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
   
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: true) {
                VStack {
                    bannerImage
                        .onTapGesture { viewModel.showPhotoPicker.toggle() }
                    
                    VStack {
                        ListDetailCardView(
                            packingList: viewModel.packingList,
                            isEditingTitle: $viewModel.isEditingTitle
                        )
                        .offset(y: -40)
                        
                        categoriesList
                        addCategoryButton
                    }
                    .padding()
                    .background(Color.colorTan)

                }//:VSTACK
            }//:SCROLL VIEW
            .background(Color.colorTan)
            .environmentObject(viewModel)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    optionsMenu
                }
            }
            .sheet(isPresented: $viewModel.isRearranging) {
                RearrangeCategoriesView()
                    .environmentObject(viewModel)
            }
            .confirmationDialog(
                "Are you sure you want to delete this list?",
                isPresented: $viewModel.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteList(dismiss: dismiss) // Perform delete
                }
                Button("Cancel", role: .cancel) { }
            }
            
        }//:NAVIGATION STACK
        
        
        
    }//:BODY
    
    
    //MARK: - BANNER IMAGE
    
    
    private var bannerImage: some View {
        ZStack {
            if let photoData = viewModel.packingList.photo,
               let bannerImage = UIImage(data: photoData) {
                Image(uiImage: bannerImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.title3)
                            .foregroundColor(.white)
                    )
            } else {
                Image("TopographyDesign")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.title3)
                            .foregroundColor(.white)
                    )
            }
        }//:ZSTACK
        .background(Color.red)
        .ignoresSafeArea()
        
    }
    
    //MARK: - CATEGORIES LIST
    
    private var categoriesList: some View {
        LazyVStack(spacing: 10) {
            if viewModel.packingList.isDeleted {
                EmptyView()
                    .onAppear {
                        dismiss() // Trigger dismissal as a side effect
                    }
            } else if viewModel.packingList.categories.isEmpty {
                ContentUnavailableView(
                    "No Lists Available",
                    systemImage: "plus.circle",
                    description: Text("Add a new list to get started")
                )
            } else {
                ForEach(viewModel.packingList.categories.sorted(by: { $0.position < $1.position })) { category in
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.customWhite)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        CategorySectionView(
                            category: category,
                            isRearranging: $viewModel.isRearranging,
                            addItem: { itemTitle in viewModel.addItem(to: category, itemTitle: itemTitle) }, // Pass the title and category
                            deleteItem: { item in viewModel.deleteItem(item) }, // Pass the item to delete
                            deleteCategory: { viewModel.deleteCategory(category) }, // Delete the category
                            globalIsExpanded: viewModel.globalIsExpanded,
                            globalExpandCollapseAction: viewModel.globalExpandCollapseAction
                        )
                        
                    }//:ZSTACK
                    
                }
            }
        }//:LAZY VSTACK
        .offset(y: -30)
    }
    
    //MARK: - ADD CATEGORY BUTTON
    
    private var addCategoryButton: some View {
        HStack {
            Button { viewModel.addNewCategory()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("New Category")
                        .padding(5)//mine
                }
            }
            .buttonStyle(BigButton())
            Spacer()
        }
        .padding(.horizontal)//mine
        .offset(y: -20)//mine
    }
    
    //MARK: - OPTIONS MENU
    
    private var optionsMenu: some View {
       
        HStack {
            Button(action: {
                viewModel.toggleAllItems()
            }) {
                Label(
                    viewModel.areAllItemsChecked ? "Check All" : "Uncheck All",
                    systemImage: viewModel.areAllItemsChecked ? "checkmark.circle.fill" : "checkmark.circle")
            }
            Menu {
                // Edit Title
                Button(action: {
                    viewModel.isEditingTitle.toggle()
                }) {
                    Label("Edit List Details", systemImage: "pencil")
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
                
                // Delete List
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
                
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
            }
        }
        .tint(.white)
    }
}

#Preview("Sample Data") {
    NavigationStack {
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory container
        )

        // Populate the container with sample data
        preloadPackingListData(context: container.mainContext)

        // Fetch a sample packing list from the container
        let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!

        // Create the ListViewModel
        let viewModel = ListViewModel(packingList: samplePackingList, modelContext: container.mainContext)

        // Return the ListView with the in-memory container
        return ListView(viewModel: viewModel)
            .modelContainer(container) // Attach the model container for SwiftData
    }
}

#Preview("Basic Preview") {
    NavigationStack {
        let placeholderPackingList = PackingList(title: "Sample Packing List")
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = ListViewModel(packingList: placeholderPackingList, modelContext: container.mainContext)

        ListView(viewModel: viewModel)
            .modelContainer(container)
    }
}
