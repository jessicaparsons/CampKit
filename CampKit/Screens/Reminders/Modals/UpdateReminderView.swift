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
    var reminder: Reminder
    
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
                
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.primary)
                            .font(.title2)
                        
                        Toggle(isOn: $showCalendar) {
                            EmptyView()
                        }
                        .tint(.colorSage)
                    }//:HSTACK
                    
                    if showCalendar {
                        DatePicker("Select Date", selection: $reminderDate, in: Date()..., displayedComponents: [.date])
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.primary)
                            .font(.title2)
                        Toggle(isOn: $showTime) {
                            EmptyView()
                        }
                        .tint(.colorSage)
                        
                    }//:HSTACK
                    .onChange(of: showTime) {
                        if showTime {
                            showCalendar = true
                        }
                    }
                    
                    if showTime {
                        DatePicker(
                            "Select Time",
                            selection: $reminderTime,
                            in: minAllowedTime...,
                            displayedComponents: .hourAndMinute
                        )
                    }
                    
                }//:SECTION
                
                
            }//:FORM
            .navigationTitle("Update Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.colorTan)
            .onAppear {
                title = reminder.title ?? "New Reminder"
                notes = reminder.notes ?? ""
                reminderDate = reminder.reminderDate ?? Date()
                reminderTime = reminder.reminderTime ?? Date()
                showCalendar = reminder.reminderDate != nil
                showTime = reminder.reminderTime != nil
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        updateReminder()
                        dismiss()
                    }.disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
        }//:NAVIGATION STACK
    }
    
    private func updateReminder() {
        reminder.title = title
        reminder.notes = notes.isEmpty ? nil : notes
        reminder.reminderDate = showCalendar ? reminderDate : nil
        reminder.reminderTime = showTime ? reminderTime : nil
        save(viewContext)
        dataRefreshTrigger.toggle()
    }
}

#Preview {
    
    @Previewable @State var dataRefresh: Bool = false
    
    do {
        let context = PersistenceController.preview.container.viewContext
        
        Reminder.generateSampleReminders(context: context)
        try? context.save()
        
        return NavigationStack {
            UpdateReminderView(
                reminder: Reminder(context: context, title: "Charge batteries"),
                dataRefreshTrigger: $dataRefresh
            )
            .environment(\.managedObjectContext, context)
        }
    }
    
}
