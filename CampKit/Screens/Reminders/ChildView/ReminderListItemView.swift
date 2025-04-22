//
//  ReminderListItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import SwiftUI

enum ReminderCellEvents {
    case onChecked(Reminder, Bool)
    case onSelect(Reminder)
    case onInfoSelected(Reminder)
}

struct ReminderListItemView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var isFocused: Bool
    
    var reminder: Reminder
    let isSelected: Bool
    let onEvent: (ReminderCellEvents) -> Void
    @State private var isChecked: Bool = false
    let delay = Delay()
    
    var isTitleOnly: Bool {
        reminder.notes == nil && reminder.reminderDate == nil && reminder.reminderTime == nil
    }
    
    var body: some View {
        HStack(alignment: .top) {
            
             //MARK: - CHECK MARK BUBBLE
            Image(systemName: isChecked || reminder.isCompleted ? "inset.filled.circle" : "circle")
                .foregroundStyle(isChecked || reminder.isCompleted ? Color.colorSage : .secondary)
                .font(.system(size: 22))
                .padding(.trailing, Constants.lineSpacing)
                .onTapGesture {
                    Task {
                        // Immediate UI feedback
                        isChecked.toggle()
                        HapticsManager.shared.triggerLightImpact()

                        if reminder.isCompleted {
                            await MainActor.run {
                                onEvent(.onChecked(reminder, isChecked))
                                save(viewContext)
                            }
                        } else {
                            // Delay, then send event back on main thread
                            await delay.performWork {
                                await MainActor.run {
                                    onEvent(.onChecked(reminder, isChecked))
                                    save(viewContext)
                                }
                            }
                        }
                    }
                }
                //MARK: - REMINDER INFO
            VStack {
                Text(reminder.title ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let notes = reminder.notes {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    if let reminderDate = reminder.reminderDate {
                        Text(formatReminderDate(reminderDate))
                    }
                    if let reminderTime = reminder.reminderTime {
                        Text(reminderTime, style: .time)
                    }
                }//:HSTACK
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            //MARK: - INFO ICON
            Spacer()
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.colorSage)
                .opacity(isSelected ? 1 : 0)
                .onTapGesture {
                    onEvent(.onInfoSelected(reminder))
                }
            
        }//:HSTACK
        .padding(.vertical, isTitleOnly ? 6 : 0)
        .contentShape(Rectangle())//makes entire row clickable
        .onTapGesture {
            onEvent(.onSelect(reminder))
        }
    }
    
    private func formatReminderDate(_ date: Date) -> String {
        if date.isToday {
            return "Today"
        } else if date.isTomorrow {
            return "Tomorrow"
        } else {
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
}

#if DEBUG
#Preview {
    
    do {
        let context = PersistenceController.preview.container.viewContext
        
        let reminder = Reminder(context: context, title: "Recharge batteries", notes: "Get Ollie's Collar", reminderDate: Date(), reminderTime: Date())
        try? context.save()
        
        return ReminderListItemView(reminder: reminder, isSelected: true, onEvent: { _ in })
    }
}
#endif
