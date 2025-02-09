//
//  WeatherModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import Foundation

struct WeatherModel {
    let conditionID: Int
    let cityName: String
    let temperatureMax: Double
    let temperatureMin: Double
    
    var highTemp: String {
        return String(format: "%.1f", temperatureMax)
    }
    
    var lowTemp: String {
        return String(format: "%.1f", temperatureMin)
    }
    
    var conditionName: String {
        switch conditionID {
            case 200...232: return "cloud.bolt.rain"
            case 300...321: return "cloud.drizzle"
            case 500...531: return "cloud.heavyrain"
            case 600...622: return "cloud.snow"
            case 701...781: return "cloud.fog"
            case 800: return "sun.max"
            case 801...804: return "cloud"
            default: return "cloud"
        }
    }
    
}
