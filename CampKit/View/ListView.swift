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
    @Bindable var packingList: PackingList // Property to accept a PackingList instance
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @State private var item: String = ""
    @State private var showPhotoPicker = false
    @State private var isCollapsed = false
    @State private var isReordering = false
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        NavigationStack {
            Section {
                // Banner Image Section
                ZStack {
                    if let photoData = packingList.photo, let bannerImage = UIImage(data: photoData) {
                        Image(uiImage: bannerImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 50, alignment: .center)
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
                
            }//:SECTION
            
            
            // Details Card
            Section {
                ListDetailView(packingList: packingList)
                .offset(y: -20)
            }
            .background(Color.colorTan)
            
            //Lists Display
         
            Section {
                // Horizontal Chip Buttons (Separate Component)
//                ChipButtonList(
//                    isCollapsed: $isCollapsed,
//                    isReordering: $isReordering
//                )
//                .background(Color.colorTan)
                
                List {
                
                    ForEach(packingList.categories) { category in
                            
                            CategorySectionView(category: category)
                        
                    }//:FOREACH
                    .onMove { from, to in
                        packingList.categories.move(fromOffsets: from, toOffset: to)
                        do {
                                try modelContext.save()
                                print("Reordering saved successfully.")
                            } catch {
                                print("Failed to save reordering: \(error.localizedDescription)")
                            }
                    }
                }//:LIST
                .environment(\.editMode, editMode)
                .background(Color.colorTan)
                .scrollContentBackground(.hidden)
                .overlay {
                    if packingList.categories.isEmpty {
                        ContentUnavailableView("Empty List", systemImage: "plus.circle", description: Text("Add some items to your list"))
                    }
                }
            } //:SECTION
            .offset(y: -10)
            .ignoresSafeArea()
            .background(Color.colorTan)
            
        }//:NAVIGATION STACK
        .tint(.accentColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Rearrange option
                    Button(action: {
                        toggleRearrangeMode()
                    }) {
                        Label(isReordering ? "Done Rearranging" : "Rearrange", systemImage: "arrow.up.arrow.down")
                    }

                    // Collapse All option
                    Button(action: {
                        collapseAllCategories()
                    }) {
                        Label("Collapse All", systemImage: "arrowtriangle.up")
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }//:TOOLBAR
        .tint(.white)
        
    }//:BODY


    private func toggleRearrangeMode() {
        withAnimation {
            isReordering.toggle()
            editMode?.wrappedValue = isReordering ? .active : .inactive
        }
        print(isReordering ? "Rearranging mode enabled." : "Rearranging mode disabled.")
    }

    private func collapseAllCategories() {
        // Logic to collapse all categories
        print("All categories collapsed.")
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
    
    private func deleteItems(in category: Category, at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(category.items[index])
            }
        }
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
