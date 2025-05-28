//
//  WeatherViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import CoreLocation
import Observation

// Protocol created so we have a dependency injection for testing
protocol WeatherFetching {
    func fetchWeather(with urlString: String) async throws -> [WeatherModel]?
    
    func getDailyWeather(from forecastList: [WeatherEntry]) async -> [DailyWeather]
}

protocol Geocoding {
    func getCoordinates(for cityName: String) async throws -> CLLocationCoordinate2D?
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

@Observable
final class WeatherViewModel {
    
    var weather: [WeatherModel]? // 5 day forecast
    var coordinates: CLLocationCoordinate2D? // user's location input
    var isNoLocationFoundMessagePresented: Bool = false
    let geoCoder: Geocoding
    
    private let weatherFetcher: WeatherFetching
    
    init(weatherFetcher: WeatherFetching, geoCoder: Geocoding) {
        self.weatherFetcher = weatherFetcher
        self.geoCoder = geoCoder
    }
    
    
    
    //Fetch weather by city and coordinates that are stored in the Packing List
    
    @MainActor
    func fetchLocation(for cityName: String) async {
        
        do {
            try await Task {
                guard let location = try await geoCoder.getCoordinates(for: cityName) else {
                    throw NetworkError.requestFailed
                }
                
                self.coordinates = location
                
                let lat = location.latitude
                let lon = location.longitude
                
                let urlString = "https://campingkit-weather.onrender.com/weather?lat=\(lat)&lon=\(lon)"
                
                let fiveDayForecast = try await weatherFetcher.fetchWeather(with: urlString)
                
                await MainActor.run {
                    self.weather = fiveDayForecast
                    isNoLocationFoundMessagePresented = false
                }
            }.value
            
            
        } catch let error as NetworkError {
            print("Could not fetch location due to network error: \(error)")
        } catch {
            print("Could not fetch location: \(error.localizedDescription)")
            isNoLocationFoundMessagePresented = true
        }
    }
    
    // Creates the user's weather choices for page 2 of the Packing List Quiz
    // If the high temp is at or above 80, mark it as "hot" mild hot cold snow rainy
    // If the temp is lower than 50, mark it as cold
    // If the conditionName == "cloud.bolt.rain", "cloud.drizzle", "cloud.heavyrain", mark it as rain
    // If the conditionName == "cloud.snow", mark it as snow
    
    //add in elevation from page one.
    
    func categorizeWeather(for forecast: [WeatherModel], elevation: Double) -> Set<String> {
        
        var weatherCategories: Set<String> = ["mild"]
        
        //The temperature decreases by approximately 0.33°F for every 100 feet of elevation gain.
        let elevationCompensation = elevation / 100 * 0.33
        var avgHigh: Double = 0
        var avgLow: Double = 0
        
        
        for day in forecast {
            let high = day.high - elevationCompensation
            let low = day.low - elevationCompensation
            let conditionName = day.conditionName
            
            avgHigh += high
            avgLow += low
            
            if high >= 80 {
                weatherCategories.insert("hot")
            }
            
            if low <= 45 {
                weatherCategories.insert("cold")
            }
            
            if conditionName == "cloud.bolt.rain" ||
                conditionName == "cloud.drizzle" ||
                conditionName == "cloud.heavyrain" {
                weatherCategories.insert("rainy")
            }
            
            if conditionName == "cloud.snow" {
                weatherCategories.insert("snowy")
                weatherCategories.remove("mild")
            }
        }
                
        //If the average low is greater than 70, or if the average high is lower than 50, the user does not have to pack for Mild weather
        if avgLow / Double(forecast.count) > 70 || avgHigh / Double(forecast.count) < 50 {
            weatherCategories.remove("mild")
        }
        
        return weatherCategories
    }
    
    //Formats the weather categories for display in the UI
    
