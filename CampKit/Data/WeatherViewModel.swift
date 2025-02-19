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
protocol WeatherFetcher {
    func fetchWeather(with urlString: String) async throws -> [WeatherModel]?
    
    func getDailyWeather(from forecastList: [WeatherEntry]) async -> [DailyWeather]
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

@Observable
class WeatherViewModel {
    
    var weather: [WeatherModel]? // 5 day forecast
    var coordinates: CLLocationCoordinate2D? // user's location input
    
    private let weatherFetcher: WeatherFetcher
    
    init(weatherFetcher: WeatherFetcher) {
        self.weatherFetcher = weatherFetcher
    }
    
    //Get coordinates from city name
    func getCoordinatesFrom(cityName: String) async throws -> CLLocationCoordinate2D? {
        let coordinates = try await CLGeocoder().geocodeAddressString(cityName)
            return coordinates.first?.location?.coordinate
    }
    
    //Fetch weather by city and coordinates that are stored in the Packing List
    @MainActor
    func fetchLocation(for cityName: String) async {
        
        do {
            guard let location = try await getCoordinatesFrom(cityName: cityName) else {
                print("Couldn't get coordinates for \(cityName)")
                return
            }
        
            self.coordinates = location
        
            let urlString = "\(Constants.weatherURL)?lat=\(location.latitude)&lon=\(location.longitude)&units=imperial&appid=\(Constants.apiKey)"
        
            print("fetchLocation called with URL: \(urlString)")
        
        
            let fiveDayForecast = try await weatherFetcher.fetchWeather(with: urlString)
            self.weather = fiveDayForecast
            
        } catch let error as NetworkError {
            print("Could not fetch location: \(error)")
        } catch {
            print("Could not fetch location: \(error.localizedDescription)")
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

class GetWeather: WeatherFetcher {
    
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
    
    private func findMode(_ numbers: [Int]) -> Int {
        let frequency = numbers.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        return frequency.max { $0.value < $1.value }?.key ?? numbers.first ?? 0
    }
}
