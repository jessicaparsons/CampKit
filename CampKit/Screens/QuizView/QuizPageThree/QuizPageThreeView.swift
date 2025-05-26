//
//  QuizPageThreeView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/25/25.
//

import SwiftUI
internal import UnsplashPhotoPicker

protocol UnsplashPhotoPickerDelegate: AnyObject {
  func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto])
  func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker)
}

struct QuizPageThreeView: View {
    
    @Bindable var viewModel: QuizViewModel
    
    var body: some View {
        UnsplashPhotoPickerConfiguration(accessKey: Constants.photoKey,
                                         secretKey: Constants.photoSecretKey,
                                         query: "camping",
                                         allowsMultipleSelection: false)
    }
}

#Preview {
    
    let previewStack = CoreDataStack.preview
    
    QuizPageThreeView(
        viewModel: QuizViewModel(context: previewStack.context))
}
