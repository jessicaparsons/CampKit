//
//  CategorySectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI

enum FocusField: Hashable {
    case categoryTitle
    case item(UUID)
}

enum DragDirection {
    case vertical, horizontal, none
}

struct CategorySectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState var isFocused: Bool
    @ObservedObject var viewModel: ListViewModel
    @ObservedObject var category: Category
    @Binding var isRearranging: Bool
    let deleteCategory: () -> Void
    @Binding var isPickerFocused: Bool
    
    //ALERTS AND SHEETS
    @State private var isEditing: Bool = false
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isRearrangingListItems: Bool = false
    
    //For rearranging items
    @State private var tempItems: [Item] = []
    
    
    private var isExpandedBinding: Binding<Bool> {
        Binding(
            get: { category.isExpanded },
            set: { newValue in
                withAnimation {
                    category.isExpanded = newValue
                    save(viewContext)
                    withAnimation(nil) {
                        viewModel.objectWillChange.send()
                    }
                }
            }
        )
    }
    
    private var allItems: [Item] {
        category.sortedItems
    }
    
    private var packedCount: Int {
        allItems.filter { $0.isPacked }.count
    }
    
    private var packedRatio: Double {
        allItems.isEmpty ? 0 : Double(packedCount) / Double(allItems.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - HEADER TOGGLE ROW
            Button {
                isExpandedBinding.wrappedValue.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(Color.colorNeonLight)
                        .font(.caption.lowercaseSmallCaps())
                        .accessibilityLabel("Expand/Collapse \(category.name)")
                    if isEditing {
                        TextField("Category Name", text: $category.name)
                            .focused($isFocused)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .onSubmit {
                                isEditing = false
                                save(viewContext)
                            }
                            .padding(.leading, Constants.horizontalPadding)
                        
                        Button("Done") {
                            isEditing = false
                            save(viewContext)
                        }
                        .padding(.vertical, 8)
                        .accessibilityHint("Done editing category name")
                        
                        //MARK: - CATEGORY NAME
                    } else {
                        Text(category.name)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)
                            .layoutPriority(1)
                        
                        Spacer()
                        
                        
                        //MARK: - PROGRESS COUNTER
                        let isSuccess = packedCount == allItems.count && allItems.count != 0
                        
                        let countText: Text = isSuccess
                        ? Text("\(packedCount)/\(allItems.count)").bold().foregroundColor(Color.colorSuccess)
                        : Text("\(packedCount)/\(allItems.count)").foregroundColor(.secondary)
                        countText
                            .font(.subheadline)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        //MARK: - MENU
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Edit Name", systemImage: "pencil")
                            }
                            Button {
                                isRearranging = true
                            } label: {
                                Label("Reorder Categories", systemImage: "arrow.up.and.down.text.horizontal")
                            }
                            Button(role: .destructive) {
                                isDeleteConfirmationPresented = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .accessibilityHint("Delete this category")
                        } label: {
                            Image(systemName: "ellipsis")
                                .padding(.horizontal, 8)
                                .padding(.vertical)
                                .foregroundStyle(Color.primary)
                                .accessibilityLabel("Menu")
                            
                        }//:MENU
                        .labelStyle(.iconOnly)
                        .confirmationDialog(
                            "Are you sure you want to delete this category?",
                            isPresented: $isDeleteConfirmationPresented,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                deleteCategory()
                                HapticsManager.shared.triggerSuccess()
                                
                            }
                            .accessibilityHint("Delete this category")
                            Button("Cancel", role: .cancel) { }
                                .accessibilityHint("Cancel deletion")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Constants.verticalSpacing)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isPickerFocused = false
                    }
                )
            }
            .onChange(of: isEditing) {
                isFocused = isEditing
            }
            
            // MARK: - EXPANDED CONTENT
            if category.isExpanded {
                Divider()
                    .padding(.horizontal)
                    .padding(.bottom, Constants.verticalSpacing)
                VStack(spacing: 2) {
                    if !category.sortedItems.isEmpty {
                        ForEach(category.sortedItems, id: \.id) { item in
                            ZStack {
                                EditableItemView<Item>(
                                    item: item,
                                    togglePacked: { viewModel.togglePacked(for: item) },
                                    deleteItem: { viewModel.deleteItem(item) },
                                    isPickerFocused: $isPickerFocused
                                )
                            }
                            .background(Color.colorWhite)
                            .contextMenu {
                                Button {
                                    isRearrangingListItems = true
                                } label: {
                                    Label("Move item", systemImage: "arrow.up.and.down.text.horizontal")
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .accessibilityHint("Delete this item")
                            }
                        }
                    }
                    AddNewItemView(
                        viewModel: viewModel,
                        category: category,
                        isPickerFocused: $isPickerFocused)
                    .padding(.bottom, 10)
                }//:LAZY VSTACK
                .sheet(isPresented: $isRearrangingListItems, onDismiss: {
                    viewModel.moveItems(tempItems, in: category)
                }) {
                    RearrangeListView(
                        items: tempItems,
                        label: { $0.title ?? "Empty item" },
                        moveAction: { source, destination in
                            tempItems.move(fromOffsets: source, toOffset: destination)
                        }
                    )
                    .onAppear { tempItems = category.sortedItems }
                }
            }
        }//:VSTACK
        
    }//:BODY
}


//MARK: - PREVIEW
#if DEBUG
#Preview {
    @Previewable @State var isRearranging: Bool = false
    @Previewable @State var isPickerFocused: Bool = false
    
    let context = CoreDataStack.preview.context
    
    let list = PackingList.samplePackingList(context: context)
    
    let categories = Category.sampleCategories(context: context)
    
    // Return the preview
    
    NavigationStack {
        CategorySectionView(
            viewModel: ListViewModel(viewContext: context, packingList: list),
            category: categories.first!,
            isRearranging: $isRearranging,
            deleteCategory: { },
            isPickerFocused: $isPickerFocused
        )
    }
}
#endif

