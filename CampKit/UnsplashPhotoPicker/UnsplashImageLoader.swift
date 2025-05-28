//
//  UnsplashImageLoader.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/27/25.
//

import SwiftUI


struct UnsplashPhotoResult: Codable {
    let results: [CustomUnsplashPhoto]
}

struct CustomUnsplashPhoto: Codable, Identifiable, Hashable {
    let id: String
    let width: Int
    let height: Int
    let urls: PhotoURLs
    let user: User
    let links: PhotoLinks
}

struct PhotoLinks: Codable, Hashable {
    let download_location: URL
}

struct User: Codable, Hashable {
    let name: String
    let links: UserLinks
}

struct UserLinks: Codable, Hashable {
    let html: String
}

struct PhotoURLs: Codable, Hashable {
    let small: URL
    let regular: URL
}

@MainActor
class UnsplashImageLoader: ObservableObject {
    
    let accessKey = Bundle.main.infoDictionary?["UNSPLASH_ACCESS_KEY"] as? String ?? ""
    @Published var photos: [CustomUnsplashPhoto] = []

    func fetchImages(for query: String = "camping") {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?query=\(query)&per_page=30&client_id=\(accessKey)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let result = try? JSONDecoder().decode(UnsplashPhotoResult.self, from: data) else {
                print("Failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                self.photos = result.results
            }
        }.resume()
    }
}

