//
//  LocationSearchService.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/11/25.
//

import Foundation
import MapKit


@Observable
class LocationSearchService: NSObject {
    
    /// Create a string that represents the user's search query. It has a property observer that will call a function whenever the query changes
    var query: String = "" {
        didSet {
            searchForCityOrRegion(query)
        }
    }
    
    ///an array of possible location results
    var results: [LocationResult] = []
    
    ///enum for indicating the current state of the search
    var status: SearchStatus = .idle
    
    ///class responsible for generating location suggestions
    var completer = MKLocalSearchCompleter()
    
    init(
        region: MKCoordinateRegion = MKCoordinateRegion(.world),
        types: MKLocalSearchCompleter.ResultType = [.address, .pointOfInterest]
    ) {
        completer = MKLocalSearchCompleter()
        
        super.init()
        
        completer.delegate = self
        completer.region = region
        completer.resultTypes = types
    }
    
    ///function that is called whenever the query changes
    private func searchForCityOrRegion(_ fragment: String) {
        self.status = .searching
        
        if !fragment.isEmpty {
            self.completer.queryFragment = fragment
        } else {
            self.status = .idle
            self.results = []
        }
    }
}

/// returns results related to camping keywords

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
                
        self.results = completer.results
            .filter { result in
                let title = result.title.lowercased()
                let subtitle = result.subtitle.lowercased()
                
                /// Allow cities, states, and countries
                let isCityOrRegion = !subtitle.isEmpty &&
                /// Exclude street addresses (e.g., "123 Main St, New York")
                                     !subtitle.contains(", ") ||
                /// Ensure it's in "City, State" format
                                     subtitle.components(separatedBy: ", ").count == 2
                
                /// Always allow nature locations
                let natureKeywords = ["state park", "national park", "forest", "wilderness", "preserve", "recreation area", "campground", "camping", "camp"]
                let isNatureLocation = natureKeywords.contains { title.contains($0) }

                /// Exclude businesses & street locations if it's not a nature location
                let excludedKeywords = ["street", "ave", "road", "highway", "mall", "boulevard", "restaurant", "store", "plaza", "center", "market", "shopping", "st", "cir", "ln", "dr", "pl", "ct"]
            
                ///Result is a business or street if it is NOT a nature location and it contains any of the excluded keywords
                let isBusinessOrStreet = !isCityOrRegion && !isNatureLocation && excludedKeywords.contains { title.contains($0) || subtitle.contains($0) }

                return !isBusinessOrStreet
            }
            .map({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
            })
        
        self.status = .result
    }
    
    ///handle the errors
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        self.status = .error(error.localizedDescription)
    }
}

struct LocationResult: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case result
}
