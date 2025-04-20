//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI


struct CategorySectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: ListViewModel
    @ObservedObject var category: Category
    @Binding var isRearranging: Bool
    
    let deleteCategory: () -> Void
    
    @State private var newItemText: String = ""
    @State private var isEditing: Bool = false
    
    //Refreshes the view when isExpanded is changed from the ViewModel
    private var isExpandedBinding: Binding<Bool> {
        Binding(
            get: { category.isExpanded },
            set: { newValue in
                withAnimation {
                    category.isExpanded = newValue
                    save(viewContext)
                }
            }
        )
    }
        
    //MARK: - CATEGORY BODY
    var body: some View {
        DisclosureGroup(isExpanded: isExpandedBinding) {
            if !category.sortedItems.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(category.sortedItems) { item in
                            EditableItemView<Item>(
                                item: item,
                                isList: false,
                                togglePacked: { viewModel.togglePacked(for: item) },
                                deleteItem: { viewModel.deleteItem(item) }
                            )
                    }//:FOREACH
                    AddNewItemView(viewModel: viewModel, category: category)
                }//:LAZY VSTACK
                
            } else {
                AddNewItemView(viewModel: viewModel, category: category)
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
                            save(viewContext)
                        }
                    Button {
                        isEditing = false // Disable editing after submit
                        save(viewContext)
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
                                .foregroundStyle(Color.primary)
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
    
    let context = PersistenceController.preview.container.viewContext
    
    let samplePackingList = PackingList.samplePackingList(context: context)
    
    let categories = Category.sampleCategories(context: context)
    
    // Return the preview
    NavigationStack {
        CategorySectionView(
            viewModel: ListViewModel(viewContext: context, packingList: samplePackingList),
            category: categories.first!,
            isRearranging: $isRearranging,
            deleteCategory: { print("Mock delete category") }
        )
    }
}


