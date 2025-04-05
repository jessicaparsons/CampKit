//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

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
                    HapticsManager.shared.triggerLightImpact()
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
        .modifier(SwipeActionModifier(viewModel: viewModel, item: item, isFocused: isFocused))
        
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
