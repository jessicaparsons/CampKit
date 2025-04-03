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
    @State private var locationPlaceholder: String = ""
    
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
                    
                    Text(locationPlaceholder)
                        .multilineTextAlignment(.trailing)
                        .onTapGesture {
                            isLocationSearchOpen = true
                        }
                }
            }//:FORM
            .navigationTitle("Edit List Details")
            .onAppear {
                locationPlaceholder = packingList.locationName ?? "Enter Location"
            }
            //MARK: - LOCATION SEARCH
            .fullScreenCover(isPresented: $isLocationSearchOpen, content: {
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    LocationSearchView(location: $locationPlaceholder,
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
                        packingList.locationName = locationPlaceholder.trimmingCharacters(in: .whitespacesAndNewlines)
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
        EditListDetailsModal(
            packingList: sampleUserList
        )
    }
}
