//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import SwiftData

struct ListDetailCardView: View {
    var viewModel: ListViewModel
    
    //Map Options
    @State private var showMapOptions = false
    let locationQuery = "1 Infinite Loop, Cupertino, CA"
        
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
            
            listLocation
            
        //MARK: - PROGRESS BAR
            progressBar
            
        }//:VSTACK
        .padding(.vertical, Constants.cardSpacing)
        .padding(.horizontal, Constants.cardSpacing)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.colorWhite)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }//:BODY
    
    
    private var listLocation: some View {
        HStack {
            Text(viewModel.packingList.locationName ?? "No Location Set")
                .multilineTextAlignment(.center)
            
            if viewModel.packingList.locationName != nil {
                Image(systemName: "arrow.up.right.square").foregroundColor(.colorSage)
            }
        }//:HSTACK
        .onTapGesture {
            if viewModel.packingList.locationName != nil {
                showMapOptions = true
            }
        }
        .confirmationDialog("Open location in:", isPresented: $showMapOptions, titleVisibility: .visible) {
            
            if let locationName = viewModel.packingList.locationName,
               let locationAddress = viewModel.packingList.locationAddress
            {
                Button("Apple Maps") {
                    openInAppleMaps(query: locationName + ", " + locationAddress)
                }
                
                Button("Google Maps") {
                    openInGoogleMaps(query: locationName + ", " + locationAddress)
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                HStack {
                    ProgressView(value: packedRatio)
                        .progressViewStyle(LinearProgressViewStyle(tint: .colorNeon))
                        .animation(.easeInOut, value: packedRatio)
                }//:HSTACK
                .frame(width: geo.size.width * 0.75)
                
                HStack {
                    Text("\(packedCount)/\(allItems.count)")
                        .font(.subheadline)
                    Spacer()
                }//:HSTACK
                .frame(width: geo.size.width * 0.25)
                Spacer()
                                    
            }//:HSTACK
        }//:GEOMETRY READER
        .padding(.horizontal, Constants.horizontalPadding)
        .frame(height: 20)
    }
    
    private var allItems: [Item] {
        viewModel.packingList.categories.flatMap( \.items )
    }
    
    private var packedCount: Int {
        allItems.filter { $0.isPacked }.count
    }
    
    private var packedRatio: Double {
        allItems.isEmpty ? 0 : Double(packedCount) / Double(allItems.count)
    }
    
    //MARK: - FUNCTIONS
    private func openInAppleMaps(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedQuery)") {
            UIApplication.shared.open(url)
        }
    }

    private func openInGoogleMaps(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "comgooglemaps://?q=\(encodedQuery)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallbackURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)") {
            UIApplication.shared.open(fallbackURL)
        }
    }
    
    
}//:STRUCT



#Preview {


        // Create an in-memory ModelContainer
    let container = PreviewContainer.shared
        
        // Populate the container with mock data
        preloadPackingListData(context: container.mainContext)
        
        // Fetch a sample PackingList
        let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!
        
        // Create a mock ListViewModel
        let viewModel = ListViewModel(modelContext: container.mainContext, packingList: samplePackingList)
        
        // Return the preview
    return ZStack {
        
        Color(.black)
            .ignoresSafeArea()
        ListDetailCardView(viewModel: viewModel)
            .modelContainer(container) // Provide the ModelContainer
        
    }
}
