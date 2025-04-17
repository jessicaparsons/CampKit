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
    @State var viewModel: RemindersViewModel
    @State private var isAddNewReminderAlertPresented: Bool = false
    @State private var selectedReminder: Reminder?
    @State private var showReminderEditScreen: Bool = false
    @AppStorage("isShowingCompletedReminders") private var isShowingCompleted: Bool = false
    @State private var selectedSort: String = "Date"
    @State private var dataRefreshTrigger = false

        
    var reminderItems: [Reminder] {
        _ = dataRefreshTrigger
        
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        
        request.sortDescriptors = selectedSort == "Date"
            ? [NSSortDescriptor(keyPath: \Reminder.reminderDate, ascending: true)]
            : [NSSortDescriptor(keyPath: \Reminder.title, ascending: true)]
        
        request.predicate = isShowingCompleted ? nil : NSPredicate(format: "isCompleted == NO")

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch failed:", error)
            return []
        }
    }
     
    @State private var newReminderTitle: String = ""
    @State private var editMode: EditMode = .inactive
    
    private var isFormValid: Bool {
        !newReminderTitle.isEmptyOrWhiteSpace
    }
    
    private func isSelectedReminder(_ reminder: Reminder) -> Bool {
        reminder.objectID == selectedReminder?.objectID
    }
    
    init(context: NSManagedObjectContext) {
        _viewModel = State(wrappedValue: RemindersViewModel(context: context))
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
                                isSelected: isSelectedReminder(reminder)) { event in
                                    switch event {
                                    case .onChecked(let reminder, let checked): reminder.isCompleted = checked
                                        dataRefreshTrigger.toggle()
                                    case .onSelect(let reminder):
                                        selectedReminder = reminder
                                    case .onInfoSelected(let reminder):
                                        showReminderEditScreen = true
                                        selectedReminder = reminder
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
        .sheet(isPresented: $isAddNewReminderAlertPresented, content: {
            let newReminder = Reminder(
                context: viewContext,
                title: "New Reminder",
                isCompleted: false)
            
                NavigationStack {
                    UpdateReminderView(reminder: newReminder, dataRefreshTrigger: $dataRefreshTrigger)
                
            }
        })
        .sheet(isPresented: $showReminderEditScreen, content: {
            if let selectedReminder {
                NavigationStack {
                    UpdateReminderView(reminder: selectedReminder, dataRefreshTrigger: $dataRefreshTrigger)
                }
            }
        })
        
        
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if editMode == .inactive {
                        Menu {
                            //SORT BY
                            Label("Sort By", systemImage: "arrow.up.arrow.down")
                                .font(.body)

                            Button {
                                withAnimation {
                                    selectedSort = "Date"
                                }
                            } label: {
                                Label("Date", systemImage: selectedSort == "Date" ? "checkmark" : "")
                            }
                            Button {
                                withAnimation {
                                    selectedSort = "Name"
                                }
                            } label: {
                                Label("Name", systemImage: selectedSort == "Name" ? "checkmark" : "")
                            }
                            Divider()
                            
                            // REARRANGE BUTTON
                            Button {
                                editMode = (editMode == .active) ? .inactive : .active
                            } label: {
                                Label("Delete Multiple", systemImage: "trash")
                                    .font(.body)
                            }
                            //SHOW / HIDE COMPLETED
                            Button {
                                isShowingCompleted.toggle()
                            } label: {
                                Label(isShowingCompleted ? "Hide Completed" : "Show Completed", systemImage: isShowingCompleted ? "eye.slash" : "eye")
                                    .font(.body)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                        // ADD BUTTON
                        Button {
                            isAddNewReminderAlertPresented = true
                            
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

#Preview() {
    do {
        let context = PersistenceController.preview.container.viewContext
        
        // Reset the AppStorage value BEFORE view init
        UserDefaults.standard.set(false, forKey: "isShowingCompletedReminders")
        
        Reminder.generateSampleReminders(context: context)
        try? context.save()
        
        return NavigationStack {
            RemindersView(context: context)
                .environment(\.managedObjectContext, context)
        }
    }
    
    
}



