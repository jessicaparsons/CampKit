//
//  WeatherLocationResultsModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/24/25.
//

import Foundation

struct WeatherLocationResultsModel: Codable, Identifiable {
    var id: String { "\(lat),\(lon)" }
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?  // ✅ Make state optional
    let local_names: [String: String]?  // ✅ Make local_names optional
    

}
