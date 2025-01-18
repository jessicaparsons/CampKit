//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListDetailCardView: View {
    @EnvironmentObject var viewModel: ListViewModel
    @Binding var isEditingTitle: Bool
    
    //placeholders
    @State private var weather: String = "H:75°F Low:60°F"
    
    var body: some View {
        // Section for Updating List Name
        VStack {
            HStack {
                HStack {
                    Spacer()
                    Text(viewModel.packingList.title)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                    Spacer()
                }//:HSTACK
                
            }//:HSTACK
            Text(viewModel.packingList.locationName ?? "No Location Set")
                .fontWeight(.bold)
            HStack {
                Image(systemName: "cloud")
                Text(weather)
            }//:HSTACK
            
        }//:VSTACK
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.colorWhite)
                .shadow(color: Color(hue: 1.0, saturation: 1.0, brightness: 0.079, opacity: 0.3), radius: 3, x: 0, y: 3)
        )
        .sheet(isPresented: $isEditingTitle) {
            EditListDetailsModal(packingList: viewModel.packingList)
        }
        .onTapGesture {
            isEditingTitle = true
        }
    }
}



#Preview {
        // Define a mock `isEditingTitle` state
        @Previewable @State var isEditingTitle: Bool = false
        
        // Create an in-memory ModelContainer
        let container = try! ModelContainer(
            for: PackingList.self, Category.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory for preview
        )
        
        // Populate the container with mock data
        preloadPackingListData(context: container.mainContext)
        
        // Fetch a sample PackingList
        let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
        
        // Create a mock ListViewModel
        let viewModel = ListViewModel(packingList: samplePackingList, modelContext: container.mainContext)
        
        // Return the preview
        return ListDetailCardView(isEditingTitle: $isEditingTitle)
            .modelContainer(container) // Provide the ModelContainer
            .environmentObject(viewModel) // Inject the mock ListViewModel
    
}
