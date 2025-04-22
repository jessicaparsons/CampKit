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

    private var isExpandedBinding: Binding<Bool> {
        Binding(
            get: { category.isExpanded },
            set: { newValue in
                withAnimation {
                    category.isExpanded = newValue
                    save(viewContext)
                    viewModel.objectWillChange.send()
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - HEADER TOGGLE ROW
            Button {
                isExpandedBinding.wrappedValue.toggle()
            } label: {
                HStack(spacing: Constants.horizontalPadding) {
                    Image(systemName: category.isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.customNeonLight)
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

                        Button("Done") {
                            isEditing = false
                            save(viewContext)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text(category.name)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
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
                        }
                        .labelStyle(.iconOnly)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, Constants.verticalSpacing)
                .contentShape(Rectangle())
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
                            isList: false,
                            togglePacked: { viewModel.togglePacked(for: item) },
                            deleteItem: { viewModel.deleteItem(item) }
                        )
                    }
                }
                AddNewItemView(viewModel: viewModel, category: category)
                    .padding(.bottom, 10)
            }
        }
    }
}


//MARK: - PREVIEW
#if DEBUG
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
            .background(.red)
        }
}
#endif

