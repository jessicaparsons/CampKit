//
//  WeatherViewModelTest.swift
//  CampKitTests
//
//  Created by Jessica Parsons on 2/7/25.
//

import XCTest
@testable import CampKit

final class WeatherViewModelTest: XCTestCase {
    
    var viewModel: WeatherViewModel!

    override func setUpWithError() throws {
        super.setUp()
        let mockFetcher = MockWeatherFetcher()
        viewModel = WeatherViewModel(weatherFetcher: mockFetcher)
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
        
        print("Fetching weather for \(cityName)")
        
        await viewModel.fetchLocation(cityName: cityName)
        
        print("Weather data received: \(String(describing: viewModel.weather))")
        
        XCTAssertNotNil(viewModel.weather, "Weather data should not be nil")
        XCTAssertEqual(viewModel.weather?.conditionID, 804)
        XCTAssertEqual(viewModel.weather?.cityName, "London")
        XCTAssertEqual(viewModel.weather?.temperatureMax ?? 0.0, 277.21, accuracy: 0.01)
        XCTAssertEqual(viewModel.weather?.temperatureMin ?? 0.0, 275.96, accuracy: 0.01)
        
        expectation.fulfill()
    
        await fulfillment(of: [expectation], timeout: 5.0)
    }

}

// Mock verson of WeatherFetcher
class MockWeatherFetcher: WeatherFetching {
    
    func fetchWeather(with urlString: String) async throws -> WeatherModel? {
        
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

            
            let id = weatherData.weather.first?.id ?? 0
            let city = weatherData.name
            let max = weatherData.main.temp_max
            let min = weatherData.main.temp_min
            
            let weather = WeatherModel(conditionID: id, cityName: city, temperatureMax: max, temperatureMin: min)
            return weather
            
        } catch {
            print("Decoding Failed: \(error)")
            throw NetworkError.decodingFailed
        }
        
    }
}
