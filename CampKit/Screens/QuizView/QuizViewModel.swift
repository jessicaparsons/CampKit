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
    
    //MARK: - PROPERTIES
    
    private let modelContext: ModelContext
    
    var participantsChoices: [Choice] = [
        Choice(name: ChoiceOptions.adults, isSelected: false), //always included
        Choice(name: ChoiceOptions.kids, isSelected: false),
        Choice(name: ChoiceOptions.dogs, isSelected: false)
    ]
    
    var activityChoices: [Choice] = [
        Choice(name: ChoiceOptions.hiking, isSelected: false),
        Choice(name: ChoiceOptions.fishing, isSelected: false),
        Choice(name: ChoiceOptions.bouldering, isSelected: false),
        Choice(name: ChoiceOptions.waterSports, isSelected: false),
        Choice(name: ChoiceOptions.biking, isSelected: false),
        Choice(name: ChoiceOptions.backpacking, isSelected: false),
        Choice(name: ChoiceOptions.kayaking, isSelected: false)
    ]

    var weatherChoices: [Choice] = [
        Choice(name: ChoiceOptions.mild, isSelected: false), // Always included
        Choice(name: ChoiceOptions.hot, isSelected: false),
        Choice(name: ChoiceOptions.cold, isSelected: false),
        Choice(name: ChoiceOptions.snowy, isSelected: false),
        Choice(name: ChoiceOptions.rainy, isSelected: false)
    ]
    
    var locationName: String = ""
    var latitude: Double?
    var longitude: Double?
    var elevation: Double = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //MARK: - METHODS
    
    @MainActor
    func createPackingList() {
        withAnimation {
            
            // filters the choices to include only the selected items
            // where 'isSelected' is true, then maps the filtered result to an array of their names
            // inserts the choices into the context
            let newPackingList = PackingList(
                title: "New Camping Trip",
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation)
            
            let selectedParticipants = participantsChoices
                .filter { $0.isSelected }
                .map { choice in
                    let participant = Participant(name: choice.name)
                    modelContext.insert(participant)
                    return participant
                }
            let selectedActivities = activityChoices
                .filter { $0.isSelected }
                .map { choice in
                    let activity = Activity(name: choice.name)
                    modelContext.insert(activity)
                    return activity
                }

            let selectedWeather = weatherChoices
                .filter { $0.isSelected }
                .map { choice in
                    let weatherCondition = WeatherCondition(name: choice.name)
                    modelContext.insert(weatherCondition)
                    return weatherCondition
                }
            
            newPackingList.participants = selectedParticipants
            print("Selected participants: \(selectedParticipants)")
            
            newPackingList.activities = selectedActivities
            print("selected activities: \(selectedActivities)")
            
            newPackingList.weatherConditions = selectedWeather
            print("selected weather: \(selectedWeather)")
         
            //Generate recommended categories and items
            let categories = generateCategories(for: selectedParticipants.map { $0.name },
                                                activities: selectedActivities.map { $0.name },
                                                weatherConditions: selectedWeather.map { $0.name}
            )
            newPackingList.categories.append(contentsOf: categories)
            
            //Save
            modelContext.insert(newPackingList)
            saveContext()
            
        }

    }
    
    private func saveContext() {
        do {
            try modelContext.save()
            print("Context saved successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    //Generate Packing Categories
    
    @MainActor
    private func generateCategories(for participants: [String], activities: [String], weatherConditions: [String]) -> [Category] {
        
        var selectedCategories: [Category] = []
        
        let defaultCategories = ["Clothing", "Camping Gear", "First Aid"]
        
        //Always include essential categories first
        
        for categoryName in defaultCategories {
            if let itemTemplates = categoryTemplates[categoryName] {
                
                //Create the categories
                let category = Category(name: categoryName, position: selectedCategories.count)
                
                //Assign position dynamically and link items to the category
                category.items = itemTemplates.enumerated().map { index, itemTemplate in
                    let newItem = Item(title: itemTemplate.title, isPacked: false)
                    newItem.position = index //Assign a position
                    newItem.category = category //Assign the category
                    
                    return newItem
                }
                
                selectedCategories.append(category)
            }
        }
        
        //Add user selected categories
        
        let userSelectedCategories = participants + activities + weatherConditions
        print("userSelectedCategories: \(userSelectedCategories)")
        
        for selection in userSelectedCategories {
            if let itemTemplates = categoryTemplates[selection] {
                
                let category = Category(name: selection, position: selectedCategories.count)
                
                category.items = itemTemplates.enumerated().map { index, itemTemplate in
                    let newItem = Item(title: itemTemplate.title, isPacked: false)
                    newItem.position = index
                    newItem.category = category
                    
                    return newItem
                }
                
                selectedCategories.append(category)
            }
        }

        return selectedCategories
    }
    
    
    //
    func toggleParticipant(_ name: String) {
        if let index = participantsChoices.firstIndex(where: { $0.name == name }) {
            print("index = \(index)")
            participantsChoices[index].isSelected.toggle()
            print("Toggled \(name) : \(participantsChoices[index].isSelected)")
        }
    }
}
