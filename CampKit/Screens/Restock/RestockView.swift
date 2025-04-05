//
//  RestockView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct RestockView: View {
    
    @Query(sort: \RestockItem.dateCreated, order: .forward) private var restockItem: [RestockItem]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    GradientHeaderView(label: "Restock")
                    
                    if restockItem.isEmpty {
                        VStack(spacing: Constants.verticalSpacing) {
                            LazyVStack {
                                ContentUnavailableView("Empty List", systemImage: "arrow.clockwise.circle", description: Text("You haven't created any restock items yet. Get started!"))
                                    .padding(.top, Constants.emptyContentSpacing)
                            }//:LAZYVSTACK
                            //addNewItemButton
                            Spacer()
                        }//:VSTACK
                    } else {
                        List {
                            ForEach(restockItem) { item in
                                Text(item.title)
                            }
                        }
                    }
                }//:VSTACK
                .navigationTitle("Restock")
                .navigationBarHidden(true)
                .scrollContentBackground(.hidden)
                .background(Color.customTan)
                .ignoresSafeArea(edges: .top)
                
                HStack {
                    Spacer()
                    addNewItemButton
                }
                .padding()
            }//:ZSTACK
        }//:NAVIGATION STACK
    }
    
    //MARK: - ADD NEW ITEM BUTTON
    
    private var addNewItemButton: some View {
        
        Button {
            
        } label: {
            BigButtonLabel(label: "Add Item")
        }
        .buttonStyle(BigButton())
        
    }//:ADDNEWLISTBUTTON
    
}

#Preview {
    let container = try! ModelContainer(for: RestockItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    for item in RestockItem.restockItems {
        container.mainContext.insert(item)
    }

        
    return NavigationStack {
        RestockView()
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
    }
}

#Preview("Empty") {
    RestockView()
}
