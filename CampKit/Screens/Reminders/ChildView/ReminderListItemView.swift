//
//  ReminderListItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import SwiftUI

enum ReminderCellEvents {
    case onChecked(ReminderItem, Bool)
    case onSelect(ReminderItem)
    case onInfoSelected(ReminderItem)
}

struct ReminderListItemView: View {
    
    @FocusState private var isFocused: Bool
    
    var reminder: ReminderItem
    let isSelected: Bool
    let onEvent: (ReminderCellEvents) -> Void
    @State private var isChecked: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
             
            Image(systemName: "circle")
                .font(.system(size: 22))
                .padding(.trailing, Constants.lineSpacing)
                .onTapGesture {
                    isChecked.toggle()
                    onEvent(.onChecked(reminder, isChecked))
                    HapticsManager.shared.triggerLightImpact()
                }
 
//                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    //.foregroundStyle(item.isPacked ? Color.colorSage : .secondary)
                
            VStack {
                Text(reminder.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let notes = reminder.notes {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    if let reminderDate = reminder.reminderDate {
                        Text(reminderDate.formatted())
                    }
                    if let reminderTime = reminder.reminderTime {
                        Text(reminderTime.formatted())
                    }
                }//:HSTACK
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            Image(systemName: "info.circle.fill")
                .opacity(isSelected ? 1 : 0)
                .onTapGesture {
                    onEvent(.onSelect(reminder))
                }
            
        }//:HSTACK
        .contentShape(Rectangle())//makes entire row clickable
        .onTapGesture {
            onEvent(.onSelect(reminder))
        }
    }
}


#Preview {
    
    let reminder = ReminderItem(title: "Recharge batteries", notes: "Get Ollie's Collar", reminderDate: Date(), reminderTime: Date())
                                
    ReminderListItemView(reminder: reminder, isSelected: false, onEvent: { _ in })
}
