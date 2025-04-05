//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

struct EditableItemView: View {
    
    @Binding var item: String
    @FocusState private var isFocused: Bool
    var isPacked: Bool
    let togglePacked: () -> Void
    let deleteItem: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    togglePacked()
                    HapticsManager.shared.triggerLightImpact()
                }) {
                    Image(systemName: isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isPacked ? Color.colorSage : .secondary)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: $item)
                    .foregroundStyle(isPacked ? Color.secondary : .primary)
                    .strikethrough(isPacked)
                    .italic(isPacked)
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
        .modifier(SwipeActionModifier(isFocused: isFocused, deleteAction: deleteItem))
        
    }//:BODY
    
}

#Preview(traits: .sizeThatFitsLayout) {
    
    @Previewable @State var title = "Tent"
    
    EditableItemView(
        item: $title,
        isPacked: true,
        togglePacked: { print("Toggle packed for \(title)") },
        deleteItem: { print("Delete item: \(title)") }
    )
    
    EditableItemView(
        item: $title,
        isPacked: false,
        togglePacked: { print("Toggle packed for \(title)") },
        deleteItem: { print("Delete item: \(title)") }
    )
    
}
