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
    @Binding var location: String
    @Binding var elevation: Double
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
                
                WeatherModuleView(location: $location)
                
                //MARK: - WEATHER SUGGESTION
                
                Text("Based on the forecast, we sugget packing for ") +
                weatherViewModel.formatWeatherCategories(weatherCategories) +
                Text(" weather.")
                
                //MARK: - WEATHER SELECTION
                
                HStack {
                    Text("Select the weather you'd like to pack for:")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                ChipSectionView(selectedFilters: $viewModel.selectedFilters, preferenceCategory: ChoiceOptions.weatherConditions)
                
            }//:VSTACK
            
        }//:VSTACK
        .padding(.horizontal, Constants.horizontalPadding)
        .task {
            await weatherViewModel.fetchLocation(for: location)
            
            if let weather = weatherViewModel.weather {
                weatherCategories = weatherViewModel.categorizeWeather(for: weather, elevation: elevation)
            }
        }
        
    }
}

#Preview {
    @Previewable @State var isStepOne: Bool = false
    @Previewable @State var location: String = ""
    @Previewable @State var elevation: Double = 0.0
    
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizPageTwoView(viewModel: QuizViewModel(modelContext: container.mainContext), isStepOne: $isStepOne, location: $location, elevation: $elevation)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
