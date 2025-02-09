//
//  WeatherData.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let description: String?
    let id: Int
}
