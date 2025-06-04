//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import CoreData

protocol EditablePackableItem: ObservableObject {
    var title: String? { get set }
    var isPacked: Bool { get set }
    var quantity: Int64 { get set }
}

struct EditableItemView<T: EditablePackableItem>: View {
    
    @ObservedObject var item: T
    @State private var disableSwipe = false
    @FocusState var isFocused: Bool
    let togglePacked: () -> Void
    let deleteItem: () -> Void
    @Binding var isPickerFocused: Bool

    
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
                        .accessibilityLabel("Check or uncheck circle to mark item as packed")
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                .accessibilityHint("Check or uncheck to mark item as packed")
                
                TextField("Item Name", text: Binding(
                    get: { item.title ?? "" },
                    set: { item.title = $0 }),
                          axis: .vertical
                )
                .focused($isFocused)
                .fontWeight(.light)
                .foregroundStyle(item.isPacked ? Color.secondary : .primary)
                .strikethrough(item.isPacked)
                .italic(item.isPacked)
                .onSubmit {
                    isFocused = false
                    disableSwipe = false
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isPickerFocused = false
                        disableSwipe = true
                    }
                )
                
                if isFocused {
                    Button {
                        isFocused = false
                        disableSwipe = false
                    } label: {
                        Text("Done")
                    }
                } else {
                    
                    
                    CollapsableStepperView(
                        value: Binding(
                            get: { Int(item.quantity) },
                            set: { item.quantity = Int64($0)
                                saveContext(for: item as! NSManagedObject)
                            }
                        ),
                        range: 0...999,
                        isPickerFocused: $isPickerFocused)
                    }
                
            }//:HSTACK
        }//:ZSTACK
        .padding(.horizontal)
        .padding(.vertical, 8)
        //MARK: - SWIPE TO DELETE
        .modifier(SwipeActionModifier(
            isFocused: disableSwipe,
            deleteAction: deleteItem))
        
    }//:BODY
    
    private func saveContext(for item: NSManagedObject) {
        do {
            try item.managedObjectContext?.save()
        } catch {
            
        }
    }
    
}

#if DEBUG
#Preview {
    @Previewable @State var isPickerFocused = false
    
    let previewStack = CoreDataStack.preview
    let item = RestockItem(context: previewStack.context, title: "Sleeping Bag", position: 0)
    let item2 = RestockItem(context: previewStack.context, title: "Tent really long test name to see if thsi will keep going wow", position: 0)
    
    VStack {
        EditableItemView(
            item: item,
            togglePacked: { },
            deleteItem: { },
            isPickerFocused: $isPickerFocused,
        )
        EditableItemView(
            item: item2,
            togglePacked: { },
            deleteItem: { },
            isPickerFocused: $isPickerFocused,
        )
    }
    .frame(height: 100)
    .environment(\.managedObjectContext, previewStack.context)
}
#endif
