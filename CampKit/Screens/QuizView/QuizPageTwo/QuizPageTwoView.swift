//
//  QuizPageTwoView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct QuizPageTwoView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    @Bindable var viewModel: QuizViewModel
    
    @Binding var isElevationAdded: Bool
    
    @State private var weatherCategories: Set<String> = []
    @State private var isWeatherLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.cardSpacing) {
            
            //MARK: - TITLE
            VStack(alignment: .center) {
                Text("Let's get the weather")
                    .font(.title)
                    .fontWeight(.bold)

            }//:VSTACK
            .padding(.top, Constants.largePadding)
            
            //MARK: - WEATHER DISPLAY
            VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                
                WeatherModuleView(isWeatherLoading: $isWeatherLoading)
                
                //MARK: - WEATHER SUGGESTION
                
                if viewModel.locationName != nil && weatherViewModel.isNoLocationFoundMessagePresented == false {
                    Text("Based on the next five day forecast") +
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
                    .padding(.bottom, Constants.quizPadding)
                Spacer()
            }//:VSTACK
            
        }//:VSTACK
        .padding(.horizontal, sizeClass == .regular ? Constants.ipadPadding : Constants.horizontalPadding)
        .background(Color.colorWhiteBackground)
        .task {
            if let locationName = viewModel.locationName {
                                
                var locationQuery = locationName
                
                if let locationAddress = viewModel.locationAddress {
                    locationQuery += ", " + locationAddress
                }
                                
                isWeatherLoading = true
                
                await weatherViewModel.fetchLocation(for: locationQuery)
                
                if let weather = weatherViewModel.weather {
                    weatherCategories = weatherViewModel.categorizeWeather(for: weather, elevation: viewModel.elevation)
                }
                isWeatherLoading = false
            } 
        }
        .onDisappear() {
            weatherViewModel.weather = nil // Reset weather for next packing list quiz
        }
        
    }
}

#if DEBUG
#Preview {
    @Previewable @State var currentStep: Int = 1
    @Previewable @State var isElevationAdded: Bool = false
    
    let previewStack = CoreDataStack.preview
    
    QuizPageTwoView(
        viewModel: QuizViewModel(context: previewStack.context),
        isElevationAdded: $isElevationAdded
    )
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
        .environment(\.managedObjectContext, previewStack.context)
}
#endif
