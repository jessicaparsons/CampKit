//
//  WeatherModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import Foundation

struct WeatherModel: Identifiable {
    let id = UUID()
    let date: String
    let conditionID: Int
    let cityName: String
    let high: Double
    let low: Double
    
    var highTemp: String {
        return String(format: "%.0f", high)
    }
    
    var lowTemp: String {
        return String(format: "%.0f", low)
    }
    
    var conditionName: String {
        switch conditionID {
            case 200...232: return "⛈️" //"cloud.bolt.rain"
            case 300...321: return "🌧️" //"cloud.drizzle
            case 500...531: return "🌧️" //"cloud.heavyrain"
            case 600...622: return "❄️" //"cloud.snow"
            case 701...781: return "🌥️" //"cloud.fog"
            case 800: return "☀️"
            case 801...804: return "☁️"
            default: return "☁️"
        }
    }
}
