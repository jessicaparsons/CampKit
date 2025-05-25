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
    @Binding var locationName: String?
    @Binding var locationAddress: String?
    
    var body: some View {
        
        NavigationView {
            ZStack {
                if locationSearchService.results.isEmpty {
                    ContentUnavailableView("No results yet", systemImage: "map", description: Text("Search for a location"))
                } else {
                    List(locationSearchService.results) { result in
                        Button {
                            locationName = result.title
                            locationAddress = result.subtitle
                            dismiss()
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
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.backward")
                    })
                }
            }
        }
        .searchable(text: $locationSearchService.query, prompt: "Search for a location")
        
    }
}
#if DEBUG
#Preview {
    
    @Previewable @State var locationNamePlaceholder: String? = "Sequoia National Forest"
    @Previewable @State var locationAddressPlaceholder: String? = "Somwhere in the Forest, CA"

    LocationSearchView(
        locationName: $locationNamePlaceholder,
        locationAddress: $locationAddressPlaceholder
    )
}
#endif
