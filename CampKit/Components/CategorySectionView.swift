//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

struct CategorySectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var category: Category
    @State private var item: String = ""
    
    @State private var isExpanded: Bool = true
    @State private var isEditing: Bool = false
    
    let globalIsExpanded: Bool
    let deleteCategory: (Category) -> Void
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            
            //Iterate through items in the category
            ForEach(category.items) { item in
                
                EditableItemView(item: item)
                
            }//:FOREACH
            
            // Add new item to the category
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.gray)
                    .font(.title3)
                TextField("Add new item", text: $item)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addItem(to: category)
                    }
                
            }//:HSTACK
            .padding(.top, 10)
            
        } label: {
            // Editable text field for category name
            if isEditing {
                TextField("Category Name", text: $category.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .onSubmit {
                        isEditing = false // Disable editing after submit
                        saveChanges()
                    }
                Spacer()
                Button {
                    isEditing = false // Disable editing after submit
                    saveChanges()
                } label: {
                    Text("Done")
                }
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
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Edit", systemImage: "ellipsis")
                    } //:MENU
                    .labelStyle(.iconOnly)
                }
            }
        } //:DISCLOSURE GROUP
        .onChange(of: globalIsExpanded) {
            isExpanded = !globalIsExpanded
        }
        .animation(.easeInOut, value: isExpanded)
        .padding()
        .disclosureGroupStyle(LeftDisclosureStyle())
        
        
    }//:BODY
    
    
    private func addItem(to category: Category) {
        if !item.isEmpty {
            let newItem = Item(title: item, isPacked: false)
            category.items.append(newItem)
            modelContext.insert(newItem)
            item = ""
        }
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
            print("Changes saved successfully.")
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }
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
                        .foregroundColor(.accentColor)
                        .font(.caption.lowercaseSmallCaps())
                        .animation(nil, value: configuration.isExpanded)
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

#Preview {
    
    @Previewable @State var isExpanded: Bool = true
    
    ZStack {
        Color(.colorTan)
        CategorySectionView(
            category: Category(name: "Sleeping", position: 0), globalIsExpanded: isExpanded,
            deleteCategory: { category in
                print("Mock delete category: \(category.name)")
            }
        )
    }
}
