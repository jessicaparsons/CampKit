//
//  WeatherViewModelTest.swift
//  CampKitTests
//
//  Created by Jessica Parsons on 2/7/25.
//

import XCTest
import CoreLocation
@testable import CampKit

final class WeatherViewModelTest: XCTestCase {
    
    var viewModel: WeatherViewModel!

    override func setUpWithError() throws {
        super.setUp()
        let mockFetcher = MockWeatherFetcher()
        let mockGeo = MockGeocoder()
        viewModel = WeatherViewModel(weatherFetcher: mockFetcher, geoCoder: mockGeo)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        super.tearDown()
    }

    //basic structure is: set up your variables, do something, then assert what the results should be.
    
    func testSuccessfulFetchLocationSuccess_CityName() {
        // Given (Arrange) // set up the scenario you want to test
        
        // When (Act)
        
        // Then (Assert)
    }

    func testFetchLocationSuccess() async throws {
        let expectation = self.expectation(description: "Fetch weather data")
        let cityName = "London"
        let mockGeo = MockGeocoder()
        
        mockGeo.mockCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        print("Fetching weather for \(cityName)")
        
        await viewModel.fetchLocation(for: cityName)
        
        print("Weather data received: \(String(describing: viewModel.weather))")
        
        XCTAssertNotNil(viewModel.weather, "Weather data should not be nil")
//        XCTAssertEqual(viewModel.weather?.conditionID, 804)
//        XCTAssertEqual(viewModel.weather?.cityName, "London")
//        XCTAssertEqual(viewModel.weather?.temperatureMax ?? 0.0, 277.21, accuracy: 0.01)
//        XCTAssertEqual(viewModel.weather?.temperatureMin ?? 0.0, 275.96, accuracy: 0.01)
        
        expectation.fulfill()
    
        await fulfillment(of: [expectation], timeout: 5.0)
    }

}

// Mock verson of WeatherFetcher
class MockWeatherFetcher: WeatherFetching {

    func getDailyWeather(from forecastList: [CampKit.WeatherEntry]) async -> [DailyWeather] {
        
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
    
    
    func fetchWeather(with urlString: String) async throws -> [WeatherModel]? {
        
        let jsonString = """
        {
            "weather": [{
                "id": 804,
                "description": "Cloudy"
            }],
            "main": {
                "temp_min": 275.96,
                "temp_max": 277.21
            },
            "name": "London"
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else {
            print("JSON Conversion Failed")
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        
        do {
            
            let weatherData = try
            decoder.decode(WeatherData.self, from: data)
            print("Mock Data Successfully Decoded: \(weatherData)")
            
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
            print("Decoding Failed: \(error)")
            throw NetworkError.decodingFailed
        }
        
    }
    
    private func findMode(_ numbers: [Int]) -> Int {
        let frequency = numbers.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        return frequency.max { $0.value < $1.value }?.key ?? numbers.first ?? 0
    }
}


//MOCK GEOCODER

final class MockGeocoder: Geocoding {
    var mockCoordinate: CLLocationCoordinate2D?
    var shouldThrow = false

    func getCoordinates(for cityName: String) async throws -> CLLocationCoordinate2D? {
        if shouldThrow {
            throw NetworkError.requestFailed
        }
        return mockCoordinate
    }
}
