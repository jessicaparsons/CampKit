//
//  RemindersView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import CoreData

struct RemindersView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var viewModel: RemindersViewModel
    @State private var isAddNewReminderAlertShowing: Bool = false
    @State private var editReminder: Reminder?
    
    @FetchRequest(
        sortDescriptors: []) var reminderItems: FetchedResults<Reminder>
    
    @State private var newReminderTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    private var isFormValid: Bool {
        !newReminderTitle.isEmptyOrWhiteSpace
    }
    
    init(context: NSManagedObjectContext) {
        self.viewModel = RemindersViewModel(context: context)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            GradientTanBackgroundView()
            
            //MARK: - EMPTY VIEW
            if reminderItems.isEmpty {
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
                        ForEach(reminderItems) { reminder in
                            ReminderListItemView(
                                reminder: reminder,
                                isSelected: false) { event in
                                    switch event {
                                    case .onChecked(let reminder, let checked): print("OnChecked")
                                    case .onSelect(let reminder):
                                        print("onSelect")
                                    case .onInfoSelected(let reminder):
                                        print("onInfoSelected")
                                    }
                                }
                        }//:FOREACH
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewContext.delete(reminderItems[index])
                            }
                            save(viewContext)
                        }
                    }
                }//:LIST
                .animation(.easeInOut, value: reminderItems.count)
            }
        }//:ZSTACK
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
        //MARK: - ADD NEW ITEM ALERT
        .alert("Add New Reminder", isPresented: $isAddNewReminderAlertShowing) {
            
            TextField("New Reminder", text: $newReminderTitle)
            
            Button("Done", action: {
                if isFormValid {
                    let newReminder = (Reminder(
                        context: viewContext,
                        title: newReminderTitle))
                    
                    try? viewContext.save()
                    newReminderTitle = ""
                }
                isAddNewReminderAlertShowing = false
                
            })
            .disabled(!isFormValid)
            
            Button("Cancel", role: .cancel) { }
        }
        
        
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if editMode == .inactive {
                        // REARRANGE BUTTON
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                        // ADD BUTTON
                        Button {
                            isAddNewReminderAlertShowing = true
                            
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
    
    let context = PersistenceController.preview.container.viewContext
    
    NavigationStack {
        RemindersView(context: context)
    }
    .environment(\.managedObjectContext, context)
    
}



