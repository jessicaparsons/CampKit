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
    private let placeholderImage: String = Constants.placeholderBannerPhoto
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            bannerImageView
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .clipped()
            
            Color.black.opacity(0.2)
                .ignoresSafeArea()
        }//:ZSTACK
        
        .ignoresSafeArea(edges: .horizontal)
        
    }
    
    // MARK: - BANNER IMAGE
    private var bannerImageView: Image {
        
        if let photoData = viewModel.packingList.photo,
                let uiImage = UIImage(data: photoData) {
            return Image(uiImage: uiImage)
            
        } else {
            return Image(placeholderImage)
        }
    }

}

#if DEBUG
#Preview {
    
    
    let context = CoreDataStack.shared.context
    
    let list = PackingList.samplePackingList(context: context)
        
    // Return the ListView with the in-memory container
    return BannerImageView(viewModel: ListViewModel(viewContext: context, packingList: list))
    
}
#endif
