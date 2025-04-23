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
                    get: { item.title ?? "" },
                    set: { item.title = $0 }))
                .focused($isFocused)
                .foregroundStyle(item.isPacked ? Color.secondary : .primary)
                .strikethrough(item.isPacked)
                .italic(item.isPacked)
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
        .modifier(SwipeActionModifier(
            isFocused: disableSwipe,
            isList: isList,
            deleteAction: deleteItem))
        
    }//:BODY
    
}
//
//#if DEBUG
//#Preview {
//    let context = PersistenceController.preview.persistentContainer.viewContext
//    let item = RestockItem(context: context, title: "Sleeping Bag", position: 0)
//    
//    EditableItemView(
//        item: item,
//        isList: false,
//        togglePacked: { },
//        deleteItem: { }
//    )
//    .environment(\.managedObjectContext, context)
//}
//#endif
