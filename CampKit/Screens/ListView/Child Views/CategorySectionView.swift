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
        
    //MARK: - CATEGORY BODY
    var body: some View {
        DisclosureGroup(isExpanded: $category.isExpanded) {
            if category.items.isEmpty {
                AddNewItemView(viewModel: viewModel, category: category)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(category.sortedItems) { item in
                        if let index = category.items.firstIndex(where: { $0.id == item.id }) {
                            EditableItemView(
                                item: $category.items[index].title,
                                isPacked: category.items[index].isPacked,
                                togglePacked: { viewModel.togglePacked(for: item) },
                                deleteItem: { viewModel.deleteItem(item) }
                            )
                        }
                    }//:FOREACH
                    AddNewItemView(viewModel: viewModel, category: category)
                }//:LAZY VSTACK
                
            }//:ELSE
            //MARK: - MENU
        } label: {
            // Editable text field for category name
            if isEditing {
                HStack {
                    TextField("Category Name", text: $category.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                        .offset(x: 10)
                        .multilineTextAlignment(.leading)
                        .onSubmit {
                            isEditing = false // Disable editing after submit
                            viewModel.saveContext()
                        }
                    Button {
                        isEditing = false // Disable editing after submit
                        viewModel.saveContext()
                    } label: {
                        Text("Done")
                    }
                    .padding(.leading, 20)
                }//:HSTACK
                .padding(.vertical)
            } else {
                VStack {
                    HStack {
                        Text(category.name)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .offset(x: 7)
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
                                .padding(.leading, 10)
                                .padding(.vertical, 10)
                                .padding(.trailing, 0)
                        } //:MENU
                        .labelStyle(.iconOnly)
                    }//:HSTACK
                    .padding(.top)
                    .padding(.leading, 10)
                    
                    if category.isExpanded {
                        Divider()
                    }
                    
                }//:VSTACK
            }//:ELSE
            
        }//:DISCLOSURE GROUP
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
                HStack {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.customNeonLight)
                        .font(.caption.lowercaseSmallCaps())
                        .offset(y: configuration.isExpanded ? -7 : 7)
                        .offset(x: configuration.isExpanded ? 0 : 7)
                        .rotationEffect(configuration.isExpanded ? .degrees(90.0) : .zero)
                    configuration.label
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            configuration
                .content
                .frame(height: configuration.isExpanded ? nil : .zero, alignment: .top)
                .clipped()
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
            deleteCategory: { print("Mock delete category: \(sampleCategory.name)") }
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
            deleteCategory: { print("Mock delete category: \(emptyCategory.name)") }
        )
        .modelContainer(container) // Provide the ModelContainer
    }
}
