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
            ScrollView {
                VStack {
                    
                    //MARK: - BANNER IMAGE
                    BannerImageView(viewModel: viewModel)
                        .frame(maxWidth: .infinity) // Ensure full width
                        .listRowInsets(EdgeInsets()) // Remove extra padding
                        .background(Color.blue)
                        .onTapGesture { viewModel.showPhotoPicker.toggle() }
                    
                    //MARK: - LIST DETAILS HEADER
                    VStack {
                        ListDetailCardView(
                            viewModel: viewModel, isEditingTitle: $viewModel.isEditingTitle
                        )
                        .offset(y: -40)
                        
                    //MARK: - LIST CATEGORIES
                        
                        CategoriesListView(viewModel: viewModel)
                        addCategoryButton
                        
                    }//:VSTACK
                    .padding(.horizontal)
                }//:VSTACK
                .background(Color.colorTan)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        optionsMenu
                    }
                }
                .sheet(isPresented: $viewModel.isRearranging) {
                    RearrangeCategoriesView(viewModel: viewModel)
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
            }//:SCROLLVIEW
            .background(Color.colorTan)
            .ignoresSafeArea(edges: .top)
        }//:NAVIGATION STACK
        
    }//:BODY
    
    
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
        .listRowBackground(Color.colorTan)
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

        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
        
        // Return the ListView with the in-memory container
        return ListView(viewModel: viewModel)
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
    }
}

#Preview("Basic Preview") {
    NavigationStack {
        let placeholderPackingList = PackingList(title: "Sample Packing List")
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: placeholderPackingList)

        ListView(viewModel: viewModel)
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
    }
}
