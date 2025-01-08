//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI


struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var packingList: PackingList // Binding to the SwiftData model
    @State private var isEditingTitle: Bool = false
    
    //placeholders
    @State private var location: String = "Yosemite National Park"
    @State private var weather: String = "H:75°F Low:60°F"
    
    var body: some View {
        // Section for Updating List Name
        VStack {
            HStack {
                HStack {
                    Spacer()
                    TextField("New Packing List", text: $packingList.title)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .offset(x: 5)
                    Menu {
                        Button("Edit Title") {
                            isEditingTitle.toggle()
                        }
                        Button("Edit Location") {
                            shareList()
                        }
                        Button(role: .destructive) {
                            deleteList()
                        } label: {
                            Label("Delete List", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .font(.title3)
                    }
                    Spacer()
                }//:HSTACK
                .sheet(isPresented: $isEditingTitle) {
                    EditTitleView(packingList: packingList)
                }
            }//:HSTACK
                Text(location)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: "cloud")
                    Text(weather)
                }//:HSTACK
            
        }//:VSTACK
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }
    
    func shareList() {
        print("Sharing the list!")
    }
    
    func deleteList() {
        print("Deleting the list!")
    }
    
}

struct EditTitleView: View {
    @Bindable var packingList: PackingList
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter new title", text: $packingList.title)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Title")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                        packingList.title = packingList.title.trimmingCharacters(in: .whitespacesAndNewlines)

                    }
                }
            }
        }
    }
}

#Preview {
    
    let sampleUserList = PackingList(title: "Summer List")
    ZStack {
        Color(.gray)
        ListDetailView(packingList: sampleUserList)
    }
}
