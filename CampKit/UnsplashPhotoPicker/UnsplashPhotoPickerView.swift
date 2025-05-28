////
////  UnsplashPhotoPickerView.swift
////  CampKit
////
////  Created by Jessica Parsons on 5/27/25.
////
//
//import SwiftUI
//import UnsplashPhotoPicker
//
//struct UnsplashPickerView: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//    var accessKey: String
//    var secretKey: String
//    var onImageSelected: (UIImage) -> Void
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UnsplashPhotoPicker {
//        let configuration = UnsplashPhotoPickerConfiguration(
//            accessKey: accessKey,
//            secretKey: secretKey,
//            query: "camping",
//            allowsMultipleSelection: false
//        )
//        let picker = UnsplashPhotoPicker(configuration: configuration)
//        picker.photoPickerDelegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UnsplashPhotoPicker, context: Context) {}
//    
//    @MainActor
//    class Coordinator: NSObject, @preconcurrency UnsplashPhotoPickerDelegate {
//        let parent: UnsplashPickerView
//
//        init(_ parent: UnsplashPickerView) {
//            self.parent = parent
//        }
//
//        func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
//            guard let photo = photos.first else { return }
//            if let url = photo.urls[.regular] {
//                URLSession.shared.dataTask(with: url) { data, _, _ in
//                    if let data = data, let image = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            self.parent.onImageSelected(image)
//                            self.parent.presentationMode.wrappedValue.dismiss()
//                        }
//                    }
//                }.resume()
//            }
//        }
//
//        func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
