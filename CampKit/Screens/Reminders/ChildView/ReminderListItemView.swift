//
//  ReminderListItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import SwiftUI

struct ReminderListItemView: View {
    var item: ReminderItem
    var onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(item.title)
        }//:HSTACK
        .contentShape(Rectangle())//makes entire row clickable
        .onTapGesture {
            onTap()
        }
    }
}


#Preview {
    ReminderListItemView(item: ReminderItem(title: "Recharge batteries"), onTap: {})
}
