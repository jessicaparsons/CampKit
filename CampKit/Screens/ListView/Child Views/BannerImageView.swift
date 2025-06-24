//
//  BannerImageView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import PhotosUI

struct BannerImageView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var viewModel: ListViewModel
    private let placeholderImage: String = Constants.placeholderBannerPhoto
    
    var body: some View {
        
        ZStack {
            Group {
                bannerImageView
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0.7), location: 0.0),
                        .init(color: Color.black.opacity(0.3), location: 0.5),
                        .init(color: Color.black.opacity(0.1), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
                
                
            }//:GROUP
            .frame(width: UIScreen.main.bounds.width, height: sizeClass == .regular ? Constants.ipadBannerHeight : Constants.bannerHeight)
            .clipped()
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
    
    
    let context = CoreDataStack.preview.context
    
    let list = PackingList.samplePackingList(context: context)
        
    // Return the ListView with the in-memory container
    return BannerImageView(viewModel: ListViewModel(viewContext: context, packingList: list))
    
}
#endif
