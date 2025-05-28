//
//  BackgroundPickerView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/28/25.
//

import SwiftUI

import SwiftUI
import PhotosUI

struct BackgroundPickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedGradient: GradientOption?
    var onGalleryImageSelected: (UIImage) -> Void

    @State private var selectedTab: PickerType = .images
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

            Group {
                if selectedTab == .images {
                    InlineUnsplashGridView(
                        selectedImage: $selectedImage,
                        setImage: { _ in
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
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, Constants.verticalSpacing)
                } else {
                    EmptyView()
                }
            }

            Spacer()
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedGalleryPhoto, matching: .images)
        .onChange(of: isPhotoPickerPresented) {
            if isPhotoPickerPresented {
                wasPhotoPickerOpened = true
            } else if wasPhotoPickerOpened && selectedGalleryPhoto == nil {
                wasPhotoPickerOpened = false
                selectedTab = .colors
            }
        }
        .onChange(of: selectedGalleryPhoto) {
            guard let selectedGalleryPhoto else { return }

            Task {
                if let data = try? await selectedGalleryPhoto.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onGalleryImageSelected(image)
                }
            }
        }
    }
}


//#Preview {
//    BackgroundPickerView(selectedImage: <#Binding<UIImage?>#>, selectedGradient: <#Binding<GradientOption?>#>, onGalleryImageSelected: <#(UIImage) -> Void#>)
//}
