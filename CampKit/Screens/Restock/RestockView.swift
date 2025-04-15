//
//  RestockView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import CoreData

struct RestockView: View {
    
    @Bindable var viewModel: RestockViewModel
    @State private var isAddNewItemShowing: Bool = false
    @State private var newItemTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    private var isFormValid: Bool {
        !newItemTitle.isEmptyOrWhiteSpace
    }
    
    init(context: NSManagedObjectContext) {
        self.viewModel = RestockViewModel(context: context)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            GradientTanBackgroundView()
            
            //MARK: - EMPTY VIEW
            if viewModel.restockItems.isEmpty {
                ScrollView {
                        ContentUnavailableView("Empty List", systemImage: "arrow.clockwise.circle", description: Text("""
You haven't created any restock items yet. 
Hit the \"+\" to get started!
"""))
                        .padding(.top, Constants.emptyContentSpacing)
                    
                }//:SCROLLVIEW
            } else {
                //MARK: - RESTOCK LIST
                List {
                    
                    Section(header:
                                Color.clear
                        .frame(height: 1) //Top Spacing
                    ) {
                        ForEach(viewModel.sortedItems) { item in
                            
                                EditableItemView<RestockItem>(
                                    item: item,
                                    isList: true,
                                    togglePacked: { viewModel.togglePacked(for: item) },
                                    deleteItem: { }
                                )
                                .listRowInsets(EdgeInsets(top: Constants.lineSpacing, leading: 0, bottom: Constants.lineSpacing, trailing: 0))
                            
                        }//:FOREACH
                        .onMove(perform: viewModel.onMove)
                        .onDelete(perform: viewModel.deleteItem)
                    }
                }//:LIST
                .animation(.easeInOut, value: viewModel.restockItems.count)
                
                
            }
        }//:ZSTACK
        .navigationTitle("Restock")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
        .task {
            await viewModel.loadItems()
        }
        //MARK: - ADD NEW ITEM POP UP
        .alert("Add New Item", isPresented: $isAddNewItemShowing) {
            TextField("New restock item", text: $newItemTitle)
            Button("Done", action: {
                if isFormValid {
                    viewModel.addNewItem(title: newItemTitle)
                    newItemTitle = ""
                }
                isAddNewItemShowing = false
            }).disabled(!isFormValid)
            Button("Cancel", role: .cancel) { }
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
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                        // ADD BUTTON
                        Button {
                            isAddNewItemShowing = true
                            
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
    }
}

#Preview("Sample Data") {
    do {
        let context = PersistenceController.preview.container.viewContext
        RestockItem.generateSampleItems(context: context)
        try? context.save()
        
        return NavigationStack {
            RestockView(context: context)
                .environment(\.managedObjectContext, context)
        }
    }
}


#Preview("Empty") {
    let context = PersistenceController.preview.container.viewContext

    NavigationStack {
        RestockView(context: context)
            .environment(\.managedObjectContext, context)

    }
}

