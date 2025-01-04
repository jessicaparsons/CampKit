//
//  ChipButtonList.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI

struct ChipButtonList: View {
    @Binding var isCollapsed: Bool
    @Binding var isReordering: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Collapse/Expand Button
                Button(action: {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }) {
                    ChipButtonLabel(
                        text: isCollapsed ? "Expand All" : "Collapse All",
                        icon: isCollapsed ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle"
                    )
                }
                
                
                // Reorder Button
                Button(action: {
                    isReordering.toggle()
                }) {
                    ChipButtonLabel(
                        text: isReordering ? "Done" : "Reorder",
                        icon: "arrow.up.arrow.down.circle"
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// A helper view to style the chip buttons
struct ChipButtonLabel: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .font(.footnote)
        .tint(.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10) // Border
                .stroke(Color.gray, lineWidth: 2) // Customize color and width
        )
    }
}

#Preview {
    @Previewable @State var isReordering = false
    @Previewable @State var isCollapsed = false
    
    ChipButtonList(
        isCollapsed: $isCollapsed,
        isReordering: $isReordering
    )
}
