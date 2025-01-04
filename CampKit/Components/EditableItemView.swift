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
    
    private func textColor(for item: Item) -> Color {
        item.isPacked ? Color.accentColor : Color.primary
    }
    
    var body: some View {
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
        }//:HSTACK
    }
}

#Preview {
    EditableItemView(item: Item(title: "Tent"))
}
