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
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
        ZStack {
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
        EditableItemView(item: sampleItem)
        }
        .modelContainer(container)
    }

