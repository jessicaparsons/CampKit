//
//  LocationSearchView.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/10/25.
//

import SwiftUI

struct LocationSearchView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var locationSearchService = LocationSearchService()
    @Binding var location: String
    @Binding var isLocationSearchOpen: Bool
    
    var body: some View {
        
        NavigationView {
            ZStack {
                if locationSearchService.results.isEmpty {
                    ContentUnavailableView("No results", systemImage: "mappin.slash", description: Text("Search for a location"))
                } else {
                    List(locationSearchService.results) { result in
                        Button {
                            location = result.title
                            isLocationSearchOpen = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                Text(result.subtitle)
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
        .searchable(text: $locationSearchService.query, prompt: "Search for a location")
        
    }
}

#Preview {
    
    @Previewable @State var location: String = ""
    @Previewable @State var isLocationSearchOpen: Bool = true
    LocationSearchView(location: $location, isLocationSearchOpen: $isLocationSearchOpen)
}
