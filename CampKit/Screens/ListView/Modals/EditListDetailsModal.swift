//
//  EditListScreen.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/9/25.
//
import SwiftUI
import SwiftData

struct EditListDetailsModal: View {
    @Bindable var packingList: PackingList
    @Environment(\.dismiss) var dismiss
    @State var isLocationSearchOpen: Bool = false
    @State private var locationNamePlaceholder: String = ""
    @State private var locationAddressPlaceholder: String = ""
    
    private var fullLocation: String {
        if locationNamePlaceholder != "" {
            return locationNamePlaceholder + ", " + locationAddressPlaceholder
        } else {
            return "Add Location"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Edit List Details")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Form {
                    Section("Title") {
                        TextField("Enter new title", text: $packingList.title)
                            .multilineTextAlignment(.leading)
                    }
                    Section("Location") {
                        Text(fullLocation)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .onTapGesture {
                                isLocationSearchOpen = true
                            }
                    }
                }//:FORM
                .onAppear {
                    locationNamePlaceholder = packingList.locationName ?? ""
                    locationAddressPlaceholder = packingList.locationAddress ?? ""
                }
                .scrollContentBackground(.hidden)
                
                //MARK: - LOCATION SEARCH
                .fullScreenCover(isPresented: $isLocationSearchOpen, content: {
                    
                    VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                        LocationSearchView(locationName: $locationNamePlaceholder,
                                           locationAddress: $locationAddressPlaceholder,
                                           isLocationSearchOpen: $isLocationSearchOpen)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.3), value: isLocationSearchOpen)
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            packingList.title = packingList.title.trimmingCharacters(in: .whitespacesAndNewlines)
                            packingList.locationName = locationNamePlaceholder.trimmingCharacters(in: .whitespacesAndNewlines)
                            packingList.locationAddress = locationAddressPlaceholder.trimmingCharacters(in: .whitespacesAndNewlines)
                            dismiss()
                        }
                    }
                }//:TOOLBAR
            }//:VSTACK
            .background(Color.colorTan)
        }//:NAVIGATIONSTACK
        
    }
}


#Preview {
    let sampleUserList = PackingList(title: "Summer List with a verylong anme", locationName: "Another very long location name and it will wrap around because it is long")
    NavigationStack {
        EditListDetailsModal(
            packingList: sampleUserList
        )
    }
}
