//
//  LocationSearchView.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/10/25.
//

import SwiftUI

struct LocationSearchView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Binding var location: String
    @Binding var isLocationSearchOpen: Bool
    @State private var searchText = ""
    
    var body: some View {
        
        NavigationView {
            ZStack {
                if weatherViewModel.weatherLocationResults.isEmpty {
                    ContentUnavailableView("No results", systemImage: "mappin.slash", description: Text("Search for a location"))
                } else {
                    List(weatherViewModel.weatherLocationResults) { result in
                        Button {
                            Task {
                                await weatherViewModel.fetchLocation(for: result)
                                location = result.name
                                isLocationSearchOpen = false
                                hideKeyboard()
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.name)
                                Text("\(result.state ?? "N/A"), \(result.country)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }//:VSTACK
                        }//:BUTTON
                    }//:LIST
                }//CONDITION
            }//:ZSTACK
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isLocationSearchOpen = false
                    }, label: {
                        Image(systemName: "arrow.backward")
                    })
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a location")
        .onChange(of: searchText) {
            Task {
                
                try? await Task.sleep(nanoseconds: 700_000_000)
                
                do {
                    try await weatherViewModel.getLocationsFrom(cityName: searchText)
                } catch {
                    print("Error fetching locations: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    
    @Previewable @State var location: String = ""
    @Previewable @State var isLocationSearchOpen: Bool = true
    LocationSearchView(location: $location, isLocationSearchOpen: $isLocationSearchOpen)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
