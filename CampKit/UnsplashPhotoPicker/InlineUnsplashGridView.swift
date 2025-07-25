//
//  InlineUnsplashGridView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/27/25.
//

import SwiftUI

struct InlineUnsplashGridView: View {
    @ObservedObject var loader: UnsplashImageLoader
    @Binding var selectedImage: UIImage?

    @State private var selectedID: String?
    @Binding var searchText: String
    
    let setImage: (UIImage) -> Void
    
    let size = (UIScreen.main.bounds.width - 40) / 3

    private let columns = [
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing)
    ]

    var body: some View {
        
        VStack {
            
            //MARK: - SEARCH BAR
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.colorForest)
                    .padding(.leading, 8)
                    .accessibilityLabel("Search images")

                TextField("Search Unsplash", text: $searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        loader.fetchImages(for: searchText)
                    }
            }
            .padding(10)
            .background(Color.colorTertiaryGrey)
            .cornerRadius(Constants.cornerRadius)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalSpacing)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: Constants.gallerySpacing) {
                    ForEach(loader.photos) { photo in
                        ZStack(alignment: .bottomLeading) {
                            Color.clear //force square container
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    AsyncImage(url: photo.urls.small) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .clipped()
                                        default:
                                            Color.gray.opacity(0.1)
                                                .overlay(ProgressView())
                                        }
                                    }
                                )
                                .clipShape(Rectangle())
                                .overlay(
                                        Rectangle()
                                            .stroke(selectedID == photo.id ? Color.colorNeon : Color.clear, lineWidth: 3)
                                    )
                                .onTapGesture {
                                    loadFullImage(from: photo.urls.regular)
                                    selectedID = photo.id
                                    HapticsManager.shared.triggerLightImpact()
                                }
                            
                            // Gradient overlay
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: 80)
                            .allowsHitTesting(false) // so taps still register on the image
                            
                            // Attribution text
                            Text("by \(photo.user.name)")
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .padding(5)
                                .onTapGesture {
                                    if let profileURL = URL(string: photo.user.links.html) {
                                        UIApplication.shared.open(profileURL)
                                    }
                                }
                        }//:ZSTACK
                    }
                }
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.bottom, Constants.quizPadding)
            }//:SCROLLVIEW
        }//:VSTACK
        .ignoresSafeArea(edges: .bottom)
    }

    func loadFullImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    selectedImage = image
                    setImage(image)
                }
            }
        }.resume()
    }
}
#if DEBUG
#Preview {
    
    @Previewable @State var selectedImage: UIImage? = nil
    @Previewable @State var searchText: String = "camping"
    
    let previewStack = CoreDataStack.preview
    
    InlineUnsplashGridView(
        loader: UnsplashImageLoader(),
        selectedImage: $selectedImage,
        searchText: $searchText,
        setImage: {_ in })
}
#endif
