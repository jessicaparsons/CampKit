//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData


struct CategorySectionView: View {
    @ObservedObject var viewModel: ListViewModel
    @Bindable var category: Category
    @Binding var isRearranging: Bool
    
    let deleteCategory: () -> Void
    
    @State private var newItemText: String = ""
    @State private var isEditing: Bool = false
    
    let globalIsExpanded: Bool // Desired global state
    let globalExpandCollapseAction: UUID // Unique trigger
        
    //MARK: - CATEGORY BODY
    var body: some View {
        DisclosureGroup(isExpanded: $category.isExpanded) {
            if category.items.isEmpty {
                AddNewItemView(viewModel: viewModel, category: category)
            } else {
                LazyVStack(spacing: 0) {
                    //Iterate through items in the category
                    ForEach(category.sortedItems) { item in
                        
                        EditableItemView(
                            viewModel: viewModel,
                            item: item,
                            togglePacked: {
                                viewModel.togglePacked(for: item)
                            })
                    }//:FOREACH
                    AddNewItemView(viewModel: viewModel, category: category)
                }//:LAZY VSTACK
                
            }//:ELSE
            //MARK: - MENU
        } label: {
            // Editable text field for category name
            if isEditing {
                TextField("Category Name", text: $category.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .offset(x: 23)
                    .onSubmit {
                        isEditing = false // Disable editing after submit
                        viewModel.saveContext()
                    }
                Spacer()
                Button {
                    isEditing = false // Disable editing after submit
                    viewModel.saveContext()
                } label: {
                    Text("Done")
                }
                .padding(.vertical)
                .padding(.leading, 30)
                .padding(.trailing, 10)
            } else {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Menu {
                        Button {
                            isEditing = true // Enable editing
                        } label: {
                            Label("Edit Name", systemImage: "pencil")
                        }
                        Button(action: {
                            isRearranging = true
                        }) {
                            Label("Rearrange", systemImage: "arrow.up.arrow.down")
                        }
                        Button(role: .destructive) {
                            deleteCategory()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Edit", systemImage: "ellipsis")
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(Constants.cornerRadius)
                    } //:MENU
                    .labelStyle(.iconOnly)
                }
                .padding(.vertical)
                .padding(.leading, 30)
                .padding(.trailing, 10)
            }
            
        }//:DISCLOSURE GROUP
        .onChange(of: globalExpandCollapseAction) {
            category.isExpanded = globalIsExpanded
        }
        .disclosureGroupStyle(LeftDisclosureStyle())
    }//:BODY
    
}


//MARK: - DISCLOSURE GROUP STYLE

struct LeftDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: configuration.isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.customNeonLight)
                        .font(.caption.lowercaseSmallCaps())
                        .offset(x: 20)
                        .animation(.default, value: configuration.isExpanded)
                    configuration.label
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

//MARK: - PREVIEW

#Preview {
    @Previewable @State var isRearranging: Bool = false
    
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Populate the container with mock data
    preloadPackingListData(context: container.mainContext)
    
    // Fetch a sample category
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
    let sampleCategory = samplePackingList.categories.first!
    
    // Create a mock ListViewModel
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    // Return the preview
    return NavigationStack {
        CategorySectionView(
            viewModel: viewModel,
            category: sampleCategory,
            isRearranging: $isRearranging,
            deleteCategory: { print("Mock delete category: \(sampleCategory.name)") },
            globalIsExpanded: true,
            globalExpandCollapseAction: UUID()
        )
        .modelContainer(container) // Provide the ModelContainer
    }
}

#Preview("Empty Category") {
    @Previewable @State var isRearranging: Bool = false
    
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Create a mock PackingList and empty Category
    let samplePackingList = PackingList(title: "Sample Packing List")
    let emptyCategory = Category(name: "Lounge", position: 0)
    samplePackingList.categories.append(emptyCategory)
    
    // Insert data into the context
    container.mainContext.insert(samplePackingList)
    container.mainContext.insert(emptyCategory)
    
    // Create a mock ListViewModel
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
    
    // Return the view with the empty category
    return NavigationStack {
        CategorySectionView(
            viewModel: viewModel,
            category: emptyCategory,
            isRearranging: $isRearranging,
            deleteCategory: { print("Mock delete category: \(emptyCategory.name)") },
            globalIsExpanded: true,
            globalExpandCollapseAction: UUID()
        )
        .modelContainer(container) // Provide the ModelContainer
    }
}
