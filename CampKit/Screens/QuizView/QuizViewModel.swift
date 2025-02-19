//
//  QuizViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI
import SwiftData
import CoreLocation

@Observable
class QuizViewModel {
    
    private let modelContext: ModelContext
    
    var whoArray: [Choice] = [
        Choice(name: "Adults", isSelected: false),
        Choice(name: "Kids", isSelected: false),
        Choice(name: "Dogs", isSelected: false)
    ]
    
    var activityArray: [Choice] = [
        Choice(name: "Hiking", isSelected: false),
        Choice(name: "Fishing", isSelected: false),
        Choice(name: "Bouldering", isSelected: false),
        Choice(name: "Water Sports", isSelected: false)
    ]
    
    var weatherArray: [Choice] = [
        Choice(name: "Warm", isSelected: false),
        Choice(name: "Cold", isSelected: false),
        Choice(name: "Snow", isSelected: false),
        Choice(name: "Rainy", isSelected: false)
    ]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
//    init(choices: [String]) {
//        self.choicesArray = choices.map {
//            Choice(name: $0, isSelected: false)
//        }
//    }
//    
    // Returns an array of names for all selected preferences.
    // It first filters the choicesArray to include only those items
    // where 'isSelected' is true, then maps the filtered result to an array of their names
    
    func getSelections() -> [String] {
        
        let whoChoices = whoArray.filter { $0.isSelected }.map { $0.name }
        let activityChoices = activityArray.filter { $0.isSelected }.map { $0.name }
        let weatherChoices = weatherArray.filter {
            $0.isSelected }.map { $0.name }
        
        return whoChoices + activityChoices + weatherChoices
    }
    
    
}
