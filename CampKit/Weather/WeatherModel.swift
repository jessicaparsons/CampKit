//
//  WeatherModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import Foundation

enum Condition {
    case thunderstorm, drizzle, rain, snow, fog, clear, clouds
    
    var emoji: String {
        switch self {
        case .thunderstorm: return "⛈️"
        case .drizzle: return "🌧️"
        case .rain: return "🌧️"
        case .snow: return "❄️"
        case .fog: return "☁️"
        case .clear: return "☀️"
        case .clouds: return "☁️"
        }
    }
}

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
    
    var conditionType: Condition {
        switch conditionID {
        case 200...232: return .thunderstorm
        case 300...321: return .drizzle
        case 500...531: return .rain
        case 600...622: return .snow
        case 701...781: return .fog
        case 800: return .clear
        case 801...804: return .clouds
        default: return .clouds
        }
    }
    
    var conditionName: String {
        conditionType.emoji
    }
}
