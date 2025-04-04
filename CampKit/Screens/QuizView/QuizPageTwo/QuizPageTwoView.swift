//
//  QuizPageTwoView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct QuizPageTwoView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @State var viewModel: QuizViewModel
    @Binding var isStepOne: Bool
    @Binding var locationName: String
    @Binding var locationAddress: String
    @Binding var elevation: Double
    @Binding var isElevationAdded: Bool
    @State private var weatherCategories: Set<String> = []
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.cardSpacing) {
            
            //MARK: - TITLE
            VStack(alignment: .center) {
                Text("Let's get the weather")
                    .font(.title)
                    .fontWeight(.bold)
            }//:VSTACK
            
            //MARK: - WEATHER DISPLAY
            VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                
                WeatherModuleView()
                
                //MARK: - WEATHER SUGGESTION
                
                if !locationName.isEmpty {
                    Text("Based on the five day forecast") +
                    (isElevationAdded ? Text(" and added elevation") : Text("")) +
                    Text(", we suggest packing for ") +
                    weatherViewModel.formatWeatherCategories(weatherCategories) +
                    Text(" weather.")
                }
                
                //MARK: - WEATHER SELECTION
                
                HStack {
                    Text("Select the weather you'd like to pack for:")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Spacer()
                }//:HSTACK
                
                ChipSectionView(selectedFilters: $viewModel.selectedFilters, preferenceCategory: ChoiceOptions.weatherConditions)
                Spacer()
            }//:VSTACK
            
        }//:VSTACK
        .padding(.horizontal, Constants.horizontalPadding)
        .task {
            let location = locationName + ", " + locationAddress
            
            await weatherViewModel.fetchLocation(for: location)
            
            if let weather = weatherViewModel.weather {
                weatherCategories = weatherViewModel.categorizeWeather(for: weather, elevation: elevation)
            }
        }
        .onDisappear() {
            weatherViewModel.weather = nil // Reset weather for next packing list quiz
        }
        
    }
}

#Preview {
    @Previewable @State var isStepOne: Bool = false
    @Previewable @State var locationName: String = ""
    @Previewable @State var locationAddress: String = ""
    @Previewable @State var elevation: Double = 0.0
    @Previewable @State var isElevationAdded: Bool = false
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizPageTwoView(viewModel: QuizViewModel(modelContext: container.mainContext), isStepOne: $isStepOne, locationName: $locationName, locationAddress: $locationAddress, elevation: $elevation, isElevationAdded: $isElevationAdded)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
