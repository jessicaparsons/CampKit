//
//  UpdateReminderView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import SwiftUI

struct UpdateReminderView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: RemindersViewModel
    
    var reminder: Reminder? = nil
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var reminderDate: Date = .now
    @State private var reminderTime: Date = .now
    
    @State private var showCalendar: Bool = false
    @State private var showTime: Bool = false
    @Binding var dataRefreshTrigger: Bool
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhiteSpace
    }
    
    var minAllowedTime: Date {
        if Calendar.current.isDateInToday(reminderDate) {
            return Date() // Now
        } else {
            // Use the start of selected date to allow any time
            return Calendar.current.startOfDay(for: reminderDate)
        }
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Reminder Name", text: $title)
                    TextField("Notes", text: $notes)
                }//:SECTION
                .listRowBackground(Color.colorWhite)
                
                Section {
                    HStack {
                        
                        Image(systemName: "calendar")
                            .foregroundStyle(.primary)
                            .font(.title2)
                            .accessibilityLabel("Select date")
                        Text("Select Date")
                            .foregroundStyle(.primary)
                        
                        Toggle(isOn: $showCalendar) {
                            EmptyView()
                        }
                        .tint(.colorSage)
                    }//:HSTACK
                    
                    if showCalendar {
                        DatePicker("", selection: $reminderDate, in: Date()..., displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.primary)
                            .font(.title2)
                            .accessibilityLabel("Select time")
                        Text("Select Time")
                            .foregroundStyle(.primary)
                        
                        Toggle(isOn: $showTime) {
                            EmptyView()
                        }
                        .tint(.colorSage)
                        
                    }//:HSTACK
                    
                    if showTime {
                        DatePicker(
                            "",
                            selection: $reminderTime,
                            in: minAllowedTime...,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                    
                }//:SECTION
                .listRowBackground(Color.colorWhite)
                
            }//:FORM
            .navigationTitle(reminder == nil ? "New Reminder" : "Update Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.colorWhiteSandsSheet)
            .onAppear {
                title = reminder?.title ?? "New Reminder"
                notes = reminder?.notes ?? ""
                reminderDate = reminder?.reminderDate ?? Date()
                reminderTime = reminder?.reminderTime ?? Date()
                showCalendar = reminder?.reminderDate != nil
                showTime = reminder?.reminderTime != nil
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        
                        let isNew = reminder == nil
                        let currentReminder = reminder ?? Reminder(context: viewContext)
                            
                        viewModel.updateReminder(
                            isNew: isNew,
                            currentReminder: currentReminder,
                            title: title,
                            notes: notes,
                            showCalendar: showCalendar,
                            showTime: showTime,
                            reminderDate: reminderDate,
                            reminderTime: reminderTime)
                        
                        dismiss()
                    }
                    .disabled(!isFormValid)
                    .accessibilityHint("Done editing reminder")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        dataRefreshTrigger.toggle()
                    }
                    .accessibilityHint("Cancel editing reminder")
                }
            }
            
        }//:NAVIGATION STACK
    }

}

#if DEBUG
#Preview {
    
    @Previewable @State var dataRefresh: Bool = false
    
    do {
        let previewStack = CoreDataStack.preview
                
        Reminder.generateSampleReminders(context: previewStack.context)
        try? previewStack.context.save()
        
        return NavigationStack {
            UpdateReminderView(
                viewModel: RemindersViewModel(context: previewStack.context),
                dataRefreshTrigger: $dataRefresh
            )
            .environment(\.managedObjectContext, previewStack.context)
        }
    }
    
}
#endif

#if DEBUG
#Preview("Blank") {
    
    @Previewable @State var dataRefresh: Bool = false
    
    do {
        let previewStack = CoreDataStack.preview
                
        
        return NavigationStack {
            UpdateReminderView(
                viewModel: RemindersViewModel(context: previewStack.context),
                dataRefreshTrigger: $dataRefresh
            )
            .environment(\.managedObjectContext, previewStack.context)
        }
    }
    
}
#endif
