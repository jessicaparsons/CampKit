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
    func fetchWeather(with urlString: String) async throws -> WeatherModel?
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

@Observable
class WeatherViewModel {
    
    var weather: WeatherModel?
    
    private let weatherFetcher: WeatherFetcher
    
    let apiKey = "461015f75676862154eee3154367a074"
    let weatherURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    init(weatherFetcher: WeatherFetcher) {
        self.weatherFetcher = weatherFetcher
    }
    
    //Get coordinates from city name
    func getCoordinatesFrom(cityName: String) async throws -> CLLocationCoordinate2D? {
        let coordinates = try await CLGeocoder().geocodeAddressString(cityName)
        return coordinates.first?.location?.coordinate
    }
    
    
    //Fetch by city name
    @MainActor
    func fetchLocation(cityName: String) async {
        
        do {
            guard let coordinates = try await getCoordinatesFrom(cityName: cityName) else {
                print("Could not get coordinates from city name")
                return
            }
        
            let lat = coordinates.latitude
            let lon = coordinates.longitude
            
            let urlString = "\(weatherURL)?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
            print("fetchLocation called with URL: \(urlString)")
        
            self.weather = try await weatherFetcher.fetchWeather(with: urlString)
            
        } catch let error as NetworkError {
            print("Could not fetch location: \(error)")
        } catch {
            print("Could not fetch location: \(error.localizedDescription)")
        }
    }
    
//    //Fetch by user location
//    func fetchLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
//        let urlString = "\(weatherURL)?appid=\(apiKey)&lat=\(latitude)&lon=\(longitude)&units=imperial"
//        
//        do {
//            self.weather = try await weatherFetcher.fetchWeather(with: urlString)
//        } catch {
//            print("Could not fetch location: \(error.localizedDescription)")
//        }
//    }
}

class GetWeather: WeatherFetcher {
    
    func fetchWeather(with urlString: String) async throws -> WeatherModel? {
        
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
            
            let id = weatherData.weather.first?.id ?? 0
            let city = weatherData.name
            let max = weatherData.main.temp_max
            let min = weatherData.main.temp_min
            
            let weather = WeatherModel(conditionID: id, cityName: city, temperatureMax: max, temperatureMin: min)
            return weather
            
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
