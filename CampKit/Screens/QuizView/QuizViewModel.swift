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
    
    var participantsArray: [Choice] = [
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
        Choice(name: "Mild", isSelected: false),
        Choice(name: "Hot", isSelected: false),
        Choice(name: "Cold", isSelected: false),
        Choice(name: "Snow", isSelected: false),
        Choice(name: "Rainy", isSelected: false)
    ]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    // Returns an array of names for all selected preferences.
    // It first filters the choicesArray to include only those items
    // where 'isSelected' is true, then maps the filtered result to an array of their names
    
    func getSelections() -> [String] {
        
        let whoChoices = participantsArray.filter { $0.isSelected }.map { $0.name }
        let activityChoices = activityArray.filter { $0.isSelected }.map { $0.name }
        let weatherChoices = weatherArray.filter {
            $0.isSelected }.map { $0.name }
        
        return whoChoices + activityChoices + weatherChoices
    }
    
    
    //if weather is above or below a certain temp, this function will return a set of warm, rainy, cold, or snow.
    // If the high temp is at or above 80, mark it as "hot" mild hot cold snow rainy
    // If the temp is lower than 50 mark it as cold
    // If the conditionName == "cloud.bolt.rain", "cloud.drizzle", "cloud.heavyrain" mark it as rain
    // If the conditionName == "cloud.snow", mark it as snow
    
    
    
}
