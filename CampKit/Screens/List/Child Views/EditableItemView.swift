//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

struct EditableItemView: View {
    
    @EnvironmentObject var viewModel: ListViewModel
    @Bindable var item: Item
    @FocusState private var isFocused: Bool
    
    @State private var offset: CGFloat = 0
    @State private var willDelete = false
    private let deletionThreshold: CGFloat = 120
    let togglePacked: () -> Void
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    togglePacked()
                }) {
                    let packedColor = viewModel.packedCircleColor(for: item)
                    Image(systemName: packedColor.systemName)
                        .foregroundColor(packedColor.color)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: $item.title)
                    .foregroundColor(viewModel.packedTextColor(for: item))
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
            .offset(x: offset)
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(Color.colorWhite)
            .offset(x: offset)
        }//:ZSTACK
        
    }//:BODY
    
}



#Preview {
    let container = try! ModelContainer(
        for: Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let sampleItem = Item(title: "Tent")
    container.mainContext.insert(sampleItem)

    return ZStack {
        Color(.colorTan)
        EditableItemView(
            item: sampleItem,
            togglePacked: {
                print("Toggle packed for \(sampleItem.title)")
            }
        )
    }
    .modelContainer(container)
}
