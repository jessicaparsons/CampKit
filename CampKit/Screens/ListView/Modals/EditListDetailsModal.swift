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
    @State private var locationNamePlaceholder: String?
    @State private var locationAddressPlaceholder: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.colorTan
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    //MARK: - EDIT TITLE
                    Text("Edit Title")
                        .font(.footnote)
                        .fontWeight(.bold)
                    
                    TextField("Enter new title", text: $packingList.title)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(Color.colorWhite)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.colorSteel, lineWidth: 1)
                        }
                    
                    //MARK: - EDIT LOCATION
                    Text("Edit Location")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text(fullLocation)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(Color.colorWhite)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.colorSteel, lineWidth: 1)
                        }
                        .onTapGesture {
                            isLocationSearchOpen = true
                        }
                    //MARK: - SAVE CHANGES BUTTON
                    Button("Save Changes") {
                        packingList.title = packingList.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        packingList.locationName = locationNamePlaceholder?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        packingList.locationAddress = locationAddressPlaceholder?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        HapticsManager.shared.triggerSuccess()
                        dismiss()
                    }
                    .padding(.top)
                    .buttonStyle(BigButtonWide())
                    
                    Spacer()
                }//:VSTACK
                .navigationTitle("Edit List Details")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .onAppear {
                    locationNamePlaceholder = packingList.locationName
                    locationAddressPlaceholder = packingList.locationAddress
                }
                .scrollContentBackground(.hidden)
                
                //MARK: - LOCATION SEARCH VIEW
                .fullScreenCover(isPresented: $isLocationSearchOpen, content: {
                    
                    VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                        LocationSearchView(isLocationSearchOpen: $isLocationSearchOpen, locationName: $locationNamePlaceholder, locationAddress: $locationAddressPlaceholder)
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
                }//:TOOLBAR
            }//:ZSTACK
        }//:NAVIGATIONSTACK
        
    }//:BODY
    
    //MARK: - COMPUTED PROPERTIES
    
    private var fullLocation: String {
        if let locationName = locationNamePlaceholder {
            var fullLocation = locationName
            
            if let locationAddress = locationAddressPlaceholder {
                fullLocation += ", " + locationAddress
            }
            
            return fullLocation
        } else {
            return "Add Location"
        }
    }
}


#Preview {
    let sampleUserList = PackingList(title: "Summer List with a very long anme", locationName: "Joshua Tree, CA")
    NavigationStack {
        EditListDetailsModal(
            packingList: sampleUserList
        )
    }
}
