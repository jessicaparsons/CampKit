//
//  UpdateReminderView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import SwiftUI

struct UpdateReminderView: View {
    
    @Environment(\.dismiss) private var dismiss
    var reminder: ReminderItem
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Reminder Name", text: Binding(
                    get: { reminder.title },
                    set: { reminder.title = $0 })
                )
            }
            .navigationTitle("Update Reminder")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            
        }//:NAVIGATION STACK
    }
}

#Preview {
    UpdateReminderView(reminder: ReminderItem(title: "Charge batteries"))
}
