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
    
    @State private var offset: CGFloat = 0
    @State private var willDelete = false
    private let deletionThreshold: CGFloat = 120
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        ZStack {
            
            // Background for delete action
            HStack {
                Spacer()
                Rectangle()
                    .fill(Color.red)
                    .frame(width: abs(offset)) // Show background width based on drag distance
                    .overlay(
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: trashIconSize()))
                            .padding(.trailing, 16),
                        alignment: .trailing
                    )
            }
            
            // Foreground for list item
            HStack {
                Button(action: {
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
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(Color.white) // Prevent bleed-through from red background
            .cornerRadius(5)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 { // Dragging to the left
                            offset = gesture.translation.width
                            let newWillDelete = abs(offset) > deletionThreshold
                            if newWillDelete != willDelete { // Only trigger feedback on state change
                                willDelete = newWillDelete
                                if willDelete {
                                    hapticFeedback.notificationOccurred(.warning)
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        if willDelete {
                            deleteItem()
                            hapticFeedback.notificationOccurred(.success)
                        } else {
                            withAnimation {
                                offset = 0 // Reset position if not deleted
                            }
                        }
                    }
            )
            .animation(.spring(), value: offset)
        }//:ZSTACK
        
    }//:BODY
    
    private func trashIconSize() -> CGFloat {
        let baseSize: CGFloat = 18
        let maxSize: CGFloat = 24
        let scaleFactor = min(abs(offset) / deletionThreshold, 1.0) // Max scale is 1.0
        return baseSize + (maxSize - baseSize) * scaleFactor
    }
    
    private func deleteItem() {
        withAnimation {
            modelContext.delete(item)
            do {
                try modelContext.save()
                print("Item deleted successfully.")
            } catch {
                print("Failed to delete item: \(error.localizedDescription)")
            }
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
        EditableItemView(item: sampleItem)
        }
        .modelContainer(container)
    }

