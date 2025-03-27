//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData
import SwipeCell

struct EditableItemView: View {
    
    @ObservedObject var viewModel: ListViewModel
    @Bindable var item: Item
    @FocusState private var isFocused: Bool
    

    @State private var willDelete = false
    let togglePacked: () -> Void
        
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    togglePacked()
                }) {
                    let packedColor = viewModel.packedCircleColor(for: item)
                    Image(systemName: packedColor.systemName)
                        .foregroundStyle(packedColor.color)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: $item.title)
                    .foregroundStyle(viewModel.packedTextColor(for: item))
                    .strikethrough(item.isPacked)
                    .italic(item.isPacked)
                    .focused($isFocused)
                    .onSubmit {
                        isFocused = false
                    }
                if isFocused {
                    Button {
                        isFocused = false
                    } label: {
                        Text("Done")
                    }
                }
            }
        }//:ZSTACK
        .padding(.horizontal)
        .padding(.vertical, 8)
        //MARK: - SWIPE TO DELETE
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
                                            viewModel.deleteItem(item)
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
    }//:BODY
    
}



#Preview(traits: .sizeThatFitsLayout) {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
    )
    
    // Sample data
    let sampleCategory = Category(name: "Sleep", position: 0)
    let sampleItem = Item(title: "Tent", isPacked: false)
    sampleItem.position = 0
    sampleItem.category = sampleCategory
    sampleCategory.items.append(sampleItem)
    
    let samplePackingList = PackingList(title: "Sample Trip")
    samplePackingList.categories.append(sampleCategory)
    container.mainContext.insert(samplePackingList)

    // Create a mock ListViewModel
    let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)

    
     return EditableItemView(
                viewModel: viewModel,
                item: sampleItem,
                togglePacked: {
                    print("Toggle packed for \(sampleItem.title)")
            }
        )
        .modelContainer(container) // Provide the SwiftData container
}
