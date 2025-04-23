//
//  BannerImageView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import PhotosUI

struct BannerImageView: View {
    
    @ObservedObject var viewModel: ListViewModel
    @Binding var bannerImage: UIImage?
    private let placeholderImage: String = "TopographyDesign"
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            bannerImageView
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 200)
                .clipped()
            
            Color.black.opacity(0.2)
                .ignoresSafeArea()
        }//:ZSTACK
        .ignoresSafeArea(edges: .horizontal)
    }
    
    // MARK: - BANNER IMAGE
    private var bannerImageView: Image {
        
        // Load the most recent in-memory image first
        if let bannerImage = bannerImage {
            return Image(uiImage: bannerImage)
            
        // Check if there is a stored image in the PackingList Model
        } else if let photoData = viewModel.packingList.photo,
                  let uiImage = UIImage(data: photoData) {
            return Image(uiImage: uiImage)
            
        } else {
            return Image(placeholderImage)
        }
    }

}
//
//#if DEBUG
//#Preview {
//    
//    @Previewable @State var bannerImage = UIImage(named: "TopographyDesign")
//    
//    let context = PersistenceController.preview.persistentContainer.viewContext
//    
//    let samplePackingList = PackingList.samplePackingList(context: context)
//        
//    // Return the ListView with the in-memory container
//    return BannerImageView(viewModel: ListViewModel(viewContext: context, packingList: samplePackingList), bannerImage: $bannerImage)
//    
//}
//#endif