    func formatWeatherCategories(_ categories: Set<String>) -> Text {
        let sortedCategories = categories.sorted()  // Sorting for consistent order
        
        switch sortedCategories.count {
        case 0:
            return Text("mild").bold() // Default message if empty
        case 1:
            return Text(sortedCategories[0]).bold()
        case 2:
            return Text(sortedCategories[0]).bold() + Text(" and ") + Text(sortedCategories[1]).bold()
        default:
            var text = Text("")
            for (index, category) in sortedCategories.enumerated() {
                if index > 0 {
                    if index == sortedCategories.count - 1 {
                        text = text + Text(", and ")
                    } else {
                        text = text + Text(", ")
                    }
                }
                text = text + Text(category).bold()
            }
            return text
        }
    }
    
    //Computed average high and low temps for Packing List view
    
    var highTemp: Double? {
        var dailyHigh: [Double] = []
        
        guard let fiveDayForecast = weather, !fiveDayForecast.isEmpty else {
            return nil
        }
        for day in fiveDayForecast {
            let high = day.high
            dailyHigh.append(high)
        }
        return dailyHigh.max()
    }
    
    var lowTemp: Double? {
        var dailyLow: [Double] = []
        
        guard let fiveDayForecast = weather, !fiveDayForecast.isEmpty else {
            return nil
        }
        for day in fiveDayForecast {
            let low = day.low
            dailyLow.append(low)
        }
        return dailyLow.min()
    }
}

struct Geocoder: Geocoding {
    func getCoordinates(for cityName: String) async throws -> CLLocationCoordinate2D? {
            let coordinates = try await CLGeocoder().geocodeAddressString(cityName)
            return coordinates.first?.location?.coordinate
    }
    
}

class WeatherAPIClient: WeatherFetching {
    
    func fetchWeather(with urlString: String) async throws -> [WeatherModel]? {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        
        do {
            
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            
            //Get the highs and lows from every day in the [List]
            //Get the mode weather id for the icon
            
            let dailyWeather = await getDailyWeather(from: weatherData.list)
            
            let weatherModels = dailyWeather.map { daily in
                
                WeatherModel(
                    date: daily.day,
                    conditionID: daily.weatherID,
                    cityName: weatherData.city.name,
                    high: daily.high,
                    low: daily.low
                )
            }
            
            return weatherModels
            
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    func getDailyWeather(from forecastList: [WeatherEntry]) async -> [DailyWeather] {
        //Create a dictionary to store daily high and low temps to use in the WeatherModel
        
        var dailyTemps: [String: [Double]] = [:]
        var dailyWeatherIDs: [String: [Int]] = [:]
        
        for threeHours in forecastList {
            let date = String(threeHours.dt_txt.prefix(10))
            
            if dailyTemps[date] == nil {
                dailyTemps[date] = []
            }
            
            //Store all temperatures
            dailyTemps[date]?.append(threeHours.main.temp_max)
            dailyTemps[date]?.append(threeHours.main.temp_min)
            
            if dailyWeatherIDs[date] == nil {
                dailyWeatherIDs[date] = []
            }
            
            //store all weather IDs
            if let weatherID = threeHours.weather.first?.id {
                
                dailyWeatherIDs[date]?.append(weatherID)
            }
            
        }
        
        var dailyWeather: [DailyWeather] = []
        
        for (date, temps) in dailyTemps {
            if let maxTemp = temps.max(), let minTemp = temps.min(), let weatherIDs = dailyWeatherIDs[date] {
                
                let mostCommonWeatherID = findMode(weatherIDs)
                
                dailyWeather.append(DailyWeather(date: date, high: maxTemp, low: minTemp, weatherID: mostCommonWeatherID))
            }
        }
        return dailyWeather.sorted { $0.date < $1.date }
    }
    
    //Finds the most common weather ID by identifying the mode.
    //This is to display the most accurate weather icon next to each day
    
    private func findMode(_ numbers: [Int]) -> Int {
        let frequency = numbers.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        return frequency.max { $0.value < $1.value }?.key ?? numbers.first ?? 0
    }
}

