//
//  RemindersView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI

struct RemindersView: View {
    
    @StateObject private var viewModel: RestockViewModel
    @State private var isAddNewReminderShowing: Bool = false
    @State private var newReminderTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    init(viewModel: RestockViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            GradientTanBackgroundView()
            
            //MARK: - EMPTY VIEW
            if viewModel.restockItems.isEmpty {
                ScrollView {
                    ContentUnavailableView("Empty List", systemImage: "bell.circle", description: Text("""
You haven't created any reminders yet. 
Hit the \"+\" to get started!
"""))
                    .padding(.top, Constants.emptyContentSpacing)
                    
                }//:SCROLLVIEW
            } else {
                //MARK: - RESTOCK LIST
                List {
                    
                    Section(header:
                                Color.clear
                        .frame(height: 1)//Top Spacing
                    ) {
                        //FOREACH
                    }
                }//:LIST
                //.animation(.easeInOut, value: viewModel.restockItems.count)
            }
        }//:ZSTACK
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
        .onTapGesture {
            hideKeyboard()
        }
        .task {
//            do {
//                viewModel.restockItems = try viewModel.fetchRestockItems()
//            } catch {
//                print("Failed to fetch items")
//            }
        }
        //MARK: - ADD NEW ITEM POP UP
//        .alert("Add New Reminder", isPresented: $isAddNewReminderShowing) {
//            TextField("New restock item", text: $newReminderTitle)
//            Button("Add Item", action: {
//                if newItemTitle != "" {
//                    viewModel.addNewReminder(title: newReminderTitle)
//                    newItemReminder = ""
//                }
//                isAddNewReminderShowing = false
//            })
//            Button("Cancel", role: .cancel) { }
//        }
        .environment(\.editMode, $editMode)
        
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if editMode == .inactive {
                        // REARRANGE BUTTON
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.body)
                        }
                        // ADD BUTTON
                        Button {
                            isAddNewReminderShowing = true
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Text("Done")
                        }
                    }
                }//:HSTACK
                .foregroundStyle(Color.primary)
            }//:TOOL BAR ITEM
        }//:TOOLBAR
    }
}

#Preview("Empty") {
    
    let container = PreviewContainer.shared

    
    return NavigationStack {
        RemindersView(viewModel: RestockViewModel(modelContext: container.mainContext))
            .modelContainer(container)
            .environment(\.modelContext, container.mainContext)
    }
}



