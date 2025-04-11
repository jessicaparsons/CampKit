//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

protocol EditablePackableItem: AnyObject {
    var title: String { get set }
    var isPacked: Bool { get set }
}

struct EditableItemView<T: EditablePackableItem>: View {
    
    var item: T
    @FocusState private var isFocused: Bool
    var isList: Bool
    let togglePacked: () -> Void
    let deleteItem: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    togglePacked()
                    HapticsManager.shared.triggerLightImpact()
                }) {
                    Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isPacked ? Color.colorSage : .secondary)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: Binding(
                    get: { item.title },
                    set: { item.title = $0 }))
                .foregroundStyle(item.isPacked ? Color.secondary : .primary)
                .strikethrough(item.isPacked)
                .italic(item.isPacked)
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }
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
            }//:HSTACK
        }//:ZSTACK
        .padding(.horizontal)
        .padding(.vertical, 8)
        //MARK: - SWIPE TO DELETE
        .modifier(SwipeActionModifier(isFocused: isFocused, isList: isList, deleteAction: deleteItem))
        
    }//:BODY
    
}

#Preview(traits: .sizeThatFitsLayout) {
    
    @Previewable @State var title = "Tent"
    let item = RestockItem(position: 0, title: "Sleeping Bag", isPacked: false)
    
    EditableItemView(
        item: item,
        isList: false,
        togglePacked: { print("Toggle packed for \(title)") },
        deleteItem: { print("Delete item: \(title)") }
    )
    
    EditableItemView(
        item: item,
        isList: false,
        togglePacked: { print("Toggle packed for \(title)") },
        deleteItem: { print("Delete item: \(title)") }
    )
    
}
