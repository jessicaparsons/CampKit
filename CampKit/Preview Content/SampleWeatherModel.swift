//
//  SampleWeatherModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/25/25.
//
#if DEBUG
import Foundation

extension WeatherModel {
    
    static var sampleWeatherModels: [WeatherModel] {
        [
            WeatherModel(date: "2025-03-25", conditionID: 801, cityName: "Paris", high: 75.0, low: 45.0)
        ]
    }
    
}
#endif
