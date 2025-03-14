//
//  WeatherModuleVIew.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct WeatherModuleView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Binding var location: String
    
    var body: some View {
        GroupBox {
            ZStack {
                VStack {
                    if let weather = weatherViewModel.weather {
                        HStack {
                            Text(weather.first?.cityName ?? "Unknown")
                                .font(.body)
                            Spacer()
                        }
                        Divider().padding(.vertical, 4)
                       
                        ForEach(weather.prefix(upTo: 5), id: \.id) { day in
                                WeatherRowView(
                                    symbol: day.conditionName,
                                    day: day.date,
                                    highTemp: day.highTemp,
                                    lowTemp: day.lowTemp
                                )
                                .frame(height: 25)
                            }
          
               
                    }//:CONDITION
                    else {
                        VStack(spacing: Constants.verticalSpacing) {
                            Text("Weather Forecast")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Choose a location on the previous screen to see weather forecast")
                                .multilineTextAlignment(.center)
                            Image(systemName: "cloud.sun")
                        }
                        .padding()
                    }
                }//:VSTACK
            }//:ZSTACK
        }//:GROUPBOX
        .backgroundStyle(LinearGradient(gradient: Gradient(colors: [
            Color.colorTan,
            Color.colorSky
        ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
    }
}

#Preview {
    
    @Previewable @State var location: String = "Los Angeles"
    WeatherModuleView(location: $location)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
