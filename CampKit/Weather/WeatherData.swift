//
//  WeatherData.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import Foundation

struct WeatherData: Codable {
    let cnt: Int
    let list: [WeatherEntry]
    let city: City
}

struct City: Codable {
    let name: String
}

struct WeatherEntry: Codable {
    let dt_txt: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let id: Int
}


///Stores the daily highs and lows and most common weatherID
struct DailyWeather {
    let date: String
    let high: Double
    let low: Double
    let weatherID: Int
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "EEEE"
            return outputFormatter.string(from: date)
        }
        
        return "Unknown"
    }
}
