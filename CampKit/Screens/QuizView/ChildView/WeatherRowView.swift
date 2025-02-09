//
//  WeatherRowView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct WeatherRowView: View {
    let symbol: String
    let day: String
    let highTemp: String
    let lowTemp: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(day)
            Spacer()
            Text("\(highTemp) / \(lowTemp) °F")
        }//:HStack
    }
}

#Preview("WeatherView") {
    
    @Previewable @State  var location: String = "Paris"
    
    WeatherModuleView(location: $location)
        .environmentObject(WeatherViewModel(weatherFetcher: GetWeather()))
}


#Preview {
    WeatherRowView(symbol: "sun.max.fill", day: "Monday", highTemp: "72", lowTemp: "27")
}
