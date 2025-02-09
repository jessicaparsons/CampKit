//
//  WeatherModuleVIew.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct WeatherModuleView: View {
    
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @Binding var location: String
    
    var body: some View {
        GroupBox {
            VStack {
                if let weather = weatherViewModel.weather {
                    HStack {
                        Text(weather.cityName)
                            .font(.body)
                        Spacer()
                    }
                    Divider().padding(.vertical, 4)
                    List {
                        WeatherRowView(
                            symbol: weather.conditionName,
                            day: weather.cityName,
                            highTemp: weather.highTemp,
                            lowTemp: weather.lowTemp
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }//:LIST
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 120)
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
        }//:GROUPBOX
        .backgroundStyle(Color.colorTan)
        .task {
            await weatherViewModel.fetchLocation(cityName: location)
        }
    }
}

#Preview {
    
    @Previewable @State var location: String = "Paris"
    WeatherModuleView(location: $location)
        .environmentObject(WeatherViewModel(weatherFetcher: GetWeather()))
}
