//
//  EditableItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI
import SwiftData

struct EditableItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    let onDelete: (Item) -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        ZStack {
            // Background for delete action
            HStack {
                Spacer()
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .font(.footnote)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.red)
            }
            .opacity(isSwiping ? 1 : 0) // Only show during swipe
            
            // Foreground content
            HStack {
                Button(action: {
                    // Toggle completion state
                    item.isPacked.toggle()
                }) {
                    Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isPacked ? .green : .gray)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent button from triggering NavigationLink
                
                TextField("Item Name", text: $item.title)
                    .foregroundColor(textColor(for: item))
                    .strikethrough(item.isPacked)
                    .italic(item.isPacked)
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if isSwiping || gesture.translation.width < 0 {
                            isSwiping = true
                            offset = min(gesture.translation.width, 0) // Limit to left swipe
                        }
                    }
                    .onEnded { _ in
                        if offset < -100 { // Threshold for delete
                            withAnimation {
                                onDelete(item)
                            }
                        } else {
                            withAnimation {
                                offset = 0
                                isSwiping = false
                            }
                        }
                    }
            )
            .padding(.vertical, 5)
        }
    }
}


#Preview {
    // Create an in-memory ModelContainer
    let container = try! ModelContainer(
        for: Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Create a sample item
    let sampleItem = Item(title: "Tent")
    container.mainContext.insert(sampleItem) // Insert it into the context
    
    // Return the view
    return ZStack {
        Color(.colorTan)
        EditableItemView(item: sampleItem) { deletedItem in
            print("Deleted item: \(deletedItem.title)")
        }
        .modelContainer(container)
    }
}
