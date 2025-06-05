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
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isShowingCompletedReminders") private var isShowingCompleted: Bool = false
    @AppStorage("selectedRemindersSort") private var selectedSort: String = "Date"
    
    @State var viewModel: RemindersViewModel
    @State private var selectedReminder: Reminder?
    
    @State private var isAddNewReminderAlertPresented: Bool = false
    @State private var showReminderEditScreen: Bool = false
    @State private var dataRefreshTrigger = false
    @Binding var isSettingsPresented: Bool

    @State private var scrollOffset: CGFloat = 0
    
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
    
    init(context: NSManagedObjectContext, isSettingsPresented: Binding<Bool>) {
        _viewModel = State(wrappedValue: RemindersViewModel(context: context))
        _isSettingsPresented = isSettingsPresented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            Color.colorWhiteSands
                .ignoresSafeArea()
            
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Text("Add a reminder for tasks and items you don’t want to forget")
                        .multilineTextAlignment(.leading)
                        .padding(.top, Constants.headerSpacing)
                        .padding(.bottom)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, Constants.wideMargin)
                    
                    //MARK: - EMPTY VIEW
                    if reminderItems.isEmpty {
                        
                        Button {
                            isAddNewReminderAlertPresented = true
                        } label: {
                            AddNewReminderButtonView()
                        }
                        .padding(.horizontal)
                        
                        EmptyContentView(
                            icon: "alarm",
                            description: "You haven't set any reminders yet")
                        
                        
                    } else {
                        //MARK: - RESTOCK LIST
                        LazyVStack {
                            ForEach(reminderItems) { reminder in
                                ReminderListItemView(
                                    reminder: reminder,
                                    isSelected: isSelectedReminder(reminder),
                                    onDelete: {
                                        viewContext.delete(reminder)
                                        save(viewContext)
                                        dataRefreshTrigger.toggle()
                                    }
                                ) { event in
                                        switch event {
                                        case .onChecked(let reminder, let checked): reminder.isCompleted = checked
                                            dataRefreshTrigger.toggle()
                                        case .onSelect(let tappedReminder):
                                            if selectedReminder == tappedReminder {
                                                selectedReminder = nil
                                            } else {
                                                selectedReminder = tappedReminder
                                            }
                                        case .onInfoSelected(let reminder):
                                            showReminderEditScreen = true
                                            selectedReminder = reminder
                                        }
                                    }
                            }//:FOREACH
                        }//:LAZYVSTACK
                        .animation(.easeInOut, value: reminderItems.count)
                        
                        Button {
                            isAddNewReminderAlertPresented = true
                        } label: {
                            AddNewReminderButtonView()
                        }
                        .padding(.horizontal)
                        
                    }//:ELSE
                    
                }//:VSTACK
                .padding(.bottom, Constants.bodyPadding)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .frame(height: 0)
                            .onChange(of: geo.frame(in: .global).minY) {
                                scrollOffset = geo.frame(in: .global).minY
                            }
                    }
                )//NAV BAR UI CHANGES ON SCROLL
            }//:SCROLLVIEW
            .scrollIndicators(.hidden)
            
            
            //MARK: - HEADER
            
            HeaderView(
                title: "Reminders",
                scrollOffset: $scrollOffset,
                scrollThreshold: -70
            )
            
            
            
        }//:ZSTACK
        .toolbar {
            reminderToolBar
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.editMode, $editMode)
        //MARK: - ADD NEW ITEM SHEET
        .sheet(isPresented: $isAddNewReminderAlertPresented, content: {
            NavigationStack {
                UpdateReminderView(viewModel: viewModel,
                                   dataRefreshTrigger: $dataRefreshTrigger)
            }
        })
        //MARK: - EDIT REMINDER SHEET
        .sheet(isPresented: $showReminderEditScreen, content: {
            if let selectedReminder {
                NavigationStack {
                    UpdateReminderView(
                        viewModel: viewModel,
                        reminder: selectedReminder,
                        dataRefreshTrigger: $dataRefreshTrigger)
                }
            }
        })
    }
    
    //MARK: - MENU
    private var reminderToolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                    Menu {
                        //SORT BY
                        Label("Sort By", systemImage: "arrow.up.arrow.down")
                        
                        Button {
                            withAnimation {
                                selectedSort = "Date"
                            }
                        } label: {
                            if selectedSort == "Date" {
                                Label("Date", systemImage: "checkmark")
                            } else {
                                Text("Date")
                            }
                        }
                        Button {
                            withAnimation {
                                selectedSort = "Name"
                            }
                        } label: {
                            if selectedSort == "Name" {
                                Label("Name", systemImage: "checkmark")
                            } else {
                                Text("Name")
                            }
                        }
                        Divider()
                        
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
                            .accessibilityLabel("Menu")
                    }
                    
                        
                    Button {
                        isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.colorForestSecondary)
                                .accessibilityLabel("Settings")
                    }

            }//:HSTACK
            .foregroundStyle(Color.primary)
            
        }//:TOOL BAR ITEM
    }//:TOOLBAR

    
    
    
}
#if DEBUG
#Preview() {
    
    @Previewable @State var isSettingsPresented: Bool = false
    
    do {
        let previewStack = CoreDataStack.preview
        
        // Reset the AppStorage value BEFORE view init
        UserDefaults.standard.set(false, forKey: "isShowingCompletedReminders")
        
        Reminder.generateSampleReminders(context: previewStack.context)
        try? previewStack.context.save()
        
        return NavigationStack {
            RemindersView(context: previewStack.context, isSettingsPresented: $isSettingsPresented)
                .environment(\.managedObjectContext, previewStack.context)
        }
    }
    
    
}
#endif


#if DEBUG
#Preview("Blank") {
    
    @Previewable @State var isSettingsPresented: Bool = false

    do {
        let previewStack = CoreDataStack.preview
        
        // Reset the AppStorage value BEFORE view init
        UserDefaults.standard.set(false, forKey: "isShowingCompletedReminders")
        
        return NavigationStack {
            RemindersView(context: previewStack.context, isSettingsPresented: $isSettingsPresented)
                .environment(\.managedObjectContext, previewStack.context)
        }
    }
    
}
#endif
