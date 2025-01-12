//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData
import SwipeCell

struct CategorySectionView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @EnvironmentObject var viewModel: ListViewModel
    @Bindable var category: Category
    @Binding var isRearranging: Bool
    
    let addItem: (String) -> Void
    let deleteItem: (Item) -> Void
    let deleteCategory: () -> Void
    
    @State private var newItemText: String = ""
    @State private var isExpanded: Bool = true
    @State private var isEditing: Bool = false
    
    let globalIsExpanded: Bool // Desired global state
    let globalExpandCollapseAction: UUID // Unique trigger
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        
        DisclosureGroup(isExpanded: $isExpanded) {
            
            //Iterate through items in the category
            ForEach(category.items) { item in
                
                EditableItemView(
                    item: item,
                    togglePacked: {
                    viewModel.togglePacked(for: item, using: modelContext)
                    })
                    .swipeCell(
                        cellPosition: .both,
                        leftSlot: nil,
                        rightSlot:
                            SwipeCellSlot(
                                slots: [
                                    SwipeCellButton(buttonStyle: .view,
                                        title: "",
                                        systemImage: "",
                                        view: {
                                            AnyView(
                                                Image(systemName: "trash")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            )},
                                        backgroundColor: .red,
                                            action: {
                                                deleteItem(item)
                                            },
                                        feedback:true
                                                   ),
                                    
                                ],
                                slotStyle: .destructiveDelay),
                        swipeCellStyle: SwipeCellStyle(
                            alignment: .leading,
                            dismissWidth: 20,
                            appearWidth: 20,
                            destructiveWidth: 240,
                            vibrationForButton: .error,
                            vibrationForDestructive: .heavy,
                            autoResetTime: 3)
                            )
                    .dismissSwipeCellForScrollViewForLazyVStack()
            }//:FOREACH
            // Add new item to the category
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.gray)
                    .font(.title3)
                TextField("Add new item", text: $newItemText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addItem(newItemText)
                        newItemText = ""
                        
                    }
                if !newItemText.isEmpty {
                    Button {
                        addItem(newItemText)
                        newItemText = ""
                    } label: {
                        Text("Done")
                    }
                }
                
            }//:HSTACK
            .padding(.vertical, 10)
            .padding(.horizontal)
            
        } label: {
            // Editable text field for category name
            if isEditing {
                TextField("Category Name", text: $category.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .onSubmit {
                        isEditing = false // Disable editing after submit
                        viewModel.saveContext(using: modelContext)
                    }
                Spacer()
                Button {
                    isEditing = false // Disable editing after submit
                    viewModel.saveContext(using: modelContext)
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
                            .cornerRadius(8)
                    } //:MENU
                    .labelStyle(.iconOnly)
                }
                .padding(.vertical)
                .padding(.leading, 30)
                .padding(.trailing, 10)
            }
        } //:DISCLOSURE GROUP
        .onChange(of: globalExpandCollapseAction) {
            isExpanded = globalIsExpanded
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

#Preview {
    
    @Previewable @State var isExpanded: Bool = true
    @Previewable @State var isRearranging: Bool = false
    
    let mockCategory = Category(name: "Sleeping", position: 0, items: [
            Item(title: "Sleeping Bag", isPacked: false),
            Item(title: "Tent", isPacked: true)
        ])

    
    ZStack {
        Color(.colorTan)
        CategorySectionView(
            category: mockCategory,
            isRearranging: $isRearranging,
            addItem: { newItem in print("Mock add new item")},
            deleteItem: { item in print("Delete mock item")} ,
            deleteCategory: { print("Delete mock category")},
            globalIsExpanded: true,
            globalExpandCollapseAction: UUID()
            
        )
        .frame(height:50)
    }
}
