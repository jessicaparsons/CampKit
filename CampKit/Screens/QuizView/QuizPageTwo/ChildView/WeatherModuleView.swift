//
//  WeatherModuleVIew.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct WeatherModuleView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    
    var body: some View {
        GroupBox {
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        if let weather = weatherViewModel.weather {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Nearest Location")
                                        .font(.caption)
                                    Text(weather.first?.cityName ?? "Unknown")
                                        .font(.body)
                                }//:VSTACK
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Group {
                                        Text("Powered by")
                                        Text("OpenWeatherAPI")
                                    }//:GROUP
                                    .foregroundColor(Color.gray)
                                    .font(.caption2)
                                }//:VSTACK
                            }//:HSTACK
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
                                Text("Choose a location on the previous screen to see a 5 day weather forecast")
                                    .multilineTextAlignment(.center)
                                Image(systemName: "cloud.sun")
                            }
                            .padding()
                        }
                    }//:VSTACK
                    Spacer()
                }//:HSTACK
            }//:ZSTACK
        }//:GROUPBOX
        .backgroundStyle(LinearGradient(gradient: Gradient(colors: [
            Color.colorTan,
            Color.colorTan
        ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
    }
}

#Preview("Quiz Page Two") {
    @Previewable @State var isStepOne: Bool = false
    @Previewable @State var locationName: String = "Paris"
    @Previewable @State var locationAddress: String = "France"
    @Previewable @State var elevation: Double = 0.0
    @Previewable @State var isElevationAdded: Bool = true
    
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizPageTwoView(viewModel: QuizViewModel(modelContext: container.mainContext), isStepOne: $isStepOne, locationName: $locationName, locationAddress: $locationAddress, elevation: $elevation, isElevationAdded: $isElevationAdded)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}


#Preview {
    
    @Previewable @State var location: String = "Los Angeles"
    WeatherModuleView()
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
