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
    @Binding var location: String
    
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
                                Text("Choose a location on the previous screen to see weather forecast")
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
            Color.colorSky
        ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
    }
}

#Preview("Quiz Page Two") {
    @Previewable @State var isStepOne: Bool = false
    @Previewable @State var location: String = "Paris"
    @Previewable @State var elevation: Double = 0.0
    
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizPageTwoView(viewModel: QuizViewModel(modelContext: container.mainContext), isStepOne: $isStepOne, location: $location, elevation: $elevation)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}


#Preview {
    
    @Previewable @State var location: String = "Los Angeles"
    WeatherModuleView(location: $location)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
