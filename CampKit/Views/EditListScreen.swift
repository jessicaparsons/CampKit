//
//  EditListScreen.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//
import SwiftUI
import SwiftData

struct EditListScreen: View {
    @Bindable var packingList: PackingList
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            
            Form {
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("Enter new title", text: $packingList.title)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Location")
                    Spacer()
                    TextField(
                        "Enter location",
                        text: Binding(
                            get: { packingList.locationName ?? "" },        // Provide default empty string if nil
                            set: { packingList.locationName = $0.isEmpty ? nil : $0 } // Set to nil if empty
                        )
                    )
                    .multilineTextAlignment(.trailing)
                }

            }//:FORM
            .navigationTitle("Edit List Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        packingList.title = packingList.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        packingList.locationName = packingList.locationName?.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
            }//:TOOLBAR
        }
    }
}


#Preview {
    let sampleUserList = PackingList(title: "Summer List")
    NavigationStack {
        EditListScreen(
            packingList: sampleUserList
        )
    }
}
