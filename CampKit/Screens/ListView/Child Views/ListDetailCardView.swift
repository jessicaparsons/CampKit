//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListDetailCardView: View {
    @ObservedObject var viewModel: ListViewModel
    @Binding var isEditingTitle: Bool
        
    var body: some View {
        //MARK: - LIST NAME
        VStack(spacing: 6) {
            HStack {
                HStack {
                    Spacer()
                    Text(viewModel.packingList.title)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .lineLimit(3)
                        .truncationMode(.tail)
                    Spacer()
                }//:HSTACK
        //MARK: - LIST LOCATION
            }//:HSTACK
            Text(viewModel.packingList.locationName ?? "No Location Set")
            
        //MARK: - PROGRESS BAR
            GeometryReader { geo in
                HStack {
                    Spacer()
                    HStack {
                        ProgressView(value: packedRatio)
                            .progressViewStyle(LinearProgressViewStyle(tint: .colorNeon))
                            .animation(.easeInOut, value: packedRatio)
                    }//:HSTACK
                    .frame(width: geo.size.width * 0.8)
                    
                    HStack {
                        Text("\(packedCount)/\(allItems.count)")
                            .font(.subheadline)
                        Spacer()
                    }//:HSTACK
                    .frame(width: geo.size.width * 0.2)
                    Spacer()
                                        
                }//:HSTACK
            }//:GEOMETRY READER
            .padding(.horizontal, Constants.horizontalPadding)
        }//:VSTACK
        .padding(.vertical, Constants.cardSpacing)
        .padding(.horizontal, Constants.cardSpacing)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.colorWhite)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $isEditingTitle) {
            EditListDetailsModal(packingList: viewModel.packingList)
        }
        .onTapGesture {
            isEditingTitle = true
        }
    }//:BODY
    
    private var allItems: [Item] {
        viewModel.packingList.categories.flatMap( \.items )
    }
    
    private var packedCount: Int {
        allItems.filter { $0.isPacked }.count
    }
    
    private var packedRatio: Double {
        allItems.isEmpty ? 0 : Double(packedCount) / Double(allItems.count)
    }
    
}//:STRUCT



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
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
        
        // Return the preview
        return ListDetailCardView(viewModel: viewModel, isEditingTitle: $isEditingTitle)
                .modelContainer(container) // Provide the ModelContainer
}
