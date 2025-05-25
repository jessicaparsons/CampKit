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

struct CategorySectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState var isFocused: Bool
    @ObservedObject var viewModel: ListViewModel
    @ObservedObject var category: Category
    @Binding var isRearranging: Bool
    let deleteCategory: () -> Void
    @State private var isEditing: Bool = false
    @Binding var isPickerFocused: Bool

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
                                    Label("Rearrange", systemImage: "arrow.up.arrow.down")
                                }
                                Button(role: .destructive) {
                                    deleteCategory()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .padding(.horizontal, 8)
                                    .padding(.vertical)
                                    .foregroundStyle(Color.primary)
                                
                            }//:MENU
                            .labelStyle(.iconOnly)
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
                if !category.sortedItems.isEmpty {
                    ForEach(category.sortedItems, id: \.id) { item in
                        EditableItemView<Item>(
                            item: item,
                            togglePacked: { viewModel.togglePacked(for: item) },
                            deleteItem: { viewModel.deleteItem(item) },
                            isPickerFocused: $isPickerFocused
                        )
                    }
                }
                AddNewItemView(
                    viewModel: viewModel,
                    category: category,
                    isPickerFocused: $isPickerFocused)
                    .padding(.bottom, 10)
                    
            }
        }
    }
}


//MARK: - PREVIEW
#if DEBUG
#Preview {
    @Previewable @State var isRearranging: Bool = false
    @Previewable @State var isPickerFocused: Bool = false
    
    let context = CoreDataStack.shared.context
    
    let list = PackingList.samplePackingList(context: context)
    
    let categories = Category.sampleCategories(context: context)
    
    // Return the preview
   
            NavigationStack {
            CategorySectionView(
                viewModel: ListViewModel(viewContext: context, packingList: list),
                category: categories.first!,
                isRearranging: $isRearranging,
                deleteCategory: { print("Mock delete category") },
                isPickerFocused: $isPickerFocused
            )
        }
}
#endif

