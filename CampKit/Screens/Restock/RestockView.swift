//
//  RestockView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct RestockView: View {

    @StateObject private var viewModel: RestockViewModel
    @State private var isAddNewItemShowing: Bool = false
    @State private var newItemTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    init(viewModel: RestockViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
            ZStack(alignment: .top) {
                GradientHeaderView(
                    label: "Restock",
                    editMode: $editMode,
                    onAdd: { isAddNewItemShowing = true })
                
                VStack {
                    
                    
                    if viewModel.restockItems.isEmpty {
                        VStack(spacing: Constants.verticalSpacing) {
                            LazyVStack {
                                ContentUnavailableView("Empty List", systemImage: "arrow.clockwise.circle", description: Text("""
You haven't created any restock items yet. 
Hit the \"+\" to get started!
"""))
                                    .padding(.top, Constants.emptyContentSpacing)
                            }//:LAZYVSTACK
                            Spacer()
                        }//:VSTACK
                    } else {

                        List {
                            ForEach(viewModel.sortedItems) { item in
                                
                                
                                if let index = viewModel.restockItems.firstIndex(where: { $0.id == item.id }) { //Allows binding item
                                    
                                        EditableItemView(
                                            item: $viewModel.restockItems[index].title,
                                            isList: true,
                                            isPacked: item.isPacked,
                                            togglePacked: { viewModel.togglePacked(for: item) },
                                            deleteItem: { }
                                        )
                                        .listRowInsets(EdgeInsets(top: Constants.lineSpacing, leading: 0, bottom: Constants.lineSpacing, trailing: 0))
                               }
                            }//:FOREACH
                            .onMove(perform: viewModel.onMove)
                            .onDelete(perform: viewModel.deleteItem)
                        }//:LIST
                        .animation(.easeInOut, value: viewModel.restockItems.count)
                    }
                }//:VSTACK
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.customTan)
                        .ignoresSafeArea(.container, edges: [.bottom])
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: -2)
                )
                .padding(.top, Constants.bodyPadding)
            }//:ZSTACK
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
            .task {
                do {
                    viewModel.restockItems = try viewModel.fetchRestockItems()
                } catch {
                    print("Failed to fetch items")
                }
            }
            //MARK: - ADD NEW ITEM POP UP
            .alert("Add New Item", isPresented: $isAddNewItemShowing) {
                TextField("New restock item", text: $newItemTitle)
                Button("Add Item", action: {
                    if newItemTitle != "" {
                        viewModel.addNewItem(title: newItemTitle)
                        newItemTitle = ""
                    }
                    isAddNewItemShowing = false
                    })
                Button("Cancel", role: .cancel) { }
            }
            .environment(\.editMode, $editMode)
    }
}

#Preview {
    let container = try! ModelContainer(for: RestockItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    for item in RestockItem.restockItems {
        container.mainContext.insert(item)
    }

    var viewModel = RestockViewModel(modelContext: container.mainContext)
    viewModel.restockItems = try! viewModel.fetchRestockItems()

    return NavigationStack {
        RestockView(viewModel: viewModel)
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
    }
}

#Preview("Empty") {
    
    let container = try! ModelContainer(for: RestockItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    return RestockView(viewModel: RestockViewModel(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(\.modelContext, container.mainContext)
}
