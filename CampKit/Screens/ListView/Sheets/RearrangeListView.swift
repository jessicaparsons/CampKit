//
//  RearrangeListView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//

import SwiftUI

struct RearrangeListView<T: Identifiable  & Equatable>: View {
    
    @Environment(\.dismiss) private var dismiss

    let items: [T]
    let label: (T) -> String
    let moveAction: (IndexSet, Int) -> Void

    var body: some View {
        NavigationStack {
                List {
                    
                    ForEach(items) { item in
                        Text(label(item))
                            .font(.headline)
                    }
                    .onMove(perform: moveAction)
                }//:LIST
                .environment(\.editMode, .constant(.active)) // Enable edit mode for reordering
                .scrollContentBackground(.hidden)
                .navigationTitle("Reorder")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.colorWhiteSands)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                           dismiss()
                        }
                    }
                }
        }//:NAVIGATION STACK
        
    }
}
#if DEBUG
#Preview {
    
    let previewStack = CoreDataStack.preview
    
    let samplePackingList = PackingList.samplePackingList(context: previewStack.context)
    

    NavigationStack {
        RearrangeListView(items: samplePackingList.sortedCategories, label: { $0.name }, moveAction: {_,_ in })
        
       
    }
    
}
#endif
