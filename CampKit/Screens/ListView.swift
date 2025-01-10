//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    @Bindable var packingList: PackingList
    @State private var globalIsExpanded: Bool = false
    @State private var globalExpandCollapseAction = UUID() // Unique trigger for .onChange in CategorySectionView
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @State private var item: String = ""
    @State private var showPhotoPicker = false
    @State private var isRearranging = false
    @State private var draggedCategory: Category?
    @State private var isEditingTitle: Bool = false
    @State private var showDeleteConfirmation = false
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollView(showsIndicators: true) {
                ZStack {
                    // Banner Image Section
                    ZStack {
                        if let photoData = packingList.photo, let bannerImage = UIImage(data: photoData) {
                            Image(uiImage: bannerImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100, alignment: .bottom)
                                .ignoresSafeArea()
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                )
                                .background(Color.red)
                        } else {
                            Image("TopographyDesign")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100, alignment: .center)
                                .ignoresSafeArea()
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                )
                        }
                        
                    }//:ZSTACK
                    .onTapGesture {
                        showPhotoPicker.toggle()
                    }
                    
                }//:ZSTACK
                
                
                // Details Card
                ZStack {
                    ListDetailView(packingList: packingList, isEditingTitle: $isEditingTitle)
                        .offset(y: -20)
                }
                .background(Color.colorTan)
                
                //Lists Display
                ZStack {
                    LazyVStack(spacing: 10) {
                        if packingList.categories.isEmpty {
                            ContentUnavailableView(
                                "No Lists Available",
                                systemImage: "plus.circle",
                                description: Text("Add a new list to get started")
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(packingList.categories.sorted(by: { $0.position < $1.position }), id: \.id) { category in
                                ZStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white) // Background color
                                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                        CategorySectionView(
                                            category: category,
                                            globalIsExpanded: globalIsExpanded,
                                            globalExpandCollapseAction: globalExpandCollapseAction,
                                            deleteCategory: deleteCategory)
                                    }
                                }//:ZSTACK
                                .onDrag {
                                    self.draggedCategory = category
                                    return NSItemProvider(object: "\(category.id)" as NSString)
                                }
                                .onDrop(
                                    of: [.text],
                                    delegate: CategoryDropDelegate(
                                        currentCategory: category,
                                        categories: $packingList.categories,
                                        draggedCategory: $draggedCategory
                                    )
                                )
                            }//:FOREACH
                            
                        }//:ELSE
                        
                    }//:LAZY VSTACK
                    .environment(\.editMode, editMode)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                    
                }//:ZSTACK
                .background(Color.colorTan)
                .offset(y: -20)
                
                HStack {
                    Button {
                        addNewCategory()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Category")
                                .padding(5)
                        }
                    }
                    .buttonStyle(BigButton())
                    Spacer()
                }//:HSTACK
                .padding(.horizontal)
                .offset(y: -20)
                
            }//:SCROLL VIEW
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.colorTan)
            
        }//:NAVIGATION STACK
        .tint(.accentColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    
                    // Edit Title
                    Button(action: {
                        isEditingTitle.toggle()
                    }) {
                        Label("Edit List Details", systemImage: "pencil")
                    }
                    
                    // Rearrange option
                    Button(action: {
                        withAnimation {
                            isRearranging.toggle()
                        }
                    }) {
                        Label(isRearranging ? "Done" : "Rearrange", systemImage: "arrow.up.arrow.down")
                    }
                    
                    // Expand All
                    Button(action: {
                        withAnimation {
                            globalIsExpanded = true
                            globalExpandCollapseAction = UUID()
                        }
                    }) {
                        Label("Expand All", systemImage: "rectangle.expand.vertical")
                    }
                    
                    // Collapse All
                    Button(action: {
                        withAnimation {
                            globalIsExpanded = false
                            globalExpandCollapseAction = UUID()
                        }
                    }) {
                        Label("Collapse All", systemImage: "rectangle.compress.vertical")
                    }
                    
                    // Delete List
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                    
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }//:TOOLBAR
        .tint(.white)
        .confirmationDialog(
            "Are you sure you want to delete this list?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteList() // Perform delete
            }
            Button("Cancel", role: .cancel) { }
            }
        
    }//:BODY
    
    
    //MARK: - Edit List
    
    func shareList() {
        print("Sharing the list!")
    }
    
    func deleteList() {
        withAnimation {
            // Delete the category from SwiftData
            modelContext.delete(packingList)
            
            // Save changes
            do {
                try modelContext.save()
                print("Category \(packingList) deleted successfully.")
                dismiss()
            } catch {
                print("Failed to delete list: \(error.localizedDescription)")
            }
        }
    }
    
    private func addNewCategory() {
        withAnimation {
            let newPosition = packingList.categories.count
            let newCategory = Category(name: "New Category", position: newPosition)
            packingList.categories.append(newCategory)
            modelContext.insert(newCategory)
            print("All categories: \(packingList.categories)")
        }
    }
    
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            // Remove the category from the packing list
            packingList.categories.removeAll { $0.id == category.id }
            
            // Delete the category from SwiftData
            modelContext.delete(category)
            
            // Save changes
            do {
                try modelContext.save()
                print("Category \(category.name) deleted successfully.")
            } catch {
                print("Failed to delete category: \(error.localizedDescription)")
            }
        }
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        packingList.categories.move(fromOffsets: source, toOffset: destination)
        do {
            try modelContext.save()
            print("Reordering saved.")
        } catch {
            print("Failed to save reordering: \(error.localizedDescription)")
        }
    }
    
    private func toggleRearrangeMode() {
        withAnimation {
            isRearranging.toggle()
            editMode?.wrappedValue = isRearranging ? .active : .inactive
        }
        print(isRearranging ? "Rearranging mode enabled." : "Rearranging mode disabled.")
    }
    
    private func addItem(to category: Category) {
        withAnimation {
            if !item.isEmpty {
                let newItem = Item(title: item, isPacked: false)
                category.items.append(newItem) // Add item to category
                modelContext.insert(newItem)   // Insert into SwiftData
                item = ""
            }
        }
    }
    
}

//MARK: - DRAG AND DROP METHODS

struct CategoryDropDelegate: DropDelegate {
    let currentCategory: Category
    @Binding var categories: [Category]
    @Binding var draggedCategory: Category?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedCategory = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedCategory,
              let fromIndex = categories.firstIndex(of: draggedCategory),
              let toIndex = categories.firstIndex(of: currentCategory),
              fromIndex != toIndex else { return }
        
        withAnimation {
            // Reorder categories in the array
            categories.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
            
            // Update the positions after the move
            updateCategoryPositions()
        }
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
    
    private func updateCategoryPositions() {
        for (index, category) in categories.enumerated() {
            category.position = index
        }
        print("Updated positions: \(categories.map { "\($0.name): \($0.position)" })")
    }
}


#Preview("Sample Data") {
    NavigationStack {
        // Create an in-memory ModelContainer
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // Populate the container with sample data
        preloadPackingListData(context: container.mainContext)
        
        let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
        
        // Return the view with the mock ModelContainer
        return ListView(packingList: samplePackingList)
            .modelContainer(container)
    }
}

#Preview("Basic Preview") {
    NavigationStack {
        ListView(packingList: PackingList(title: "Sample List"))
    }
}
