//
//  WeatherRowView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct WeatherRowView: View {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = TemperatureUnit.fahrenheit.rawValue

    let symbol: String
    let day: String
    let highTemp: String
    let lowTemp: String
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.fixed(30), alignment: .leading),  // Icon
            GridItem(.flexible(), alignment: .leading), // Day
            GridItem(.fixed(70), alignment: .leading), // High Temp
            GridItem(.fixed(70), alignment: .leading)  // Low Temp
        ]) {
            Text(symbol)
            Text(day)
            Text("H: \(displayedTemperature(from: highTemp))°")
            Text("L: \(displayedTemperature(from: lowTemp))°")
        }
        .font(.subheadline)
        .padding(0)
    }
    
    private func displayedTemperature(from fahrenheitString: String) -> String {
            guard let fahrenheit = Double(fahrenheitString) else { return fahrenheitString }
            
            if temperatureUnit == TemperatureUnit.celsius.rawValue {
                let celsius = (fahrenheit - 32) * 5 / 9
                return String(format: "%.0f°C", celsius)
            } else {
                return String(format: "%.0f°F", fahrenheit)
            }
        }
}

#Preview("WeatherView") {
    
    @Previewable @State var location: String = "Paris"
    @Previewable @State var isWeatherLoading: Bool = false
    
    WeatherModuleView(isWeatherLoading: $isWeatherLoading)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}


#Preview {
    WeatherRowView(symbol: "sun.max.fill", day: "Monday", highTemp: "72", lowTemp: "27")
}
