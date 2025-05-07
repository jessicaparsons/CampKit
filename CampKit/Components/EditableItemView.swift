//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI

protocol EditablePackableItem: ObservableObject {
    var title: String? { get set }
    var isPacked: Bool { get set }
}

struct EditableItemView<T: EditablePackableItem>: View {
    
    @ObservedObject var item: T
    @State private var disableSwipe = false
    @FocusState var isFocused: Bool
    var isList: Bool
    let togglePacked: () -> Void
    let deleteItem: () -> Void
    @Binding var isPickerFocused: Bool
    
    @State private var quantity: Int = 0

    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    togglePacked()
                    HapticsManager.shared.triggerLightImpact()
                    isPickerFocused = false
                        
                }) {
                    Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isPacked ? Color.colorSage : .secondary)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: Binding(
                    get: { item.title ?? "" },
                    set: { item.title = $0 }))
                .focused($isFocused)
                .fontWeight(.light)
                .foregroundStyle(item.isPacked ? Color.secondary : .primary)
                .strikethrough(item.isPacked)
                .italic(item.isPacked)
                .onSubmit {
                    isFocused = false
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isPickerFocused = false
                    }
                )
                
                if isFocused {
                    Button {
                        isFocused = false
                    } label: {
                        Text("Done")
                    }
                }
                
                
                CollapsableStepperView(
                    value: $quantity,
                    range: 0...999,
                    isPickerFocused: $isPickerFocused)
            
                
            }//:HSTACK
        }//:ZSTACK
        .padding(.horizontal)
        .padding(.vertical, 8)
        //MARK: - SWIPE TO DELETE
        .modifier(SwipeActionModifier(
            isFocused: disableSwipe,
            isList: isList,
            deleteAction: deleteItem))
        
    }//:BODY
    
}

#if DEBUG
#Preview {
    @Previewable @State var isPickerFocused = false
    
    let previewStack = CoreDataStack.preview
    let item = RestockItem(context: previewStack.context, title: "Sleeping Bag", position: 0)
    let item2 = RestockItem(context: previewStack.context, title: "Tent", position: 0)
    
    VStack {
        EditableItemView(
            item: item,
            isList: false,
            togglePacked: { },
            deleteItem: { },
            isPickerFocused: $isPickerFocused,
        )
        EditableItemView(
            item: item2,
            isList: false,
            togglePacked: { },
            deleteItem: { },
            isPickerFocused: $isPickerFocused,
        )
    }
    .frame(height: 100)
    .environment(\.managedObjectContext, previewStack.context)
}
#endif
