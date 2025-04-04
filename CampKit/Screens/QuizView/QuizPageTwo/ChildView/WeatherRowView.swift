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
        LazyVGrid(columns: [
            GridItem(.fixed(30), alignment: .leading),  // Icon
            GridItem(.flexible(), alignment: .leading), // Day
            GridItem(.fixed(80), alignment: .leading), // High Temp
            GridItem(.fixed(80), alignment: .leading)  // Low Temp
        ]) {
            Text(symbol)
            Text(day)
            Text("H: \(highTemp)°")
            Text("L: \(lowTemp)°F")
        }
        .font(.subheadline)
        .padding(0)
    }
}

#Preview("WeatherView") {
    
    @Previewable @State var location: String = "Paris"
    
    WeatherModuleView()
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}


#Preview {
    WeatherRowView(symbol: "sun.max.fill", day: "Monday", highTemp: "72", lowTemp: "27")
}
