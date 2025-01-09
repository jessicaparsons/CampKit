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
    @Binding var isEditingTitle: Bool
    
    //placeholders
    @State private var weather: String = "H:75°F Low:60°F"
    
    var body: some View {
        // Section for Updating List Name
        VStack {
            HStack {
                HStack {
                    Spacer()
                    Text(packingList.title)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                    Spacer()
                }//:HSTACK
                .sheet(isPresented: $isEditingTitle) {
                    EditListScreen(packingList: packingList)
                }
            }//:HSTACK
            Text(packingList.locationName ?? "No Location Set")
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
}



#Preview {
    
    @Previewable @State var isEditingTitle: Bool = false
    
    let sampleUserList = PackingList(title: "Summer List", locationName: "Joshua Tree")
    ZStack {
        Color(.gray)
        ListDetailView(packingList: sampleUserList, isEditingTitle: $isEditingTitle)
    }
}