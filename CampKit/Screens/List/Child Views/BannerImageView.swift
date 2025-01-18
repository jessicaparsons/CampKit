//
//  BannerImageView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct BannerImageView: View {
    
    @EnvironmentObject var viewModel: ListViewModel
    private let placeholderImage: String = "TopographyDesign"
    
    var body: some View {
        ZStack {
            bannerImageView
                .resizable()
                .scaledToFill()
                .frame(height: 250, alignment: .center)
                .clipped()
                .overlay(cameraOverlay)
        }
        .ignoresSafeArea(edges: .horizontal)
    }
    
    // MARK: - SUBVIEWS
    private var bannerImageView: Image {
        if let photoData = viewModel.packingList.photo,
           let uiImage = UIImage(data: photoData) {
            return Image(uiImage: uiImage)
        } else {
            return Image(placeholderImage)
        }
    }
    
    private var cameraOverlay: some View {
        Image(systemName: "camera")
            .font(.title3)
            .foregroundColor(.white)
    }
}


#Preview {
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true) // In-memory container
    )

    // Populate the container with sample data
    preloadPackingListData(context: container.mainContext)

    // Fetch a sample packing list from the container
    let samplePackingList = try! container.mainContext.fetch(FetchDescriptor<PackingList>()).first!

    // Create the ListViewModel
    let viewModel = ListViewModel(packingList: samplePackingList, modelContext: container.mainContext)

    // Return the ListView with the in-memory container
    return BannerImageView()
        .modelContainer(container)
        .environmentObject(viewModel)
    
}
