//
//  QuizPageThreeView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/25/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

enum PickerType: String, CaseIterable, Identifiable {
    case images = "Unsplash"
    case colors = "Colors"
    case gallery = "My Photos"
    var id: String { self.rawValue }
}

struct QuizPageThreeView: View {
    
    @Bindable var viewModel: QuizViewModel
    
    @State private var selectedTab: PickerType = .images
    @State private var selectedImage: UIImage?
    @State private var selectedGradient: GradientOption?
    @State private var selectedGalleryPhoto: PhotosPickerItem?
    
    @State private var isPhotoPickerPresented = false
    @State private var wasPhotoPickerOpened = false
    @State private var bannerImage: UIImage? = nil


    
    private let columns = [
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing),
        GridItem(.flexible(), spacing: Constants.gallerySpacing)
    ]
    
    
    let accessKey = Bundle.main.infoDictionary?["UNSPLASH_ACCESS_KEY"] as? String ?? ""
    let secretKey = Bundle.main.infoDictionary?["UNSPLASH_SECRET_KEY"] as? String ?? ""
    
    
    var body: some View {
        VStack {
            //MARK: - TITLE
            VStack(alignment: .center) {
                Text("Choose a background")
                    .font(.title)
                    .fontWeight(.bold)
                
            }//:VSTACK
            .padding(.top, Constants.largePadding)
            
            Picker("", selection: $selectedTab) {
                ForEach(PickerType.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: selectedTab) {
                if selectedTab == .gallery {
                    isPhotoPickerPresented.toggle()
                }
            }
            
            //MARK: - PHOTO GALLERY PICKER
            .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedGalleryPhoto, matching: .images)
            .onChange(of: isPhotoPickerPresented) {
                if isPhotoPickerPresented {
                    wasPhotoPickerOpened = true
                } else if wasPhotoPickerOpened && selectedGalleryPhoto == nil {
                    // Picker was opened and closed without selecting
                    wasPhotoPickerOpened = false
                    selectedTab = .colors
                }
            }
            .onChange(of: selectedGalleryPhoto) {
                guard let selectedGalleryPhoto else { return }

                Task {
                    if let data = try? await selectedGalleryPhoto.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.setGalleryPhoto(image)
                    } else {
                        print("Failed to save gallery image")
                    }
                }
            }

            
            //MARK: - TABS
            
            if selectedTab == .images {
                InlineUnsplashGridView(
                    selectedImage: $selectedImage,
                    setImage: { image in
                        viewModel.setTempPhoto(image)
                    }
                )
                
            } else if selectedTab == .colors {
                
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
                            }
                    }//:FOREACH
                }//:LAZYVGRID
                .padding(.horizontal)
                .padding(.vertical, Constants.verticalSpacing)
                
            } else {
                
                EmptyView()
                
            }//:ELSE
            
            
            Spacer()
            
        }//:VSTACK
        .ignoresSafeArea(edges: .bottom)
        
    }
}


#Preview {
    
    @Previewable @State var previewStack = CoreDataStack.preview
    
    QuizPageThreeView(viewModel: QuizViewModel(context: previewStack.context))
}
