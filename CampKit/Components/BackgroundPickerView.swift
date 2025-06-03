//
//  BackgroundPickerView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/28/25.
//

import SwiftUI
import PhotosUI

enum PickerType: String, CaseIterable, Identifiable {
    case images = "Unsplash Photos"
    case colors = "Presets"
    var id: String { self.rawValue }
}

struct BackgroundPickerView: View {
    
    @StateObject private var loader = UnsplashImageLoader()
    @State private var searchText = "camping"
    var onImageSelected: (UIImage) -> Void
    
    @State private var selectedTab: PickerType = .images
    @State private var selectedImage: UIImage?
    @State private var selectedGradient: GradientOption?
    @State private var selectedImageName: String?
    @State private var selectedGalleryPhoto: PhotosPickerItem?
    @State private var isPhotoPickerPresented = false
    @State private var wasPhotoPickerOpened = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing)
    ]
    
    var body: some View {
        VStack {
            Text("Choose a background")
                .font(.title)
                .fontWeight(.bold)
            
            Picker("", selection: $selectedTab) {
                ForEach(PickerType.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Group {
                if selectedTab == .images {
                    InlineUnsplashGridView(
                        loader: loader,
                        selectedImage: $selectedImage,
                        searchText: $searchText,
                        setImage: { image in
                            selectedImage = image
                            onImageSelected(image)
                        }
                    )
                } else if selectedTab == .colors {
                    
                    ScrollView {
                        
                        VStack(spacing: 0) {
                            
                            //IMAGES
                            LazyVGrid(columns: columns, spacing: Constants.gallerySpacing) {
                                ForEach(presetImages) { image in
                                    Image(image.name)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .overlay(
                                            Rectangle()
                                                .stroke(selectedImageName == image.name ? Color.colorNeon : Color.clear, lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            selectedImageName = image.name
                                            selectedImage = UIImage(named: image.name)
                                            if let image = selectedImage {
                                                onImageSelected(image)
                                            }
                                            HapticsManager.shared.triggerLightImpact()
                                        }
                                }
                                
                            }
                            .padding(.horizontal)
                            .padding(.top, Constants.verticalSpacing)
                            .padding(.bottom, 5)
                            
                            //GRADIENTS
                            LazyVGrid(columns: columns, spacing: Constants.gallerySpacing) {
                                ForEach(presetGradients) { gradientOption in
                                    gradientOption.gradient
                                        .aspectRatio(1, contentMode: .fit)
                                        .overlay(
                                            Rectangle()
                                                .stroke(selectedGradient == gradientOption ? Color.colorNeon : Color.clear, lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            selectedGradient = gradientOption
                                            if let image = imageFromGradient(gradientOption.gradient) {
                                                selectedImage = image
                                                onImageSelected(image)
                                            }
                                            HapticsManager.shared.triggerLightImpact()
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, Constants.verticalSpacing)
                            .padding(.top, 0)
                            
                        }//:VSTACK
                    }//:SCROLLVIEW
                }
            }
            
            Spacer()
        }//:VSTACK
        .ignoresSafeArea(edges: .bottom)
        .task {
            loader.fetchImages(for: searchText)
        }
    }//:BODY
    
    
    func imageFromGradient(_ gradient: LinearGradient, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let controller = UIHostingController(
            rootView: gradient
                .frame(width: size.width, height: size.height)
                .ignoresSafeArea()
                .fixedSize()
            )
        let view = controller.view
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
    @Previewable @State var selectedImage: UIImage? = nil
    
    BackgroundPickerView(onImageSelected: { _ in })
}
