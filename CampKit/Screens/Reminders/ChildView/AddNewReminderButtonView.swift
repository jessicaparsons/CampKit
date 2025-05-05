//
//  AddNewReminderButtonView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/4/25.
//

import SwiftUI

struct AddNewReminderButtonView: View {
    var body: some View {
        
        
        HStack {
            Image(systemName: "plus.circle")
                .foregroundColor(.secondary)
                .font(.system(size: 22))
            Text("Add new reminder")
                .foregroundColor(.secondary)
            Spacer()
            
        }//:HSTACK
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.colorWhite)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    AddNewReminderButtonView()
}
